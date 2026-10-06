"""Generates workflow diagrams, Gantt chart, and UI wireframes."""
import datetime
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.patches import FancyBboxPatch, Polygon
from diagram_lib import (new_fig, save, box, box_plain, ellipse, arrow, line, text,
                         BLUE, BLUE2, LBLUE, LBLUE2, GREEN, LGREEN, ORANGE, LORANGE, GRAY, LGRAY,
                         RED, LRED, PURPLE, LPURPLE, DARK)


def diamond(ax, cx, cy, w, h, s, fc=LBLUE2, ec=BLUE2, fs=7.5, tc='white'):
    p = Polygon([(cx - w / 2, cy), (cx, cy + h / 2), (cx + w / 2, cy), (cx, cy - h / 2)],
                fc=fc, ec=ec, lw=1.6, zorder=3)
    ax.add_patch(p)
    lines = s.split('\n')
    n = len(lines)
    start = cy + (n - 1) * (fs * 0.24)
    for i, ln in enumerate(lines):
        text(ax, cx, start - i * (fs * 0.24), ln, fs=fs, color=tc, bold=True)


def start_node(ax, cx, cy, r=3):
    ax.add_patch(Polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)],
                         fc=GREEN, ec=GREEN, zorder=3))
    text(ax, cx, cy, 'START', fs=6, color='white', bold=True)


def end_node(ax, cx, cy, r=3.4):
    ax.add_patch(Polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)],
                         fc=RED, ec=RED, zorder=3))
    text(ax, cx, cy, 'END', fs=6, color='white', bold=True)


# ---------------------------------------------------------------- FIG 15 Coin workflow
def make_coin(path):
    fig, ax = new_fig(12, 9)
    ax.set_xlim(0, 110); ax.set_ylim(0, 96)
    start_node(ax, 20, 90)
    box(ax, 6, 76, 28, 8, 'Child completes task', fs=8, fc=LBLUE)
    arrow(ax, 20, 87, 20, 84.5, '')
    diamond(ax, 56, 72, 40, 14, 'Verification type?', fc=LBLUE2, tc='white')
    arrow(ax, 20, 76, 20, 78, '')
    arrow(ax, 34, 78, 42, 76, '', rad=0.2, color=BLUE, lw=1.2)
    # self check
    box(ax, 6, 54, 30, 9, 'Credit coins immediately', fs=8, fc=LGREEN, ec=GREEN)
    arrow(ax, 44, 72, 20, 63, 'self-check', color=GREEN, fs=7)
    box(ax, 6, 38, 30, 9, 'Record ledger entry', fs=8, fc=LGREEN, ec=GREEN)
    arrow(ax, 21, 54, 21, 47.5, '', color=GREEN)
    box(ax, 6, 22, 30, 9, 'Task status = Verified\nNotify child', fs=7.5, fc=LGREEN, ec=GREEN)
    arrow(ax, 21, 38, 21, 31.5, '', color=GREEN)
    # approval path
    box(ax, 48, 54, 34, 9, 'Credit TEMPORARY coins\nTask = Pending verification', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 66, 72, 60, 63, 'parent approval', color=ORANGE, fs=7)
    diamond(ax, 66, 40, 40, 14, 'Parent approves?', fc=LBLUE2, tc='white')
    arrow(ax, 65, 54, 65, 47, '', color=ORANGE)
    box(ax, 86, 30, 22, 9, 'Coins finalised', fs=7.5, fc=LGREEN, ec=GREEN)
    arrow(ax, 82, 40, 88, 36, 'yes', color=GREEN, fs=7)
    box(ax, 48, 30, 22, 9, 'Temp coins removed', fs=7.5, fc=LRED, ec=RED)
    arrow(ax, 50, 40, 50, 36, 'no', color=RED, fs=7)
    end_node(ax, 21, 8)
    end_node(ax, 90, 8)
    arrow(ax, 21, 22, 21, 12, '', color=GREEN)
    arrow(ax, 88, 30, 89, 12, '', color=GREEN)
    arrow(ax, 48, 33, 24, 10, '', color=RED)
    # bonus / removal
    box(ax, 58, 6, 44, 9, 'Parent may also add bonus coins or remove coins\n(recorded in ledger)', fs=6.8, fc=LGRAY, ec=GRAY)
    save(fig, path, 'Coin Workflow')


