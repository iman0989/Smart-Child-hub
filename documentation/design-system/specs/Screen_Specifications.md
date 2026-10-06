# Smart Child Hub — Screen Specifications

Design System Phase 2 · 22 screens · Companion to `Design_System_Guide.docx`
All screens are rendered at **1440 × 1920 px** in `documentation/mockups/`.

Legend:
- **Mode** — Child (My Day), Parent (Family Manager) or Shared.
- **Status bar** — device status bar shown on every screen except splash.
- **Navigation** — bottom bar (child mode / compact parent) or rail + app bar (expanded parent).

---

## 1. Splash — `01_splash.png` (Child · brand)

**Purpose.** Brand reveal. Establishes identity in under 1 second.

**Elements**
- Full-canvas gradient `#4F6BF5 → #8A5BF5` with soft white and sunshine blobs.
- Sunny logo mark, centered (scale 17).
- Wordmark "Smart Child Hub" in Baloo 2, 800 weight, 34 px, white.
- Tagline "Your family's smart hub for happy daily habits" (Nunito 12 px, `#DDE5FF`).
- Three loading dots at bottom (opacity 0.9 / 0.5 / 0.25).
- Footer text "Made for happy little routines" (`#D6DCFE`, 8.5 px).

**Motion.** Sunny spins in with a glowing halo over 900 ms (decelerate); wordmark scales 0.9 → 1.0.

**State.** Appears for ~1.4 s then transitions (fade-through 300 ms) to Welcome.

---

## 2. Welcome — `02_welcome.png` (Shared)

**Purpose.** First decision point: child path vs parent path. No login required for children.

**Elements**
- Logo centered at top (13), headline "Welcome to Smart Child Hub!" (Baloo 2, 26 px, 800).
- Card A — **My Day** (child mode): `child` icon on `#FFE0C7`, "For kids – tasks, coins, badges & fun", `Kids` pill (`#FF8A3D`).
- Card B — **Family Manager** (parent mode): `parent` icon on `#DDE5FF`, "For parents – manage tasks, rewards & reports", `Parents` pill (`#4F6BF5`).
- Primary button **Get Started** (`#4F6BF5`, `sparkle` icon).

**Interaction.** Tapping My Day → Choose Profile. Tapping Family Manager / Get Started → Parent Login.

---

## 3. Choose Profile — `03_choose_profile.png` (Child)

**Purpose.** Kiosk profile selection. Children tap their own card; no account needed.

**Elements**
- Header "Who's playing?" with subtitle "Pick a profile to start My Day".
- 2 × 2 grid of child cards (39 × 29): avatar circle, name (Baloo 2, 15 px), age, coin chip.
- **Add a new child** card (`#FFF7E0`) → parent-gated creation flow.
- **Parent PIN** card: `lock` icon, "Sign in as parent" → Parent Login.
- Primary button **Continue as <name>** (`#4F6BF5`, `child` icon).

**Interaction.** Tap child → Child PIN (if child PIN set) else child dashboard. Tap continue → Child PIN.

---

## 4. Child PIN — `04_child_pin.png` (Child)

**Purpose.** Optional 4-digit gate protecting a specific child's profile.

