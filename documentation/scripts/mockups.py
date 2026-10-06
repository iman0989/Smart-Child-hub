"""Render all 22 screen mockups for the Smart Child Hub design system."""
import os
import numpy as np
import ui_lib as U
import tokens as T

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'mockups')
os.makedirs(OUT, exist_ok=True)

P = T.LIGHT
A = T.ACCENT
S = T.STATUS
NAV_CHILD = [('home', 'Home'), ('tasks', 'Tasks'), ('trophy', 'Rewards'),
             ('badge', 'Badges'), ('person', 'Me')]
NAV_PARENT = [('home', 'Home'), ('tasks', 'Tasks'), ('person', 'Children'),
              ('chart', 'Reports'), ('gear', 'Settings')]

# ---------------------------------------------------------------- helpers
def task_row(ax, x, y, w, h, icon, ibg, title, subtitle, status, coins=0,
             checked=False, ic=7, z=3):
    U.card(ax, x, y, w, h, r=16, fc='#FFFFFF', level=1, zorder=z)
    U.icon_badge_circle(ax, x + h / 2, y + h / 2, h * 0.3, icon, ibg, ic=ic, zorder=z + 0.5)
    tx = x + h + 2
    U.text(ax, tx, y + 2.6, title, 'Quicksand', 12.5, 700, '#191A24', zorder=z + 1)
    U.text(ax, tx, y + h - 2.6, subtitle, 'Nunito', 9, 600, '#767685', zorder=z + 1)
    if checked:
        U.draw_icon(ax, 'check', x + w - 8, y + h / 2 - 2, 4, '#FFFFFF', zorder=z + 1)
        ax.add_patch(U.Circle((x + w - 6, y + h / 2), 3.2, fc='#2FAE66', ec='#FFFFFF', lw=1.2, zorder=z + 0.8))
    else:
        ax.add_patch(U.Circle((x + w - 6, y + h / 2), 3.2, fc='#FFFFFF', ec='#B9BAC6', lw=1.6, zorder=z + 0.8))
    st = S.get(status, '#8E8E99')
    tw = U.text_w(ax, status.upper(), 'Nunito', 7.5, 800)
    U.pill(ax, x + w - 6 - tw / 2 - 3.4, y + h / 2, tw + 6.8, 5.4,
           status.upper(), bg=U.hx(st, 0.14), fg=st, family='Nunito', size=7.5, weight=800, zorder=z + 1)
    if coins:
        U.coin_chip(ax, x + w - 8.5, y + h / 2 - 3.6, coins, h=5.6,
                    bg='#FFF7E0', fg='#8A5A00', size=3.8, zorder=z + 1)

def child_row(ax, x, y, w, h, avatar, color, name, subtitle, right='', coins=None,
              on=None, z=3):
    U.card(ax, x, y, w, h, r=16, fc='#FFFFFF', level=1, zorder=z)
    U.avatar(ax, x + h / 2, y + h / 2, h * 0.28, avatar, color, '#FFFFFF', size=h * 0.5, zorder=z + 0.5)
    tx = x + h + 1.5
    U.text(ax, tx, y + 2.8, name, 'Nunito', 13, 800, '#191A24', zorder=z + 1)
    U.text(ax, tx, y + h - 3.0, subtitle, 'Nunito', 9.5, 600, '#767685', zorder=z + 1)
    if right == 'chev':
        U.draw_icon(ax, 'chev_right', x + w - 6.5, y + h / 2 - 3, 6, '#767685', zorder=z + 1)
    elif right == 'edit':
        U.icon_badge_circle(ax, x + w - 8, y + h / 2, 5, 'edit', '#E9EAF6', fg='#43434F', ic=5.5, zorder=z + 1)
        U.icon_badge_circle(ax, x + w - 17, y + h / 2, 5, 'trash', '#FFE7E7', fg='#E5484D', ic=5.5, zorder=z + 1)
    if coins is not None:
        U.coin_chip(ax, x + w - 8.5, y + h / 2, coins, h=5.8, size=4, zorder=z + 1)
    if on is not None:
        U.toggle(ax, x + w - 16, y + h / 2 - 2.4, 13, 4.8, on=on, color='#2FAE66', zorder=z + 1)

def stat_card(ax, x, y, w, h, value, label, icon, color, vf='#191A24', z=3):
    U.card(ax, x, y, w, h, r=18, fc='#FFFFFF', level=1, zorder=z)
    U.icon_badge_circle(ax, x + w / 2, y + 8.2, 4.6, icon, U.hx(color, 0.13), fg=color, ic=4.6, zorder=z + 0.5)
    U.text(ax, x + w / 2, y + 14.6, value, 'Nunito', 21, 800, vf, ha='center', va='top', zorder=z + 1)
    U.text(ax, x + w / 2, y + h - 4.4, label, 'Nunito', 9, 600, '#767685', ha='center', va='center', zorder=z + 1)

def empty_state(ax, cx, cy, icon, title, subtitle, color='#B9BAC6'):
    U.icon_badge_circle(ax, cx, cy - 10, 9, icon, '#EEF0F8', fg=color, ic=9, zorder=3)
    U.text(ax, cx, cy - 0.5, title, 'Baloo 2', 17, 700, '#191A24', ha='center', va='center', zorder=4)
    for i, ln in enumerate(U.wrap(ax, subtitle, 'Nunito', 9.5, 600, 60, 2)):
        U.text(ax, cx, cy + 5 + i * 4.2, ln, 'Nunito', 9.5, 600, '#767685', ha='center', va='center', zorder=4)

def filter_chips(ax, x, y, items, active=0, w=100):
    cw = (w - 12) / len(items)
    for i, (label, icon) in enumerate(items):
        bg = P['primary'] if i == active else '#FFFFFF'
        fg = '#FFFFFF' if i == active else '#43434F'
        cx = x + cw * i + cw / 2
        U.pill(ax, cx, y, cw - 2.6, 7.2, label, bg=bg, fg=fg, family='Nunito',
               size=9.5, weight=700, icon=icon, ic=4.4, zorder=3)

def section_bar(ax, x, y, title, more=None, color='#191A24'):
    U.section(ax, x, y, title, more, color=color)

# ---------------------------------------------------------------- screens
def s_splash():
    fig, ax = U.canvas(gradient=('#4F6BF5', '#8A5BF5'))
    U.blob(ax, 12, 128, 22, 16, '#FFFFFF', 0.07, rot=30, zorder=0.5)
    U.blob(ax, 90, 16, 26, 20, '#FFFFFF', 0.06, rot=15, zorder=0.5)
    U.blob(ax, 88, 120, 16, 12, '#FFC93C', 0.12, rot=-20, zorder=0.5)
    U.draw_icon(ax, 'sparkle', 14, 20, 7, '#FFC93C', zorder=2)
    U.draw_icon(ax, 'sparkle', 82, 96, 5, '#FFFFFF', zorder=2)
    U.draw_icon(ax, 'sparkle', 24, 44, 4.5, '#C4F6E8', zorder=2)
    U.logo(ax, 50, 78, 17, text=None)
    U.text(ax, 50, 46, 'Smart Child Hub', 'Baloo 2', 34, 800, '#FFFFFF', ha='center', va='center', zorder=5)
    for i, ln in enumerate(U.wrap(ax, 'Your family\u2019s smart hub for happy daily habits',
                                  'Nunito', 12, 600, 62, 2)):
        U.text(ax, 50, 38.5 - i * 4.6, ln, 'Nunito', 12, 600, '#DDE5FF', ha='center', va='center', zorder=5)
    for i, a in enumerate((0.9, 0.5, 0.25)):
        U._circle(ax, 45 + i * 5, 16, 1.3, '#FFFFFF', zorder=5, alpha=a)
    U.text(ax, 50, 8, 'Made for happy little routines', 'Nunito', 8.5, 600, '#D6DCFE',
           ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '01_splash.png'))