# ---------------------------------------------------------------- FIG 16 Approval workflow
def make_approval(path):
    fig, ax = new_fig(11, 9.5)
    ax.set_xlim(0, 100); ax.set_ylim(0, 100)
    start_node(ax, 50, 94)
    box(ax, 32, 82, 36, 8, 'Child submits task\n(for parent approval)', fs=7.5, fc=LBLUE)
    arrow(ax, 50, 91, 50, 90.5, '')
    box(ax, 32, 68, 36, 8, 'Status = SUBMITTED\nTemporary coins credited', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 50, 82, 50, 76.5, '')
    box(ax, 32, 54, 36, 8, 'Parent notified in dashboard', fs=7.5, fc=LBLUE)
    arrow(ax, 50, 68, 50, 62.5, '')
    diamond(ax, 50, 42, 44, 13, 'Approve?', fc=LBLUE2, tc='white')
    arrow(ax, 50, 54, 50, 49, '')
    box(ax, 4, 26, 34, 9, 'Approve', fs=8, fc=LGREEN, ec=GREEN)
    arrow(ax, 36, 41, 21, 35, 'yes', color=GREEN, fs=7)
    box(ax, 4, 10, 34, 9, 'Status = VERIFIED\nCoins finalised\nNotify child', fs=7, fc=LGREEN, ec=GREEN)
    arrow(ax, 21, 26, 21, 19.5, '', color=GREEN)
    box(ax, 62, 26, 34, 9, 'Reject', fs=8, fc=LRED, ec=RED)
    arrow(ax, 66, 41, 79, 35, 'no', color=RED, fs=7)
    box(ax, 62, 10, 34, 9, 'Choose rejection reason\nTemp coins removed\nautomatically', fs=7, fc=LRED, ec=RED)
    arrow(ax, 79, 26, 79, 19.5, '', color=RED)
    end_node(ax, 50, 4)
    arrow(ax, 21, 10, 44, 6, '', color=GREEN)
    arrow(ax, 79, 10, 56, 6, '', color=RED)
    save(fig, path, 'Approval Workflow')


# ---------------------------------------------------------------- FIG 17 Reward workflow
def make_reward(path):
    fig, ax = new_fig(11.5, 9.5)
    ax.set_xlim(0, 105); ax.set_ylim(0, 100)
    start_node(ax, 52, 94)
    box(ax, 34, 82, 36, 8, 'Child views reward list\nand selects a reward', fs=7.5, fc=LBLUE)
    arrow(ax, 52, 91, 52, 90.5, '')
    diamond(ax, 52, 70, 46, 13, 'Sufficient coins?', fc=LBLUE2, tc='white')
    arrow(ax, 52, 82, 52, 77, '')
    box(ax, 6, 58, 30, 9, 'Show message\n\u201cNot enough coins\u201d', fs=7, fc=LGRAY, ec=GRAY)
    arrow(ax, 38, 69, 21, 63, 'no', color=GRAY, fs=7)
    box(ax, 6, 42, 30, 9, 'Child can earn more\ncoins first', fs=7, fc=LBLUE)
    arrow(ax, 21, 58, 21, 51.5, '')
    end_node(ax, 21, 30)
    arrow(ax, 21, 42, 21, 34, '', color=GRAY)
    box(ax, 52, 58, 34, 9, 'Create redemption request\n(status = PENDING)', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 66, 69, 64, 63, 'yes', color=GREEN, fs=7)
    box(ax, 52, 42, 34, 9, 'Parent notified & approves', fs=7.5, fc=LBLUE)
    arrow(ax, 69, 58, 69, 51.5, '')
    box(ax, 70, 26, 32, 9, 'Deduct coins\nGrant reward\nNotify child', fs=7, fc=LGREEN, ec=GREEN)
    arrow(ax, 69, 42, 79, 35, 'approved', color=GREEN, fs=6.8)
    box(ax, 52, 26, 12, 9, 'Reject / cancel', fs=6.5, fc=LRED, ec=RED)
    arrow(ax, 66, 42, 58, 35, 'rejected', color=RED, fs=6.8)
    end_node(ax, 52, 14)
    arrow(ax, 52, 26, 52, 18, '', color=BLUE)
    arrow(ax, 79, 26, 55, 18, '', color=GREEN)
    save(fig, path, 'Reward Workflow')


