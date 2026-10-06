"""Generates analysis & design diagrams (context, DFD, ER, UML, architecture...)."""
import math
from diagram_lib import (new_fig, save, box, box_plain, ellipse, actor, arrow, line,
                         datastore, dashed_zone, text, BLUE, BLUE2, LBLUE, LBLUE2, GREEN, LGREEN,
                         ORANGE, LORANGE, GRAY, LGRAY, RED, LRED, PURPLE, LPURPLE, DARK)

OUT = None


def _set_out(d):
    global OUT
    OUT = d


def _crow(ax, x, y, ux, uy, color=BLUE, lw=1.6):
    L = 3.0
    px, py = -uy, ux
    line(ax, x + ux * 1.6, y + uy * 1.6, x + ux * 2.2 + px * L, y + uy * 2.2 + py * L, color=color, lw=lw)
    line(ax, x + ux * 1.6, y + uy * 1.6, x + ux * 2.2 - px * L, y + uy * 2.2 - py * L, color=color, lw=lw)


def _rel(ax, x1, y1, x2, y2, many1=False, many2=False, label=None, color=BLUE, lw=1.5, fs=7):
    line(ax, x1, y1, x2, y2, color=color, lw=lw)
    dx, dy = x2 - x1, y2 - y1
    L = math.hypot(dx, dy) or 1
    ux, uy = dx / L, dy / L
    if many2:
        _crow(ax, x2, y2, ux, uy, color=color, lw=lw)
    if many1:
        _crow(ax, x1, y1, -ux, -uy, color=color, lw=lw)
    if label:
        mx, my = (x1 + x2) / 2 + 1.5, (y1 + y2) / 2
        text(ax, mx, my, label, fs=fs, color=GRAY, style='italic')


def _entity(ax, x, y, w, h, name, attrs, fc=LBLUE2, ec=BLUE, fs=7.5):
    box(ax, x, y, w, h, header=name, header_fc=BLUE, text=attrs, fs=fs, fc=fc, rounding=0.4)
    cx = x + w / 2
    text(ax, cx, y - 1.6, name, fs=6.5, color=GRAY, style='italic')


# ---------------------------------------------------------------- FIG 1 Context
def make_context(path):
    fig, ax = new_fig(11, 6.5)
    ax.set_xlim(0, 110); ax.set_ylim(0, 60)
    text(ax, 55, 57, 'Offline Family Dashboard \u2014 shared home tablet (no child smartphone)', fs=9, color=GRAY)
    # System
    box(ax, 40, 20, 30, 22, ['SMART CHILD DAILY', 'ACTIVITY TRACKING', 'SYSTEM', '', '(Offline Local Network)'],
        fs=10.5, fc=LBLUE, ec=BLUE, bold=True)
    # Parent
    actor(ax, 14, 46, 'Parent (Administrator)', color=GREEN)
    box_plain(ax, 4, 16, 20, 12, ['Login / PIN', 'Manage children & tasks', 'Approve / reject', 'Coins, rewards, badges'], fc=LGREEN, ec=GREEN, fs=7)
    # Child
    actor(ax, 96, 46, 'Child', color=ORANGE)
    box_plain(ax, 86, 16, 20, 12, ['Select own profile', 'Complete tasks', 'Earn coins', 'Claim rewards'], fc=LORANGE, ec=ORANGE, fs=7)
    # Flows
    arrow(ax, 24, 40, 40, 34, 'child & task data, approvals,\ncoins, rewards, messages', rad=-0.25, color=GREEN, fs=7, text_dy=-0.2)
    arrow(ax, 40, 27, 24, 30, 'dashboards, reports,\ncharts, notifications', rad=-0.25, color=GREEN, fs=7, text_dy=-0.2)
    arrow(ax, 86, 40, 70, 34, 'profile selection,\ntask completion', rad=-0.25, color=ORANGE, fs=7)
    arrow(ax, 70, 27, 86, 30, 'tasks, coins, badges,\nrewards, messages', rad=-0.25, color=ORANGE, fs=7, text_dy=-0.2)
    save(fig, path, 'Context Diagram')


# ---------------------------------------------------------------- FIG 2 DFD L0
def make_dfd0(path):
    fig, ax = new_fig(11.5, 7)
    ax.set_xlim(0, 112); ax.set_ylim(0, 70)
    actor(ax, 12, 58, 'Parent', color=GREEN)
    actor(ax, 100, 58, 'Child', color=ORANGE)
    box(ax, 34, 32, 44, 18, ['0.0', 'SMART CHILD DAILY', 'ACTIVITY TRACKING SYSTEM'], fs=10, fc=LBLUE, bold=True)
    arrow(ax, 26, 48, 34, 43, 'login, child/task data,\napprovals, coins', rad=-0.2, color=GREEN, fs=7)
    arrow(ax, 34, 40, 26, 44, 'reports, dashboards,\nnotifications', rad=-0.2, color=GREEN, fs=7)
    arrow(ax, 86, 48, 78, 43, 'profile selection,\ncompletion', rad=-0.2, color=ORANGE, fs=7)
    arrow(ax, 78, 40, 86, 44, 'tasks, coins, badges,\nrewards', rad=-0.2, color=ORANGE, fs=7)
    stores = [('D1 Parents', 6), ('D2 Children', 28), ('D3 Tasks & Assignments', 50), ('D4 Coins & Rewards', 76), ('D5 Badges & Messages', 100)]
    for label, x in stores:
        datastore(ax, x, 8, 16, label, ec=BLUE, fs=7.5)
        arrow(ax, x + 8, 32, x + 8, 13, '', color=BLUE, lw=1.2)
        arrow(ax, x + 8, 13, x + 8, 32, '', color=BLUE, lw=1.2)
    text(ax, 56, 62, 'reads / updates', fs=7, color=GRAY, style='italic')
    save(fig, path, 'DFD \u2013 Level 0 (Context-level Processes)')


