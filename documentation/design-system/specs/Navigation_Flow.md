# Smart Child Hub — Navigation Flow

Design System Phase 2 · Companion to `Screen_Specifications.md` and `Design_System_Guide.docx`

This document defines the complete screen-to-screen navigation. Nodes are mockup IDs from
`documentation/mockups/`. The graph below is the contract for Phase 3 route definitions.

---

## 1. Entry

```
[Launch]
   |
   v
01 Splash ──────── (1.4 s, fade-through) ────────> 02 Welcome
```

- Splash is shown once per cold start.
- Welcome is the single branch point between the two modes.

---

## 2. Child Mode (My Day)

```
                 +--> 04 Child PIN ──(correct)──> 05 Child Dashboard
                 |    (child PIN set)
03 Choose Profile +
                 +--> 05 Child Dashboard ──────── (no child PIN)
```

From the dashboard, the child moves through the bottom navigation bar
(Home · Tasks · Rewards · Badges · Me):

```
05 Child Dashboard ─ Home
06 Task Screen     ─ Tasks
07 Rewards         ─ Rewards
08 Coins           ─ Rewards > My coins        (secondary entry)
09 Badges          ─ Badges
10 Achievements    ─ Badges > Achievements     (secondary entry)
11 Messages        ─ Me > Messages
12 Child Reports   ─ Me > My reports
```

**Secondary entries (inline actions, not nav destinations):**

- `05` task row tap → `06` Task Screen.
- `07` reward tap → confirmation dialog → redemption (parent approval) → returns to `07`.
- `08` coin history → single-row tap → task detail (optional).
- `09` badge tap → badge detail dialog.
- `11` chat tap → `11` Messages.
- `12` chart tap → period selector (Week/Month).

**Child mode exits:**

- Choose Profile `Parent PIN` card → `13` Parent Login.
- Anywhere → "Switch profile" → `03` Choose Profile.

---

## 3. Parent Mode (Family Manager)

```
02 Welcome / 03 Choose Profile
           |
           v
13 Parent Login ──(correct PIN)──> 14 Parent Dashboard
```

The parent zone uses the bottom navigation bar (Home · Tasks · Children · Reports · Settings)
with the app bar back affordance:

```
14 Parent Dashboard   ─ Home
16 Manage Tasks       ─ Tasks
15 Manage Children    ─ Children
20 Parent Reports     ─ Reports
21 Settings           ─ Settings
```

**Secondary entries:**

- `14` "Needs approval" Review pill → `17` Pending Approval.
- `14` child card tap → `19` Coin Management (per child) or child detail.
- `15` Add child card / FAB → Add Child form (dialog) → returns to `15`.
- `15` edit / trash → edit form / delete confirm (PIN-gated).
- `16` FAB → Add Task form → returns to `16`.
- `17` Approve / Reject → updates ledger, list refreshes.
- `18` Rewards Management — reached from `16` (Rewards sub-tab) and from the FAB.
- `19` Save changes → ledger write → returns to `14`.
- `20` Export → generates PDF locally → share sheet.
- `21` rows → dialogs (PIN change, toggles, help).
- `21` Sign out → `13` Parent Login.
- `21` About / version → `22` About.

**Parent mode exits:**

- `13` Kids mode pill → `03` Choose Profile.
- Sign out → `13` Parent Login (locked).

---

## 4. Navigation Bar Contracts

Child bottom bar (5 items, accent `#4F6BF5`):

| Index | Icon | Route | Screen |
|-------|------|-------|--------|
| 0 | home | / | 05 Child Dashboard |
| 1 | tasks | /tasks | 06 Task Screen |
| 2 | trophy | /rewards | 07 Rewards |
| 3 | badge | /badges | 09 Badges |
| 4 | person | /me | 08 Coins (profile hub) |

Parent bottom bar (5 items, accent `#4F6BF5`):

| Index | Icon | Route | Screen |
|-------|------|-------|--------|
| 0 | home | /family | 14 Parent Dashboard |
| 1 | tasks | /tasks | 16 Manage Tasks |
| 2 | person | /children | 15 Manage Children |
| 3 | chart | /reports | 20 Parent Reports |
| 4 | gear | /settings | 21 Settings |

> On expanded (≥ 840 dp) screens the parent bar becomes a navigation rail; child mode keeps the
> bottom bar at every size.

---

## 5. Flow Rules

1. **PIN gating.** `04`, `13` and every destructive parent action re-verify the PIN. No route
   bypasses the parent PIN.
2. **Back behaviour.** In child mode, back from `05` returns to `03`. Back from `13` returns to
   `03` via the Kids mode pill. In parent mode, back returns to the previous parent screen.
3. **Transitions.** Screen transitions are fade-through with an 8% horizontal slide, 300 ms,
   emphasized curve.
4. **Deep links.** Not applicable — the app is fully offline and local.
5. **Idle/security.** After 5 minutes idle in parent mode the app returns to `13`; after 10
   minutes in child mode it returns to `03` (profile picker).
6. **Approval state.** Pending approval counts are live on `14`; approving/rejecting in `17`
   immediately updates the badge, the child balance and the coin ledger.

---

## 6. Route Table (summary)

| # | Screen | Parent | Child | Nav source → destination |
|---|--------|--------|-------|--------------------------|
| 01 | Splash | ✓ | ✓ | Launch → 02 |
| 02 | Welcome | ✓ | ✓ | 01 → 03 / 13 |
| 03 | Choose Profile | ✓ | ✓ | 02 → 04 / 05 / 13 |
| 04 | Child PIN |  | ✓ | 03 → 05 |
| 05 | Child Dashboard |  | ✓ | 04/03 → 06/07/09/08 |
| 06 | Task Screen |  | ✓ | 05 → 06; 06 → 05 |
| 07 | Rewards |  | ✓ | 05 → 07 → 08 |
| 08 | Coins |  | ✓ | 07 → 08; Me hub |
| 09 | Badges |  | ✓ | 05 → 09 → 10 |
| 10 | Achievements |  | ✓ | 09 → 10 |
| 11 | Messages |  | ✓ | Me → 11 |
| 12 | Child Reports |  | ✓ | Me → 12 |
| 13 | Parent Login | ✓ |  | 02/03 → 14 |
| 14 | Parent Dashboard | ✓ |  | 13 → 15/16/17/20/21 |
| 15 | Manage Children | ✓ |  | 14 → 15 |
| 16 | Manage Tasks | ✓ |  | 14 → 16 → 18 |
| 17 | Pending Approval | ✓ |  | 14 → 17 |
| 18 | Rewards Mgmt | ✓ |  | 16 → 18 |
| 19 | Coin Management | ✓ |  | 14 → 19 |
| 20 | Parent Reports | ✓ |  | 14 → 20 |
| 21 | Settings | ✓ |  | 14 → 21 → 22 |
| 22 | About | ✓ |  | 21 → 22 |