# ---------------------------------------------------------------- FIG 18 Parent workflow
def make_parent(path):
    fig, ax = new_fig(12.5, 9.5)
    ax.set_xlim(0, 115); ax.set_ylim(0, 100)
    start_node(ax, 18, 92)
    box(ax, 4, 78, 28, 9, 'Parent logs in\n(username + PIN)', fs=7.5, fc=LBLUE)
    arrow(ax, 18, 89, 18, 87.5, '')
    box(ax, 4, 62, 28, 9, 'Open Dashboard\n(overview + alerts)', fs=7.5, fc=LBLUE)
    arrow(ax, 18, 78, 18, 71.5, '')
    box(ax, 42, 78, 30, 9, 'Add / edit child\n(one profile per child)', fs=7.5, fc=LBLUE)
    arrow(ax, 32, 83, 42, 82, '', rad=0.2, color=BLUE)
    box(ax, 42, 62, 30, 9, 'Create tasks with\nschedule, coins, verification type', fs=7, fc=LBLUE)
    arrow(ax, 57, 78, 57, 71.5, '', color=BLUE)
    box(ax, 80, 62, 30, 9, 'Child completes tasks\n(self-check / submit)', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 72, 67, 80, 66, '', rad=0.2, color=BLUE)
    box(ax, 80, 46, 30, 9, 'Approve / reject\n(choose reason if rejected)', fs=7, fc=LBLUE)
    arrow(ax, 95, 62, 95, 55.5, '')
    box(ax, 42, 46, 30, 9, 'Assign coins, rewards,\nbadges & messages', fs=7, fc=LGREEN, ec=GREEN)
    arrow(ax, 80, 51, 72, 50, '', rad=0.2, color=BLUE)
    arrow(ax, 57, 46, 57, 39, '', color=BLUE)
    box(ax, 42, 30, 30, 9, 'View reports & charts\n(daily \u2026 yearly)', fs=7, fc=LBLUE)
    arrow(ax, 57, 30, 57, 23, '', color=BLUE)
    box(ax, 4, 30, 28, 9, 'Adjust tasks / rewards\nbased on analytics', fs=7, fc=LGRAY, ec=GRAY)
    arrow(ax, 42, 35, 32, 34, '', rad=0.2, color=BLUE)
    end_node(ax, 18, 16)
    arrow(ax, 18, 30, 18, 20, '', color=BLUE)
    arrow(ax, 57, 23, 22, 16, '', color=BLUE)
    arrow(ax, 30, 34, 22, 30, '', color=BLUE, lw=1.0, style='-')
    save(fig, path, 'Parent Workflow')


# ---------------------------------------------------------------- FIG 19 Child workflow
def make_child(path):
    fig, ax = new_fig(11.5, 9.5)
    ax.set_xlim(0, 105); ax.set_ylim(0, 100)
    start_node(ax, 52, 94)
    box(ax, 30, 82, 44, 8, 'Choose my profile\n(kiosk \u2013 no login needed)', fs=7.5, fc=LORANGE, ec=ORANGE)
    arrow(ax, 52, 91, 52, 90.5, '')
    box(ax, 30, 68, 44, 8, 'Child dashboard\n(greeting + today overview)', fs=7.5, fc=LBLUE)
    arrow(ax, 52, 82, 52, 76.5, '')
    box(ax, 30, 54, 44, 8, 'View today\u2019s tasks\n(daily / weekly / custom)', fs=7.5, fc=LBLUE)
    arrow(ax, 52, 68, 52, 62.5, '')
    diamond(ax, 52, 42, 44, 13, 'Complete task?', fc=LBLUE2, tc='white')
    arrow(ax, 52, 54, 52, 49, '')
    box(ax, 4, 32, 34, 8, 'Self-check \u2192 coins now\nor submit for approval', fs=7, fc=LORANGE, ec=ORANGE)
    arrow(ax, 38, 41, 21, 36, 'yes', color=GREEN, fs=7)
    box(ax, 4, 16, 34, 8, 'Track coins, badges,\nprogress & streak', fs=7, fc=LGREEN, ec=GREEN)
    arrow(ax, 21, 32, 21, 24.5, '', color=GREEN)
    box(ax, 66, 32, 34, 8, 'Redeem rewards\nwhen coins allow', fs=7, fc=LGREEN, ec=GREEN)
    arrow(ax, 66, 41, 83, 36, 'no', color=GRAY, fs=7)
    end_node(ax, 52, 6)
    arrow(ax, 21, 16, 48, 8, '', color=GREEN)
    arrow(ax, 83, 32, 56, 8, '', color=GRAY)
    save(fig, path, 'Child Workflow')