# ---------------------------------------------------------------- FIG 3 DFD L1
def make_dfd1(path):
    fig, ax = new_fig(13.5, 9)
    ax.set_xlim(0, 118); ax.set_ylim(0, 82)
    actor(ax, 8, 66, 'Parent', color=GREEN)
    actor(ax, 110, 66, 'Child', color=ORANGE)
    procs = [
        ('1.0 Authentication &\nAccess Control', 6, 70, 16, 11),
        ('2.0 Child &\nProfile Mgmt', 28, 70, 16, 11),
        ('3.0 Task Mgmt &\nScheduling', 50, 70, 16, 11),
        ('4.0 Verification &\nApproval', 72, 70, 16, 11),
        ('5.0 Coin &\nReward Mgmt', 94, 70, 16, 11),
        ('6.0 Badge Mgmt', 6, 50, 16, 9),
        ('7.0 Reports &\nAnalytics', 28, 50, 16, 11),
        ('8.0 Notifications &\nMessages', 50, 50, 18, 11),
    ]
    for lbl, x, y, w, h in procs:
        box(ax, x, y, w, h, lbl, fs=8, fc=LBLUE, bold=True)
    # Parent flows
    arrow(ax, 20, 66, 14, 70, 'credentials', rad=-0.2, color=GREEN, fs=6.5)
    arrow(ax, 30, 66, 36, 70, 'child mgmt', rad=-0.2, color=GREEN, fs=6.5)
    arrow(ax, 30, 60, 36, 55, 'reports', rad=-0.3, color=GREEN, fs=6.5)
    arrow(ax, 20, 60, 36, 62, '', color=GREEN, lw=1)
    # Child flows
    arrow(ax, 100, 66, 96, 70, 'completion', rad=-0.2, color=ORANGE, fs=6.5)
    arrow(ax, 92, 60, 100, 63, 'task list / rewards', rad=-0.2, color=ORANGE, fs=6.5)
    # Process-to-process (main chain)
    arrow(ax, 22, 75, 28, 75, '', color=BLUE, lw=1.2)
    arrow(ax, 44, 75, 50, 75, '', color=BLUE, lw=1.2)
    arrow(ax, 66, 75, 72, 75, '', color=BLUE, lw=1.2)
    arrow(ax, 88, 75, 94, 75, '', color=BLUE, lw=1.2)
    arrow(ax, 22, 61, 14, 64, '', color=BLUE, lw=1.2)
    arrow(ax, 44, 61, 30, 61, '', color=BLUE, lw=1.2)
    arrow(ax, 66, 61, 60, 61, '', color=BLUE, lw=1.2)
    # Data stores
    stores = [
        ('D1 Parents', 8, 22, 12), ('D2 Children', 26, 22, 13),
        ('D3 Tasks', 45, 22, 12), ('D4 Assignments', 63, 22, 14),
        ('D5 Coin Transactions', 84, 22, 20), ('D6 Rewards', 8, 6, 14),
        ('D7 Badges & Awards', 28, 6, 16), ('D8 Messages & Notifications', 50, 6, 18),
        ('D9 Settings & Reminders', 74, 6, 18),
    ]
    for lbl, x, y, w in stores:
        datastore(ax, x, y, w, lbl, ec=BLUE, fs=6.8)
    # store connections (representative)
    for x in (14, 32, 51, 70, 94):
        arrow(ax, x + 6, 22, x + 6, 46, '', color=BLUE, lw=1.0)
    for x in (15, 36, 59):
        arrow(ax, x + 6, 6, x + 6, 20, '', color=BLUE, lw=1.0)
    arrow(ax, 94 + 8, 22, 84, 20, '', color=BLUE, lw=1.0)
    save(fig, path, 'DFD \u2013 Level 1 (Main Processes)')


