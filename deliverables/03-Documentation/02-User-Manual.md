# Smart Child Hub — User Manual

Version 1.0 · App package `com.smarthub.smart_child_hub`

---

## 1. Introduction

Smart Child Hub helps families build healthy daily routines. Parents set up
child profiles, track activities, sleep, meals, water, mood, homework,
attendance and screen time, reward children with coins, and review progress
through reports.

Demo account: **dana@example.com** / **123456**.

---

## 2. Installation

### 2.1 Android app

1. Install the release APK from `deliverables/01-Release-APK/`.
   On Android, allow installation from unknown sources when prompted.
2. Open **Smart Child Hub**.

> The app must be able to reach the backend server (same Wi-Fi or emulator
> host). If the screen reports "request timed out", the backend URL is not
> reachable — see section 8 (Troubleshooting).

### 2.2 Backend (developer / demo setup)

1. Start XAMPP → start **MySQL** (Apache optional).
2. Create the database: `mysql -u root < backend/database/schema.sql`
3. Seed demo data: `php backend/database/seed.php`
4. Start the API: `php -S 0.0.0.0:8080 -t backend/public backend/public/index.php`

---

## 3. First launch & onboarding

On first launch a splash screen appears and the app shows a 3-page onboarding
introduction. Tap **Next** to page through it or **Skip** to jump straight to
the login screen.

---

## 4. Registration & login

### 4.1 Create an account

1. On the login screen tap **Create account**.
2. Enter your **Full name**, a valid **Email address**, an optional **Phone**,
   a **Password** (at least 6 characters including a number), and confirm it.
3. Tap **Create account**. You are signed in automatically.

### 4.2 Sign in

- Enter your email and password and tap **Sign in**.
- **Remember me** is on by default so you stay signed in between launches.
- **Forgot password?** — enter your email to receive a reset link (in the demo
  build the one-time token is returned in the response and shown in the dev
  server output; production sends it by email).

### 4.3 Sign out

Settings → scroll to the bottom → **Sign out** (or Profile → **Sign out**).

---

## 5. Parent features

After signing in you land on the **Family Dashboard** with five tabs:
**Home · Activities · Reports · Alerts · Settings**.

### 5.1 Home (dashboard)

- Personal greeting and today's date.
- Stat cards: **Tasks done**, **On time %**, **Pending**.
- **Today's progress** weekly bar chart.
- **Today's summaries** — live per-child view of sleep, meals, water, mood,
  homework, attendance and screen time.
- **Children** — tap a child card to view their profile.
- **Quick actions** — add a glass of water, log sleep, log mood, open reports.
- Pull down to refresh.

### 5.2 Activities (tracking hub)

Tap any card to open that tracker:

- **Sleep** — log bedtime, wake-up time and quality; see the last 7 nights.
- **Meals** — add meals (breakfast/lunch/dinner/snack) with calories,
  protein/carbs/fat; see today's nutrition summary.
- **Water** — add/remove glasses toward the daily goal with timestamps.
- **Mood** — tap an emoji to check in; see this week's mood chart.
- **Screen time** — track allowed vs. used minutes.
- **Homework** — add assignments with subject and due date; mark them
  in progress/completed.
- **Attendance** — mark present/late/absent; view the monthly attendance rate.

### 5.3 Reports

- Per-child **daily**, **weekly** and **monthly** reports.
- Completion rate, coins earned, day streak, average sleep, water intake.
- Charts: task trend, sleep trend, category breakdown and attendance.
- Reports are generated on demand and persisted for history.

### 5.4 Alerts (notifications)

- List of notifications (activity, meal, homework, announcement).
- Unread badge on the bell icon in app bars; tap a notification to mark it read.
- **Mark all read** from the Alerts screen.

### 5.5 Settings

- **Appearance** — dark mode toggle.
- **Notifications** — enable notifications, activity/meal/homework reminders.
- **Privacy** — anonymous analytics, let kids add their own tasks.
- **Account** — Profile and About.
- **Sign out** at the bottom.

### 5.6 Profile & family management

Settings → **Profile** (or dashboard → Children → **Manage**):

- View/edit your **name, phone and avatar** (tap the edit icon).
- **Children** section — **Add** a child: name, age, grade/class, school and
  avatar. Children appear as cards; tap one to switch to that child's profile.
- **More** — jump to Settings or About.

---

## 6. Child features (kids mode)

In Profile, tap a child card (or on the child dashboard tap the avatar) to
**switch to the child's profile**. A **Choose profile** screen lists each child
— tap one to enter **kids mode**, or **Add a new child**.

Kids mode (`ChildShell`) has its own tabs: **Home · Activities · Reports ·
Alerts · Me**:

- **Home** — the child's day at a glance: tasks, coins, streak, today's
  summaries and quick actions.
- **Activities** — the same tracking hub as the parent, scoped to the child.
- **Reports** — the child's own report cards.
- **Alerts** — the child's notifications.
- **Me** — the child's profile; parent account shortcut and **Switch to
  parent** button to return to the family dashboard.

**Kids can add their own tasks** when enabled in Settings → Privacy.

---

## 7. Rewards: coins & streaks

- Completing an **activity** or **homework** assignment credits the child's
  **coins**.
- The **day streak** grows each day a task is completed and resets on a missed
  day.
- Coins, streak, completion rate and sleep/water averages are summarized in
  every report period.

---

## 8. Troubleshooting

| Problem | Likely cause | Fix |
| --- | --- | --- |
| "The request timed out. Please try again." | Backend URL unreachable | Start the PHP server; use the correct `API_BASE_URL` (see section 2.2) |
| "Failed to connect" / network error | Wrong host for device | Use the PC's LAN IP (not `localhost`) and start PHP on `0.0.0.0` |
| Login fails with "Incorrect email or password" | Wrong credentials | Reset via **Forgot password**, or use `dana@example.com` / `123456` |
| "An account with this email already exists" | Email already registered | Log in instead, or register with another email |
| Dashboard empty / "No data yet" | No records for the period | Add activities in **Activities** tab first |
| Child doesn't appear | Not added yet | Profile → **Add** child |
| Dark mode doesn't stick | Theme setting | Toggle in Settings → Appearance (applies immediately) |
| App stays on splash | Server down or session restore timeout | Check the server, then relaunch the app |

---

## 9. Version history

| Version | Date | Notes |
| --- | --- | --- |
| 1.0.0 | Aug 2026 | Initial release — full parent + child flows, 8 trackers, reports, notifications, signed release APK |
