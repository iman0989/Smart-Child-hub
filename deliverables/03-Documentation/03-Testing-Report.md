# Smart Child Daily Activity Tracking System — Testing Report

Version 1.0 · Phase 7 release

---

## 1. Executive Summary

The Smart Child Hub application passed its complete test campaign with **all
suites green**:

| Test suite | Scope | Result |
|---|---|---|
| Static analysis (`flutter analyze`) | Whole Flutter app | 0 issues |
| Unit / widget tests (`flutter test`) | App bootstrap | 1 / 1 passed |
| Integration tests (`flutter drive`) | End-to-end flows on emulator against live API | 2 / 2 passed |
| Backend API tests (`api_test.php`) | Live REST API, 19 sections | 153 / 153 passed |
| Database tests (`db_test.php`) | Schema, constraints, CRUD, cascades | 127 / 127 passed |
| Screenshot drive | 10-screen capture run | 1 / 1 passed |

No open defects remain. Four real defects were found and fixed during the
testing phase (see §6).

---

## 2. Test Environment

| Item | Value |
|---|---|
| Host OS | Windows 10 / 11 (x64) |
| Mobile runtime | Android 11 emulator (`emulator-5554`, API 30, x86_64) |
| Flutter | 3.38.9 · Dart 3.10.8 |
| App package | `com.smarthub.smart_child_hub`, v1.0.0+1 |
| Backend | PHP 8.0.30 (XAMPP), Apache rewrite |
| Database | MariaDB 10.4.32, database `smart_child_hub` |
| API base | `http://127.0.0.1:8080` (host) / `http://10.0.2.2:8080` (emulator) |
| Test data | Dedicated QA account `dana@example.com` / `123456` |

---

## 3. Static Analysis & Widget Tests (Flutter)

Command: `flutter analyze` → **0 issues, 0 warnings**.

Command: `flutter test` → **1 / 1 passed**.

| Test | What it verifies |
|---|---|
| `widget_test.dart` | App builds, splash shows, no framework exceptions at startup |

---

## 4. Integration Tests (End-to-End)

Command (run against the live backend):

```
flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/app_flow_test.dart \
    -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Result: **2 / 2 suites passed**.

Coverage:

1. **Parent full journey** — onboarding → registration → login → add a child →
   complete a routine activity (coin award) → log sleep → view reports →
   verify notification → profile update → logout.
2. **Repeat run + fresh session** — re-login as a returning user with a cleared
   session, verify dashboard loads from a persisted session and screens below
   the fold are reachable (scroll behavior).

These tests also drove the **10-screen screenshot capture** used in the
deliverables (`integration_test/screenshots_test.dart`, run via the same
driver).

---

## 5. Backend & Database Tests (PHP)

### 5.1 API tests — `backend/tests/api_test.php` (153 / 153)

The runner exercises the **live HTTP API** over 19 sections:

- **Health** — `GET /api/health` returns 200.
- **Authentication** — register (success + validation), login, wrong password,
  unknown user, logout, `GET /api/me`, rate limiting.
- **Parent / children** — profile get & update, child create/update/delete,
  dashboard summary.
- **Activities (coin awards)** — create/complete routine tasks, duplicate
  completion is idempotent, coin balance and streak update correctly,
  validation of bad payloads.
- **Sleep (upsert)** — one record per child+date, update overwrites cleanly.
- **Meals** — create/update/delete, nutrition totals.
- **Water intake** — glass log with daily goal.
- **Moods** — daily check-in + weekly chart aggregation.
- **Homework** — assignments CRUD and completion progress.
- **Attendance** — present/late/absent per school day.
- **Screen time** — allowed vs. used minutes.
- **Notifications** — list with pagination, read/unread toggle.
- **Reports** — daily, weekly, monthly and history reports.
- **Ownership & authorization** — a child of one parent is never accessible
  from another account (403), missing/invalid token (401).
- **Security** — SQL-injection strings are rejected safely, stored values are
  HTML-escaped (XSS), no debug headers.
- **Password & token hashing** — passwords stored as bcrypt, API tokens stored
  as SHA-256 hashes.
- **Password reset & change** — flow works and invalidates old tokens.
- **Routing & HTTP methods** — unknown routes → 404, wrong method → 405.
- **Cleanup** — removes the QA fixtures created during the run.

Also collected during the run: **per-request response times** with a 300 ms
slow-endpoint threshold (all endpoints below the threshold → no slow endpoint
report).

### 5.2 Database tests — `backend/tests/db_test.php` (127 / 127)

Runs directly against MariaDB and verifies:

- **Structure** — correct engine (InnoDB), charset, and all 15 tables exist.
- **Foreign keys & cascades** — referential integrity; deleting a child
  cascades to activities, sleep, meals, water, moods, homework, attendance,
  screen-time and report rows.
- **Unique constraints** — upsert keys (child+date) enforce single rows.
- **CRUD round-trips** — inserts, updates, deletes and re-reads of every table.

---

## 6. Defects Found & Fixed

| # | Area | Symptom | Root cause | Fix |
|---|---|---|---|---|
| 1 | Auth (client) | Registration always failed with "Validation failed." | App sent `passwordConfirmation` (camelCase) but the API contract requires `password_confirmation` (snake_case) | Fixed payloads in `auth_repository.dart` for register and reset |
| 2 | Dashboard/Reports UI | RenderFlex overflow at runtime | `Spacer()` inside a `Column` in an unbounded-height layout | Replaced with fixed `SizedBox(height: 12)` in `statistics_card.dart` |
| 3 | Dev server bind | Emulator could not reach the API (connection timeouts) | Dev server bound to IPv6-only `[::1]` | Server restarted on IPv4 `127.0.0.1:8080` |
| 4 | Test session leakage | Integration tests interfered with each other | Persistent session across test runs | Added explicit session reset (prefs + token clear) between tests |

All four are fixed and verified by re-running the affected suites.

---

## 7. Performance Notes

- Slow-endpoint threshold during the API run: **300 ms** — no endpoint
  exceeded it.
- Release APK size: **52.8 MB** (APK signature scheme v2 verified).
- Debug APK installed size: ~84.6 MB; cold start to dashboard completes within
  the app's splash window (< 3 s) on the API-30 emulator.

---

## 8. Release Verification

- Release APK built and **signed** with the project keystore
  (`smart-child-hub-release.jks`, alias `smartchildhub`, scheme v2).
- APK installed successfully on the emulator and launched (`MainActivity` in
  focus).
- Database dump produced via `mysqldump` (exit code 0) — available at
  `deliverables/02-Database/smart_child_hub.sql`.

---

## 9. Sign-Off

All automated suites pass and the two manual release checks (install + launch)
succeed. **The system is ready for Phase 7 delivery.**

| Check | Status |
|---|---|
| `flutter analyze` | PASS |
| `flutter test` | PASS |
| Integration tests (2 suites) | PASS |
| API tests (153) | PASS |
| DB tests (127) | PASS |
| Release APK signed + installable | PASS |
| Database backup exported | PASS |