# ---------------------------------------------------------------- FIG 4 DFD L2
def make_dfd2(path):
    fig, ax = new_fig(12.5, 8)
    ax.set_xlim(0, 116); ax.set_ylim(0, 76)
    text(ax, 58, 73, 'Process 4.0 Verification & Approval \u2013 exploded', fs=9, color=GRAY)
    actor(ax, 8, 46, 'Child', color=ORANGE)
    actor(ax, 108, 46, 'Parent', color=GREEN)
    sub = [
        ('4.1 Self-Check\nCompletion', 24, 56, 18, 10),
        ('4.2 Submit for\nApproval', 48, 56, 18, 10),
        ('4.3 Approve\nAssignment', 72, 56, 18, 10),
        ('4.4 Reject\nAssignment', 72, 32, 18, 10),
        ('4.5 Issue / Deduct\nCoins', 48, 32, 18, 10),
    ]
    for lbl, x, y, w, h in sub:
        box(ax, x, y, w, h, lbl, fs=8, fc=LBLUE, bold=True)
    datastore(ax, 30, 10, 18, 'D4 Assignments', ec=BLUE, fs=7)
    datastore(ax, 60, 10, 22, 'D5 Coin Transactions', ec=BLUE, fs=7)
    # flows
    arrow(ax, 18, 46, 24, 52, 'task completion', rad=-0.2, color=ORANGE, fs=6.5)
    arrow(ax, 18, 40, 24, 60, '', color=ORANGE, lw=1.0)
    arrow(ax, 33, 56, 39, 56, 'update status', rad=-0.1, color=BLUE, fs=6.5, text_dy=1)
    arrow(ax, 42, 62, 48, 62, 'submission', color=BLUE, fs=6.5, text_dy=0.8)
    arrow(ax, 57, 56, 63, 56, 'decision', color=BLUE, fs=6.5)
    arrow(ax, 72, 62, 66, 62, '', color=BLUE, lw=1.0)
    arrow(ax, 81, 56, 88, 50, 'approve', color=GREEN, fs=6.5)
    arrow(ax, 81, 38, 88, 46, 'reject', color=RED, fs=6.5)
    arrow(ax, 66, 36, 57, 36, 'finalize / deduct', color=BLUE, fs=6.5)
    arrow(ax, 57, 38, 48, 38, '', color=BLUE, lw=1.0)
    arrow(ax, 39, 30, 30, 22, 'status', color=BLUE, fs=6.5)
    arrow(ax, 57, 28, 60, 18, 'ledger', color=BLUE, fs=6.5)
    save(fig, path, 'DFD \u2013 Level 2 (Verification & Approval)')


# ---------------------------------------------------------------- FIG 5 ER
def make_er(path):
    fig, ax = new_fig(13.5, 9.5)
    ax.set_xlim(0, 118); ax.set_ylim(0, 92)
    E = lambda x, y, n, attrs: _entity(ax, x, y, 20, 15, n, attrs)
    E(2, 72, 'parents', ['PK parent_id', 'full_name', 'email', 'phone', 'username', 'password_hash', 'pin', 'role'])
    E(28, 72, 'children', ['PK child_id', 'FK parent_id', 'first_name', 'last_name', 'avatar', 'date_of_birth', 'total_coins', 'status'])
    E(54, 72, 'tasks', ['PK task_id', 'FK parent_id', 'title', 'description', 'schedule_type', 'repeat_days', 'coins_reward', 'verification_type', 'is_active'])
    E(82, 72, 'assignments', ['PK assignment_id', 'FK child_id', 'FK task_id', 'due_date', 'status', 'completed_at', 'verified_at', 'rejection_reason', 'coins_awarded'])
    E(2, 46, 'coin_transactions', ['PK transaction_id', 'FK child_id', 'FK assignment_id', 'type', 'amount', 'reason', 'created_by', 'created_at'])
    E(28, 46, 'rewards', ['PK reward_id', 'FK parent_id', 'title', 'description', 'cost_coins', 'is_active'])
    E(54, 46, 'redemptions', ['PK redemption_id', 'FK child_id', 'FK reward_id', 'status', 'requested_at', 'approved_at', 'granted_at'])
    E(80, 46, 'badges', ['PK badge_id', 'FK parent_id', 'name', 'description', 'criterion'])
    E(2, 20, 'badge_awards', ['PK award_id', 'FK child_id', 'FK badge_id', 'awarded_at', 'awarded_by'])
    E(28, 20, 'messages', ['PK message_id', 'FK parent_id', 'FK child_id', 'subject', 'body', 'is_read', 'sent_at'])
    E(54, 20, 'notifications', ['PK notification_id', 'FK parent_id', 'FK child_id', 'message', 'type', 'is_read', 'created_at'])
    E(80, 20, 'reminders', ['PK reminder_id', 'FK parent_id', 'FK task_id', 'remind_time', 'frequency', 'is_enabled'])
    E(52, 2, 'settings', ['PK setting_id', 'FK parent_id', 'setting_key', 'setting_value', 'updated_at'])
    # relationships
    _rel(ax, 22, 78, 28, 78, many2=True, label='manages')
    _rel(ax, 48, 78, 54, 78, many2=True, label='creates')
    _rel(ax, 52, 72, 82, 72, many1=True, many2=True, label='schedules', lw=1.4)
    _rel(ax, 62, 72, 82, 69, many2=True, label='generates', lw=1.2)
    _rel(ax, 22, 70, 22, 61, many2=True, label='earns')
    _rel(ax, 48, 70, 28, 62, many2=True, label='redeems')
    _rel(ax, 74, 70, 54, 62, many2=True, label='has')
    _rel(ax, 90, 70, 80, 61, many2=True, label='earned from')
    _rel(ax, 22, 46, 28, 46, many2=True, label='ordered from')
    _rel(ax, 48, 46, 54, 46, many2=True, label='is awarded')
    _rel(ax, 74, 46, 80, 46, many2=True, label='grants')
    _rel(ax, 22, 35, 22, 28, many2=True, label='awards')
    _rel(ax, 48, 35, 28, 28, many2=True, label='receives')
    _rel(ax, 74, 35, 54, 28, many2=True, label='sends')
    _rel(ax, 90, 35, 80, 28, many2=True, label='sends')
    _rel(ax, 52, 2 + 10, 48, 4, many2=False, label='', lw=1.2)
    _rel(ax, 62, 2 + 10, 62, 20, many2=True, label='', lw=1.2)
    save(fig, path, 'ER Diagram (Logical Design)')