# ---------------------------------------------------------------- FIG 20 Gantt
def make_gantt(path):
    tasks = [
        ('Project Initiation & Planning', '2026-08-03', '2026-08-05', BLUE),
        ('Requirements Analysis', '2026-08-05', '2026-08-08', BLUE),
        ('Software Analysis & Design (SAD)', '2026-08-08', '2026-08-13', BLUE2),
        ('Database Design', '2026-08-12', '2026-08-15', BLUE2),
        ('API & Architecture Design', '2026-08-13', '2026-08-16', BLUE2),
        ('Frontend Development (Flutter)', '2026-08-15', '2026-08-22', GREEN),
        ('Backend Development (Laravel)', '2026-08-15', '2026-08-22', GREEN),
        ('Integration & Offline Verification', '2026-08-22', '2026-08-25', ORANGE),
        ('System Testing & User Acceptance', '2026-08-24', '2026-08-27', ORANGE),
        ('Final Documentation & Report', '2026-08-24', '2026-08-29', PURPLE),
        ('Deployment, Review & Submission', '2026-08-28', '2026-08-31', PURPLE),
    ]
    milestones = [('Requirements approved', '2026-08-08'), ('Design approved', '2026-08-14'),
                  ('Development complete', '2026-08-22'), ('Testing complete', '2026-08-27'),
                  ('Final submission', '2026-08-31')]
    fig, ax = plt.subplots(figsize=(12.5, 7), dpi=200)
    fig.patch.set_facecolor('white')
    start = datetime.date(2026, 8, 3)
    end = datetime.date(2026, 8, 31)
    n = len(tasks)
    for i, (name, s, e, color) in enumerate(tasks):
        d0 = datetime.date.fromisoformat(s)
        d1 = datetime.date.fromisoformat(e)
        x0 = (d0 - start).days
        x1 = (d1 - start).days + 1
        ax.barh(n - i, x1 - x0, left=x0, height=0.62, color=color, edgecolor='white', zorder=3)
        ax.text(x0 - 0.2, n - i, name, ha='right', va='center', fontsize=8, zorder=4)
        ax.text(x1 + 0.2, n - i, f'{d0.strftime("%d %b")} \u2013 {d1.strftime("%d %b")}', ha='left', va='center', fontsize=7, color='#444', zorder=4)
    days = [(start + datetime.timedelta(days=k)) for k in range((end - start).days + 1)]
    for d in days:
        if d.weekday() >= 5:
            ax.axvspan((d - start).days, (d - start).days + 1, color='#EFEFEF', zorder=1)
    for mname, md in milestones:
        dd = datetime.date.fromisoformat(md)
        x = (dd - start).days + 0.5
        ax.plot([x, x], [0.5, n + 0.5], color='#C00000', lw=1.1, ls='--', zorder=2)
        ax.plot(x, n - 0.25, marker='D', color='#C00000', ms=5, zorder=4)
        ax.text(x, n + 0.8, f'* {mname}\n{dd.strftime("%d %b")}', ha='center', va='bottom', fontsize=6.6, color='#C00000')
    ax.set_yticks([])
    ax.set_ylim(0.2, n + 1.6)
    ax.set_xlim(-0.5, (end - start).days + 1.2)
    ax.set_xticks([k for k in range((end - start).days + 1) if days[k].weekday() < 5])
    ax.set_xticklabels([days[k].strftime('%d %b') for k in range((end - start).days + 1) if days[k].weekday() < 5], fontsize=7, rotation=45, ha='right')
    ax.set_xlabel('Project timeline \u2014 03 August 2026 to 31 August 2026 (working days)', fontsize=9)
    ax.spines[['top', 'right', 'left']].set_visible(False)
    ax.grid(axis='x', color='#D0D0D0', lw=0.6, zorder=0)
    save(fig, path, 'Gantt Chart \u2013 Project Schedule')
    plt.close(fig)