def s_welcome():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.logo(ax, 50, 108, 13)
    U.text(ax, 50, 86, 'Welcome to Smart Child Hub!', 'Baloo 2', 26, 800, '#0E1E5C',
           ha='center', va='center', zorder=5)
    U.text(ax, 50, 79.5, 'Choose how you want to open the app', 'Nunito', 12, 600, '#767685',
           ha='center', va='center', zorder=5)
    U.card(ax, 10, 50, 80, 20, r=24, fc='#FFFFFF', level=2, zorder=3)
    U.icon_badge_circle(ax, 22, 58, 6.4, 'child', '#FFE0C7', fg='#FF8A3D', ic=7, zorder=4)
    U.text(ax, 31.5, 53.5, 'My Day', 'Baloo 2', 17, 700, '#191A24', zorder=5)
    U.text(ax, 31.5, 59.5, 'For kids \u2013 tasks, coins, badges & fun', 'Nunito', 9.5, 600, '#767685', zorder=5)
    U.pill(ax, 79, 60, 13, 6.4, 'Kids', bg='#FF8A3D', fg='#FFFFFF', size=9.5, weight=800, zorder=4)
    U.card(ax, 10, 26, 80, 20, r=24, fc='#FFFFFF', level=2, zorder=3)
    U.icon_badge_circle(ax, 22, 34, 6.4, 'parent', '#DDE5FF', fg='#4F6BF5', ic=7, zorder=4)
    U.text(ax, 31.5, 29.5, 'Family Manager', 'Nunito', 16, 800, '#191A24', zorder=5)
    U.text(ax, 31.5, 35.5, 'For parents \u2013 manage tasks, rewards & reports', 'Nunito', 9.5, 600, '#767685', zorder=5)
    U.pill(ax, 79, 36, 13, 6.4, 'Parents', bg='#4F6BF5', fg='#FFFFFF', size=9.5, weight=800, zorder=4)
    U.button(ax, 20, 10, 60, 9.6, 'Get Started', bg='#4F6BF5', icon='sparkle', ic=4.6, zorder=4)
    U.save(fig, os.path.join(OUT, '02_welcome.png'))

def s_choose_profile():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, "Who's playing?", subtitle='Pick a profile to start My Day', back=False)
    kids = [('M', '#FF8A3D', 'Mia', '6 years', 240, 0.72),
            ('L', '#54C3F6', 'Leo', '9 years', 180, 0.55),
            ('A', '#A98BFF', 'Ava', '4 years', 95, 0.30),
            ('N', '#3DDB9E', 'Noah', '11 years', 305, 0.88)]
    for i, (ini, col, nm, age, coins, pct) in enumerate(kids):
        col_i, row = i % 2, i // 2
        x = 10 + col_i * 43
        y = 104 - row * 34
        U.card(ax, x, y, 39, 29, r=22, fc='#FFFFFF', level=2, zorder=3)
        U.avatar(ax, x + 19.5, y + 10.5, 7, ini, col, size=12, zorder=4, ring='#E9EAF6', ring_lw=1.5)
        U.text(ax, x + 19.5, y + 20.5, nm, 'Baloo 2', 15, 700, '#191A24', ha='center', va='center', zorder=5)
        U.text(ax, x + 19.5, y + 25.6, age, 'Nunito', 9, 600, '#767685', ha='center', va='center', zorder=5)
        U.coin_chip(ax, x + 19.5, y + 3.0, coins, h=6.0, size=4.2, zorder=5)
    U.card(ax, 10, 36, 39, 29, r=22, fc='#FFF7E0', level=1, zorder=3)
    U.icon_badge_circle(ax, 29.5, 51.5, 6.4, 'add_child', '#FFE0C7', fg='#FF8A3D', ic=7, zorder=4)
    U.text(ax, 29.5, 43.5, 'Add a new child', 'Quicksand', 12, 700, '#8A5A00', ha='center', va='center', zorder=5)
    U.card(ax, 53, 36, 39, 29, r=22, fc='#FFFFFF', level=1, zorder=3)
    U.draw_icon(ax, 'lock', 68, 45.5, 8, '#4F6BF5', zorder=4)
    U.text(ax, 72.5, 53.5, 'Parent PIN', 'Nunito', 11, 800, '#191A24', ha='center', va='center', zorder=5)
    U.text(ax, 72.5, 59.5, 'Sign in as parent', 'Nunito', 8.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.button(ax, 20, 12, 60, 9.6, 'Continue as Mia', bg='#4F6BF5', icon='child', ic=4.6, zorder=4)
    U.save(fig, os.path.join(OUT, '03_choose_profile.png'))

def s_child_pin():
    fig, ax = U.canvas(gradient=('#F7F8FE', '#E6EBFF'))
    U.status_bar(ax, fg='#191A24')
    U.logo(ax, 50, 120, 10)
    U.text(ax, 50, 102, 'Hi Mia, welcome back!', 'Baloo 2', 22, 800, '#0E1E5C', ha='center', va='center', zorder=5)
    U.text(ax, 50, 95.5, 'Enter your 4-digit secret PIN', 'Nunito', 11, 600, '#767685', ha='center', va='center', zorder=5)
    U.icon_badge_circle(ax, 50, 84, 7, 'lock', '#4F6BF5', fg='#FFFFFF', ic=8, zorder=3)
    dots = [True, True, False, False]
    for i, on in enumerate(dots):
        U._circle(ax, 42 + i * 5.5, 70.5, 2.1 if on else 1.5, '#4F6BF5', alpha=1 if on else 0.3, zorder=4)
    keys = [('1', None), ('2', None), ('3', None), ('4', None), ('5', None), ('6', None),
            ('7', None), ('8', None), ('9', None), ('', 'star'), ('0', None), ('', 'back')]
    for i, (k, ic) in enumerate(keys):
        col, row = i % 3, i // 3
        cx = 26 + col * 24
        cy = 58 - row * 15
        if ic == 'star':
            U.draw_icon(ax, 'star', cx - 4.2, cy - 4.2, 8.4, '#FFC93C', zorder=4)
        elif ic == 'back':
            U.draw_icon(ax, 'chev_left', cx - 4.2, cy - 4.2, 8.4, '#767685', zorder=4)
        else:
            U.card(ax, cx - 9.4, cy - 9.4, 18.8, 18.8, r=10, fc='#FFFFFF', level=1, zorder=3)
            U.text(ax, cx, cy, k, 'Quicksand', 20, 700, '#191A24', ha='center', va='center', zorder=4)
    U.text(ax, 50, 8, 'Forgot PIN? Ask a parent', 'Nunito', 9.5, 600, '#4F6BF5', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '04_child_pin.png'))