# ---------------------------------------------------------------- FIG 6 Use case
def make_usecase(path):
    fig, ax = new_fig(14, 9.5)
    ax.set_xlim(0, 120); ax.set_ylim(0, 90)
    dashed_zone(ax, 14, 2, 92, 80, 'Smart Child Daily Activity Tracking System', fc='white')
    actor(ax, 7, 60, 'Parent\n(Administrator)', color=GREEN)
    actor(ax, 113, 60, 'Child', color=ORANGE)
    puc = ['Login / PIN Access', 'Manage Children', 'Manage Tasks & Scheduling', 'Assign / Remove Coins',
           'Create Rewards', 'Approve / Reject Tasks', 'Create & Assign Badges', 'Generate Reports',
           'View Analytics & Charts', 'Manage Reminders & Notifications', 'Configure Settings', 'Send Messages']
    for i, u in enumerate(puc):
        r, c = divmod(i, 2)
        ellipse(ax, 30 + c * 22, 68 - r * 11, 18, 7.4, u, fs=7)
    cuc = ['Select Profile', 'View Tasks', 'Complete Tasks', 'View Coins', 'View Badges',
           'View Rewards', 'Redeem Rewards', 'View Progress', 'Read Messages']
    for i, u in enumerate(cuc):
        r, c = divmod(i, 2)
        ellipse(ax, 88 + c * 22, 68 - r * 11, 18, 7.4, u, fs=7)
    # include relations
    arrow(ax, 39, 68, 39, 62, 'include', rad=-0.4, color=BLUE, fs=6.5)
    arrow(ax, 88, 62, 88, 66, '', color=BLUE, fs=6.5, lw=1.2)
    arrow(ax, 95, 46, 88, 44, '', color=BLUE, fs=6.5, lw=1.2)
    # actor links
    for y in range(0, 6):
        arrow(ax, 15, 60 - y * 4, 22, 62 - y * 4, '', color=GREEN, lw=1.1, style='-')
    arrow(ax, 22, 60 - 1, 21, 62 - 1, '', color=GREEN, lw=1.1)
    for y in range(0, 5):
        arrow(ax, 105, 60 - y * 4, 98, 62 - y * 4, '', color=ORANGE, lw=1.1, style='-')
    save(fig, path, 'Use Case Diagram')


