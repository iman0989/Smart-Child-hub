# Smart Child Daily Activity Tracking System — Technical Documentation

Version 1.0 · Phase 7 release

---

## 1. System Overview

The **Smart Child Daily Activity Tracking System** ("Smart Child Hub") is a
family-centered mobile application that helps parents track, reward and review
their children's daily routines. It is a full-stack system built with a
**Flutter** mobile client and a **PHP + MySQL REST API** backend.

Parents create child profiles and track daily activities:

- **Activities** — routine tasks (homework, chores, hygiene…) with coin rewards.
- **Sleep** — bedtime, wake-up time, duration and sleep quality.
- **Meals** — breakfast/lunch/dinner/snacks with a nutrition summary.
- **Water** — daily hydration goal with a glass log.
- **Mood** — daily mood check-ins and a weekly mood chart.
- **Homework** — school assignments with status and completion progress.
- **Attendance** — school day attendance (present / late / absent).
- **Screen time** — allowed vs. used screen minutes.

Children earn **coins** for completed tasks, which feeds a gamified streak and
reward system. The app produces **daily, weekly and monthly reports** with
charts, and sends **notifications** for reminders and milestone events.

Two app modes are supported: a **parent zone** (manage the whole family) and a
**kids mode** (children pick their own profile and log their own day).

---

## 2. Architecture

The system follows a clean two-tier architecture: a mobile client and a
stateless REST API server, with a relational database for persistence.

```
┌─────────────────────┐        HTTPS / JSON        ┌─────────────────────────┐
│  Flutter Mobile App  │ ◄────────────────────────► │    PHP 8 REST API       │
│  (Android)           │   Bearer-token REST calls  │  (MVC, front controller)│
│                      │                            │          │              │
│  Screens / Providers │                            │  Controllers / Models   │
│  (Provider state mgt)│                            │          │              │
└─────────────────────┘                            │    PDO (prepared stmts) │
                                                    └────────────┬────────────┘
                                                                 │
                                                   ┌─────────────▼────────────┐
                                                   │   MariaDB / MySQL        │
                                                   │   15 tables, FK cascades │
                                                   └──────────────────────────┘
```

### 2.1 Client-side architecture (Flutter)

- **Presentation layer** — `screens/` (auth, parent, child, activities,
  reports, notifications, settings, onboarding, splash) and `widgets/`
  (reusable cards, charts, common components).
- **State management** — `Provider` (`ChangeNotifier`). Screen-scoped and
  app-scoped providers (`AuthProvider`, `ChildProvider`, `SleepProvider`,
  `MealProvider`, `WaterProvider`, `MoodProvider`, `HomeworkProvider`,
  `AttendanceProvider`, `ScreenTimeProvider`, `NotificationProvider`,
  `SettingsProvider`, `TaskProvider`, `ReportProvider`).
- **Data access** — `repositories/` call a thin `ApiClient` wrapper around the
  `http` package; a `SessionManager` owns the bearer token and cached profile.
- **Domain models** — `models/` mirror the backend JSON contracts exactly
  (camelCase keys), so responses deserialize without mapping.
- **Routing** — named routes in `routes/app_routes.dart`.

Flow: `SplashScreen` → restores session → `OnboardingScreen` (first run) →
`LoginScreen` / `RegisterScreen` → `ParentShell` (5-tab dashboard) →
`ChooseProfileScreen` (pick or add a child) → `ChildShell` (kids mode).

### 2.2 Server-side architecture (PHP)

- **Front controller** — `public/index.php` bootstraps autoloading, error
  handling, CORS and the router; Apache `.htaccess` rewrites everything to it.
- **Routing** — `core/Router.php` maps REST routes to controller methods.
- **Request / Response** — `core/Request.php` parses JSON bodies and query
  params; `core/Response.php` emits the unified `{success, message, data, errors}`
  envelope with correct status codes and security headers.
- **Controllers** — `AuthController`, `ParentController`,
  `ChildActivityController`, `NotificationController`, `ReportController`.
- **Validation** — `core/Validator.php` (typed, ranged, enum-aware checks).
- **Persistence** — PDO with `EMULATE_PREPARES=false`; every query uses
  prepared statements. `core/Auth.php` verifies the SHA-256-hashed bearer token.

---

## 3. Technology Stack

| Layer | Technology | Version |
| --- | --- | --- |
| Mobile framework | Flutter (Dart) | Flutter 3.38.9 / Dart 3.10.8 |
| Backend runtime | PHP | 8.0.30 (PDO) |
| Database | MariaDB / MySQL | 10.4.32 (XAMPP) |
| API style | JSON REST | Bearer-token auth |
| State management | provider package | ^6.x |
| HTTP client | http package | ^1.x |
| Charts | flutter custom-drawn charts | in-repo `widgets/charts` |
| Local storage | shared_preferences | ^2.x |
| Build | Gradle / Kotlin | AGP (Flutter default), minSdk 24 |