# ================================================================ WIREFRAMES
def _chrome(ax, app_title):
    ax.set_xlim(0, 100); ax.set_ylim(0, 64)
    f = FancyBboxPatch((1, 1), 98, 62, boxstyle="round,pad=0.25,rounding_size=1.6",
                       fc='white', ec='#7F7F7F', lw=2.4, zorder=1)
    ax.add_patch(f)
    box_plain(ax, 3, 58.5, 94, 3, f'9:41   \u2022\u2022\u2022   {app_title}    \u2014  battery', fc=LGRAY, ec='none', fs=6)
    line(ax, 3, 58.2, 97, 58.2, color='#BFBFBF', lw=0.8)


def _wfbox(ax, x, y, w, h, label, fc=LBLUE, ec=BLUE, fs=6.5, bold=False, style='normal'):
    f = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0,rounding_size=0.4", fc=fc, ec=ec, lw=1.0, zorder=3)
    ax.add_patch(f)
    lines = label.split('\n')
    n = len(lines)
    if style == 'placeholder':
        for i in range(int(h)):
            pass
    start = y + h / 2 + (n - 1) * (fs * 0.22)
    for i, ln in enumerate(lines):
        text(ax, x + w / 2, start - i * (fs * 0.22), ln, fs=fs, bold=bold, color=DARK, zorder=4)


def _ann(ax, x, y, label, color=GRAY):
    text(ax, x, y, label, fs=5.6, color=color, style='italic')


def _btn(ax, x, y, w, h, label, fc=BLUE, fs=6.5):
    _wfbox(ax, x, y, w, h, label, fc=fc, ec=fc, fs=fs, bold=True)


def wf_login(path):
    fig, ax = new_fig(9, 6.5)
    _chrome(ax, 'Smart Child Tracking')
    box_plain(ax, 34, 44, 32, 8, 'SMART CHILD\nDAILY ACTIVITY TRACKING', fc=LBLUE, ec=BLUE, fs=8, bold=True)
    _wfbox(ax, 30, 34, 40, 4, 'Username', fc='white', ec='#9FB6C9', fs=6)
    _wfbox(ax, 30, 28, 40, 4, 'PIN / Password', fc='white', ec='#9FB6C9', fs=6)
    _btn(ax, 30, 21, 40, 5, 'LOGIN (Parent)', fs=7)
    _wfbox(ax, 30, 14, 40, 4, 'Switch to Child Mode', fc=LGRAY, ec=GRAY, fs=6)
    _ann(ax, 50, 9, 'Parent enters credentials; children use the child kiosk instead of logging in.')
    save(fig, path, 'Login / PIN Screen Wireframe')