# ---------------------------------------------------------------- FIG 7 Class
def make_class(path):
    fig, ax = new_fig(14, 9.5)
    ax.set_xlim(0, 120); ax.set_ylim(0, 88)
    classes = [
        ('Parent', ['- parentId : int', '- fullName : string', '- pin : string', '- role : string'], ['+ login()', '+ createChild()', '+ createTask()', '+ approveTask()', '+ assignCoins()']),
        ('Child', ['- childId : int', '- firstName : string', '- totalCoins : int', '- status : string'], ['+ selectProfile()', '+ completeTask()', '+ viewCoins()', '+ redeemReward()']),
        ('Task', ['- taskId : int', '- title : string', '- scheduleType : enum', '- coinsReward : int', '- verificationType : enum'], ['+ create()', '+ schedule()', '+ deactivate()']),
        ('Assignment', ['- assignmentId : int', '- dueDate : date', '- status : enum', '- rejectionReason : string'], ['+ markVerified()', '+ markRejected()', '+ markMissed()']),
        ('CoinTransaction', ['- transactionId : int', '- type : enum', '- amount : int', '- reason : string'], ['+ record()', '+ reverse()']),
        ('Reward', ['- rewardId : int', '- title : string', '- costCoins : int', '- isActive : bool'], ['+ create()', '+ update()', '+ redeem()']),
        ('Redemption', ['- redemptionId : int', '- status : enum', '- requestedAt : datetime'], ['+ request()', '+ approve()', '+ grant()']),
        ('Badge', ['- badgeId : int', '- name : string', '- criterion : string'], ['+ create()', '+ assign()']),
        ('BadgeAward', ['- awardId : int', '- awardedAt : datetime'], ['+ award()']),
        ('ReportService', ['- period : enum'], ['+ dailyReport()', '+ weeklyReport()', '+ monthlyReport()', '+ yearlyReport()', '+ completionRate()']),
    ]
    positions = [
        (2, 60, 20, 26), (24, 60, 20, 26), (46, 60, 20, 26), (68, 60, 20, 26), (90, 60, 28, 26),
        (2, 18, 20, 26), (24, 18, 20, 26), (46, 18, 20, 26), (68, 18, 20, 26), (90, 18, 28, 26),
    ]
    for (name, attrs, methods), (x, y, w, h) in zip(classes, positions):
        # header + two compartments
        box(ax, x, y + h - 5, w, 5, header=name, header_fc=BLUE, text='', fs=9)
        box_plain(ax, x, y + 8, w, h - 13, '', fc='white', ec=BLUE, lw=1.4, fs=8)
        for i, a in enumerate(attrs):
            text(ax, x + 1.2, y + 8 + (len(attrs) - i) * 2.1 - 1.2, a, fs=6.6, ha='left', color=DARK)
        for i, m in enumerate(methods):
            text(ax, x + 1.2, y + (len(methods) - i) * 2.0 - 1.0, m, fs=6.6, ha='left', color=BLUE, style='italic')
    _rel(ax, 24, 72, 24, 60, many2=True, label='1..*', lw=1.4)
    _rel(ax, 66, 72, 46, 60, many2=True, label='*', lw=1.4)
    _rel(ax, 78, 66, 68, 63, many2=True, label='*', lw=1.2)
    _rel(ax, 24, 33, 24, 44, many2=True, label='1..*', lw=1.4)
    _rel(ax, 46, 33, 46, 44, many2=True, label='*', lw=1.2)
    _rel(ax, 68, 33, 68, 44, many2=True, label='*', lw=1.2)
    _rel(ax, 46, 38, 36, 44, many2=True, label='', lw=1.2)
    save(fig, path, 'Class Diagram (Domain Model)')


# ---------------------------------------------------------------- FIG 8 Sequence
def make_sequence(path):
    fig, ax = new_fig(13.5, 8.5)
    ax.set_xlim(0, 120); ax.set_ylim(0, 84)
    actors = ['Child (Tablet UI)', 'Flutter App', 'Laravel API', 'MySQL Database', 'Parent (Tablet)']
    xs = [14, 38, 64, 92, 110]
    for x, a in zip(xs, actors):
        box(ax, x - 9, 76, 18, 6, a, fs=7.5, fc=LBLUE, bold=True)
        ax.plot([x, x], [2, 76], color=GRAY, lw=1.1, ls='--', zorder=1)
    msgs = [
        (xs[0], xs[1], 70, 'taps \u201cComplete Task\u201d', 'self'),
        (xs[1], xs[2], 64, 'POST /assignments/{id}/complete', 'req'),
        (xs[2], xs[3], 58, 'UPDATE assignment status', 'req'),
        (xs[3], xs[2], 52, 'affected rows = 1', 'res'),
        (xs[2], xs[1], 47, 'coins awarded + status', 'res'),
        (xs[1], xs[0], 42, 'shows coins & verification state', 'res'),
        (xs[4], xs[2], 34, 'approve / reject task', 'req'),
        (xs[2], xs[3], 28, 'finalise verification & coins', 'req'),
        (xs[3], xs[2], 23, 'OK', 'res'),
        (xs[2], xs[1], 18, 'updated balance', 'res'),
    ]
    ylab = {'self': 'App', 'req': 'HTTP', 'res': 'HTTP'}
    for x1, x2, y, m, kind in msgs:
        col = GREEN if 'res' == kind else BLUE
        if kind == 'self':
            arrow(ax, x1, y, x2, y, '', rad=0.0, color=BLUE, lw=1.2)
            text(ax, (x1 + x2) / 2, y + 1.2, m, fs=6.6, color=DARK)
            arrow(ax, x1 + 1.5, y, x1 + 1.5, y - 2.5, '', color=BLUE, lw=1.2, style='-')
        elif kind == 'req':
            arrow(ax, x1, y, x2 - 1, y, '', color=BLUE, lw=1.3)
            text(ax, (x1 + x2) / 2, y + 1.1, m, fs=6.6, color=BLUE)
        else:
            arrow(ax, x2, y, x1 + 1, y, '', color=GREEN, lw=1.3, ls='--')
            text(ax, (x1 + x2) / 2, y + 1.1, m, fs=6.6, color=GREEN)
    text(ax, 60, 38.5, 'alt', fs=7, color=ORANGE, bold=True)
    dashed_zone(ax, 34, 10, 82, 30, 'if verification_type = parent_approval', fc='#FFF8F0', lc=ORANGE)
    save(fig, path, 'Sequence Diagram \u2013 Task Completion & Approval')


