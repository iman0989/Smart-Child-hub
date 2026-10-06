# Smart Child Hub — Phase 7 Deliverables

Final delivery package for the **Smart Child Daily Activity Tracking System**
("Smart Child Hub").

> **Demo login:** `dana@example.com` / `123456`

## Package contents

```
deliverables/
├── 01-Release-APK/
│   └── SmartChildHub-release.apk        Signed release APK (52.8 MB, scheme v2)
├── 02-Database/
│   └── smart_child_hub.sql              Full database dump (mysqldump)
├── 03-Documentation/
│   ├── 01-Technical-Documentation.md    Architecture, stack, data model
│   ├── 02-User-Manual.md                End-user guide
│   ├── 03-Testing-Report.md             All test suites + defects found
│   ├── 04-Deployment-Guide.md           Install, env config, backup/restore
│   └── 05-API-Reference.md              Full REST endpoint reference
├── 04-Presentation/
│   ├── presentation.md                  Slide deck (Markdown, Marp/Slidev-ready)
│   └── slides.html                      Self-contained HTML slides (double-click)
├── 05-Screenshots/
│   ├── 01-onboarding.png … 10-profile.png  10 screens captured on emulator
└── 06-Source-Code/
    └── SmartChildHub-source.zip         Flutter app + PHP backend source
```

## Quick start

1. **Database:** `mysql -u root < backend/database/schema.sql` then
   `php backend/database/seed.php`
2. **API:** `php -S 127.0.0.1:8080 -t backend/public backend/public/index.php`
   (use the IPv4 address so Android emulators can reach it)
3. **App:** install `01-Release-APK/SmartChildHub-release.apk` on a device, or
   rebuild with `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080`
4. Log in with the demo account above.

See `03-Documentation/04-Deployment-Guide.md` for details.

## Verification summary

| Suite | Result |
|---|---|
| `flutter analyze` / `flutter test` | 0 issues / 1–1 |
| Integration tests (emulator, live API) | 2 / 2 |
| Backend API tests | 153 / 153 |
| Database tests | 127 / 127 |
| Signed APK install + launch | PASS |