def s_child_dashboard():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Good morning!', 'Mia', 240, coin_delta=15, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 80, 88, 14.5, r=22, fc='#FFFFFF', level=2, zorder=3)
    U.logo(ax, 17, 87.2, 5.4)
    U.text(ax, 25, 82.6, 'Great job today!', 'Baloo 2', 16, 700, '#191A24', zorder=5)
    U.text(ax, 25, 88.4, 'You finished 4 of 6 tasks', 'Nunito', 9.5, 600, '#767685', zorder=5)
    U.ring(ax, 83, 87.2, 5.4, 0.67, '#2FAE66', center_txt=('67%', 'today'), width=2.8, zorder=4)
    U.pill(ax, 31, 90.4, 12, 5.6, '5 day streak', bg='#FFF3D1', fg='#B26A00', icon='lightning', ic=3.4, zorder=5)
    section_bar(ax, 8, 76.2, 'My Tasks')
    U.text(ax, 92, 76.2, 'See all', 'Nunito', 10, 700, '#4F6BF5', ha='right', va='top', zorder=5)
    task_row(ax, 6, 63.4, 88, 11, 'water', '#D7F2E2', 'Drink water', '8:00 am \u00b7 Good morning', 'completed', coins=5, checked=True, z=3)
    task_row(ax, 6, 50.8, 88, 11, 'homework', '#DBE9FD', 'Finish math homework', '4:00 pm \u00b7 Learning', 'pending', coins=10, z=3)
    task_row(ax, 6, 38.2, 88, 11, 'run', '#F5E0D1', 'Play in the park', '6:00 pm \u00b7 Exercise', 'pending', coins=8, z=3)
    section_bar(ax, 8, 33.4, 'This Week')
    U.card(ax, 6, 18.5, 88, 13.6, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 11, 29.4, 'Coins earned', 'Nunito', 9, 700, '#767685', zorder=5)
    U.coin_chip(ax, 29, 29.4, 62, h=6.0, size=4.2, zorder=5)
    U.bars(ax, 11, 21.4, 54, 7.6, [4, 9, 6, 12, 8, 15, 11], '#4F6BF5',
           labels=['M', 'T', 'W', 'T', 'F', 'S', 'S'], radius=2.4, gap=1.4, zorder=4)
    U.card(ax, 62, 20.5, 27, 9.6, r=16, fc='#FFE0C7', level=1, zorder=3)
    U.text(ax, 75.5, 23.6, 'Goal this week', 'Nunito', 8, 700, '#8A5A00', ha='center', va='center', zorder=5)
    U.text(ax, 75.5, 28.0, '100', 'Nunito', 16, 800, '#FF8A3D', ha='center', va='center', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 0, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '05_child_dashboard.png'))

def s_task_screen():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Good morning!', 'Mia', 240, avatar_c='#FFC93C', avatar_l='M')
    filter_chips(ax, 6, 90.4, [('All', 'sparkle'), ('Today', 'sun'), ('Pending', 'clock'), ('Done', 'check')], active=1)
    section_bar(ax, 8, 83.6, 'Morning routine')
    U.text(ax, 92, 83.6, '2 / 3 done', 'Nunito', 9.5, 700, '#2FAE66', ha='right', va='top', zorder=5)
    task_row(ax, 6, 71.6, 88, 10.4, 'bed', '#F5E0D1', 'Make your bed', '7:30 am', 'completed', coins=5, checked=True)
    task_row(ax, 6, 59.8, 88, 10.4, 'water', '#D7F2E2', 'Drink a glass of water', '8:00 am', 'completed', coins=5, checked=True)
    task_row(ax, 6, 48.0, 88, 10.4, 'paint', '#FFE0C7', 'Brush your teeth', '8:15 am', 'pending', coins=5)
    section_bar(ax, 8, 41.6, 'Learning & fun')
    task_row(ax, 6, 29.8, 88, 10.4, 'homework', '#DBE9FD', 'Finish math homework', '4:00 pm', 'pending', coins=10)
    task_row(ax, 6, 18.0, 88, 10.4, 'book', '#D8F3FB', 'Read 15 minutes', '7:00 pm', 'locked', coins=8)
    U.bottom_nav(ax, NAV_CHILD, 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '06_task_screen.png'))

def s_rewards():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'Your rewards', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 80, 88, 12.5, r=22, fc='#4F6BF5', level=2, zorder=3)
    U.gradient_rect(ax, 6, 80, 88, 12.5, 22, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 12, 83.2, 'Saving for', 'Nunito', 9, 700, '#C4F6E8', zorder=5)
    U.text(ax, 12, 87.0, 'Weekend movie night', 'Quicksand', 14, 700, '#FFFFFF', zorder=5)
    U.coin_chip(ax, 68, 84.4, 160, h=7.4, bg='#FFFFFF', fg='#0E1E5C', size=5, zorder=5)
    U.text(ax, 70, 89.8, 'of 300', 'Nunito', 8, 600, '#D6DCFE', ha='center', va='center', zorder=5)
    U.hbar(ax, 10, 90.6, 80, 2.8, 0.53, '#FFC93C', track=U.hx('#FFFFFF', 0.25), r=1.4, zorder=4)
    section_bar(ax, 8, 75.0, 'Top rewards')
    U.text(ax, 92, 75.0, 'See all', 'Nunito', 10, 700, '#4F6BF5', ha='right', va='top', zorder=5)
    rewards = [('film', 'Weekend movie night', 300, '#A98BFF', 0.53),
               ('food', 'Ice cream date', 150, '#FF7BA9', 0.9),
               ('pets', 'Pet the neighbour\u2019s puppy', 200, '#FFB37A', 0.0),
               ('music', 'Karaoke night', 250, '#54C3F6', 0.2)]
    for i, (icon, nm, cost, col, pct) in enumerate(rewards):
        col_i, row = i % 2, i // 2
        x = 6 + col_i * 45
        y = 60.5 - row * 22.5
        U.card(ax, x, y, 43, 21, r=20, fc='#FFFFFF', level=2, zorder=3)
        U.icon_badge_circle(ax, x + 21.5, y + 7.4, 5.2, icon, U.hx(col, 0.16), fg=col, ic=5.6, zorder=4)
        U.text(ax, x + 21.5, y + 14.4, nm, 'Quicksand', 11.5, 700, '#191A24', ha='center', va='center', zorder=5)
        locked = pct <= 0.01
        if locked:
            U.pill(ax, x + 21.5, y + 18.4, 15, 5.4, 'Locked', bg='#E9EAF6', fg='#767685', icon='lock', ic=3.4, zorder=5)
        else:
            U.coin_chip(ax, x + 21.5, y + 18.4, cost, h=5.6, size=3.8, bg='#FFF7E0', fg='#8A5A00', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 2, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '07_rewards.png'))

def s_coins():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'My coins', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 79, 88, 16, r=22, fc='#FFFFFF', level=2, zorder=3)
    U._circle(ax, 22, 88, 6.4, '#FFC93C', zorder=4)
    U._circle(ax, 22, 88, 3.6, '#FFB800', zorder=4.2)
    U.draw_icon(ax, 'star', 20.6, 86.6, 2.8, '#FFFFFF', zorder=5)
    U.text(ax, 34, 82.2, 'Total balance', 'Nunito', 9.5, 700, '#767685', zorder=5)
    U.text(ax, 34, 86.2, '240', 'Nunito', 26, 800, '#0E1E5C', zorder=5)
    U.pill(ax, 34, 92.2, 17, 6, '+ 62 this week', bg='#D7F2E2', fg='#2FAE66', icon='lightning', ic=3.6, zorder=5)
    section_bar(ax, 8, 73.6, 'Coin history')
    entries = [('check', '#2FAE66', 'Brush teeth task', 'Today \u00b7 8:02 am', 10, True),
               ('star', '#A98BFF', 'Morning star badge', 'Today \u00b7 8:15 am', 25, True),
               ('homework', '#FFB37A', 'Math homework done', 'Yesterday \u00b7 4:10 pm', 10, True),
               ('food', '#FF7BA9', 'Ice cream date', 'Mon \u00b7 5:30 pm', -150, False)]
    for i, (icon, col, nm, sub, amt, pos) in enumerate(entries):
        y = 62.5 - i * 12.6
        U.card(ax, 6, y, 88, 11, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.5, 4.6, icon, U.hx(col, 0.15), fg=col, ic=4.8, zorder=4)
        U.text(ax, 20, y + 2.4, nm, 'Quicksand', 11.5, 700, '#191A24', zorder=5)
        U.text(ax, 20, y + 8.2, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        U.text(ax, 89, y + 5.5, ('+%d' % amt) if pos else ('-%d' % -amt),
               'Nunito', 12, 800, '#2FAE66' if pos else '#E5484D', ha='right', va='center', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 2, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '08_coins.png'))