# ---------------------------------------------------------------- FIG 9 Activity
def make_activity(path):
    fig, ax = new_fig(11.5, 8.5)
    ax.set_xlim(0, 100); ax.set_ylim(0, 88)
    circle = lambda cx, cy, r, fc: ax.add_patch(__import__('matplotlib.patches', fromlist=['Circle']).Circle((cx, cy), r, fc=fc, ec=BLUE, lw=1.6, zorder=3))
    circle(50, 84, 2.5, '#1F4E79')
    box(ax, 34, 72, 32, 8, 'Child selects a task', fs=8.5, fc=LBLUE)
    arrow(ax, 50, 81, 50, 80.5, '')
    ellipse(ax, 50, 62, 44, 12, 'Verification type?', fs=8.5, fc=LGREEN, ec=GREEN)
    arrow(ax, 50, 72, 50, 68, '')
    # self check path
    box(ax, 2, 46, 26, 8, 'Award coins immediately', fs=8, fc=LGREEN, ec=GREEN)
    arrow(ax, 34, 61, 15, 54, 'self-check', color=GREEN, fs=7)
    box(ax, 2, 30, 26, 8, 'Task = Verified', fs=8, fc=LGREEN, ec=GREEN)
    arrow(ax, 15, 46, 15, 38, '', color=GREEN)
    # approval path
    box(ax, 36, 46, 28, 8, 'Award temporary coins\nSubmit for approval', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 62, 61, 50, 54, 'parent approval', color=ORANGE, fs=7)
    ellipse(ax, 50, 30, 44, 12, 'Parent approves?', fs=8.5, fc=LBLUE2, ec=BLUE2, tc='white')
    arrow(ax, 50, 46, 50, 36, '', color=ORANGE)
    box(ax, 72, 16, 26, 8, 'Finalise coins\nNotify child', fs=7.5, fc=LGREEN, ec=GREEN)
    arrow(ax, 66, 30, 85, 24, 'yes', color=GREEN, fs=7)
    box(ax, 2, 16, 26, 8, 'Remove temp coins\nRecord rejection reason', fs=7, fc=LRED, ec=RED)
    arrow(ax, 34, 29, 15, 24, 'no', color=RED, fs=7)
    circle(50, 4, 2.5, BLUE)
    arrow(ax, 85, 16, 55, 6, '', color=BLUE)
    arrow(ax, 15, 16, 45, 6, '', color=BLUE)
    save(fig, path, 'Activity Diagram \u2013 Task Completion & Verification')


# ---------------------------------------------------------------- FIG 10 State
def make_state(path):
    fig, ax = new_fig(12, 7.5)
    ax.set_xlim(0, 110); ax.set_ylim(0, 70)
    states = [
        ('PENDING', 'task assigned', 4, 40, 18, 9),
        ('COMPLETED', 'self-check\nauto-verified', 30, 56, 20, 10),
        ('SUBMITTED', 'pending parent\nverification', 30, 26, 20, 10),
        ('VERIFIED', 'coins finalised', 62, 56, 20, 10),
        ('REJECTED', 'coins removed', 62, 26, 20, 10),
        ('MISSED', 'not completed\nby due date', 62, 4, 20, 10),
    ]
    for name, note, x, y, w, h in states:
        box(ax, x, y, w, h, name, fs=8.5, fc=LBLUE, bold=True)
        text(ax, x + w / 2, y - 1.4, note, fs=6.8, color=GRAY, style='italic')
    ax.add_patch(__import__('matplotlib.patches', fromlist=['Circle']).Circle((4, 62), 2.2, fc=BLUE, ec=BLUE, zorder=3))
    arrow(ax, 6, 62, 12, 49, 'assigned', fs=6.8)
    arrow(ax, 22, 46, 30, 58, 'self-check completed', color=GREEN, fs=6.8)
    arrow(ax, 22, 42, 30, 32, 'submitted for approval', color=ORANGE, fs=6.8)
    arrow(ax, 40, 56, 62, 58, 'parent approves / auto verify', color=GREEN, fs=6.6)
    arrow(ax, 40, 26, 62, 28, 'parent rejects', color=RED, fs=6.8)
    arrow(ax, 22, 24, 62, 8, 'due date passes', color=GRAY, fs=6.8)
    arrow(ax, 62, 30, 62, 16, '', color=GRAY, lw=1.0)
    # reset
    arrow(ax, 72, 6, 6, 6, '', rad=-0.3, color=GRAY, lw=1.0, style='-')
    arrow(ax, 6, 6, 6, 58, '', color=GRAY, lw=1.0, style='-')
    text(ax, 76, 7, 'reset / new assignment', fs=6.5, color=GRAY, style='italic')
    save(fig, path, 'State Diagram \u2013 Assignment Lifecycle')


