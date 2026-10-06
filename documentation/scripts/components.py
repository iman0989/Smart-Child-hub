"""Render component library boards + individual component images."""
import os
import numpy as np
import ui_lib as U
import tokens as T

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'components')
os.makedirs(OUT, exist_ok=True)

P = T.LIGHT
A = T.ACCENT
S = T.STATUS
HL = U.HLAND

# ---------------------------------------------------------------- primitives
def board(title, subtitle, w=10.0, h=7.5):
    fig, ax = U.canvas(bg=P['background'], w=w, h=h, dpi=240, ylim=HL)
    U.blob(ax, 4, HL - 6, 14, 8, '#DDE5FF', 0.5, rot=10, zorder=0.5)
    U.blob(ax, 96, HL - 2, 12, 9, '#FFE0C7', 0.4, rot=-14, zorder=0.5)
    U.text(ax, 4, HL - 2.6, title, 'Baloo 2', 20, 800, '#0E1E5C', zorder=5)
    U.text(ax, 4, HL - 6.2, subtitle, 'Nunito', 10, 600, '#767685', zorder=5)
    U.pill(ax, 90, HL - 3.4, 16, 6, 'Component', bg='#4F6BF5', fg='#FFFFFF', size=9, weight=800, zorder=5)
    return fig, ax

def cell(ax, x, y, w, h, label, desc, fc='#FFFFFF', zorder=3):
    U.card(ax, x, y, w, h, r=14, fc=fc, level=1, zorder=zorder)
    U.text(ax, x + 2.2, y + h - 1.4, label, 'Nunito', 8.5, 800, '#191A24', zorder=zorder + 1)
    for i, ln in enumerate(U.wrap(ax, desc, 'Nunito', 7.5, 500, w - 4.4, 2)):
        U.text(ax, x + 2.2, y + h - 1.4 - 3.0 - i * 3.0, ln, 'Nunito', 7.5, 500, '#767685', zorder=zorder + 1)

def caption(ax, x, y, label):
    U.text(ax, x, y, label, 'Nunito', 8, 700, '#43434F', zorder=5)