def s_badges():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'My badges', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 79.5, 88, 12.5, r=22, fc='#4F6BF5', level=2, zorder=3)
    U.gradient_rect(ax, 6, 79.5, 88, 12.5, 22, '#4F6BF5', '#7A5BF5', zorder=3)
    U.icon_badge_circle(ax, 17, 85.8, 5.4, 'medal', '#FFC93C', fg='#FFFFFF', ic=6, zorder=4)
    U.text(ax, 25, 82.4, 'New badge unlocked!', 'Quicksand', 14, 700, '#FFFFFF', zorder=5)
    U.text(ax, 25, 88.0, 'Early Bird \u2013 5 morning tasks', 'Nunito', 9.5, 600, '#D6DCFE', zorder=5)
    U.pill(ax, 86, 85.8, 13, 6.4, 'Collect', bg='#FFC93C', fg='#45260A', size=9, weight=800, zorder=5)
    section_bar(ax, 8, 74.2, 'Collection')
    U.text(ax, 92, 74.2, '6 / 12', 'Nunito', 10, 700, '#767685', ha='right', va='top', zorder=5)
    badges = [('sun', 'Morning Star', '#F2B705', True), ('water', 'Hydration Hero', '#3FB9E0', True),
              ('homework', 'Bookworm', '#A98BFF', True), ('run', 'Energy Burst', '#FF7BA9', True),
              ('star', 'First Steps', '#C98A5B', True), ('sparkle', 'Shining Star', '#E8A500', False),
              ('trophy', 'Champion', '#9AA4B5', False), ('heart', 'Kind Heart', '#FFB37A', False),
              ('plants', 'Green Thumb', '#3DDB9E', False), ('paint', 'Little Artist', '#54C3F6', False)]
    for i, (icon, nm, col, on) in enumerate(badges):
        col_i, row = i % 4, i // 4
        x = 8 + col_i * 22
        y = 62 - row * 18.5
        U.card(ax, x, y - 5, 19.5, 17.5, r=16, fc='#FFFFFF', level=1, zorder=3)
        if on:
            U.icon_badge_circle(ax, x + 9.75, y - 0.5, 4.6, icon, col, fg='#FFFFFF', ic=5, zorder=4)
            U.text(ax, x + 9.75, y + 6.0, nm, 'Nunito', 6.5, 700, '#191A24', ha='center', va='center', zorder=5)
        else:
            U.icon_badge_circle(ax, x + 9.75, y - 0.5, 4.6, icon, '#EEF0F8', fg='#B9BAC6', ic=5, zorder=4)
            U.text(ax, x + 9.75, y + 6.0, nm, 'Nunito', 6.5, 700, '#B9BAC6', ha='center', va='center', zorder=5)
            U.draw_icon(ax, 'lock', x + 6.9, y - 3.6, 5.6, '#B9BAC6', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 3, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '09_badges.png'))

def s_achievements():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'Achievements', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 80.5, 88, 12.5, r=22, fc='#FFFFFF', level=2, zorder=3)
    U.text(ax, 11, 83.0, 'Your progress', 'Nunito', 9, 700, '#767685', zorder=5)
    U.text(ax, 11, 87.6, '4 of 6 goals done this week', 'Quicksand', 13, 700, '#191A24', zorder=5)
    U.ring(ax, 30, 87.2, 5.2, 0.72, '#4F6BF5', center_txt=('72%', 'tasks'), width=3, zorder=4)
    U.ring(ax, 48, 87.2, 5.2, 0.5, '#FF8A3D', center_txt=('5', 'streak'), width=3, zorder=4)
    U.ring(ax, 66, 87.2, 5.2, 0.84, '#FFC93C', center_txt=('84%', 'coins'), width=3, zorder=4)
    section_bar(ax, 8, 75.6, 'Milestones')
    rows = [('water', 'Drink water for 7 days', 5, 7, 'D7F2E2', '#2FAE66', True),
            ('homework', 'Finish homework 10 times', 8, 10, 'DBE9FD', '#4F6BF5', False),
            ('run', 'Play outside 15 days', 12, 15, 'F5E0D1', '#FF8A3D', False),
            ('trophy', 'Complete 50 tasks', 38, 50, 'FCEFC8', '#E8A500', False)]
    for i, (icon, nm, cur, total, bg, col, done) in enumerate(rows):
        y = 63.5 - i * 12.0
        U.card(ax, 6, y, 88, 10.4, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.2, 4.4, icon, U.hx(col, 0.13), fg=col, ic=4.6, zorder=4)
        U.text(ax, 20, y + 2.2, nm, 'Quicksand', 11.5, 700, '#191A24', zorder=5)
        U.text(ax, 20, y + 7.6, 'Reward +25 coins', 'Nunito', 8, 600, '#767685', zorder=5)
        U.hbar(ax, 66, y + 5.2, 26, 2.6, cur / total, col, r=1.3, zorder=4)
        U.text(ax, 91, y + 5.2, '%d/%d' % (cur, total), 'Nunito', 8.5, 800, '#191A24', ha='right', va='center', zorder=5)
        if done:
            U.draw_icon(ax, 'check', 92.5, y + 5.2 - 2, 4, '#2FAE66', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 3, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '10_achievements.png'))

def s_messages():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'Messages', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 82.5, 88, 10.5, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.avatar(ax, 14, 87.8, 4.8, 'D', '#54C3F6', size=8, zorder=4)
    U.text(ax, 21, 84.2, 'Mom', 'Quicksand', 12, 700, '#191A24', zorder=5)
    U.text(ax, 21, 89.0, 'Great job today sweetie!', 'Nunito', 9, 600, '#767685', zorder=5)
    U.pill(ax, 86, 87.8, 9, 5, '3', bg='#4F6BF5', fg='#FFFFFF', size=8, weight=800, zorder=5)
    U.text(ax, 8, 79.6, 'Today', 'Nunito', 9, 700, '#B9BAC6', zorder=5)
    U._rr(ax, 16, 62.5, 46, 14, 14, fc='#FFFFFF', zorder=3)
    U.text(ax, 20, 65.2, 'Mommy I finished my homework!', 'Nunito', 9.5, 600, '#191A24', zorder=5)
    U.text(ax, 20, 72.2, 'Can we watch a movie tonight?', 'Nunito', 9.5, 600, '#191A24', zorder=5)
    U.text(ax, 58, 74.6, '4:02 PM', 'Nunito', 7.5, 600, '#767685', ha='right', va='center', zorder=5)
    U.gradient_rect(ax, 42, 40.5, 46, 18, 14, '#4F6BF5', '#5E7BFF', zorder=3)
    U.text(ax, 46, 42.8, 'Of course! You earned it', 'Nunito', 9.5, 600, '#FFFFFF', zorder=5)
    U.text(ax, 46, 47.5, 'Movie night at 7pm it is!', 'Nunito', 9.5, 600, '#FFFFFF', zorder=5)
    U.text(ax, 84, 56.6, '4:08 PM', 'Nunito', 7.5, 600, '#C4F6E8', ha='right', va='center', zorder=5)
    U._rr(ax, 22, 24.5, 42, 10.5, 14, fc='#FFFFFF', zorder=3)
    U.text(ax, 26, 27.0, 'Yay! Can Leo join too?', 'Nunito', 9.5, 600, '#191A24', zorder=5)
    U._rr(ax, 6, 16.8, 88, 7, 12, fc='#FFFFFF', ec='#E9EAF6', lw=1, zorder=3)
    U.draw_icon(ax, 'send', 78, 18.3, 4.4, '#4F6BF5', zorder=4)
    U.text(ax, 10, 17.8, 'Type a message...', 'Nunito', 9, 600, '#B9BAC6', zorder=5)
    U.bottom_nav(ax, [('home', 'Home'), ('message', 'Chats'), ('trophy', 'Rewards'), ('badge', 'Badges'), ('person', 'Me')], 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '11_messages.png'))