Demo account (seeded): `dana@example.com` / `123456`.

---

## 4. Database Design

Fifteen tables, all `CHAR(36)` UUID primary keys, `InnoDB`, `utf8mb4`,
foreign keys with `ON DELETE CASCADE` (and `SET NULL` where optional), plus
secondary indexes on the hot `(child_id, date)` lookups.

### 4.1 Table summary

| Table | Purpose | Key relationships |
| --- | --- | --- |
| `parents` | Family-manager accounts | — |
| `auth_tokens` | Session tokens (SHA-256 hashes) | `parent_id → parents` |
| `password_resets` | One-time reset tokens | `parent_id → parents` |
| `children` | Child profiles (coins, streak) | `parent_id → parents` |
| `activities` | Daily routine tasks | `child_id → children` |
| `sleep_records` | One row per child+date | `child_id → children` |
| `meals` | Meal log | `child_id → children` |
| `water_intakes` | Daily intake (goal + count) | `child_id → children` |
| `water_glasses` | Per-glass timestamps | `intake_id → water_intakes` |
| `moods` | Mood check-ins | `child_id → children` |
| `homework` | Assignments | `child_id → children` |
| `attendance` | School attendance | `child_id → children` |
| `screen_time` | Screen usage | `child_id → children` |
| `notifications` | Parent notifications | `parent_id → parents`, `child_id → children` (nullable, `SET NULL`) |
| `reports` | Persisted report snapshots | `child_id → children` |

### 4.2 Unique constraints (upsert targets)

- `sleep_records(child_id, date)`
- `water_intakes(child_id, date)`
- `attendance(child_id, date)`
- `screen_time(child_id, date)`

These four are **upserts**: a `POST` for an existing date returns `200` and
updates the row.

Other constraints: unique `parents.email`, unique
`water_glasses(intake_id, logged_at)`, unique `auth_tokens.token_hash`,
unique `password_resets.token_hash`, and a check `age BETWEEN 0 AND 18`.

### 4.3 Indexes

Primary UUID keys everywhere plus:

- `idx_activities_child_date (child_id, date)`
- `idx_meal_child_date (child_id, date)`
- `idx_homework_child_due (child_id, due_date)`
- `uq_sleep_child_date`, `uq_water_child_date`, `uq_attendance_child_date`,
  `uq_screen_time_child_date`
- `idx_children_parent (parent_id)`
- `idx_notifications_read (parent_id, read)`
- `idx_notifications_parent_created (parent_id, created_at)` — added in QA to
  fix a full-table scan on the notifications feed (verified at 100k rows).
- `idx_reports_child_period (child_id, type, period_date)`

### 4.4 Schema file

`backend/database/schema.sql` — canonical schema (creates the database,
tables, constraints and indexes). `backend/database/seed.php` seeds the demo
account and realistic sample data.

---

## 5. API Documentation

Full reference: **`03-Documentation/05-API-Reference.md`** (also at
`backend/docs/API.md`).

Highlights:

- Base URL `http://localhost:8080` (dev server) or `/backend/public` (Apache).
- Unified envelope `{success, message, data, errors}`; camelCase JSON keys.
- Auth via `Authorization: Bearer <token>`; only SHA-256 hashes stored.
- Endpoint groups: auth (7), parent (8), child activity resources (8 groups),
  notifications (8), reports (4).
- All child-scoped resources verify ownership; foreign children return `404`.
- Security: prepared statements, bcrypt passwords, field-level validation
  (`422`), ownership checks, XSS/CSRF hardening headers.

---

## 6. Folder Structure