# ---------------------------------------------------------------- boards
def b_buttons():
    fig, ax = board('Buttons & Actions', 'Primary, secondary, tonal, text, FAB and icon actions')
    cell(ax, 4, HL - 14, 22, 11, 'Button hierarchy', 'Four levels of emphasis per Material 3.')
    U.button(ax, 6, HL - 20.5, 18, 5.6, 'Primary', bg=P['primary'], icon='sparkle', ic=3.2)
    U.button(ax, 6, HL - 27.5, 18, 5.6, 'Secondary', bg=P['secondaryContainer'], fg=P['onSecondaryContainer'])
    U.button(ax, 6, HL - 34.5, 18, 5.6, 'Tonal', bg=P['primaryContainer'], fg=P['onPrimaryContainer'])
    U.button(ax, 6, HL - 41.5, 18, 5.6, 'Text', bg='#FFFFFF', fg=P['primary'], ec=P['outlineVariant'])
    U.button(ax, 6, HL - 48.5, 18, 5.6, 'Disabled', bg=P['surfaceContainerHigh'], fg='#B9BAC6')
    U.button(ax, 6, HL - 55.5, 18, 5.6, 'Danger', bg=P['error'], icon='trash', ic=3.2)
    cell(ax, 30, HL - 14, 22, 11, 'Floating action buttons', 'Elevated circular action buttons.')
    for i, (nm, col) in enumerate((('FAB', P['secondary']), ('Small FAB', P['primary']), ('Mia FAB', '#2FAE66'))):
        cx = 34 + i * 8
        U.fab(ax, cx, HL - 30, 5.2, icon='plus' if i < 2 else 'sparkle', color=col)
        U.text(ax, cx, HL - 26.2, nm, 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.fab(ax, 34, HL - 42, 5.2, icon='bell', color=P['primary'])
    U.fab(ax, 43, HL - 42, 5.2, icon='edit', color=P['secondary'])
    U.fab(ax, 52, HL - 42, 5.2, icon='plus', color='#A98BFF')
    cell(ax, 30, HL - 48, 22, 6.5, 'Extended FAB', 'Wide FAB with label.')
    U.button(ax, 32, HL - 51.5, 18, 5, 'Add reward', bg=P['secondary'], icon='plus', ic=3, r=8)
    cell(ax, 56, HL - 14, 22, 11, 'Icon actions', 'Tappable icon buttons with badges.')
    for i, nm in enumerate(('home', 'bell', 'edit', 'trash', 'plus', 'heart')):
        cx = 60 + i * 4.4
        U.icon_badge_circle(ax, cx, HL - 25, 3.2, nm, U.hx(P['primary'], 0.1), fg=P['primary'], ic=3.4)
    U.text(ax, 62, HL - 21.5, 'Back', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.text(ax, 76, HL - 21.5, 'Badged bell', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    cell(ax, 56, HL - 33, 22, 11, 'Button states', 'Enabled, pressed, focused, disabled.')
    for i, (nm, bg, fg) in enumerate((('Enabled', P['primary'], '#FFFFFF'),
                                      ('Pressed', U.blend(P['primary'], '#000000', 0.12), '#FFFFFF'),
                                      ('Disabled', P['surfaceContainerHigh'], '#B9BAC6'))):
        U.button(ax, 58, HL - 39 - i * 7, 18, 4.8, nm, bg=bg, fg=fg, r=8)
    U.button(ax, 58, HL - 60, 18, 4.8, 'Focused', bg=P['primary'], fg='#FFFFFF', r=8, ec='#0E1E5C')
    cell(ax, 82, HL - 14, 14, 11, 'Ripple', 'Touch feedback expands from the press point.')
    U._circle(ax, 86.5, HL - 23, 1.6, U.hx(P['primary'], 0.5), zorder=4)
    U._circle(ax, 86.5, HL - 23, 2.8, U.hx(P['primary'], 0.25), zorder=3.5)
    U._circle(ax, 86.5, HL - 23, 4.0, U.hx(P['primary'], 0.12), zorder=3)
    U.card(ax, 82, HL - 31, 14, 9, r=12, fc='#FFFFFF', level=1, zorder=3)
    U.draw_icon(ax, 'tasks', 86.5, HL - 28.6, 4, P['primary'], zorder=4)
    U.text(ax, 86.5, HL - 24.4, 'Task card', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '01_buttons.png'))

def b_cards():
    fig, ax = board('Cards & Containers', 'Surfaces, elevation levels and corner radii')
    levels = [(0, 'Level 0', 'Flat', P['surfaceContainer']), (1, 'Level 1', 'Resting', '#FFFFFF'),
              (2, 'Level 2', 'Floating', '#FFFFFF'), (3, 'Level 3', 'Dialog', '#FFFFFF')]
    for i, (lv, nm, use, fc) in enumerate(levels):
        x = 4 + i * 24
        U.card(ax, x, HL - 20, 22, 12, r=16, fc=fc, level=lv, zorder=3)
        U.text(ax, x + 2.4, HL - 22.2, nm, 'Nunito', 9, 800, '#191A24', zorder=5)
        U.text(ax, x + 2.4, HL - 24.4, 'elevation.shadow.%d' % lv, 'Nunito', 7, 500, '#767685', zorder=5)
        U.text(ax, x + 2.4, HL - 26.4, use, 'Nunito', 7.5, 600, '#4F6BF5', zorder=5)
    U.card(ax, 4, HL - 34.5, 44, 10, r=16, fc='#FFFFFF', level=2, zorder=3)
    U.gradient_rect(ax, 4, HL - 34.5, 44, 10, 16, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 8, HL - 38.8, 'Hero / gradient card', 'Nunito', 11, 800, '#FFFFFF', zorder=5)
    U.text(ax, 8, HL - 41.4, 'Brand surfaces can use the primary gradient', 'Nunito', 7.5, 600, '#D6DCFE', zorder=5)
    U.pill(ax, 42, HL - 38.8, 12, 5, 'Action', bg='#FFFFFF', fg=P['primary'], size=8, weight=800, zorder=5)
    cell(ax, 52, HL - 34.5, 44, 10, 'Card anatomy', 'Title, subtitle, icon, trailing action, optional shadow.')
    U.card(ax, 54, HL - 40, 40, 5.6, r=10, fc='#FFFFFF', level=1, zorder=3)
    U.icon_badge_circle(ax, 56.4, HL - 37.2, 2.6, 'tasks', U.hx(P['primary'], 0.12), fg=P['primary'], ic=2.8, zorder=4)
    U.text(ax, 60, HL - 36.0, 'Brush teeth', 'Quicksand', 8.5, 700, '#191A24', zorder=5)
    U.text(ax, 60, HL - 38.4, 'Morning routine', 'Nunito', 6.5, 500, '#767685', zorder=5)
    U.pill(ax, 90, HL - 37.2, 7, 3.6, 'Done', bg=U.hx(S['completed'], 0.14), fg=S['completed'], size=6, weight=800, zorder=5)
    U.coin_chip(ax, 90, HL - 33.4, 5, h=3.2, size=2.2, zorder=5)
    U.save(fig, os.path.join(OUT, '02_cards.png'))

def b_chips():
    fig, ax = board('Chips, Badges, Toggles & Status', 'Compact interactive elements and task status colours')
    cell(ax, 4, HL - 14, 30, 11, 'Filter chips', 'Used on task and report lists.')
    U.pill(ax, 12, HL - 22, 8, 4.6, 'All', bg=P['primary'], fg='#FFFFFF', size=7, weight=700, icon='sparkle', ic=2.8)
    U.pill(ax, 24, HL - 22, 10, 4.6, 'Today', bg='#FFFFFF', fg='#43434F', size=7, weight=700, icon='sun', ic=2.8, ec=P['outlineVariant'])
    U.pill(ax, 36, HL - 22, 11, 4.6, 'Pending', bg='#FFFFFF', fg='#43434F', size=7, weight=700, icon='clock', ic=2.8, ec=P['outlineVariant'])
    U.pill(ax, 12, HL - 29, 10, 4.6, 'Streak', bg='#FFF3D1', fg='#B26A00', size=7, weight=800, icon='lightning', ic=2.8)
    U.pill(ax, 26, HL - 29, 11, 4.6, 'Parents', bg=P['primaryContainer'], fg=P['onPrimaryContainer'], size=7, weight=800, icon='parent', ic=2.8)
    cell(ax, 4, HL - 32, 30, 11, 'Badges & tiers', 'Badge levels use dedicated tier colours.')
    tiers = [('Bronze', '#C98A5B'), ('Silver', '#9AA4B5'), ('Gold', '#E8A500'), ('Diamond', '#3FB9E0')]
    for i, (nm, col) in enumerate(tiers):
        cx = 9 + i * 7.4
        U.icon_badge_circle(ax, cx, HL - 38, 3.0, 'badge', col, fg='#FFFFFF', ic=3.2, zorder=4)
        U.text(ax, cx, HL - 33.6, nm, 'Nunito', 6.5, 700, '#191A24', ha='center', va='center', zorder=5)
    cell(ax, 38, HL - 14, 28, 11, 'Toggles & checkboxes', 'Binary controls keep one accent colour.')
    U.toggle(ax, 42, HL - 22, 14, 5, on=True, color='#2FAE66')
    U.toggle(ax, 60, HL - 22, 14, 5, on=False, color='#2FAE66')
    U.text(ax, 42, HL - 18.4, 'On', 'Nunito', 7, 600, '#767685', va='center', zorder=5)
    U.text(ax, 60, HL - 18.4, 'Off', 'Nunito', 7, 600, '#767685', va='center', zorder=5)
    for i, on in enumerate((True, False)):
        cx = 44 + i * 20
        ax.add_patch(U.Circle((cx, HL - 26.5), 2.6, fc='#FFFFFF' if on else '#FFFFFF', ec='#B9BAC6', lw=1.4, zorder=4))
        if on:
            U.draw_icon(ax, 'check', cx - 1.3, HL - 27.8, 2.6, P['primary'], zorder=5)
    U.text(ax, 44, HL - 31.2, 'Checkbox', 'Nunito', 7, 600, '#767685', va='center', zorder=5)
    U.text(ax, 64, HL - 31.2, 'Radio', 'Nunito', 7, 600, '#767685', va='center', zorder=5)
    U._circle(ax, 64, HL - 26.5, 2.6, '#FFFFFF', ec='#B9BAC6', lw=1.4, zorder=4)
    U._circle(ax, 64, HL - 26.5, 1.1, P['primary'], zorder=5)
    cell(ax, 38, HL - 34, 28, 13, 'Task status chips', 'Six states are used across the app.')
    statuses = [('Completed', 'completed', '#D7F2E2'), ('Pending', 'pending', '#FFF3D1'),
                ('Rejected', 'rejected', '#FFE7E7'), ('Verified', 'verified', '#C4F6E8'),
                ('Missed', 'missed', '#E9EAF6'), ('Locked', 'locked', '#E9EAF6')]
    for i, (nm, key, bg) in enumerate(statuses):
        col = i % 2
        row = i // 2
        x = 42 + col * 22
        y = HL - 40.5 - row * 5.6
        U.pill(ax, x, y, 18, 4.2, nm, bg=U.hx(S[key], 0.14), fg=S[key], size=7, weight=800, icon={'Completed': 'check', 'Pending': 'clock', 'Rejected': 'cross', 'Verified': 'verified', 'Missed': 'minus', 'Locked': 'lock'}[nm], ic=2.6)
    cell(ax, 70, HL - 14, 26, 11, 'Coin chip', 'Primary reward currency display.')
    U.coin_chip(ax, 83, HL - 22, 240, h=5.6, size=3.8, bg='#FFF7E0', fg='#8A5A00', zorder=5)
    U.coin_chip(ax, 83, HL - 29, 62, h=5.6, size=3.8, bg='#FFFFFF', fg='#0E1E5C', zorder=5)
    U.text(ax, 83, HL - 32.5, 'Coin chips use Quicksand numbers', 'Nunito', 7, 600, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '03_chips.png'))

def b_inputs():
    fig, ax = board('Inputs & Forms', 'Fields, PIN pads, search, selects')
    cell(ax, 4, HL - 14, 30, 11, 'Text field', 'Filled fields with label and helper text.')
    U.card(ax, 6, HL - 24, 26, 5.2, r=8, fc=P['surfaceContainer'], level=0, zorder=3)
    U.text(ax, 8, HL - 25.4, 'Task name', 'Nunito', 7.5, 600, P['primary'], zorder=5)
    U.text(ax, 8, HL - 27.8, 'Drink a glass of water', 'Nunito', 8, 700, '#191A24', zorder=5)
    U.card(ax, 6, HL - 32.6, 26, 5.2, r=8, fc=P['surfaceContainer'], level=0, zorder=3)
    U.text(ax, 8, HL - 34.0, 'Coins reward', 'Nunito', 7.5, 600, '#767685', zorder=5)
    U.coin_chip(ax, 28, HL - 34.9, 5, h=3.6, size=2.4, zorder=5)
    cell(ax, 38, HL - 14, 30, 11, 'Search field', 'Rounded search used on lists.')
    U.card(ax, 40, HL - 23, 26, 5.6, r=14, fc='#FFFFFF', level=1, ec=P['outlineVariant'], zorder=3)
    U.draw_icon(ax, 'search', 42.5, HL - 25.6, 3.4, '#767685', zorder=4)
    U.text(ax, 47.5, HL - 24.2, 'Search children', 'Nunito', 8, 600, '#B9BAC6', zorder=5)
    cell(ax, 38, HL - 32, 30, 11, 'Coin adjuster', 'Plus/minus balance stepper.')
    U.card(ax, 40, HL - 39, 26, 6, r=10, fc='#FFFFFF', level=1, zorder=3)
    U.icon_badge_circle(ax, 43.4, HL - 36, 3, 'minus', '#FFE7E7', fg=P['error'], ic=3.2, zorder=4)
    U.coin_chip(ax, 53, HL - 36, 240, h=4, size=2.7, zorder=5)
    U.icon_badge_circle(ax, 62.6, HL - 36, 3, 'plus', '#D7F2E2', fg=S['completed'], ic=3.2, zorder=4)
    cell(ax, 72, HL - 14, 24, 11, 'PIN pad', '4-digit child lock keypad.')
    for i, k in enumerate(('1', '2', '3', '4', '5', '6', '7', '8', '9')):
        col, row = i % 3, i // 3
        cx = 76 + col * 6
        cy = HL - 22 - row * 6
        U.card(ax, cx - 2.6, cy - 2.6, 5.2, 5.2, r=2.8, fc='#FFFFFF', level=1, zorder=3)
        U.text(ax, cx, cy, k, 'Quicksand', 8, 700, '#191A24', ha='center', va='center', zorder=4)
    U._circle(ax, 76, HL - 40, 1.1, P['primary'], zorder=4)
    U._circle(ax, 82, HL - 40, 1.1, P['primary'], zorder=4)
    U._circle(ax, 88, HL - 40, 0.9, U.hx(P['primary'], 0.4), zorder=4)
    U._circle(ax, 94, HL - 40, 0.9, U.hx(P['primary'], 0.4), zorder=4)
    U.save(fig, os.path.join(OUT, '04_inputs.png'))

def b_navigation():
    fig, ax = board('Navigation & App Chrome', 'Status bar, headers, bottom navigation, FAB placement')
    U.pill(ax, 50, HL - 4, 20, 5, 'Status bar 9:41', bg='#FFFFFF', fg='#191A24', size=7, weight=700, zorder=5)
    U.card(ax, 4, HL - 14, 44, 8.6, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.draw_icon(ax, 'chev_left', 6.6, HL - 12.4, 3.2, '#191A24', zorder=4)
    U.text(ax, 11, HL - 12.2, 'Header title', 'Nunito', 9.5, 800, '#191A24', zorder=5)
    U.draw_icon(ax, 'bell', 44, HL - 12.4, 3.4, '#191A24', zorder=4)
    U.card(ax, 52, HL - 14, 44, 8.6, r=14, fc='#4F6BF5', level=1, zorder=3)
    U.gradient_rect(ax, 52, HL - 14, 44, 8.6, 14, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 55, HL - 13.0, 'Hi Mia!', 'Quicksand', 6.5, 700, '#DDE5FF', zorder=5)
    U.text(ax, 55, HL - 9.8, 'Good morning', 'Quicksand', 8.5, 700, '#FFFFFF', zorder=5)
    U.coin_chip(ax, 90, HL - 12.6, 240, h=3.6, size=2.4, zorder=5)
    U.card(ax, 4, HL - 26, 44, 8.4, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.avatar(ax, 8.5, HL - 21.8, 3.6, 'M', '#FFC93C', size=6.5, zorder=4)
    U.text(ax, 14, HL - 22.6, 'Profile row', 'Nunito', 8, 800, '#191A24', zorder=5)
    U.text(ax, 14, HL - 25.2, 'Parent \u00b7 Primary account', 'Nunito', 6, 600, '#767685', zorder=5)
    U.draw_icon(ax, 'chev_right', 44, HL - 24, 2.8, '#767685', zorder=5)
    U.card(ax, 52, HL - 26, 44, 8.4, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 55, HL - 22.6, 'Section header', 'Nunito', 9, 800, '#191A24', zorder=5)
    U.text(ax, 55, HL - 25.2, 'With optional "See all" link', 'Nunito', 6, 600, '#767685', zorder=5)
    U.text(ax, 92, HL - 22.6, 'See all', 'Nunito', 6.5, 700, '#4F6BF5', ha='right', va='center', zorder=5)
    U.card(ax, 4, HL - 38, 92, 9, r=14, fc='#FFFFFF', level=2, zorder=3)
    items = [('home', 'Home', True), ('tasks', 'Tasks', False), ('trophy', 'Rewards', False),
             ('badge', 'Badges', False), ('person', 'Me', False)]
    for i, (icon, nm, act) in enumerate(items):
        cx = 4 + 92 * (i / 5) + 9.2
        if act:
            U.rr(ax, cx - 4, HL - 34.4, 8, 2.2, 2.2, fc=U.hx(P['primary'], 0.14), zorder=4)
            U.draw_icon(ax, icon, cx - 1.5, HL - 33.4, 3, P['primary'], zorder=5)
            U.text(ax, cx, HL - 30.2, nm, 'Nunito', 5.5, 700, P['primary'], ha='center', va='center', zorder=5)
        else:
            U.draw_icon(ax, icon, cx - 1.5, HL - 33.4, 3, U.hx('#191A24', 0.55), zorder=5)
            U.text(ax, cx, HL - 30.2, nm, 'Nunito', 5.5, 600, U.hx('#191A24', 0.55), ha='center', va='center', zorder=5)
    U.text(ax, 50, HL - 41.2, 'Bottom navigation \u00b7 5 items \u00b7 active pill', 'Nunito', 7, 600, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '05_navigation.png'))

def b_charts():
    fig, ax = board('Charts & Progress', 'Rings, bars, lines, donuts and data display')
    cell(ax, 4, HL - 14, 22, 11, 'Progress ring', 'Rounded caps, percentage in centre.')
    U.ring(ax, 15, HL - 28, 6, 0.72, '#2FAE66', center_txt=('72%', 'done'), width=3, zorder=4)
    U.ring(ax, 27, HL - 28, 6, 0.5, '#FF9F0A', center_txt=('50%', ''), width=3, zorder=4)
    cell(ax, 30, HL - 14, 22, 11, 'Progress bar', 'Horizontal, rounded, labelled.')
    U.hbar(ax, 34, HL - 26, 14, 2.6, 0.53, '#FFC93C', r=1.3, zorder=4)
    U.text(ax, 34, HL - 22.6, '160 / 300 coins', 'Nunito', 6.5, 700, '#191A24', zorder=5)
    U.hbar(ax, 34, HL - 30, 14, 2.6, 0.84, '#4F6BF5', r=1.3, zorder=4)
    U.text(ax, 34, HL - 33.6, 'Achievement milestone', 'Nunito', 6.5, 600, '#767685', zorder=5)
    cell(ax, 56, HL - 14, 22, 11, 'Column chart', 'Weekly task counts.')
    U.bars(ax, 60, HL - 24, 14, 6, [4, 6, 3, 7, 5, 8, 6], '#4F6BF5',
           labels=['M', 'T', 'W', 'T', 'F', 'S', 'S'], radius=1, gap=0.7, zorder=4)
    cell(ax, 82, HL - 14, 14, 11, 'Donut', 'Status distribution.')
    U.donut(ax, 89, HL - 22, 4.4, [0.55, 0.25, 0.12, 0.08], ['#2FAE66', '#FF9F0A', '#E5484D', '#B9BAC6'], 2.4, zorder=4)
    U.text(ax, 89, HL - 30.5, '24 tasks', 'Nunito', 6.5, 700, '#191A24', ha='center', va='center', zorder=5)
    cell(ax, 4, HL - 30, 30, 12, 'Line chart', 'Trends with soft area fill.')
    U.line_chart(ax, 8, HL - 38, 22, 6, [18, 26, 22, 31, 29, 40, 42], '#4F6BF5', zorder=4)
    U.text(ax, 32, HL - 38.5, '+42%', 'Nunito', 8, 800, '#2FAE66', ha='right', va='center', zorder=5)
    U.text(ax, 32, HL - 41.5, 'vs last week', 'Nunito', 6.5, 600, '#767685', ha='right', va='center', zorder=5)
    cell(ax, 38, HL - 30, 30, 12, 'Sparklines & legends', 'Compact inline visuals.')
    U.line_chart(ax, 42, HL - 38, 14, 5, [2, 5, 4, 8, 6], '#2FAE66', fill=False, zorder=4)
    legend = [('#2FAE66', 'Completed'), ('#FF9F0A', 'Pending'), ('#E5484D', 'Missed')]
    for i, (col, nm) in enumerate(legend):
        U._circle(ax, 42, HL - 41.5 - i * 3.4, 1.1, col, zorder=4)
        U.text(ax, 44, HL - 41.5 - i * 3.4, nm, 'Nunito', 6.5, 600, '#191A24', va='center', zorder=5)
    cell(ax, 72, HL - 30, 24, 12, 'Statistics', 'Big numbers with labels.')
    U.card(ax, 74, HL - 38, 20, 8, r=12, fc='#FFFFFF', level=1, zorder=3)
    U.icon_badge_circle(ax, 77.5, HL - 36.2, 2.4, 'tasks', U.hx(P['primary'], 0.12), fg=P['primary'], ic=2.6, zorder=4)
    U.text(ax, 81, HL - 35.6, '24', 'Nunito', 13, 800, '#191A24', zorder=5)
    U.text(ax, 81, HL - 38.2, 'Tasks done', 'Nunito', 6.5, 600, '#767685', zorder=5)
    U.save(fig, os.path.join(OUT, '06_charts.png'))

def b_dialogs():
    fig, ax = board('Dialogs, Snackbars & Empty States', 'Transient and contextual feedback')
    cell(ax, 4, HL - 14, 30, 11, 'Confirmation dialog', 'Level-3 elevation, centred on screen.')
    U.card(ax, 8, HL - 38, 22, 22, r=16, fc='#FFFFFF', level=3, zorder=3)
    U.icon_badge_circle(ax, 19, HL - 34.5, 4, 'trash', '#FFE7E7', fg=P['error'], ic=4.2, zorder=4)
    U.text(ax, 19, HL - 28.5, 'Delete task?', 'Nunito', 11, 800, '#191A24', ha='center', va='center', zorder=5)
    for i, ln in enumerate(U.wrap(ax, 'This task will be removed for all children.', 'Nunito', 7.5, 500, 18, 2)):
        U.text(ax, 19, HL - 25.4 - i * 3.0, ln, 'Nunito', 7.5, 500, '#767685', ha='center', va='center', zorder=5)
    U.button(ax, 10, HL - 42.5, 8.4, 4.4, 'Cancel', bg='#FFFFFF', fg='#43434F', ec=P['outlineVariant'], size=7.5, r=6)
    U.button(ax, 19.6, HL - 42.5, 8.4, 4.4, 'Delete', bg=P['error'], fg='#FFFFFF', size=7.5, r=6)
    U.card(ax, 4, HL - 31.6, 30, 14, r=14, fc=U.hx('#0E1E5C', 0.06), level=0, ec=P['outlineVariant'], zorder=2)
    cell(ax, 38, HL - 14, 28, 11, 'Snackbars', 'Transient feedback with action.')
    U.rr(ax, 42, HL - 26, 22, 5.4, 8, fc=U.hx('#191A24', 0.92), zorder=4)
    U.text(ax, 44.5, HL - 24.9, 'Task approved! +10 coins', 'Nunito', 7.5, 600, '#FFFFFF', zorder=5)
    U.text(ax, 61, HL - 24.9, 'UNDO', 'Nunito', 7.5, 800, '#FFC93C', ha='right', va='center', zorder=5)
    U.rr(ax, 42, HL - 33.5, 22, 5.4, 8, fc=U.hx(S['completed'], 0.95), zorder=4)
    U.text(ax, 44.5, HL - 32.4, 'Badge unlocked!', 'Nunito', 7.5, 700, '#FFFFFF', zorder=5)
    cell(ax, 38, HL - 30, 28, 12, 'Empty states', 'Friendly illustrations with guidance.')
    U.card(ax, 42, HL - 38, 22, 10, r=12, fc='#FFFFFF', level=1, zorder=3)
    U.icon_badge_circle(ax, 53, HL - 35.6, 3.6, 'sparkle', '#EEF0F8', fg='#B9BAC6', ic=3.8, zorder=4)
    U.text(ax, 53, HL - 31.0, 'No tasks yet', 'Quicksand', 9, 700, '#191A24', ha='center', va='center', zorder=5)
    U.text(ax, 53, HL - 29.4, 'Ask a parent to add your first task', 'Nunito', 6.5, 500, '#767685', ha='center', va='center', zorder=5)
    cell(ax, 70, HL - 14, 26, 11, 'Tooltip & toasts', 'Micro-feedback.')
    U.rr(ax, 74, HL - 26, 18, 5, 4, fc='#191A24', zorder=4)
    U.text(ax, 83, HL - 25.6, '+5 coins earned', 'Nunito', 7, 700, '#FFFFFF', ha='center', va='center', zorder=5)
    U._poly(ax, [(79, HL - 26), (80, HL - 24.4), (81, HL - 26)], '#191A24', zorder=4)
    U.rr(ax, 74, HL - 34, 18, 5, 4, fc='#4F6BF5', zorder=4)
    U.text(ax, 83, HL - 33.6, 'Saving changes...', 'Nunito', 7, 700, '#FFFFFF', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '07_dialogs.png'))

def b_avatars():
    fig, ax = board('Avatars, Mascot & Empty Illustration', 'Identity visuals across modes')
    cell(ax, 4, HL - 14, 30, 11, 'Child avatars', 'Colourful initials with optional ring.')
    colors = ['#FF8A3D', '#54C3F6', '#A98BFF', '#3DDB9E', '#FF7BA9']
    for i, col in enumerate(colors):
        U.avatar(ax, 8 + i * 5.6, HL - 22, 2.4, 'MKLAN'[i], col, size=4, zorder=4)
    for i, col in enumerate(colors):
        U.avatar(ax, 8 + i * 5.6, HL - 30.5, 2.0, 'M', col, size=3.4, ring='#FFFFFF', ring_lw=1, zorder=4)
    cell(ax, 38, HL - 14, 28, 11, 'Parent avatars', 'Neutral but warm colours.')
    for i, col in enumerate(['#4F6BF5', '#1FBFA0', '#FF8A3D', '#A98BFF']):
        U.avatar(ax, 43 + i * 5.6, HL - 22, 2.4, 'DP'[i % 2], col, size=4, zorder=4)
    cell(ax, 4, HL - 34, 30, 12, 'Sunny mascot', 'Primary brand illustration.')
    U.logo(ax, 19, HL - 40.5, 5.5)
    U.text(ax, 19, HL - 47.5, 'Sunny', 'Baloo 2', 9, 700, '#191A24', ha='center', va='center', zorder=5)
    U.text(ax, 19, HL - 49.8, 'Greets, celebrates, guides', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    cell(ax, 38, HL - 34, 28, 12, 'Illustration styles', 'Soft shapes, no harsh strokes.')
    U.icon_badge_circle(ax, 47, HL - 41, 5, 'trophy', '#FCEFC8', fg='#E8A500', ic=5.4, zorder=4)
    U.icon_badge_circle(ax, 56, HL - 41, 5, 'child', '#FFE0C7', fg='#FF8A3D', ic=5.4, zorder=4)
    U.icon_badge_circle(ax, 65, HL - 41, 5, 'heart', '#FFE7EC', fg='#FF7BA9', ic=5.4, zorder=4)
    cell(ax, 70, HL - 14, 26, 11, 'Icon set', '48 custom glyphs, 2px stroke feel.')
    names = list(U.ICONS.keys())
    for i, nm in enumerate(names[:36]):
        col = i % 9
        row = i // 9
        U.draw_icon(ax, nm, 72 + col * 2.8, HL - 24 - row * 3.2, 2.2, '#4F6BF5', zorder=4)
    U.save(fig, os.path.join(OUT, '08_avatars.png'))

def b_typography():
    fig, ax = board('Typography Scale', 'Baloo 2 for display, Quicksand for child UI, Nunito for everything else')
    rows = [
        ('Display Large', 'Baloo 2', 800, 57, '240', 'Hero numbers'),
        ('Display Medium', 'Baloo 2', 700, 45, 'Good job!', 'Screen heroes'),
        ('Headline Large', 'Baloo 2', 700, 32, 'My Tasks', 'Dashboard'),
        ('Headline Small', 'Baloo 2', 700, 24, 'Weekly rewards', 'Cards'),
        ('Title Large', 'Nunito', 700, 22, 'Family Dashboard', 'Parent screens'),
        ('Title Medium', 'Nunito', 600, 16, 'Manage Children', 'List titles'),
        ('Body Large', 'Nunito', 400, 16, 'Turn chores into playful tasks.', 'Body'),
        ('Body Medium', 'Nunito', 400, 14, 'Parents stay in control.', 'Secondary'),
        ('Label Large', 'Nunito', 600, 14, 'APPROVE TASK', 'Buttons'),
        ('Stat Large', 'Nunito', 800, 48, '240', 'Big numbers'),
    ]
    for i, (nm, fam, w, sz, sample, use) in enumerate(rows):
        y = HL - 16 - i * 5.4
        U.pill(ax, 8, y, 26, 3.4, nm, bg='#EEF0F8', fg='#43434F', size=6.5, weight=700)
        U.text(ax, 37, y, sample, fam, sz, w, '#191A24', ha='left', va='center', zorder=5)
        U.text(ax, 88, y, use, 'Nunito', 7, 600, '#767685', ha='right', va='center', zorder=5)
    U.text(ax, 50, HL - 71.5, 'Quicksand numbers render in tabular figures for balanced totals.', 'Nunito', 7, 500, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '09_typography.png'))

def b_colors():
    fig, ax = board('Colour Palette', 'Light theme brand, accent, semantic and badge colours')
    groups = [
        ('Brand', [('Primary', P['primary']), ('On primary', '#FFFFFF'), ('Primary container', P['primaryContainer']),
                   ('Secondary', P['secondary']), ('Secondary container', P['secondaryContainer']),
                   ('Tertiary', P['tertiary'])]),
        ('Accent', [('Sunshine', A['sunshine']), ('Candy', A['candy']), ('Sky', A['sky']),
                    ('Grape', A['grape']), ('Mint', A['mint']), ('Peach', A['peach'])]),
        ('Semantic', [('Success', P['success']), ('Warning', P['warning']), ('Error', P['error']),
                      ('Info', P['info']), ('On surface', P['onSurface']), ('Outline', P['outline'])]),
        ('Badge tiers', [('Bronze', '#C98A5B'), ('Silver', '#9AA4B5'), ('Gold', '#E8A500'), ('Diamond', '#3FB9E0'),
                         ('Sunshine', A['sunshine']), ('Mint', A['mint'])]),
    ]
    for gi, (gname, cols) in enumerate(groups):
        y = HL - 15 - gi * 15
        U.text(ax, 5, y, gname, 'Nunito', 9, 800, '#191A24', zorder=5)
        for i, (nm, col) in enumerate(cols):
            col_i = i % 6
            row = i // 6
            x = 5 + col_i * 15.6
            cy = y - 4.5 - row * 7.5
            U.rr(ax, x, cy - 1.9, 13.4, 3.8, 2, fc=col, ec='#FFFFFF', lw=0.8, zorder=4)
            U.text(ax, x + 6.7, cy - 6.4, nm, 'Nunito', 6, 600, '#43434F', ha='center', va='center', zorder=5)
            U.text(ax, x + 6.7, cy + 3.6, col, 'Nunito', 5.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.text(ax, 50, HL - 74.5, 'Colours are used for feedback and joy, never for data alone.', 'Nunito', 7.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.save(fig, os.path.join(OUT, '10_colors.png'))

def b_spacing():
    fig, ax = board('Spacing & Layout', '8dp grid, corner radii, elevation and touch targets')
    sp = [4, 8, 12, 16, 20, 24, 32, 40, 48, 64]
    for i, v in enumerate(sp):
        x = 5 + i * 9.4
        U.rr(ax, x, HL - 16, 8, 4, 1, fc=P['primary'], zorder=4)
        U.text(ax, x + 4, HL - 18.4, '%d' % v, 'Nunito', 6.5, 700, '#191A24', ha='center', va='center', zorder=5)
    radii = [('xs', 8, 'small chips'), ('sm', 12, 'search fields'), ('md', 16, 'list cards'),
             ('lg', 20, 'cards'), ('xl', 24, 'hero cards'), ('xxl', 32, 'dialogs'), ('full', 999, 'pills')]
    for i, (nm, v, use) in enumerate(radii):
        x = 5 + i * 13.4
        U.rr(ax, x, HL - 26, 11, 7, min(v, 5), fc='#FFFFFF', ec=P['outlineVariant'], lw=1.4, zorder=4)
        U.text(ax, x + 5.5, HL - 31.4, 'r%d' % v, 'Nunito', 6.5, 700, '#191A24', ha='center', va='center', zorder=5)
        U.text(ax, x + 5.5, HL - 33.6, nm, 'Nunito', 5.5, 500, '#767685', ha='center', va='center', zorder=5)
    U.card(ax, 5, HL - 40, 45, 9.4, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 8, HL - 42, 'Screen padding 24', 'Nunito', 7.5, 700, '#191A24', zorder=5)
    U.text(ax, 8, HL - 44.4, 'Card padding 20 \u00b7 Grid gap 16 \u00b7 Touch target min 48dp', 'Nunito', 6.5, 500, '#767685', zorder=5)
    U.text(ax, 8, HL - 46.6, 'Content max width 880dp on expanded layouts', 'Nunito', 6.5, 500, '#767685', zorder=5)
    U.card(ax, 54, HL - 40, 42, 9.4, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 57, HL - 42, 'Targets & density', 'Nunito', 7.5, 700, '#191A24', zorder=5)
    U.text(ax, 57, HL - 44.4, 'Buttons 48dp high \u00b7 icon targets 44dp \u00b7 list rows 56dp', 'Nunito', 6.5, 500, '#767685', zorder=5)
    U.text(ax, 57, HL - 46.6, 'Bottom nav 80dp \u00b7 app bar 64dp', 'Nunito', 6.5, 500, '#767685', zorder=5)
    U.text(ax, 50, HL - 53.5, 'Layout tokens', 'Nunito', 9, 800, '#191A24', ha='center', va='center', zorder=5)
    U.pill(ax, 50, HL - 59, 34, 5, 'Compact < 600dp', bg='#FFFFFF', fg='#43434F', size=7, weight=700, ec=P['outlineVariant'])
    U.pill(ax, 50, HL - 66, 34, 5, 'Medium 600-840dp', bg=P['primaryContainer'], fg=P['onPrimaryContainer'], size=7, weight=700)
    U.pill(ax, 50, HL - 73, 34, 5, 'Expanded > 840dp', bg='#D7F2E2', fg='#1E5434', size=7, weight=700)
    U.save(fig, os.path.join(OUT, '11_spacing.png'))

# ---------------------------------------------------------------- main
BOARDS = [b_buttons, b_cards, b_chips, b_inputs, b_navigation, b_charts,
          b_dialogs, b_avatars, b_typography, b_colors, b_spacing]

if __name__ == '__main__':
    for fn in BOARDS:
        fn()
    print('All %d component boards rendered.' % len(BOARDS))
