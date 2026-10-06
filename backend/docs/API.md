# Smart Child Hub – REST API Documentation

Backend for the **Smart Child Daily Activity Tracking System** (Phase 4).

- **Stack:** PHP 8+ (PDO), MySQL / MariaDB, JSON REST API
- **Architecture:** MVC-style folder layout with a front controller
- **Base URL:** `http://localhost/backend/public` (Apache) or `http://localhost:8080` (dev server)
- **Demo account:** `dana@example.com` / `123456`

---

## 1. Getting started

### 1.1 Requirements

- PHP 8.0+
- MySQL 5.7+ / MariaDB 10.4+ running locally
- Apache with `mod_rewrite` (XAMPP/WAMP) **or** the PHP built-in server

### 1.2 Database setup

```bash
# 1. Create the database and all tables.
mysql -u root < backend/database/schema.sql

# 2. Seed the demo account and sample data.
php backend/database/seed.php
```

### 1.3 Run the API

**Option A – Apache (XAMPP):** place the project under `htdocs`, then open
`http://localhost/backend/public/api/health`.

**Option B – PHP built-in server:**

```bash
php -S localhost:8080 -t backend/public backend/public/index.php
```

Check it is alive:

```bash
curl http://localhost:8080/api/health
# {"success":true,"message":"API is healthy.","data":{...}}
```

### 1.4 Configuration

Edit `backend/app/config/config.php`:

| Constant | Purpose |
| --- | --- |
| `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USER` / `DB_PASS` | Database connection |
| `BASE_URL` | Base URL used for links in responses |
| `TOKEN_TTL_HOURS` | Bearer token lifetime (default 720 h) |
| `RESET_TOKEN_TTL_MINUTES` | Password-reset token lifetime |
| `CORS_ALLOWED_ORIGINS` | `*` for dev, or a comma-separated allow-list |
| `APP_DEBUG` | Show exception detail in responses (dev only) |

---

## 2. Conventions

### 2.1 Response envelope

Every response uses the same shape:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": { ... }
}
```

Errors add a field-level `errors` object (HTTP 422):

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": { "email": "The email address is invalid." },
  "data": null
}
```

### 2.2 HTTP status codes

| Code | Meaning |
| --- | --- |
| `200` | OK (also returned for upserts that updated an existing row) |
| `201` | Created |
| `204` | Deleted (no body) |
| `400` | Malformed / missing parameters |
| `401` | Missing, invalid or expired token |
| `404` | Route, child, or record not found |
| `409` | Conflict (duplicate email / unique record) |
| `422` | Validation failed (`errors` object present) |
| `500` | Unexpected server error |

### 2.3 Authentication

All endpoints except **register, login, forgot-password, reset-password** and
`/api/health` require a Bearer token:

```
Authorization: Bearer <token>
```

Tokens are returned by `register` and `login` in `data.token`. Only the SHA-256
hash is stored server-side. Sessions can be revoked individually (`logout`) or
in bulk (password reset / change).

### 2.4 Date & enum formats

| Field | Format |
| --- | --- |
| `date` / `dueDate` / `periodDate` | `YYYY-MM-DD` |
| `timestamp` / `generatedAt` | `YYYY-MM-DD HH:MM:SS` (ISO-like) |
| `glassTimes[]` | ISO `YYYY-MM-DDTHH:MM:SS` |

Enums (matching the Flutter model layer):

| Resource | Values |
| --- | --- |
| Activity `status` | `pending`, `completed`, `inProgress`, `locked` |
| Sleep `quality` | `restful`, `good`, `fair`, `poor` |
| Meal `type` | `breakfast`, `lunch`, `dinner`, `snack` |
| Mood `mood` | `happy`, `excited`, `calm`, `tired`, `sad`, `angry` |
| Homework `status` | `pending`, `inProgress`, `completed` |
| Attendance `status` | `present`, `absent`, `late` |
| Notification `type` | `activity`, `meal`, `homework`, `announcement` |

JSON keys are **camelCase** and match the Flutter model `fromJson` factories
exactly, so responses can be deserialized without mapping.

---

## 3. Authentication endpoints

### `POST /api/auth/register` — create a parent account
Body: `fullName`, `email`, `phone` (optional), `password`, `password_confirmation`.
→ `201` with `{ user, token, tokenType, expiresIn }`. `409` on duplicate email.

### `POST /api/auth/login`
Body: `email`, `password`.
→ `200` with `{ user, token, tokenType, expiresIn }`. `401` on bad credentials.

### `POST /api/auth/logout` *(auth)*
Revokes the current token. → `200`.

### `GET /api/auth/me` *(auth)*
Returns the authenticated parent profile. → `200`.

### `POST /api/auth/forgot-password`
Body: `email`.
→ `200`. For development the one-time `resetToken` is returned in the body
(in production it would be emailed). Always uses the same message to avoid
account enumeration.

### `POST /api/auth/reset-password`
Body: `token`, `email`, `password`, `password_confirmation`.
→ `200`. Marks the token used and revokes all sessions.