def s_reports_child():
    fig, ax = U.canvas(bg=P['background'])
    U.status_bar(ax)
    U.header_child(ax, 'Hi Mia!', 'My reports', 240, avatar_c='#FFC93C', avatar_l='M')
    U.card(ax, 6, 80.5, 88, 12.5, r=22, fc='#4F6BF5', level=2, zorder=3)
    U.gradient_rect(ax, 6, 80.5, 88, 12.5, 22, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 12, 83.4, 'This week summary', 'Nunito', 9, 700, '#C4F6E8', zorder=5)
    U.text(ax, 12, 88.2, 'You were a superstar!', 'Quicksand', 15, 700, '#FFFFFF', zorder=5)
    U.pill(ax, 80, 86.8, 14, 6.2, 'Week', bg='#FFFFFF', fg='#4F6BF5', icon='calendar', ic=3.6, zorder=5)
    stat_card(ax, 6, 64.5, 28.6, 13.5, '24', 'Tasks done', 'tasks', '#2FAE66')
    stat_card(ax, 37.4, 64.5, 28.6, 13.5, '5', 'Day streak', 'lightning', '#FF9F0A')
    stat_card(ax, 68.8, 64.5, 25.2, 13.5, '62', 'Coins', 'coin', '#E8A500')
    section_bar(ax, 8, 59.8, 'Tasks per day')
    U.card(ax, 6, 44.5, 88, 13, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.bars(ax, 10, 48, 80, 7, [4, 6, 3, 7, 5, 8, 6], '#4F6BF5',
           labels=['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], radius=2, gap=2.4, zorder=4)
    section_bar(ax, 8, 39.4, 'Task results')
    U.card(ax, 6, 25.5, 88, 12.5, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.donut(ax, 22, 31.8, 5.6, [0.55, 0.25, 0.12, 0.08], ['#2FAE66', '#FF9F0A', '#E5484D', '#B9BAC6'], 3.2, zorder=4)
    legend = [('#2FAE66', 'Completed', '55%'), ('#FF9F0A', 'Pending', '25%'),
              ('#E5484D', 'Missed', '12%'), ('#B9BAC6', 'Locked', '8%')]
    for i, (col, nm, pct) in enumerate(legend):
        U._circle(ax, 45, 29.5 + i * 3.4, 1.3, col, zorder=4)
        U.text(ax, 48, 29.5 + i * 3.4, nm, 'Nunito', 9, 700, '#191A24', va='center', zorder=5)
        U.text(ax, 89, 29.5 + i * 3.4, pct, 'Nunito', 9, 700, '#767685', ha='right', va='center', zorder=5)
    U.bottom_nav(ax, NAV_CHILD, 0, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '12_reports_child.png'))

def s_parent_login():
    fig, ax = U.canvas(gradient=('#F7F8FE', '#E6EBFF'))
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.logo(ax, 50, 116, 11)
    U.text(ax, 50, 96, 'Family Manager', 'Baloo 2', 24, 800, '#0E1E5C', ha='center', va='center', zorder=5)
    U.text(ax, 50, 89.5, 'Sign in to manage your family', 'Nunito', 11, 600, '#767685', ha='center', va='center', zorder=5)
    U.card(ax, 12, 32, 76, 52, r=26, fc='#FFFFFF', level=3, zorder=3)
    U.text(ax, 18, 78, 'Parent PIN', 'Nunito', 12, 800, '#191A24', zorder=5)
    U.text(ax, 18, 74.6, 'Only parents can open this area', 'Nunito', 9, 600, '#767685', zorder=5)
    U.card(ax, 18, 60, 64, 11, r=16, fc='#EEF0F8', level=0, zorder=4)
    for i, on in enumerate([True, True, True, False]):
        U._circle(ax, 27 + i * 7.5, 65.6, 1.7, '#191A24' if on else '#C7C8D4', zorder=5)
    U.draw_icon(ax, 'eye', 76, 62.6, 6.4, '#767685', zorder=5)
    U.button(ax, 18, 46, 64, 9.6, 'Sign in', bg='#4F6BF5', icon='lock', ic=4.4, zorder=4)
    U.text(ax, 50, 38.5, 'Forgot PIN? Reset with the master key', 'Nunito', 8.5, 600, '#4F6BF5', ha='center', va='center', zorder=5)
    U.pill(ax, 50, 18, 26, 6.6, 'Kids mode', bg='#FFE0C7', fg='#FF8A3D', icon='child', ic=4, zorder=4)
    U.text(ax, 50, 9, 'Children don\u2019t need an account', 'Nunito', 8.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '13_parent_login.png'))

def s_parent_dashboard():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax, a='#DDE5FF', b='#D8F3FB', c='#D7F2E2')
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Family Dashboard', subtitle='Mon, 3 Aug 2026', back=False, bell=3)
    stat_card(ax, 6, 110, 28.6, 13, '42', 'Tasks done', 'tasks', '#4F6BF5')
    stat_card(ax, 37.4, 110, 28.6, 13, '81%', 'On time', 'clock', '#2FAE66')
    stat_card(ax, 68.8, 110, 25.2, 13, '8', 'Pending', 'bell', '#FF9F0A')
    section_bar(ax, 8, 104.8, 'Today\u2019s progress')
    U.card(ax, 6, 89, 88, 13.5, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.bars(ax, 10, 92.4, 80, 7.2, [2, 5, 4, 8, 6, 9, 7], '#4F6BF5',
           labels=['M', 'T', 'W', 'T', 'F', 'S', 'S'], radius=2, gap=2.4, zorder=4)
    section_bar(ax, 8, 84.2, 'Children')
    kids = [('M', '#FF8A3D', 'Mia', '4 tasks \u00b7 240 coins', 0.72, True),
            ('L', '#54C3F6', 'Leo', '2 tasks \u00b7 180 coins', 0.55, True)]
    for i, (ini, col, nm, sub, pct, act) in enumerate(kids):
        y = 70.5 - i * 14.5
        U.card(ax, 6, y, 88, 12.6, r=18, fc='#FFFFFF', level=1, zorder=3)
        U.avatar(ax, 14.5, y + 6.3, 5.4, ini, col, size=9, zorder=4)
        U.text(ax, 22.5, y + 2.8, nm, 'Nunito', 13, 800, '#191A24', zorder=5)
        U.text(ax, 22.5, y + 8.2, sub, 'Nunito', 9.5, 600, '#767685', zorder=5)
        U.ring(ax, 78, y + 6.3, 4.4, pct, '#2FAE66', center_txt=(str(int(pct * 100)) + '%', ''), width=2.6, zorder=4)
        U.draw_icon(ax, 'chev_right', 87, y + 3.3, 6, '#767685', zorder=5)
    section_bar(ax, 8, 52.2, 'Needs approval')
    U.card(ax, 6, 37.5, 88, 11.4, r=18, fc='#FFF3D1', level=1, zorder=3)
    U.icon_badge_circle(ax, 13.5, 43.2, 4.8, 'homework', '#FFE0C7', fg='#FF9F0A', ic=5, zorder=4)
    U.text(ax, 21, 39.6, 'Mia finished math homework', 'Nunito', 11.5, 800, '#45260A', zorder=5)
    U.text(ax, 21, 45.0, 'Waiting for your check \u00b7 2:10 pm', 'Nunito', 9, 600, '#B26A00', zorder=5)
    U.pill(ax, 84, 43.2, 13, 6, 'Review', bg='#FF9F0A', fg='#FFFFFF', size=9.5, weight=800, zorder=5)
    U.bottom_nav(ax, NAV_PARENT, 0, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '14_parent_dashboard.png'))

def s_manage_children():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Manage Children', subtitle='Profiles & balances', back=True)
    U.card(ax, 6, 110, 88, 9.6, r=16, fc='#FFFFFF', level=1, zorder=3)
    U.draw_icon(ax, 'search', 10.6, 113.2, 4.4, '#767685', zorder=4)
    U.text(ax, 17, 114.9, 'Search children', 'Nunito', 9.5, 600, '#B9BAC6', zorder=5)
    kids = [('M', '#FF8A3D', 'Mia', '6 years old', 240, True),
            ('L', '#54C3F6', 'Leo', '9 years old', 180, True),
            ('A', '#A98BFF', 'Ava', '4 years old', 95, True)]
    for i, (ini, col, nm, sub, coins, act) in enumerate(kids):
        y = 96.5 - i * 14.5
        child_row(ax, 6, y, 88, 12.6, ini, col, nm, sub, right='edit', coins=coins)
    U.card(ax, 6, 38.5, 88, 12.6, r=18, fc='#FFF7E0', level=1, zorder=3)
    U.icon_badge_circle(ax, 14.5, 44.8, 5.4, 'add_child', '#FFE0C7', fg='#FF8A3D', ic=5.8, zorder=4)
    U.text(ax, 23, 41.0, 'Add a new child', 'Nunito', 12.5, 800, '#8A5A00', zorder=5)
    U.text(ax, 23, 46.4, 'Create a profile with a fun avatar', 'Nunito', 9, 600, '#B26A00', zorder=5)
    U.draw_icon(ax, 'chev_right', 89, 41.8, 6, '#FF8A3D', zorder=5)
    U.fab(ax, 86, 20, 6.4, color='#FF8A3D')
    U.text(ax, 50, 26, 'Each child gets their own PIN', 'Nunito', 9, 600, '#767685', ha='center', va='center', zorder=5)
    U.bottom_nav(ax, NAV_PARENT, 2, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '15_manage_children.png'))

