# Smart Child Daily Activity Tracking System — Deployment & Configuration Guide

Version 1.0 · Phase 7 release

---

## 1. Prerequisites

| Component | Required version | Notes |
|---|---|---|
| PHP | 8.0+ | CLI + Apache module (XAMPP recommended on Windows) |
| MariaDB / MySQL | 10.4+ | InnoDB required (foreign keys, upserts) |
| Flutter | 3.38.x · Dart 3.10.x | Only needed to rebuild / re-sign the app |
| Android SDK | API 30+ | Only needed to rebuild the APK |
| Network | Open to client | Port `8080` for the API (or your chosen port) |

---

## 2. Backend configuration

The backend is a single "environment config" file backed by environment
variables. All values can be overridden without editing code by prefixing the
variable when starting PHP, e.g.:

```bash
DB_HOST=db.example.com DB_PASS=secret php -S 127.0.0.1:8080 -t backend/public backend/public/index.php
```

### 2.1 Config file — `backend/app/config/config.php`

| Constant | Env override | Default | Meaning |
|---|---|---|---|
| `APP_NAME` | — | `Smart Child Hub API` | Display name |
| `APP_VERSION` | — | `1.0.0` | API version |
| `BASE_URL` | `BASE_URL` | `http://localhost/backend/public` | Absolute API base used in links/emails |
| `DB_HOST` | `DB_HOST` | `127.0.0.1` | Database host |
| `DB_PORT` | `DB_PORT` | `3306` | Database port |
| `DB_NAME` | `DB_NAME` | `smart_child_hub` | Database name |
| `DB_USER` | `DB_USER` | `root` | Database user |
| `DB_PASS` | `DB_PASS` | *(empty)* | Database password |
| `PASSWORD_MIN_LENGTH` | — | `6` | Minimum password length |
| `TOKEN_TTL_HOURS` | — | `720` | Auth token lifetime (30 days) |
| `RESET_TOKEN_TTL_MINUTES` | — | `60` | Password-reset token lifetime |
| `RESET_TOKEN_CHARS` | — | `32` | Reset token length |
| `CHILD_PIN_REGEX` | — | `^[0-9]{4}$` | Child PIN format (4 digits) |
| `CORS_ALLOWED_ORIGINS` | `CORS_ALLOWED_ORIGINS` | `*` | Comma-separated allowed origins |
| `APP_DEBUG` | — | `true` | Show real error messages (set `false` in production) |

> **Production checklist:** set `APP_DEBUG = false`, a strong `DB_PASS`,
> narrow `CORS_ALLOWED_ORIGINS`, and serve over HTTPS behind a reverse proxy.

### 2.2 Database setup

```bash
# Create the 15-table schema.
mysql -u root -p < backend/database/schema.sql

# Seed the demo account and sample data.
php backend/database/seed.php
#   Demo login:  dana@example.com / 123456
```

### 2.3 Run the API

XAMPP Apache (document root → `backend/public`):

```bash
# backend/public/.htaccess already rewrites everything to index.php
```

Or the PHP built-in server:

```bash
php -S 127.0.0.1:8080 -t backend/public backend/public/index.php
```

> **Windows note:** the built-in server defaults to an IPv6 `[::1]` bind on some
> setups, which Android emulators cannot reach. Use the explicit IPv4 address
> `127.0.0.1` as shown above. Emulators reach the host via `10.0.2.2`.

### 2.4 Verify

```bash
curl http://127.0.0.1:8080/api/health
```

---

## 3. Mobile app configuration

The API base URL is compiled into the app with a `--dart-define` flag. The
default is `http://localhost:8080` (a physical device on the same LAN, or an
iOS simulator).

```bash
# Android emulator (host machine is 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Physical device on the same Wi-Fi as the API host
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

Config source: `app/lib/core/network/api_config.dart` (`ApiConfig.baseUrl`,
request timeout, device name reported to the API).

---

## 4. Building & signing the release APK

```bash
cd app

# 1. Android signing keystore (one-time):
#    app/android/app/smart-child-hub-release.jks, alias smartchildhub
#    (paths + credentials are read from app/android/key.properties)

# 2. Build the release APK.
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_SERVER:8080

# 3. Output.
#    app/build/app/outputs/flutter-apk/app-release.apk
```

The Gradle signing config (`app/android/app/build.gradle.kts`) reads
`key.properties`; if it is missing it falls back to debug signing so local
builds never break. Verify the signature with:

```bash
apksigner verify --print-certs app-release.apk
```

A prebuilt, signed copy ships in `deliverables/01-Release-APK/`.

---

## 5. Database backup & restore

### Backup (export)

```bash
mysqldump -u root -p smart_child_hub > smart_child_hub.sql
```

On Windows PowerShell, use a `cmd` wrapper so the redirect writes UTF-8/ASCII
and `<`/`>` are handled by cmd, not PowerShell:

```cmd
cmd /c "mysqldump -u root smart_child_hub > smart_child_hub.sql"
```

### Restore (import)

```bash
mysql -u root -p smart_child_hub < smart_child_hub.sql
```

The shipped backup is `deliverables/02-Database/smart_child_hub.sql`.

### Suggested rotation

Back up after every release, or nightly via cron/Task Scheduler:

```bash
mysqldump -u root --single-transaction --routines smart_child_hub | gzip > backup-$(date +%F).sql.gz
```

---

## 6. Running the test suites

```bash
# Flutter static analysis + widget tests
cd app
flutter analyze
flutter test

# End-to-end integration tests (requires a running API + emulator)
flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/app_flow_test.dart \
    -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Backend API tests (against a live server) + DB tests
php backend/tests/api_test.php
php backend/tests/db_test.php
```

---

## 7. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Emulator "connection refused" to API | Server bound to `[::1]` (IPv6) | Restart with `php -S 127.0.0.1:8080` |
| "Validation failed." on register | camelCase vs snake_case field names | Keep `password_confirmation` in API payloads |
| 401 on every call | Wrong `API_BASE_URL` / token expired | Re-login; rebuild with correct `--dart-define` |
| RenderFlex overflow on dashboard | Known fixed issue (`statistics_card.dart`) | Pull the latest source |
| App can't reach server on LAN | Windows firewall blocks PHP | Allow inbound on the API port |

---

## 8. Deployment runbook (quick)

1. Install prerequisites (PHP 8+, MariaDB 10.4+, Flutter if rebuilding).
2. `mysql -u root < backend/database/schema.sql`
3. `php backend/database/seed.php`
4. Serve `backend/public` (Apache or `php -S 127.0.0.1:8080 -t backend/public backend/public/index.php`).
5. `curl http://127.0.0.1:8080/api/health` → `200`.
6. Install `deliverables/01-Release-APK/SmartChildHub-release.apk` on a device.
7. Log in with the demo account (or register a new family).
