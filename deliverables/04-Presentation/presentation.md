# Smart Child Daily Activity Tracking System

**Presentation deck — Phase 7 final delivery**

*Use any Markdown-to-slides tool (Marp, Slidev, reveal.js, VS Code reveal
extension) to present. Each `---` is a slide boundary.*

---

## Slide 1 · Title

# Smart Child Hub
### Smart Child Daily Activity Tracking System
A family app for tracking, rewarding and reviewing children's daily routines

Phase 7 · Final Delivery · Version 1.0

---

## Slide 2 · The Problem

Parents juggling work and family struggle to keep track of:

- Daily routines (homework, chores, hygiene, meals)
- Sleep, water intake and screen time
- School attendance and mood
- What the day actually looked like at a glance

**Result:** missed routines, forgotten assignments, no visibility or history.

---

## Slide 3 · The Solution

One app for the whole family:

- **Parents** manage child profiles, assign tasks with **coin rewards** and streaks
- **Kids mode** lets children pick their own profile and log their own day
- **Daily / weekly / monthly reports** with charts
- **Notifications** for reminders and milestones

Two modes, one family.

---

## Slide 4 · Features

- Routine **activities** with coin-based gamification
- **Sleep** bedtime/wake/duration/quality logging
- **Meals**, **water goals**, **mood check-ins**
- **Homework** assignments with completion progress
- **School attendance** (present / late / absent)
- **Screen time** allowance vs. usage
- Rich **reports** and **notifications**

---

## Slide 5 · Architecture

```
Flutter App (Android)  ◄── HTTPS/JSON + Bearer token ──►  PHP 8 REST API
      │                                                       │
  Provider state                                              │
  repositories / ApiClient                                Controllers / Models
      │                                                       │
      │                                                   PDO (prepared stmts)
      │                                                       │
      └──────────────────► MariaDB (15 tables, FKs) ◄─────────┘
```

Clean two-tier: stateless API + relational persistence.

---

## Slide 6 · Tech Stack

| Layer | Technology |
|---|---|
| Client | Flutter 3.38 · Dart 3.10 · Provider state management |
| API | PHP 8 · MVC front controller · PDO prepared statements |
| Database | MariaDB / MySQL · InnoDB · 15 tables with cascades |
| Auth | bcrypt passwords · SHA-256-hashed bearer tokens (30-day TTL) |
| Security | SQLi-safe, XSS-escaped, rate-limited, ownership checks |

---

## Slide 7 · Database Design

15 tables covering every domain:

- `parents`, `children`, `child_activities`
- `sleep_records`, `meals`, `water_intake`, `moods`
- `homework`, `attendance`, `screen_time`
- `notifications`, `reports` and supporting tables

**Upsert keys** (child + date) keep one record per domain per day;
**cascading deletes** keep the family tree clean.

---

## Slide 8 · Security

- Passwords stored with **bcrypt**
- Auth tokens stored **hashed** (SHA-256), never in plaintext
- **Ownership enforcement** — a parent can only read their own children
- Validation (422), auth (401), not-found (404), conflict (409)
- Rate limiting on auth endpoints
- SQL-injection tests and XSS-escape tests in the QA suite

---

## Slide 9 · Testing — All Green

| Suite | Scope | Result |
|---|---|---|
| `flutter analyze` | Static analysis | 0 issues |
| `flutter test` | Widget tests | 1 / 1 |
| Integration tests | End-to-end on emulator vs live API | 2 / 2 |
| API tests | 19 sections, live HTTP | 153 / 153 |
| DB tests | Schema, FKs, CRUD, cascades | 127 / 127 |
| Screenshot drive | 10-screen capture | 1 / 1 |

---

## Slide 10 · Defects Caught & Fixed

| Defect | Fix |
|---|---|
| Registration always failed | camelCase `passwordConfirmation` → `password_confirmation` |
| Dashboard RenderFlex overflow | Replaced `Spacer()` with fixed spacing |
| Emulator couldn't reach API | Server bound to IPv4 `127.0.0.1`, not IPv6 `[::1]` |
| Integration tests interfered | Explicit session reset between tests |

All verified by re-running the affected suites.

---

## Slide 11 · Release Artifacts

- **Signed release APK** (52.8 MB, APK signature scheme v2)
- **Database dump** (`smart_child_hub.sql`)
- **Full documentation** — technical, user manual, testing report,
  deployment guide, API reference
- **10 screenshots** captured on a real emulator
- **Source code** archive

---

## Slide 12 · Live Demo Flow

1. Onboarding → register / login (`dana@example.com` / `123456`)
2. Add a child profile
3. Complete a routine activity → coins + streak update
4. Log sleep / meals / water / mood
5. Open the daily report with charts
6. Check notifications
7. Switch to kids mode and back

---

## Slide 13 · Deployment

```bash
mysql -u root < backend/database/schema.sql
php backend/database/seed.php
php -S 127.0.0.1:8080 -t backend/public backend/public/index.php
```

Android emulators reach the host via `10.0.2.2`; rebuild the APK with
`--dart-define=API_BASE_URL=http://10.0.2.2:8080`.

---

## Slide 14 · Future Work

- Push notifications (FCM) instead of in-app polling
- Offline-first sync for kids mode
- Multi-language support
- Wearable / smartwatch sleep tracking integration
- Parent web dashboard

---

## Slide 15 · Thank You

**Smart Child Hub — Smart Child Daily Activity Tracking System**

Phase 7 · Final Delivery

Questions?