**Elements**
- Soft gradient background, small logo, "Hi Mia, welcome back!" (Baloo 2, 22 px).
- Lock badge, 4 pin dots (filled/unfilled).
- 3 × 4 numeric keypad with large rounded keys (`star` at * key, `chev_left` at # key).
- Footer link "Forgot PIN? Ask a parent".

**Interaction.** Correct PIN → child dashboard. Wrong PIN → gentle shake (250 ms, standard) and error dot state.

---

## 5. Child Dashboard — `05_child_dashboard.png` (Child)

**Purpose.** The daily hub: greeting, progress, today's tasks, weekly earnings.

**Elements**
- Child header: "Good morning!", avatar `M` on `#FFC93C`, coin balance chip with `+15` delta.
- Hero card: Sunny + "Great job today!" + "You finished 4 of 6 tasks" + progress ring **67% today** + `5 day streak` pill (`#FFF3D1`).
- Section **My Tasks** (+ See all) with task rows (checked / pending states, status pill, coin chip).
- Section **This Week**: bar chart (M–S) + goal card "Goal this week 100" (`#FFE0C7`).
- Bottom nav: Home · Tasks · Rewards · Badges · Me (accent `#4F6BF5`).

**States.** Card entrance staggered 300 ms emphasized; coin chip animates on balance change.

---

## 6. Task Screen — `06_task_screen.png` (Child)

**Purpose.** Full task list with filters and statuses.

**Elements**
- Child header; filter chips **All / Today / Pending / Done** (active = Today).
- Sections **Morning routine** (2/3 done) and **Learning & fun**.
- Task rows carry status pills: `completed`, `pending`, `locked` (grey, lock icon), with coin values.
- Bottom nav on Tasks (index 1).

**State notes.** Locked tasks cannot be tapped until their schedule unlocks; pending self-check taps → confirm dialog.

---

## 7. Rewards — `07_rewards.png` (Child)

**Purpose.** Rewards shop for the child.

**Elements**
- Child header "Your rewards".
- Gradient "Saving for" hero (`#4F6BF5 → #7A5BF5`): "Weekend movie night", coin chip **160 / 300**, progress bar `#FFC93C`.
- Section **Top rewards** (+ See all), 2 × 2 cards: illustration icon, name, price chip or `Locked` pill.
- Bottom nav on Rewards (index 2).

**Interaction.** Tap affordable reward → confirmation dialog → redemption submitted for parent approval (Reward claim 500 ms bounce).

---

## 8. Coins — `08_coins.png` (Child)

**Purpose.** Transparent coin ledger for the child.

**Elements**
- Child header "My coins".
- Balance card: coin mark (double circle + star), "Total balance" **240**, `+62 this week` pill.
- Section **Coin history**: rows with icon, name, timestamp, signed amount (+green / −red).

**Rules.** Every earn and spend appears immediately; tabular numerals keep totals stable.

---

## 9. Badges — `09_badges.png` (Child)

**Purpose.** Badge collection with tiers.

**Elements**
- Child header "My badges".
- Gradient unlock hero: `medal` on `#FFC93C`, "New badge unlocked!", "Early Bird – 5 morning tasks", `Collect` pill.
- Section **Collection** (6/12): 4-column grid of badge cards; locked ones greyed with `lock` icon.

**State.** Badge unlock animation (scale 0→1 + golden glow, 600 ms bounce) fires when earned.

---

## 10. Achievements — `10_achievements.png` (Child)

**Purpose.** Streaks, milestones, progress.

**Elements**
- Child header "Achievements".
- Progress card: three rings — **72% tasks**, **5 streak**, **84% coins**.
- Section **Milestones**: rows with icon, title, "Reward +25 coins", progress bar, count n/N, check when done.

---

## 11. Messages — `11_messages.png` (Child)

**Purpose.** Simple parent–child messaging without a phone.

**Elements**
- Child header "Messages"; chat list with `3` unread pill; conversation bubbles (incoming white, outgoing gradient `#4F6BF5 → #5E7BFF`); timestamps.
- Composer bar with `send` icon; placeholder "Type a message...".

**Rules.** Messages are local and positive; no media, no notifications outside the home.

---

## 12. Child Reports — `12_reports_child.png` (Child)

**Purpose.** Child-friendly weekly summary.

**Elements**
- Gradient "This week summary" hero: "You were a superstar!" + `Week` pill.
- Stat cards: **24** Tasks done, **5** Day streak, **62** Coins.
- Section **Tasks per day**: bar chart Mon–Sun.
- Section **Task results**: donut 55% completed / 25% pending / 12% missed / 8% locked + legend.

---

## 13. Parent Login — `13_parent_login.png` (Parent)

**Purpose.** PIN-gated entry to the parent zone.

**Elements**
- Soft gradient, logo, "Family Manager" (Baloo 2, 24 px).
- Raised card (level 3): "Parent PIN", "Only parents can open this area", pin dots, `eye` reveal toggle, primary **Sign in** button.
- "Forgot PIN? Reset with the master key" link.
- `Kids mode` pill (`#FFE0C7`/`#FF8A3D`) → back to Choose Profile.

**Rules.** Wrong PIN → lockout messaging after repeated failures (5 attempts → 30 s lock).

---

## 14. Parent Dashboard — `14_parent_dashboard.png` (Parent)

**Purpose.** Family overview at a glance.

**Elements**
- Parent header "Family Dashboard" (Mon, 3 Aug 2026) with notification bell (3).
- Stat cards: **42** Tasks done, **81%** On time, **8** Pending.
- **Today's progress**: bar chart M–S.
- **Children** cards: avatar, name, "4 tasks · 240 coins", completion ring, chevron.
- **Needs approval** banner (`#FFF3D1`): "Mia finished math homework", `Review` pill → Pending Approval.
- Bottom nav on Home (index 0).

---

## 15. Manage Children — `15_manage_children.png` (Parent)

**Purpose.** Profile administration.

**Elements**
- Parent header "Manage Children" + back; search bar.
- Child rows: avatar, name, age, coin chip, edit (`#E9EAF6`) and trash (`#FFE7E7`) actions.
- **Add a new child** card (`#FFF7E0`) + FAB (`#FF8A3D`).
- Note "Each child gets their own PIN".

**Interaction.** Edit/delete are destructive-gated by PIN re-entry.

---

## 16. Manage Tasks — `16_manage_tasks.png` (Parent)

**Purpose.** Task and schedule administration.

**Elements**
- Parent header "Manage Tasks" + back; filter chips All/Morning/Evening/Done.
- **Morning routine** rows: icon, title, "Mia & Leo · 7:30 am · +5 coins", status pill (`verified`/`active`), edit + trash.
- **Evening routine** rows incl. `paused` state.
- FAB (`#4F6BF5`) → add task.

**Task fields.** Name, assignees, schedule (daily/weekly/custom days), time, coin value, verification type, active/paused.

---

## 17. Pending Approval — `17_pending_approval.png` (Parent)

**Purpose.** Approval queue for self-checked... wait — approve/reject of completed tasks.

**Elements**
- Info banner "Approved tasks add coins automatically".
- Approval cards: avatar + child + task name, "Today · 8:15 am · +5 coins", task thumbnail icon, **Approve +N** (green) and **Reject** (outlined red) buttons.

**Interaction.** Approve → coin added to child balance + ledger entry. Reject → optional reason dialog.

---

## 18. Rewards Management — `18_rewards_management.png` (Parent)

**Purpose.** Manage the reward shop and redemptions.

**Elements**
- Parent header "Rewards" + back; filter chips All/Active/Paused.
- Reward rows: illustration icon, "300 coins · Shared", edit + trash, active toggle (`#2FAE66`).
- FAB (`#4F6BF5`) → add reward.
- Note "Coins are awarded when tasks are approved".

---

## 19. Coin Management — `19_coin_management.png` (Parent)

**Purpose.** Manual balance adjustments with audit.

**Elements**
- Gradient balance card: "Total family balance" **515**, `+3 this week` pill.
- Section **Adjust per child**: avatar, current balance chip, `minus`/`plus` steppers.
- Primary **Save changes** button.
- Note "Changes apply to both the balance and history".

**Rules.** Every manual change writes an audit trail entry visible in the child's ledger.

---

## 20. Parent Reports — `20_reports_parent.png` (Parent)

**Purpose.** Period insights and export.

**Elements**
- Parent header "Reports" + back; filter chips Week/Month/All time.
- Stat cards: **42** Tasks done, **81%** Completion, **515** Coins.
- **Children comparison**: bar chart (Mia/Leo/Ava) with values.
- **Weekly trend**: line chart with "+42% vs last week" badge.
- **By category**: horizontal bars Health/Learning/Activity/Routine.
- **Export report (PDF)** outlined button (`download` icon).

---

## 21. Settings — `21_settings.png` (Parent)

**Purpose.** Family preferences.

**Elements**
- Parent header "Settings" + back.
- Account card: avatar `D`, "Dana Smith", "Parent · Primary account".
- Rows: Notifications (toggle), Parent PIN (chevron), Dark mode (toggle), Kids can add tasks (toggle), Help & support, **Sign out** (red, `#FFE7E7`).
- Version footer "Smart Child Hub · Version 1.0.0".

---

## 22. About — `22_about.png` (Parent · brand)

**Purpose.** Product story and privacy statement.

**Elements**
- Brand gradient canvas, logo, "Smart Child Hub", "Version 1.0.0".
- White card: "About this app" + description.
- Feature list: 100% offline, kid-friendly with no ads, Parent PIN keeps settings safe.
- Button "Made with love for families" (white/`#4F6BF5`, `heart` icon); footer "Sunny © 2026 Smart Child Hub".

---

## Cross-Screen Rules

1. Every screen renders at the active theme (light/dark) using tokens only — never raw hex in widgets.
2. Every interactive element has a ≥ 48 × 48 dp touch target.
3. Task status always pairs colour + icon + text label.
4. Child mode uses Baloo 2/Quicksand; parent mode uses Nunito. Numerals are tabular.
5. Loading states never show a frozen frame (bouncing dots / spinning coin, 1000 ms loop).
6. Parent-only actions (children, tasks, approvals, rewards, coins, reports, settings, about) are always behind the parent PIN.