def wf_parent_dash(path):
    fig, ax = new_fig(12, 7.5)
    _chrome(ax, 'Parent Dashboard')
    box_plain(ax, 3, 50, 26, 5, '  MENU', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    box_plain(ax, 33, 50, 26, 5, 'Good morning, Parent', fc=LBLUE, ec=BLUE, fs=6.5)
    box_plain(ax, 63, 50, 34, 5, 'Notifications (3)', fc=LORANGE, ec=ORANGE, fs=6.5)
    menu = ['Children', 'Tasks', 'Verification', 'Coins & Rewards', 'Badges', 'Reports', 'Messages', 'Settings']
    y = 44
    for m in menu:
        box_plain(ax, 3, y, 26, 4.2, m, fc='white', ec='#BFBFBF', fs=6)
        y -= 4.6
    box_plain(ax, 34, 30, 30, 18, 'Children overview\n[child cards: name, avatar,\ncoins, tasks today]', fc=LBLUE2, ec=BLUE2, fs=6.5)
    box_plain(ax, 68, 30, 29, 18, 'Pending approvals\n[task items with approve /\nreject buttons]', fc=LORANGE, ec=ORANGE, fs=6.5)
    box_plain(ax, 34, 8, 30, 18, 'Today\u2019s completion chart\n[bar chart placeholder]', fc=LGREEN, ec=GREEN, fs=6.5)
    box_plain(ax, 68, 8, 29, 18, 'Quick actions\n[+ Add child  + Add task\n+ Create reward]', fc=LGRAY, ec=GRAY, fs=6.5)
    _ann(ax, 50, 4.5, 'Left: navigation drawer \u00b7 Centre: overview widgets \u00b7 Right: approvals & quick actions')
    save(fig, path, 'Parent Dashboard Wireframe')


def wf_child_dash(path):
    fig, ax = new_fig(10, 7)
    _chrome(ax, 'Child Mode')
    box_plain(ax, 3, 50, 94, 5, 'Hi, Sara!  \u2014  today you have 4 tasks', fc=LGREEN, ec=GREEN, fs=7, bold=True)
    box_plain(ax, 3, 34, 30, 12, 'My Coins\n* 120', fc=LORANGE, ec=ORANGE, fs=8, bold=True)
    box_plain(ax, 36, 34, 30, 12, 'Badges\n* 5 earned', fc=LBLUE, ec=BLUE, fs=7, bold=True)
    box_plain(ax, 69, 34, 28, 12, 'Progress\n75% this week', fc=LGREEN, ec=GREEN, fs=7, bold=True)
    box_plain(ax, 3, 14, 94, 16, 'Today\u2019s tasks\n[ ] Brush teeth (daily)  * 10\n[ ] Homework (Mon\u2013Fri)  * 20\n[ ] Play outside (Thu)  * 15\n[x] Read a book  * 10  OK Verified', fc='white', ec='#9FB6C9', fs=6.5)
    _btn(ax, 34, 7, 32, 5, 'VIEW ALL TASKS', fs=6.5)
    _ann(ax, 50, 4, 'Child chooses their profile, sees only their own tasks and rewards.')
    save(fig, path, 'Child Dashboard Wireframe')


def wf_tasks(path):
    fig, ax = new_fig(10, 7)
    _chrome(ax, 'Tasks')
    box_plain(ax, 3, 50, 34, 5, '\u2190  Back   My Tasks', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    box_plain(ax, 41, 50, 56, 5, 'Filters:  All | Daily | Weekly | Monthly | Custom', fc=LGRAY, ec=GRAY, fs=6)
    items = [
        ('Brush Teeth', 'Daily \u00b7 * 10 \u00b7 Self-check', 'COMPLETE'),
        ('Homework', 'Mon\u2013Fri \u00b7 * 20 \u00b7 Parent approval', 'SUBMIT'),
        ('Jummah Prayer', 'Friday only \u00b7 * 25 \u00b7 Self-check', 'COMPLETE'),
        ('Play Outside', 'Thursday \u00b7 * 15 \u00b7 Self-check', 'COMPLETE'),
        ('Visit Grandparents', 'Sat & Sun \u00b7 * 30 \u00b7 Parent approval', 'SUBMIT'),
    ]
    y = 42
    for t, meta, act in items:
        box_plain(ax, 3, y, 66, 5.4, f'{t}\n{meta}', fc='white', ec='#9FB6C9', fs=6)
        _wfbox(ax, 72, y + 1, 25, 3.4, act, fc=GREEN, ec=GREEN, fs=5.5, bold=True)
        y -= 6.2
    _ann(ax, 50, 4.5, 'Each task shows schedule type, coins and verification type.')
    save(fig, path, 'Task Screen Wireframe')


def wf_reports(path):
    fig, ax = new_fig(12, 7.5)
    _chrome(ax, 'Reports')
    box_plain(ax, 3, 50, 30, 5, 'Reports & Analytics', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    box_plain(ax, 37, 50, 60, 5, 'Period:  Daily | Weekly | Monthly | Yearly', fc=LGRAY, ec=GRAY, fs=6)
    cards = [('Completed', '142'), ('Rejected', '6'), ('Pending', '9'), ('Missed', '11'), ('Coins', '1,240'), ('Badges', '18')]
    x = 3
    for lab, val in cards:
        box_plain(ax, x, 40, 15, 7, f'{val}\n{lab}', fc=LBLUE2, ec=BLUE2, fs=6.5, bold=True)
        x += 16
    box_plain(ax, 3, 8, 46, 28, 'Completion Rate chart\n(bar/line placeholder)', fc=LGREEN, ec=GREEN, fs=7)
    box_plain(ax, 53, 8, 44, 28, 'Child performance table\nTop Child: Sara \u2013 96%\n[per-child rows]', fc='white', ec='#9FB6C9', fs=6.5)
    _btn(ax, 68, 2, 29, 4, 'EXPORT / PRINT REPORT', fs=6)
    _ann(ax, 50, 4.5, 'Reports cover completed, rejected, pending and missed tasks with top-child ranking.')
    save(fig, path, 'Reports Screen Wireframe')


def wf_coins(path):
    fig, ax = new_fig(10, 7)
    _chrome(ax, 'Coins')
    box_plain(ax, 3, 50, 30, 5, 'Coin Wallet', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    box_plain(ax, 3, 34, 46, 12, 'Total balance\n* 1,240', fc=LORANGE, ec=ORANGE, fs=9, bold=True)
    box_plain(ax, 53, 34, 44, 12, 'Parent tools\n+ Add bonus coins\n\u2212 Remove coins\n(choose child & reason)', fc=LBLUE2, ec=BLUE2, fs=6.5)
    box_plain(ax, 3, 8, 94, 22, 'Transaction history\n+10  Brush Teeth (self-check)     3 Aug\n+20  Homework (approved)            2 Aug\n\u221210  Temporary coins removed       2 Aug\n+15  Bonus for helping               1 Aug', fc='white', ec='#9FB6C9', fs=6.5)
    _ann(ax, 50, 4.5, 'Every credit/debit is recorded in the ledger.')
    save(fig, path, 'Coins Screen Wireframe')


def wf_rewards(path):
    fig, ax = new_fig(10, 7)
    _chrome(ax, 'Rewards Shop')
    box_plain(ax, 3, 50, 30, 5, 'Rewards Shop', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    box_plain(ax, 37, 50, 60, 5, 'My balance: * 120', fc=LORANGE, ec=ORANGE, fs=6.5, bold=True)
    rewards = [('Ice Cream', '* 40', 'REDEEM'), ('Movie Night', '* 120', 'REDEEM'),
               ('Family Trip', '* 300', 'LOCKED'), ('Extra Play Time', '* 60', 'REDEEM'),
               ('Toy', '* 150', 'LOCKED')]
    y = 42
    for r, cost, act in rewards:
        box_plain(ax, 3, y, 60, 5, f'{r}  \u00b7  {cost}', fc='white', ec='#9FB6C9', fs=6)
        fc = GREEN if act == 'REDEEM' else GRAY
        _wfbox(ax, 68, y + 0.7, 29, 3.6, act, fc=fc, ec=fc, fs=5.5, bold=True)
        y -= 6.2
    _ann(ax, 50, 4.5, 'Redemptions request parent approval and deduct coins from the balance.')
    save(fig, path, 'Rewards Screen Wireframe')


def wf_settings(path):
    fig, ax = new_fig(10, 7)
    _chrome(ax, 'Settings')
    box_plain(ax, 3, 50, 30, 5, 'Settings', fc=LBLUE, ec=BLUE, fs=6.5, bold=True)
    rows = ['Change PIN / Password', 'Manage notifications & reminders', 'Task types & default coins',
            'Rewards & badge library', 'Offline sync status: CONNECTED OK', 'Backup data', 'About / Help']
    y = 42
    for r in rows:
        box_plain(ax, 3, y, 94, 4.4, r, fc='white', ec='#BFBFBF', fs=6)
        y -= 5.2
    _ann(ax, 50, 4.5, 'All settings are managed by the parent only.')
    save(fig, path, 'Settings Screen Wireframe')


def run(d):
    make_coin(d + '\\f15_coin_workflow.png')
    make_approval(d + '\\f16_approval_workflow.png')
    make_reward(d + '\\f17_reward_workflow.png')
    make_parent(d + '\\f18_parent_workflow.png')
    make_child(d + '\\f19_child_workflow.png')
    make_gantt(d + '\\f20_gantt_chart.png')
    wf_login(d + '\\f21_wireframe_login.png')
    wf_parent_dash(d + '\\f22_wireframe_parent_dashboard.png')
    wf_child_dash(d + '\\f23_wireframe_child_dashboard.png')
    wf_tasks(d + '\\f24_wireframe_tasks.png')
    wf_reports(d + '\\f25_wireframe_reports.png')
    wf_coins(d + '\\f26_wireframe_coins.png')
    wf_rewards(d + '\\f27_wireframe_rewards.png')
    wf_settings(d + '\\f28_wireframe_settings.png')
    print('Misc diagrams done:', d)