```
Smart-Child-Daily-Activity-Tracking-System/
├── app/                          # Flutter client
│   ├── lib/
│   │   ├── main.dart             # App entry + provider wiring
│   │   ├── core/
│   │   │   ├── network/          # ApiClient, ApiConfig, SessionManager, TokenStore
│   │   │   ├── repositories/     # Data-access layer per domain
│   │   │   ├── services/         # AuthService, DashboardLoader
│   │   │   ├── theme/            # AppTheme, AppPalette, dark mode
│   │   │   ├── constants/        # AppIcons, AppRoutes, AppConstants
│   │   │   └── utils/            # Validators, Formatters, Responsive
│   │   ├── models/               # Dart models (mirror API JSON)
│   │   ├── providers/            # ChangeNotifier state providers
│   │   ├── routes/               # Named-route table
│   │   ├── screens/              # splash, onboarding, authentication,
│   │   │                         #   parent, child, activities, reports,
│   │   │                         #   notifications, settings
│   │   └── widgets/              # cards, charts, common components
│   ├── test/widget_test.dart     # Splash boot widget test
│   ├── integration_test/         # End-to-end flow tests (2 suites)
│   └── android/                  # Android project + release signing config
├── backend/                      # PHP REST API
│   ├── public/
│   │   ├── index.php             # Front controller
│   │   └── .htaccess             # Rewrites + deny sensitive files
│   ├── app/
│   │   ├── config/config.php     # Environment configuration
│   │   ├── core/                 # Router, Request, Response, Database,
│   │   │                         #   Auth, Validator, AppException, Controller
│   │   ├── controllers/          # 5 controllers
│   │   └── models/               # 13 row mappers
│   ├── database/
│   │   ├── schema.sql            # 15 tables
│   │   └── seed.php              # Demo data
│   ├── docs/API.md               # API reference
│   └── tests/                    # api_test.php (153 checks), db_test.php (127 checks)
├── deliverables/                 # Phase 7 final package
│   ├── 01-Release-APK/           # Signed release APK
│   ├── 02-Database/              # smart_child_hub.sql dump
│   ├── 03-Documentation/         # Technical doc, user manual, testing report,
│   │                             #   deployment guide, API reference
│   ├── 04-Presentation/          # Presentation slides
│   ├── 05-Screenshots/           # UI screenshots
│   └── 06-Source-Code/           # Source archives
```

---

## 7. Installation Guide

### 7.1 Prerequisites

- Flutter SDK 3.38+ (Dart 3.10+)
- PHP 8.0+
- MySQL 5.7+ / MariaDB 10.4+ (XAMPP/WAMP/LAMP)
- Android device or emulator (API 24+) for the mobile app

### 7.2 Backend

```bash
# 1. Create the database and tables.
mysql -u root < backend/database/schema.sql

# 2. Seed demo data (optional but recommended).
php backend/database/seed.php

# 3. Run the API (Option A: PHP built-in server).
php -S localhost:8080 -t backend/public backend/public/index.php

# Verify
curl http://localhost:8080/api/health
```

Option B — Apache (XAMPP): place the project under `htdocs` and open
`http://localhost/backend/public/api/health`.

### 7.3 Mobile app

```bash
cd app
flutter pub get

# Connect an Android emulator (host machine reachable via 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

On a physical device, pass the host machine's LAN IP instead, e.g.
`--dart-define=API_BASE_URL=http://192.168.1.50:8080` (the backend must then be
started with `php -S 0.0.0.0:8080 -t backend/public backend/public/index.php`).

### 7.4 Running the test suites

```bash
# Backend API integration tests (against a running server)
php backend/tests/api_test.php

# Backend database tests (isolated throwaway DB)
php backend/tests/db_test.php

# Flutter widget tests
cd app && flutter test

# Flutter end-to-end UI tests (emulator + live backend)
cd app && flutter test integration_test -d emulator-5554 \
    --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

---

## 8. Configuration Guide

### 8.1 Backend — `backend/app/config/config.php`

| Constant | Purpose | Default |
| --- | --- | --- |
| `DB_HOST` / `DB_PORT` | Database host / port | `127.0.0.1` / `3306` |
| `DB_NAME` | Database name | `smart_child_hub` |
| `DB_USER` / `DB_PASS` | Database credentials | `root` / `` |
| `BASE_URL` | Base URL for links in responses | `http://localhost:8080` |
| `TOKEN_TTL_HOURS` | Bearer token lifetime | `720` (30 days) |
| `RESET_TOKEN_TTL_MINUTES` | Password-reset token lifetime | `60` |
| `CORS_ALLOWED_ORIGINS` | Allowed origins | `*` (dev) |
| `APP_DEBUG` | Detailed exception output | `true` (dev only) |

### 8.2 Mobile app — `app/lib/core/network/api_config.dart`

| Setting | Purpose | Default |
| --- | --- | --- |
| `API_BASE_URL` (dart-define) | Backend origin at build time | `http://localhost:8080` |
| `timeout` | Per-request timeout | 20 s |
| `deviceName` | Reported device name on token issue | `mobile` |

### 8.3 Android release signing — `app/android/key.properties`

```
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=smartchildhub
storeFile=app/smart-child-hub-release.jks
```

The keystore lives at `app/android/app/smart-child-hub-release.jks` and is
loaded by `app/android/app/build.gradle.kts`. Keep it private; if absent the
build falls back to debug signing.