def s_manage_tasks():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Manage Tasks', subtitle='Routines for all children', back=True)
    filter_chips(ax, 6, 110, [('All', 'sparkle'), ('Morning', 'sun'), ('Evening', 'moon'), ('Done', 'check')], active=0)
    section_bar(ax, 8, 103.6, 'Morning routine')
    rows = [('bed', '#F5E0D1', 'Make your bed', 'Mia & Leo \u00b7 7:30 am \u00b7 +5 coins', 'verified'),
            ('water', '#D7F2E2', 'Drink a glass of water', 'All children \u00b7 8:00 am \u00b7 +5 coins', 'active'),
            ('paint', '#FFE0C7', 'Brush your teeth', 'All children \u00b7 8:15 am \u00b7 +5 coins', 'active')]
    for i, (icon, bg, nm, sub, st) in enumerate(rows):
        y = 91.5 - i * 12.8
        U.card(ax, 6, y, 88, 11, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.5, 4.6, icon, bg, fg='#191A24', ic=4.8, zorder=4)
        U.text(ax, 20, y + 2.4, nm, 'Nunito', 11.5, 800, '#191A24', zorder=5)
        U.text(ax, 20, y + 8.0, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        U.draw_icon(ax, 'edit', 82, y + 3.5, 4.6, '#43434F', zorder=5)
        U.draw_icon(ax, 'trash', 89, y + 3.5, 4.6, '#E5484D', zorder=5)
        st_c = S.get(st, '#8E8E99')
        U.pill(ax, 80, y + 2.6, 13, 5, st.upper(), bg=U.hx(st_c, 0.14), fg=st_c, size=7, weight=800, zorder=5)
    section_bar(ax, 8, 50.5, 'Evening routine')
    rows2 = [('book', '#D8F3FB', 'Read 15 minutes', 'All children \u00b7 7:00 pm \u00b7 +8 coins', 'active'),
             ('bed', '#E9EAF6', 'Go to bed on time', 'All children \u00b7 8:30 pm \u00b7 +6 coins', 'paused')]
    for i, (icon, bg, nm, sub, st) in enumerate(rows2):
        y = 38.8 - i * 12.8
        U.card(ax, 6, y, 88, 11, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.5, 4.6, icon, bg, fg='#191A24', ic=4.8, zorder=4)
        U.text(ax, 20, y + 2.4, nm, 'Nunito', 11.5, 800, '#191A24', zorder=5)
        U.text(ax, 20, y + 8.0, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        U.draw_icon(ax, 'edit', 82, y + 3.5, 4.6, '#43434F', zorder=5)
        U.draw_icon(ax, 'trash', 89, y + 3.5, 4.6, '#E5484D', zorder=5)
        st_c = '#8E8E99'
        U.pill(ax, 80, y + 2.6, 13, 5, st.upper(), bg=U.hx(st_c, 0.14), fg=st_c, size=7, weight=800, zorder=5)
    U.fab(ax, 86, 20, 6.4, color='#4F6BF5')
    U.bottom_nav(ax, NAV_PARENT, 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '16_manage_tasks.png'))

def s_pending_approval():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Pending Approval', subtitle='3 tasks waiting for you', back=True)
    U.card(ax, 6, 110, 88, 11, r=18, fc='#FFF3D1', level=1, zorder=3)
    U.draw_icon(ax, 'info', 11.5, 113.2, 4.6, '#FF9F0A', zorder=4)
    U.text(ax, 18, 114.9, 'Approved tasks add coins automatically', 'Nunito', 9.5, 700, '#B26A00', zorder=5)
    items = [('M', '#FF8A3D', 'Mia', 'Brush teeth', 'Today \u00b7 8:15 am \u00b7 +5 coins', 'water'),
             ('L', '#54C3F6', 'Leo', 'Math homework', 'Today \u00b7 4:05 pm \u00b7 +10 coins', 'homework'),
             ('M', '#FF8A3D', 'Mia', 'Read 15 minutes', 'Today \u00b7 7:02 pm \u00b7 +8 coins', 'book')]
    for i, (ini, col, who, nm, sub, icon) in enumerate(items):
        y = 94.5 - i * 24.5
        U.card(ax, 6, y, 88, 22.5, r=20, fc='#FFFFFF', level=2, zorder=3)
        U.avatar(ax, 14.5, y + 16.5, 5.2, ini, col, size=9, zorder=4)
        U.text(ax, 22.5, y + 4.5, who + ' \u00b7 ' + nm, 'Nunito', 12.5, 800, '#191A24', zorder=5)
        U.text(ax, 22.5, y + 10.2, sub, 'Nunito', 9, 600, '#767685', zorder=5)
        U.icon_badge_circle(ax, 78, y + 7.5, 5.2, icon, '#EEF0F8', fg='#43434F', ic=5.6, zorder=4)
        U.button(ax, 12, y + 15.2, 40, 6.6, 'Approve +%d' % (5 if i == 0 else (10 if i == 1 else 8)),
                 bg='#2FAE66', size=10, r=8, zorder=4)
        U.button(ax, 54, y + 15.2, 36, 6.6, 'Reject', bg='#FFFFFF', fg='#E5484D', ec='#FFDAD6', size=10, r=8, zorder=4)
    U.bottom_nav(ax, NAV_PARENT, 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '17_pending_approval.png'))

