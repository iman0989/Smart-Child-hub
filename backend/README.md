# Smart Child Hub – Backend

REST API for the **Smart Child Daily Activity Tracking System** (Phase 4).

PHP 8+ / MySQL REST API with JSON responses, Bearer-token authentication,
full CRUD for parents, children and every tracking domain, notifications,
reports, and prepared-statement-safe data access.

## Quick start

```bash
# 1. Create the database (15 tables).
mysql -u root < backend/database/schema.sql

# 2. Seed the demo account and sample data.
php backend/database/seed.php
#   Demo login:  dana@example.com / 123456

# 3. Run (XAMPP Apache or PHP built-in server).
php -S localhost:8080 -t backend/public backend/public/index.php

# 4. Verify.
curl http://localhost:8080/api/health
```

## Docs

Full endpoint reference, response formats, status codes and security notes:

- **API documentation:** [`docs/API.md`](docs/API.md)

## Layout

```
public/            Front controller + .htaccess (only web-visible folder)
app/config/        Environment configuration
app/core/          Framework: router, request, response, DB, auth, validator
app/controllers/   Auth, Parent, ChildActivity, Notification, Report
app/models/        Row mappers matching the Flutter JSON contracts
database/          schema.sql + seed.php
docs/              API.md
```