### `POST /api/auth/change-password` *(auth)*
Body: `currentPassword`, `newPassword`, `newPasswordConfirmation`.
→ `200` with a fresh token (all other sessions are revoked).

---

## 4. Parent endpoints

All require auth.

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/parent/profile` | Parent profile |
| `PUT` | `/api/parent/profile` | Partial profile update (`fullName`, `phone`, `avatarKey`) |
| `GET` | `/api/parent/dashboard` | Dashboard statistics |
| `GET` | `/api/parent/children` | List children |
| `POST` | `/api/parent/children` | Add child |
| `GET` | `/api/parent/children/{id}` | View child |
| `PUT` | `/api/parent/children/{id}` | Update child |
| `DELETE` | `/api/parent/children/{id}` | Delete child |
| `POST` | `/api/parent/children/{id}/photo` | Upload or replace a child's photo |
| `DELETE` | `/api/parent/children/{id}/photo` | Remove a child's photo |

### Add child body
`name` (required), `age` (0–18), `grade`, `school`, `avatarKey`,
`pin` (4 digits, optional), `coins`, `streakDays`.

### Child photo
The photo lives on the server and is referenced by the child's `photoUrl`
field. It is **not** writable through `POST`/`PUT /api/parent/children` — only
these two endpoints change it.

`POST /api/parent/children/{id}/photo` takes `multipart/form-data` with a single
`photo` file part and returns the updated child. The upload is validated by
content, not by the client-supplied filename:

- only `image/jpeg`, `image/png` and `image/webp` are accepted, and the stored
  extension is derived from the detected type;
- 5 MB maximum file size, 8000 px maximum edge and 25 megapixels maximum;
- the previous photo is deleted only after the new one is stored, so a failed
  upload never leaves the child without a photo.

`DELETE /api/parent/children/{id}/photo` clears `photoUrl` and deletes the file.
It is idempotent: removing when no photo is set returns `200` with an empty
`photoUrl`. Deleting the child also removes its photo file.

Uploads are written to `backend/public/uploads/` under an unguessable name
(child id plus 12 random bytes). That directory serves only those three image
types and sends `X-Content-Type-Options: nosniff`; everything else is denied.
Photo files are not served behind authentication because `Image.network` cannot
send the bearer token, so the unguessable filename is what protects them.

Errors use the normal envelope with per-field messages under `errors.photo`.

### Dashboard response
```json
{
  "childrenCount": 3,
  "totalCoins": 515,
  "todayTasksDone": 3,
  "todayTasksTotal": 7,
  "pendingHomework": 2,
  "unreadNotifications": 3,
  "averageSleepHours": 9.1,
  "waterGoalProgress": 75.0,
  "children": [
    { "child": { ... }, "todayTasksDone": 3, "todayTasksTotal": 7 }
  ]
}
```

---

## 5. Child activity endpoints

All require auth. Every record is verified to belong to one of the
authenticated parent's children; a foreign child returns `404`.

### 5.1 Activities (daily routine tasks)

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/children/{id}/activities?date=YYYY-MM-DD` | List (optionally by date) |
| `POST` | `/api/children/{id}/activities` | Create |
| `GET` | `/api/children/{id}/activities/{aId}` | View |
| `PUT` | `/api/children/{id}/activities/{aId}` | Update |
| `DELETE` | `/api/children/{id}/activities/{aId}` | Delete |

Body: `title` (required), `icon`, `category`, `time`, `coins`, `status`, `date`.

> Marking an activity `completed` credits the child's coin balance.

### 5.2 Sleep tracking

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/children/{id}/sleep?date=YYYY-MM-DD` | List |
| `POST` | `/api/children/{id}/sleep` | Create / upsert per child+date |
| `GET` | `/api/sleep/{id}` | View |
| `PUT` | `/api/sleep/{id}` | Update |
| `DELETE` | `/api/sleep/{id}` | Delete |

Body: `date`, `bedtimeHour` (0–23), `bedtimeMinute`, `wakeHour`, `wakeMinute`,
`hours` (0–24), `quality`, `notes`.

### 5.3 Meal tracking

`/api/children/{id}/meals` and `/api/meals/{id}`
Body: `date`, `type`, `name` (required), `icon`, `time`, `calories`,
`protein`, `carbs`, `fat`, `eaten` (bool).

### 5.4 Water intake

`/api/children/{id}/water` and `/api/water/{id}`
Body: `date`, `glasses`, `targetGlasses`, `glassTimes[]` (ISO datetimes).
One row per child+date (upsert); the glass log is stored in `water_glasses`.

### 5.5 Mood tracking

`/api/children/{id}/moods` and `/api/moods/{id}`
Body: `date` (datetime), `mood`, `note`.

### 5.6 Homework

`/api/children/{id}/homework` and `/api/homework/{id}`
Body: `title` (required), `subject` (required), `icon`, `dueDate`,
`status`, `coins`, `progress` (0–1).

### 5.7 Attendance

`/api/children/{id}/attendance` and `/api/attendance/{id}`
Body: `date`, `status`, `className`. One row per child+date (upsert).

### 5.8 Screen time

`/api/children/{id}/screen-time` and `/api/screen-time/{id}`
Body: `date`, `allowedMinutes`, `usedMinutes`, `category`.
One row per child+date (upsert).

> Resources with a `child+date` unique key (`sleep`, `water`, `attendance`,
> `screen_time`) **upsert**: a `POST` for an existing date returns `200` and
> updates the row instead of failing.

---

## 6. Notifications

All require auth. Notifications belong to the parent; they are stored as rows
ready to be hydrated into FCM / APNs push payloads.

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/notifications?read=0&page=1&per_page=20` | List (filter + paginated) |
| `GET` | `/api/notifications/unread-count` | Unread count |
| `POST` | `/api/notifications` | Create |
| `GET` | `/api/notifications/{id}` | View |
| `PUT` | `/api/notifications/{id}` | Update |
| `PUT` | `/api/notifications/{id}/read` | Mark read |
| `PUT` | `/api/notifications/read-all` | Mark all read |
| `DELETE` | `/api/notifications/{id}` | Delete |