def s_rewards_management():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Rewards', subtitle='Manage the reward shop', back=True)
    filter_chips(ax, 6, 110, [('All', 'sparkle'), ('Active', 'check'), ('Paused', 'moon')], active=0)
    section_bar(ax, 8, 103.4, 'Available rewards')
    rows = [('film', '#A98BFF', 'Weekend movie night', '300 coins \u00b7 Shared', True),
            ('food', '#FF7BA9', 'Ice cream date', '150 coins \u00b7 Mia', True),
            ('music', '#54C3F6', 'Karaoke night', '250 coins \u00b7 Shared', True),
            ('pets', '#FFB37A', 'Walk the puppy', '120 coins \u00b7 Leo', False)]
    for i, (icon, bg, nm, sub, on) in enumerate(rows):
        y = 91.4 - i * 13.0
        U.card(ax, 6, y, 88, 11.2, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.6, 4.8, icon, U.hx(bg, 0.16), fg=bg, ic=5, zorder=4)
        U.text(ax, 20, y + 2.4, nm, 'Nunito', 11.5, 800, '#191A24', zorder=5)
        U.text(ax, 20, y + 8.2, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        U.draw_icon(ax, 'edit', 78, y + 3.6, 4.6, '#43434F', zorder=5)
        U.draw_icon(ax, 'trash', 84, y + 3.6, 4.6, '#E5484D', zorder=5)
        U.toggle(ax, 87, y + 3.4, 12, 4.6, on=on, color='#2FAE66', zorder=5)
    U.fab(ax, 86, 20, 6.4, color='#4F6BF5')
    U.text(ax, 50, 26, 'Coins are awarded when tasks are approved', 'Nunito', 9, 600, '#767685', ha='center', va='center', zorder=5)
    U.bottom_nav(ax, NAV_PARENT, 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '18_rewards_management.png'))

def s_coin_management():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Coin Management', subtitle='Adjust balances safely', back=True)
    U.card(ax, 6, 109, 88, 11.5, r=20, fc='#4F6BF5', level=2, zorder=3)
    U.gradient_rect(ax, 6, 109, 88, 11.5, 20, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 12, 112.0, 'Total family balance', 'Nunito', 9, 700, '#C4F6E8', zorder=5)
    U.text(ax, 12, 117.0, '515', 'Nunito', 22, 800, '#FFFFFF', zorder=5)
    U.draw_icon(ax, 'coin', 50, 112.5, 5.6, '#FFC93C', zorder=5)
    U.pill(ax, 76, 114.8, 19, 6.2, '+ 3 this week', bg='#FFC93C', fg='#45260A', icon='lightning', ic=3.6, zorder=5)
    section_bar(ax, 8, 103.2, 'Adjust per child')
    kids = [('M', '#FF8A3D', 'Mia', 240), ('L', '#54C3F6', 'Leo', 180), ('A', '#A98BFF', 'Ava', 95)]
    for i, (ini, col, nm, coins) in enumerate(kids):
        y = 91.2 - i * 14.2
        U.card(ax, 6, y, 88, 12.4, r=18, fc='#FFFFFF', level=1, zorder=3)
        U.avatar(ax, 14.5, y + 6.2, 5.2, ini, col, size=9, zorder=4)
        U.text(ax, 22, y + 2.6, nm, 'Nunito', 13, 800, '#191A24', zorder=5)
        U.text(ax, 22, y + 8.0, 'Current balance', 'Nunito', 9, 600, '#767685', zorder=5)
        U.coin_chip(ax, 64, y + 6.2, coins, h=6.2, size=4.2, zorder=5)
        U.icon_badge_circle(ax, 76, y + 6.2, 4.4, 'minus', '#FFE7E7', fg='#E5484D', ic=4.6, zorder=4)
        U.icon_badge_circle(ax, 84.5, y + 6.2, 4.4, 'plus', '#D7F2E2', fg='#2FAE66', ic=4.6, zorder=4)
    U.button(ax, 20, 24, 60, 9.6, 'Save changes', bg='#4F6BF5', icon='check', ic=4.4, zorder=4)
    U.text(ax, 50, 18.5, 'Changes apply to both the balance and history', 'Nunito', 8.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.bottom_nav(ax, NAV_PARENT, 1, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '19_coin_management.png'))

def s_reports_parent():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax, a='#DDE5FF', b='#D8F3FB', c='#D7F2E2')
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Reports', subtitle='Insights across the family', back=True)
    filter_chips(ax, 6, 110, [('Week', 'calendar'), ('Month', 'chart'), ('All time', 'trophy')], active=0)
    stat_card(ax, 6, 98, 28.6, 11.5, '42', 'Tasks done', 'tasks', '#4F6BF5')
    stat_card(ax, 37.4, 98, 28.6, 11.5, '81%', 'Completion', 'target', '#2FAE66')
    stat_card(ax, 68.8, 98, 25.2, 11.5, '515', 'Coins', 'coin', '#E8A500')
    section_bar(ax, 8, 92.2, 'Children comparison')
    U.card(ax, 6, 76, 88, 14, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.bars(ax, 10, 79.4, 80, 8, [24, 16, 9], ['#FF8A3D', '#54C3F6', '#A98BFF'], radius=2.4, gap=12, zorder=4)
    labels3 = [('Mia', 24), ('Leo', 16), ('Ava', 9)]
    for i, (nm, v) in enumerate(labels3):
        U.text(ax, 10 + i * 34.5, 89.4, '%d' % v, 'Nunito', 11, 800, '#191A24', ha='center', va='bottom', zorder=5)
        U.text(ax, 10 + i * 34.5, 92.4, nm, 'Nunito', 9, 600, '#767685', ha='center', va='bottom', zorder=5)
    section_bar(ax, 8, 70.8, 'Weekly trend')
    U.card(ax, 6, 55, 88, 13.5, r=20, fc='#FFFFFF', level=1, zorder=3)
    U.line_chart(ax, 10, 58.4, 80, 7.2, [18, 26, 22, 31, 29, 40, 42], '#4F6BF5', zorder=4)
    U.text(ax, 88, 60.6, '+42% vs last week', 'Nunito', 8.5, 800, '#2FAE66', ha='right', va='center', zorder=5)
    section_bar(ax, 8, 49.4, 'By category')
    cats = [('water', '#3DDB9E', 'Health', 38), ('homework', '#4F6BF5', 'Learning', 34),
            ('run', '#FF8A3D', 'Activity', 20), ('bed', '#A98BFF', 'Routine', 8)]
    for i, (icon, col, nm, pct) in enumerate(cats):
        y = 37.5 - i * 8.2
        U.text(ax, 8, y, nm, 'Nunito', 9.5, 700, '#191A24', va='center', zorder=5)
        U.hbar(ax, 24, y - 0.5, 50, 3.4, pct / 100, col, r=1.7, zorder=4)
        U.text(ax, 90, y, '%d%%' % pct, 'Nunito', 9.5, 800, '#191A24', ha='right', va='center', zorder=5)
    U.button(ax, 20, 14, 60, 8.6, 'Export report (PDF)', bg='#FFFFFF', fg='#4F6BF5',
             ec='#DDE5FF', icon='download', ic=4.2, zorder=4)
    U.bottom_nav(ax, NAV_PARENT, 3, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '20_reports_parent.png'))