# ---------------------------------------------------------------- FIG 11 Navigation
def make_navigation(path):
    fig, ax = new_fig(13, 7.5)
    ax.set_xlim(0, 120); ax.set_ylim(0, 76)
    dashed_zone(ax, 1, 2, 57, 66, 'PARENT APP', fc='#F5FAF0', lc=GREEN)
    dashed_zone(ax, 61, 2, 58, 66, 'CHILD APP', fc='#FFF7EF', lc=ORANGE)
    box(ax, 16, 62, 26, 8, 'Parent Dashboard', fs=8.5, fc=LGREEN, ec=GREEN, bold=True)
    pnav = [('Children', ['Add / Edit / Delete child', 'Child profile & coins']),
            ('Tasks', ['Create / Edit / Delete', 'Schedules & reminders']),
            ('Verification', ['Approve / Reject', 'Rejection reason']),
            ('Coins & Rewards', ['Bonus / remove coins', 'Create rewards', 'Redemptions']),
            ('Badges', ['Create badges', 'Assign badges']),
            ('Reports', ['Daily / Weekly / Monthly / Yearly', 'Charts & analytics', 'Top child']),
            ('Messages', ['Send to child']),
            ('Settings', ['PIN, notifications, data'])]
    y = 56
    for label, sub in pnav:
        box(ax, 6, y, 22, 6.5, label, fs=7, fc='white', ec=GREEN)
        text(ax, 37, y + 3, ' \u2022 '.join(sub), fs=6.4, color=DARK, ha='left')
        arrow(ax, 16, y, 6, y + 5, '', color=GREEN, lw=0.9, style='-')
        y -= 6.8
    box(ax, 76, 62, 28, 8, 'Choose Child Profile', fs=8.5, fc=LORANGE, ec=ORANGE, bold=True)
    cnav = [('Today\u2019s Tasks', ['View tasks', 'Complete / submit']),
            ('My Coins', ['Balance', 'History']),
            ('My Badges', ['Earned badges']),
            ('Rewards', ['View rewards', 'Redeem']),
            ('My Progress', ['Completion rate', 'Streaks']),
            ('Messages', ['Read parent messages'])]
    yy = 54
    for label, sub in cnav:
        box(ax, 66, yy, 20, 6.5, label, fs=7, fc='white', ec=ORANGE)
        text(ax, 97, yy + 3, ' \u2022 '.join(sub), fs=6.4, color=DARK, ha='left')
        arrow(ax, 76, yy, 66, yy + 5, '', color=ORANGE, lw=0.9, style='-')
        yy -= 7.6
    arrow(ax, 76, 60, 76, 62, '', color=ORANGE, lw=1.4, style='-')
    save(fig, path, 'Navigation Structure')


# ---------------------------------------------------------------- FIG 12 Architecture
def make_arch(path):
    fig, ax = new_fig(12, 8)
    ax.set_xlim(0, 110); ax.set_ylim(0, 80)
    layers = [
        ('PRESENTATION LAYER \u2013 Flutter (Shared Tablet)', ['Parent Dashboard / Child Dashboard', 'Login (username + PIN)', 'Task, Reports, Coins, Rewards, Settings screens'], LBLUE, BLUE),
        ('API LAYER \u2013 Laravel REST API', ['Controllers: Auth, Child, Task, Verification, Coin, Reward, Badge, Report, Notification', 'Routes: /api/* \u2013 JSON'], LBLUE2, BLUE2),
        ('BUSINESS LOGIC LAYER \u2013 Laravel Services', ['TaskService, CoinService, ApprovalService, RewardService, BadgeService, ReportService, NotificationService'], LPURPLE, PURPLE),
        ('DATA ACCESS LAYER \u2013 Eloquent ORM', ['Models, Migrations, Seeders, Query Builder, Validators'], LGRAY, GRAY),
        ('DATABASE LAYER \u2013 MySQL', ['parents, children, tasks, assignments, coin_transactions, rewards, redemptions, badges, badge_awards, messages, notifications, reminders, settings'], LGREEN, GREEN),
    ]
    y = 66
    for name, desc, fc, ec in layers:
        box(ax, 8, y, 94, 11, header=name, header_fc=ec, text=desc, fs=7, fc=fc, rounding=0.6)
        y -= 12.5
    dashed_zone(ax, 0, 20, 110, 54, 'OFFLINE LOCAL NETWORK (Home Wi-Fi)', fc='white', lc=ORANGE, lw=1.3)
    box(ax, 20, 4, 70, 10, 'Single shared home tablet \u2013 children only select their profile (no personal logins)', fs=8, fc=LORANGE, ec=ORANGE)
    arrow(ax, 55, 66, 55, 80, '', color=BLUE, lw=1.0, style='-')
    text(ax, 64, 80, 'user interaction', fs=7, color=GRAY, style='italic')
    save(fig, path, 'System Architecture \u2013 5-Layer Stack')