Create body: `type`, `title` (required), `message` (required), `icon`,
`childId` (optional, must be an owned child), `read` (bool).

Notification JSON: `id`, `type`, `title`, `message`, `timestamp`, `read`,
`icon`.

---

## 7. Reports

All require auth. Statistics are computed on demand and persisted in the
`reports` table.

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/children/{id}/reports/daily` | Daily statistics |
| `GET` | `/api/children/{id}/reports/weekly` | Weekly statistics (Mon–Sun) |
| `GET` | `/api/children/{id}/reports/monthly` | Monthly statistics |
| `GET` | `/api/children/{id}/reports/history?type=weekly` | Persisted report history |

Response:

```json
{
  "id": "...",
  "childId": "...",
  "type": "weekly",
  "periodDate": "2026-08-03",
  "generatedAt": "2026-08-06T19:00:00",
  "stats": {
    "tasksDone": 5,
    "completionRate": 71.4,
    "coins": 60,
    "dayStreak": 5,
    "sleepHours": 9.1,
    "waterGlasses": 6,
    "taskChart": [ { "label": "Mon", "value": 6 }, "..." ],
    "trendChart": [ { "label": "Mon", "value": 9.5 }, "..." ],
    "categoryChart": [ { "label": "Learning & fun", "value": 3 }, "..." ],
    "attendance": [
      { "label": "present", "value": 19 },
      { "label": "absent",  "value": 1 },
      { "label": "late",    "value": 0 }
    ]
  }
}
```

---

## 8. Security

- **Prepared statements everywhere** (PDO, `EMULATE_PREPARES=false`) — SQL
  injection is prevented at the data layer.
- **Password hashing** with `password_hash()` / `PASSWORD_DEFAULT` (bcrypt).
- **Bearer tokens** — raw token returned once; only SHA-256 hashes stored;
  expiry + revocation support; bulk revocation on password change/reset.
- **Input validation** — every endpoint validates types, lengths, ranges and
  enum values and responds `422` with field-level errors.
- **Ownership checks** — children, records and notifications are always
  scoped to the authenticated parent (`404` for foreign resources).
- **XSS prevention** — JSON responses are served as `application/json` with
  `Content-Type: application/json`, `X-Content-Type-Options: nosniff`,
  `X-Frame-Options: DENY` and `Referrer-Policy: no-referrer`.
- **CSRF-ready** — token-based auth; `OPTIONS` preflight handled; CORS can be
  locked to an origin allow-list. State-changing routes accept
  `X-CSRF-Token` headers for future web-client hardening.
- **Rate limiting note** — for production, add a per-IP limiter in front of
  `/api/auth/login` and `/api/auth/forgot-password`.

---

## 9. Project layout

```
backend/
├── public/
│   ├── index.php            # Front controller (autoload, errors, routes)
│   └── .htaccess            # Apache rewrites + deny .sql/.env/.md
├── app/
│   ├── config/config.php    # Environment configuration
│   ├── core/                # Router, Request, Response, Database, Auth,
│   │                        #   Validator, AppException, Controller
│   ├── controllers/         # AuthController, ParentController,
│   │                        #   ChildActivityController, NotificationController,
│   │                        #   ReportController
│   └── models/              # DB-row mappers matching Flutter JSON contracts
├── database/
│   ├── schema.sql           # 15 tables (FKs, indexes, constraints)
│   └── seed.php             # Demo account + sample data
└── docs/API.md              # This document
```

## 10. Database tables

`parents`, `auth_tokens`, `password_resets`, `children`, `activities`,
`sleep_records`, `meals`, `water_intakes`, `water_glasses`, `moods`,
`homework`, `attendance`, `screen_time`, `notifications`, `reports`.

All tables use `CHAR(36)` UUID primary keys, `ON DELETE CASCADE` foreign keys,
and targeted secondary indexes on the most-used `(child_id, date)` lookups.