def s_settings():
    fig, ax = U.canvas(bg=P['background'])
    U.decor(ax)
    U.status_bar(ax, fg='#191A24')
    U.header_parent(ax, 'Settings', subtitle='Family preferences', back=True)
    U.card(ax, 6, 110, 88, 13, r=18, fc='#FFFFFF', level=1, zorder=3)
    U.avatar(ax, 14, 116.5, 5.6, 'D', '#4F6BF5', size=10, zorder=4)
    U.text(ax, 22.5, 112.6, 'Dana Smith', 'Nunito', 13, 800, '#191A24', zorder=5)
    U.text(ax, 22.5, 118.0, 'Parent \u00b7 Primary account', 'Nunito', 9.5, 600, '#767685', zorder=5)
    U.draw_icon(ax, 'chev_right', 89, 113.5, 6, '#767685', zorder=5)
    def setting_row(y, icon, nm, sub, ctrl='chev', ctrl_icon=None, ctrl_txt=None):
        U.card(ax, 6, y, 88, 10.8, r=16, fc='#FFFFFF', level=1, zorder=3)
        U.icon_badge_circle(ax, 13, y + 5.4, 4.6, icon, U.hx(P['primary'], 0.1), fg=P['primary'], ic=4.8, zorder=4)
        U.text(ax, 20, y + 2.6, nm, 'Nunito', 11.5, 800, '#191A24', zorder=5)
        if sub:
            U.text(ax, 20, y + 7.8, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        if ctrl == 'chev':
            U.draw_icon(ax, 'chev_right', 88, y + 2.4, 5.6, '#767685', zorder=5)
        elif ctrl == 'toggle':
            U.toggle(ax, 86, y + 3.2, 12, 4.6, on=True, color='#2FAE66', zorder=5)
        elif ctrl == 'txt':
            U.pill(ax, 84, y + 5.4, 18, 5.6, ctrl_txt or '', bg='#EEF0F8', fg='#191A24', size=8.5, weight=700, zorder=5)
    setting_row(110 - 0, 'bell', 'Notifications', 'Reminders and approvals', ctrl='toggle')
    setting_row(95.2, 'lock', 'Parent PIN', 'Change the 4-digit code', ctrl='chev')
    setting_row(82.6, 'moon', 'Dark mode', 'Easier on the eyes at night', ctrl='toggle')
    setting_row(70.0, 'target', 'Kids can add tasks', 'Let children suggest tasks', ctrl='toggle')
    U.card(ax, 6, 53, 88, 9.6, r=16, fc='#FFFFFF', level=1, zorder=3)
    U.icon_badge_circle(ax, 13, 57.8, 4.6, 'help', U.hx(P['primary'], 0.1), fg=P['primary'], ic=4.8, zorder=4)
    U.text(ax, 20, 55.6, 'Help & support', 'Nunito', 11.5, 800, '#191A24', zorder=5)
    U.draw_icon(ax, 'chev_right', 88, 54.8, 5.6, '#767685', zorder=5)
    U.card(ax, 6, 41, 88, 9.6, r=16, fc='#FFE7E7', level=1, zorder=3)
    U.icon_badge_circle(ax, 13, 45.8, 4.6, 'logout', '#FFDAD6', fg='#E5484D', ic=4.8, zorder=4)
    U.text(ax, 20, 43.6, 'Sign out', 'Nunito', 11.5, 800, '#E5484D', zorder=5)
    U.draw_icon(ax, 'chev_right', 88, 42.8, 5.6, '#E5484D', zorder=5)
    U.text(ax, 50, 33, 'Smart Child Hub \u00b7 Version 1.0.0', 'Nunito', 8.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.bottom_nav(ax, NAV_PARENT, 4, accent='#4F6BF5')
    U.save(fig, os.path.join(OUT, '21_settings.png'))

def s_about():
    fig, ax = U.canvas(gradient=('#4F6BF5', '#7A5BF5'))
    U.blob(ax, 12, 130, 22, 16, '#FFFFFF', 0.07, rot=30, zorder=0.5)
    U.blob(ax, 90, 14, 26, 20, '#FFFFFF', 0.06, rot=15, zorder=0.5)
    U.status_bar(ax)
    U.logo(ax, 50, 114, 11)
    U.text(ax, 50, 94, 'Smart Child Hub', 'Baloo 2', 28, 800, '#FFFFFF', ha='center', va='center', zorder=5)
    U.text(ax, 50, 88, 'Version 1.0.0', 'Nunito', 10, 600, '#D6DCFE', ha='center', va='center', zorder=5)
    U.card(ax, 8, 44, 84, 36, r=24, fc='#FFFFFF', level=3, zorder=3)
    U.text(ax, 14, 74.5, 'About this app', 'Nunito', 13, 800, '#191A24', zorder=5)
    desc = 'A family smart hub that turns daily chores into playful tasks, coins and badges - all offline and private. Designed to help children build healthy routines while parents stay in control.'
    lines = U.wrap(ax, desc, 'Nunito', 10.5, 600, 74, 5)
    y = 70.0
    for ln in lines:
        U.text(ax, 14, y, ln, 'Nunito', 10.5, 600, '#43434F', zorder=5)
        y -= 4.4
    features = [('shield', '100% offline \u2013 data stays in your home'),
                ('child', 'Kid-friendly design with no ads'),
                ('lock', 'Parent PIN keeps settings safe')]
    for i, (icon, ft) in enumerate(features):
        U.icon_badge_circle(ax, 18, y - 1, 3.8, icon, '#EEF0F8', fg='#4F6BF5', ic=4, zorder=4)
        U.text(ax, 24, y - 1, ft, 'Nunito', 9.5, 700, '#191A24', va='center', zorder=5)
        y -= 5.2
    U.button(ax, 24, 14, 52, 8.6, 'Made with love for families', bg='#FFFFFF', fg='#4F6BF5',
             icon='heart', ic=4.2, zorder=4)
    U.text(ax, 50, 7.6, 'Sunny \u00a9 2026 Smart Child Hub', 'Nunito', 8.5, 600, '#D6DCFE', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '22_about.png'))

# ---------------------------------------------------------------- main
SCREENS = [
    s_splash, s_welcome, s_choose_profile, s_child_pin, s_child_dashboard,
    s_task_screen, s_rewards, s_coins, s_badges, s_achievements, s_messages,
    s_reports_child, s_parent_login, s_parent_dashboard, s_manage_children,
    s_manage_tasks, s_pending_approval, s_rewards_management, s_coin_management,
    s_reports_parent, s_settings, s_about,
]

if __name__ == '__main__':
    for fn in SCREENS:
        fn()
    print('All %d mockups rendered.' % len(SCREENS))