# ---------------------------------------------------------------- FIG 13 Deployment
def make_deployment(path):
    fig, ax = new_fig(12.5, 7.5)
    ax.set_xlim(0, 118); ax.set_ylim(0, 70)
    dashed_zone(ax, 1, 1, 116, 68, 'Home Local Network (Offline)', fc='white', lc=GRAY, lw=1.3)
    box(ax, 4, 44, 50, 20, header='Node: Shared Family Tablet', header_fc=BLUE,
        text=['\u201cSmart Child Daily Activity Tracking\u201d', 'Flutter client application', 'Parent mode \u00b7 Child kiosk mode', 'Local screen \u2013 no child smartphone'], fs=7.5)
    box(ax, 64, 44, 50, 20, header='Node: Home Server / PC', header_fc=GREEN,
        text=['Laravel REST API (PHP 8.x)', 'Apache / built-in PHP server', 'Serves offline API on LAN', 'Data backup & settings'], fs=7.5)
    box(ax, 34, 8, 50, 20, header='Node: Database Server', header_fc=ORANGE,
        text=['MySQL 8.x database', 'All system tables & records', 'Runs on the same home server', 'No external internet dependency'], fs=7.5)
    arrow(ax, 54, 54, 64, 54, 'HTTP on LAN (192.168.x.x)', color=BLUE, fs=7)
    arrow(ax, 59, 22, 59, 44, '', color=BLUE, lw=1.3, style='-')
    text(ax, 66, 33, 'MySQL / TCP', fs=7, color=ORANGE)
    text(ax, 4, 4, 'All communication stays inside the home network \u2013 system works fully offline.', fs=7.5, color=GRAY, style='italic', ha='left')
    save(fig, path, 'Deployment Diagram')


# ---------------------------------------------------------------- FIG 14 DB relationship
def make_db_rel(path):
    fig, ax = new_fig(13.5, 9)
    ax.set_xlim(0, 120); ax.set_ylim(0, 90)
    def t(x, y, name, cols):
        box(ax, x, y, 26, 16, header=name, header_fc=BLUE, text=cols, fs=6.8, rounding=0.3)
    t(2, 70, 'parents', ['PK id', 'full_name', 'email', 'phone', 'username', 'password_hash', 'pin'])
    t(32, 70, 'children', ['PK id', 'FK parent_id', 'first_name', 'last_name', 'avatar', 'total_coins'])
    t(62, 70, 'tasks', ['PK id', 'FK parent_id', 'title', 'schedule_type', 'coins_reward', 'verification_type'])
    t(92, 70, 'assignments', ['PK id', 'FK child_id', 'FK task_id', 'status', 'due_date', 'rejection_reason'])
    t(2, 44, 'coin_transactions', ['PK id', 'FK child_id', 'FK assignment_id', 'type', 'amount', 'reason'])
    t(32, 44, 'rewards', ['PK id', 'FK parent_id', 'title', 'cost_coins'])
    t(62, 44, 'redemptions', ['PK id', 'FK child_id', 'FK reward_id', 'status'])
    t(92, 44, 'badges', ['PK id', 'FK parent_id', 'name', 'criterion'])
    t(2, 18, 'badge_awards', ['PK id', 'FK child_id', 'FK badge_id', 'awarded_at'])
    t(32, 18, 'messages', ['PK id', 'FK parent_id', 'FK child_id', 'body', 'is_read'])
    t(62, 18, 'notifications', ['PK id', 'FK parent_id', 'FK child_id', 'message', 'is_read'])
    t(92, 18, 'reminders', ['PK id', 'FK task_id', 'remind_time', 'is_enabled'])
    _rel(ax, 28, 77, 32, 77, many2=True)
    _rel(ax, 58, 77, 62, 77, many2=True)
    _rel(ax, 88, 77, 92, 74, many2=True, label='generates', lw=1.2)
    _rel(ax, 14, 70, 14, 60, many2=True)
    _rel(ax, 46, 70, 46, 60, many2=True)
    _rel(ax, 78, 70, 78, 60, many2=True)
    _rel(ax, 28, 50, 32, 50, many2=True)
    _rel(ax, 58, 50, 62, 50, many2=True)
    _rel(ax, 88, 50, 92, 50, many2=True)
    _rel(ax, 14, 44, 14, 34, many2=True)
    _rel(ax, 46, 44, 46, 34, many2=True)
    _rel(ax, 78, 44, 78, 34, many2=True)
    _rel(ax, 108, 44, 108, 34, many2=True)
    save(fig, path, 'Database Relationship Diagram')


def run(d):
    _set_out(d)
    make_context(d + '\\f01_context.png')
    make_dfd0(d + '\\f02_dfd_level0.png')
    make_dfd1(d + '\\f03_dfd_level1.png')
    make_dfd2(d + '\\f04_dfd_level2.png')
    make_er(d + '\\f05_er_diagram.png')
    make_usecase(d + '\\f06_use_case.png')
    make_class(d + '\\f07_class_diagram.png')
    make_sequence(d + '\\f08_sequence_diagram.png')
    make_activity(d + '\\f09_activity_diagram.png')
    make_state(d + '\\f10_state_diagram.png')
    make_navigation(d + '\\f11_navigation.png')
    make_arch(d + '\\f12_system_architecture.png')
    make_deployment(d + '\\f13_deployment_diagram.png')
    make_db_rel(d + '\\f14_database_relationship.png')
    print('Analysis diagrams done:', d)
