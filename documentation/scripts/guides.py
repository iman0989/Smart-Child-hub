"""Build the 7 professional style-guide PDFs."""
import os
import numpy as np
import matplotlib.pyplot as plt

import ui_lib as U
import tokens as T
import pdf_lib as PL

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'style-guide')
os.makedirs(OUT, exist_ok=True)
COMPS = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'components')

P = T.LIGHT
A = T.ACCENT
S = T.STATUS
HL = U.HLAND

def embed(ax, path, x, y, w, h):
    img = plt.imread(path)
    ax.imshow(img, extent=[x, x + w, y, y + h], aspect='auto', zorder=3, interpolation='lanczos')

# ------------------------------------------------------------- single build
def guide_ui_style():
    d = PL.Doc(os.path.join(OUT, 'UI_Style_Guide.pdf'), 'UI Style Guide')
    d.cover('UI Style Guide', 'The visual language of Smart Child Hub',
            ['Design principles', 'Visual language', 'Layout & grid',
             'Components overview', 'Feedback & states', 'Accessibility & dark mode'])
    d.chapter(1, 'Design Principles', 'Four ideas shape every screen')
    fig, ax = d.page('Design principles', 'What we optimise for on every screen')
    cards = [('Playful', 'Big rounded shapes, friendly mascot Sunny and warm colours make routines feel like games, never chores.', '#FF8A3D'),
             ('Clear', 'One primary action per screen. Big type and generous spacing mean a 4-year-old and a parent both understand instantly.', '#4F6BF5'),
             ('Safe', 'Parent-only zones sit behind a PIN. No accounts, no ads, no internet \u2013 a private family space.', '#2FAE66'),
             ('Rewarding', 'Coins, badges and confetti celebrate every win and turn effort into visible, motivating progress.', '#E8A500')]
    for i, (t, desc, col) in enumerate(cards):
        col_i, row = i % 2, i // 2
        x = 6 + col_i * 45
        y = 58 - row * 26
        PL.card(ax, x, y, 43, 24, title=t)
        U.icon_badge_circle(ax, x + 6, y + 19.5, 4.2, ['sparkle', 'eye', 'shield', 'star'][i],
                            U.hx(col, 0.14), fg=col, ic=4.4, zorder=4)
        yy = y + 14.4
        for ln in U.wrap(ax, desc, 'Nunito', 9, 600, 38, 5):
            U.text(ax, x + 2.6, yy, ln, 'Nunito', 9, 600, '#43434F', zorder=5)
            yy -= 4.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'Visual Language', 'Rounded, soft, glassy, alive')
    fig, ax = d.page('Shapes, depth and gradients', 'The signature Smart Child Hub look')
    PL.card(ax, 6, 56, 43, 10, title='Rounded geometry')
    for ln in U.wrap(ax, 'Radii are generous and consistent: 16dp cards, 24dp hero cards, full pills for chips and buttons. Nothing has sharp corners in child mode.',
                     'Nunito', 9, 600, 38, 4):
        U.text(ax, 8.4, 51.4, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    U.rr(ax, 10, 44, 6, 4, 1, fc=P['primary'], zorder=4); U.text(ax, 17.4, 44.8, 'r8', 'Nunito', 6, 600, '#767685', va='center', zorder=5)
    U.rr(ax, 22, 44, 6, 4, 2, fc=P['primary'], zorder=4); U.text(ax, 29.4, 44.8, 'r16', 'Nunito', 6, 600, '#767685', va='center', zorder=5)
    U.rr(ax, 34, 44, 6, 4, 3, fc=P['primary'], zorder=4); U.text(ax, 41.4, 44.8, 'r24', 'Nunito', 6, 600, '#767685', va='center', zorder=5)
    U.rr(ax, 46, 44, 6, 4, 3, fc=P['primary'], zorder=4); U.text(ax, 53.4, 44.8, 'full', 'Nunito', 6, 600, '#767685', va='center', zorder=5)
    PL.card(ax, 53, 56, 41, 10, title='Glass & soft shadows')
    for ln in U.wrap(ax, 'Floating cards sit on soft indigo shadows (never black). Translucent white layers create a subtle glass effect over gradient headers.',
                     'Nunito', 9, 600, 36, 4):
        U.text(ax, 55.4, 51.4, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    U.card(ax, 56, 44, 9, 6, r=8, fc='#FFFFFF', level=1); U.card(ax, 67, 44, 9, 6, r=8, fc='#FFFFFF', level=2)
    U.card(ax, 78, 44, 9, 6, r=8, fc='#FFFFFF', level=3)
    U.text(ax, 60, 42, 'L0', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.text(ax, 71, 42, 'L1', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.text(ax, 82, 42, 'L2', 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    PL.card(ax, 6, 32, 88, 9, title='Brand gradients')
    U.gradient_rect(ax, 8, 26, 26, 4.4, 8, '#4F6BF5', '#7A5BF5', zorder=4)
    U.text(ax, 11, 28, 'Primary hero', 'Nunito', 7, 700, '#FFFFFF', va='center', zorder=5)
    U.gradient_rect(ax, 38, 26, 26, 4.4, 8, '#FF8A3D', '#FFB37A', zorder=4)
    U.text(ax, 41, 28, 'Secondary', 'Nunito', 7, 700, '#FFFFFF', va='center', zorder=5)
    U.gradient_rect(ax, 68, 26, 26, 4.4, 8, '#FFC93C', '#FFE08A', zorder=4)
    U.text(ax, 71, 28, 'Sunshine accent', 'Nunito', 7, 700, '#45260A', va='center', zorder=5)
    for ln in U.wrap(ax, 'Gradients are used for hero surfaces, headers and celebrations. Body content always sits on flat, quiet surfaces so text stays readable.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 22.4, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Layout & Grid', 'An 8dp system, tablet-first')
    fig, ax = d.page('Layout tokens', 'The numbers behind every screen')
    rows = [('Screen padding', '24dp', 'All edges of the content area'),
            ('Card padding', '20dp', 'Inside cards, below titles'),
            ('Grid gap', '16dp', 'Between cards and columns'),
            ('Grid columns', '6 (medium) / 12 (expanded)', 'Tablet portrait and landscape'),
            ('Content max width', '880dp', 'Centred on very large screens'),
            ('Touch target', '48dp minimum', 'Never compromise tap targets'),
            ('Bottom nav height', '80dp', '5 destinations, active pill'),
            ('App bar height', '64dp', 'Child gradient header / parent white')]
    y = 62
    for name, val, use in rows:
        U.text(ax, 8, y, name, 'Nunito', 9.5, 800, '#191A24', zorder=5)
        U.text(ax, 34, y, val, 'Nunito', 9.5, 700, '#4F6BF5', zorder=5)
        U.text(ax, 58, y, use, 'Nunito', 8.5, 500, '#767685', zorder=5)
        y -= 6.2
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Grid in practice', 'Tablet portrait (primary target)')
    U.card(ax, 8, 16, 84, 46, r=16, fc='#FFFFFF', level=2, zorder=3)
    U.rr(ax, 12, 56, 76, 3.2, 6, fc='#4F6BF5', zorder=4)
    for i in range(6):
        x = 12 + i * 12.6
        U.rr(ax, x, 14, 10, 38, 6, fc='#E9EAF6' if i % 3 else '#DDE5FF', zorder=4)
        if i in (0, 1):
            U.rr(ax, x + 0.8, 14, 8.4, 10, 5, fc='#FFFFFF', zorder=4.2)
        U.text(ax, x + 5, 10.5, '%d' % (i + 1), 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=5)
    U.text(ax, 50, 8, '6-column grid \u00b7 24dp margins \u00b7 16dp gutters', 'Nunito', 8, 600, '#767685', ha='center', va='center', zorder=5)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Components Overview', 'A small, consistent set')
    fig, ax = d.page('The building blocks', 'Full specs in the Component Library guide')
    boards = [('01', 'Buttons & actions', '01_buttons.png'), ('02', 'Cards & containers', '02_cards.png'),
              ('03', 'Chips & status', '03_chips.png'), ('04', 'Inputs & PIN', '04_inputs.png'),
              ('05', 'Navigation', '05_navigation.png'), ('06', 'Charts & progress', '06_charts.png'),
              ('07', 'Dialogs & snackbars', '07_dialogs.png'), ('08', 'Avatars & mascot', '08_avatars.png')]
    for i, (num, nm, img) in enumerate(boards):
        col_i, row = i % 4, i // 4
        x = 6 + col_i * 23
        y = 56 - row * 25
        PL.card(ax, x, y, 21.5, 23, title=nm)
        embed(ax, os.path.join(COMPS, img), x + 2, y + 2, 17.5, 17.5)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'Feedback & States', 'Nothing is ever silent or stuck')
    fig, ax = d.page('Loading, empty, error, celebration', 'Four states every screen must handle')
    states = [('Loading', 'Three bouncing dots or a spinning coin with soft pulse. Under 400ms always.', '#4F6BF5', 'sparkle'),
              ('Empty', 'Friendly illustration, short guidance, one clear next action.', '#B9BAC6', 'help'),
              ('Error', 'Warm message, no jargon, and a retry that actually works.', '#E5484D', 'info'),
              ('Celebration', 'Confetti, badges and coin flights reward every completed task.', '#E8A500', 'star')]
    for i, (t, desc, col, ic) in enumerate(states):
        col_i, row = i % 2, i // 2
        x = 6 + col_i * 45
        y = 52 - row * 23
        PL.card(ax, x, y, 43, 21, title=t)
        U.icon_badge_circle(ax, x + 5, y + 16, 3.8, ic, U.hx(col, 0.14), fg=col, ic=4, zorder=4)
        yy = y + 11.6
        for ln in U.wrap(ax, desc, 'Nunito', 8.5, 600, 37, 4):
            U.text(ax, x + 2.4, yy, ln, 'Nunito', 8.5, 600, '#43434F', zorder=5)
            yy -= 4.2
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(6, 'Accessibility & Dark Mode', 'Inclusive by default')
    fig, ax = d.page('Contrast and touch', 'Minimums we commit to')
    rows = [('Text contrast', '4.5:1 for body text, 3:1 for large display type'),
            ('Touch targets', '48dp minimum, 24dp spacing between targets'),
            ('Colour not alone', 'Statuses pair colour with icon and label'),
            ('Type sizes', 'Body text never below 14sp; captions 12sp minimum'),
            ('Reduce motion', 'Honour the system setting; disable confetti and springs')]
    y = 62
    for k, v in rows:
        U.text(ax, 8, y, k, 'Nunito', 9.5, 800, '#191A24', zorder=5)
        for ln in U.wrap(ax, v, 'Nunito', 9, 600, 72, 2):
            U.text(ax, 30, y, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
        y -= 6.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Dark theme', 'Night-friendly surfaces')
    U.gradient_rect(ax, 6, 20, 88, 40, 16, T.DARK['surface'], '#12131A', zorder=3)
    U.rr(ax, 12, 46, 30, 10, 10, fc=T.DARK['surfaceContainer'], zorder=4)
    U.text(ax, 14, 50.6, 'Surface container', 'Nunito', 8, 700, T.DARK['onSurface'], zorder=5)
    U.text(ax, 14, 48.2, '#23242F', 'Nunito', 6.5, 500, T.DARK['onSurfaceVariant'], zorder=5)
    U.rr(ax, 46, 46, 30, 10, 10, fc=T.DARK['primaryContainer'], zorder=4)
    U.text(ax, 48, 50.6, 'Primary container', 'Nunito', 8, 700, T.DARK['onPrimaryContainer'], zorder=5)
    U.text(ax, 48, 48.2, '#334798', 'Nunito', 6.5, 500, T.DARK['onPrimaryContainer'], zorder=5)
    U.rr(ax, 80, 46, 12, 10, 10, fc=T.DARK['surfaceVariant'], zorder=4)
    for ln in U.wrap(ax, 'Dark mode keeps the same brand hues but lowers surface luminance and raises accent luminance for contrast on dark backgrounds.',
                     'Nunito', 9, 600, 82, 3):
        U.text(ax, 8, 24, ln, 'Nunito', 9, 600, T.DARK['onSurface'], zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 2 COLOR
def guide_color():
    d = PL.Doc(os.path.join(OUT, 'Color_Palette.pdf'), 'Color Palette Guide')
    d.cover('Color Palette', 'A joyful, disciplined colour system',
            ['Brand colours', 'Accent colours', 'Semantic & status',
             'Badge tiers', 'Surfaces (light)', 'Dark theme', 'Usage & contrast'])
    d.chapter(1, 'Brand Colours', 'The emotional core')
    fig, ax = d.page('Primary, secondary, tertiary', 'Used for actions, highlights and identity')
    brand = [('Primary', P['primary'], '#FFFFFF'), ('On primary', '#FFFFFF', '#4F6BF5'),
             ('Primary container', P['primaryContainer'], '#0E1E5C'), ('Secondary', P['secondary'], '#FFFFFF'),
             ('Secondary container', P['secondaryContainer'], '#45260A'), ('Tertiary', P['tertiary'], '#FFFFFF')]
    for i, (nm, c, on) in enumerate(brand):
        col_i, row = i % 3, i // 3
        x = 8 + col_i * 30
        y = 56 - row * 16
        PL.swatch(ax, x, y, 26, 12, c, name=nm, hexv=c, r=10)
        U.text(ax, x + 13, y + 4, nm, 'Nunito', 8, 800, on, ha='center', va='center', zorder=6)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Colour roles', 'How brand colours behave')
    roles = [('Primary', 'Buttons, active nav, links, focus rings. The family trust colour \u2013 present on every screen.'),
             ('Secondary', 'Child-mode actions, rewards, FABs. Warm orange signals \u201cfor kids\u201d.'),
             ('Tertiary', 'Verified states, success accents on brand surfaces. Teal \u201cgood\u201d moments.'),
             ('Containers', 'Soft tinted backgrounds for chips, icon badges and emphasised areas.')]
    y = 62
    for k, v in roles:
        U.text(ax, 8, y, k, 'Nunito', 9.5, 800, '#191A24', zorder=5)
        for ln in U.wrap(ax, v, 'Nunito', 9, 600, 74, 3):
            U.text(ax, 30, y, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
        y -= 7.2
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'Accent Colours', 'Six playful helpers')
    fig, ax = d.page('Accents', 'For child avatars, categories and delight')
    accents = [('Sunshine', A['sunshine']), ('Candy', A['candy']), ('Sky', A['sky']),
               ('Grape', A['grape']), ('Mint', A['mint']), ('Peach', A['peach'])]
    for i, (nm, c) in enumerate(accents):
        col_i, row = i % 3, i // 3
        x = 8 + col_i * 30
        y = 52 - row * 18
        PL.swatch(ax, x, y, 26, 12, c, name=nm, hexv=c, r=10)
        U.text(ax, x + 13, y + 4, nm, 'Nunito', 8, 800, '#FFFFFF', ha='center', va='center', zorder=6)
    for ln in U.wrap(ax, 'Accents are used sparingly for identity (child avatars), category icons and celebratory moments. Never more than three on one screen.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 20, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Semantic & Status', 'Feedback colours with meaning')
    fig, ax = d.page('Semantic colours', 'Success, warning, error, info')
    sem = [('Success', P['success'], 'Tasks approved, coins earned'), ('Warning', P['warning'], 'Pending tasks, approvals'),
           ('Error', P['error'], 'Rejected tasks, destructive actions'), ('Info', P['info'], 'Tips, neutral information')]
    for i, (nm, c, use) in enumerate(sem):
        col_i, row = i % 2, i // 2
        x = 8 + col_i * 45
        y = 56 - row * 16
        PL.swatch(ax, x, y, 41, 12, c, name=nm, hexv=c, r=10)
        U.text(ax, x + 20.5, y + 4, nm, 'Nunito', 8, 800, '#FFFFFF', ha='center', va='center', zorder=6)
        U.text(ax, x + 20.5, y + 10.4, use, 'Nunito', 7.5, 600, '#191A24', ha='center', va='center', zorder=6)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Task status colours', 'Six states, never colour alone')
    statuses = [('Completed', 'completed'), ('Pending', 'pending'), ('Rejected', 'rejected'),
                ('Verified', 'verified'), ('Missed', 'missed'), ('Locked', 'locked')]
    for i, (nm, key) in enumerate(statuses):
        col_i, row = i % 3, i // 3
        x = 8 + col_i * 30
        y = 56 - row * 15
        PL.swatch(ax, x, y, 26, 11, S[key], name=nm, hexv=S[key], r=10)
        U.text(ax, x + 13, y + 4, nm, 'Nunito', 8, 800, '#FFFFFF', ha='center', va='center', zorder=6)
    for ln in U.wrap(ax, 'Every status pairs a colour chip with an icon and a label (e.g. a clock for Pending). This keeps the app usable with colour blindness or in greyscale.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 22, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Badge Tiers', 'Progress feels shiny')
    fig, ax = d.page('Four achievement tiers', 'Bronze to diamond')
    tiers = [('Bronze', '#C98A5B'), ('Silver', '#9AA4B5'), ('Gold', '#E8A500'), ('Diamond', '#3FB9E0')]
    for i, (nm, c) in enumerate(tiers):
        x = 10 + i * 22
        PL.swatch(ax, x, 50, 18, 12, c, r=10)
        U.icon_badge_circle(ax, x + 9, 56, 4, 'medal', c, fg='#FFFFFF', ic=4.4, zorder=6)
        U.text(ax, x + 9, 47.6, nm, 'Nunito', 8, 800, '#191A24', ha='center', va='center', zorder=6)
        U.text(ax, x + 9, 45.0, c, 'Nunito', 6.5, 600, '#767685', ha='center', va='center', zorder=6)
    for ln in U.wrap(ax, 'Badges in the same tier share one gold-to-diamond language. Tier colours never replace semantic colours.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 36, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'Surfaces & Dark Theme', 'The stage for the content')
    fig, ax = d.page('Light surfaces', 'Quiet backgrounds, crisp content')
    surf = [('Background', P['background']), ('Surface', P['surface']), ('Container', P['surfaceContainer']),
            ('High', P['surfaceContainerHigh']), ('Variant', P['surfaceVariant']), ('On surface', P['onSurface'])]
    for i, (nm, c) in enumerate(surf):
        col_i, row = i % 3, i // 3
        x = 8 + col_i * 30
        y = 54 - row * 16
        PL.swatch(ax, x, y, 26, 11, c, name=nm, hexv=c, r=10)
        U.text(ax, x + 13, y + 4, nm, 'Nunito', 8, 800, '#FFFFFF', ha='center', va='center', zorder=6)
    for ln in U.wrap(ax, 'Cards sit on Surface; the screen rests on Background. A cool near-white keeps everything calm so brand colours can shine.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 22, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Dark surfaces', 'Same hues, night-safe luminance')
    U.gradient_rect(ax, 6, 14, 88, 52, 16, T.DARK['surface'], '#0E0E14', zorder=3)
    dark = [('Surface', T.DARK['surface']), ('Container', T.DARK['surfaceContainer']),
            ('High', T.DARK['surfaceContainerHigh']), ('Variant', T.DARK['surfaceVariant']),
            ('Primary', T.DARK['primary']), ('On surface', T.DARK['onSurface'])]
    for i, (nm, c) in enumerate(dark):
        col_i, row = i % 3, i // 3
        x = 12 + col_i * 28
        y = 56 - row * 15
        PL.swatch(ax, x, y, 24, 10, c, name=nm, hexv=c, r=9)
        U.text(ax, x + 12, y + 3.6, nm, 'Nunito', 7.5, 800, '#FFFFFF', ha='center', va='center', zorder=6)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(6, 'Usage & Contrast', 'Colour discipline')
    fig, ax = d.page('Rules of thumb', '60 / 30 / 10 and beyond')
    rules = [('Proportion', '60% neutrals, 30% brand, 10% accents on any screen.'),
             ('Contrast', 'Body text needs 4.5:1; large display text 3:1. Never place brand blue text on brand blue.'),
             ('Emotion', 'Green means good, red means stop \u2013 do not re-purpose semantic colours for decoration.'),
             ('Dark mode', 'Use the dark token set; never lower accent brightness below 4.5:1 on dark surfaces.'),
             ('Testing', 'Check every screen in greyscale and with a 2.0 colour-blind filter.')]
    y = 62
    for k, v in rules:
        U.text(ax, 8, y, k, 'Nunito', 9.5, 800, '#191A24', zorder=5)
        for ln in U.wrap(ax, v, 'Nunito', 9, 600, 72, 3):
            U.text(ax, 30, y, ln, 'Nunito', 9, 600, '#43434F', zorder=5); break
        y -= 7.2
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 3 TYPOGRAPHY
def guide_typography():
    d = PL.Doc(os.path.join(OUT, 'Typography_Guide.pdf'), 'Typography Guide')
    d.cover('Typography Guide', 'Baloo 2, Quicksand and Nunito working together',
            ['Font roles', 'The type scale', 'Hierarchy in use', 'Numbers & totals', 'Good practice'])
    d.chapter(1, 'Font Roles', 'Three families, one voice')
    fig, ax = d.page('The family system', 'Why three fonts')
    roles = [('Baloo 2', 'Display & headlines', 'Round, friendly, high-energy. Reserved for child-mode heroes, greetings and big numbers. Weights 700\u2013800.', 800),
             ('Quicksand', 'Child UI & numerals', 'Soft geometric with wide, open letters. Used for task names, buttons and coin totals in child mode.', 700),
             ('Nunito', 'Body & parent UI', 'Highly readable at small sizes. All body text, labels, parent screens, tables and data. Weights 400\u2013800.', 700)]
    for i, (fam, role, desc, w) in enumerate(roles):
        y = 58 - i * 14.5
        PL.card(ax, 6, y, 88, 13, title=fam)
        U.text(ax, 10, y + 8.2, role, 'Nunito', 10, 800, '#4F6BF5', zorder=6)
        for ln in U.wrap(ax, desc, 'Nunito', 8.5, 600, 76, 3):
            U.text(ax, 10, y + 4.6, ln, 'Nunito', 8.5, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'The Type Scale', 'Ten sizes, three families')
    fig, ax = d.page('Full scale', 'Name \u00b7 family \u00b7 size/line \u00b7 weight')
    types = T.TYPES[:10]
    for i, (nm, fam, sz, lh, w, use) in enumerate(types):
        y = 62 - i * 5.9
        PL.tag(ax, 10, y, nm, bg='#EEF0F8', fg='#43434F')
        sample = {'Display Large': '240', 'Display Medium': 'Great!', 'Display Small': 'Coins',
                  'Headline Large': 'My Tasks', 'Headline Medium': 'Rewards',
                  'Headline Small': 'Badge earned', 'Title Large': 'Family Dashboard',
                  'Title Medium': 'Manage Children', 'Body Large': 'Turn chores into fun.',
                  'Body Medium': 'Parents stay in control.'}.get(nm, 'Sample')
        U.text(ax, 38, y, sample, fam, sz, w, '#191A24', va='center', zorder=6)
        U.text(ax, 88, y, '%d/%d \u00b7 %s' % (sz, lh, fam.split(' ')[0]), 'Nunito', 7, 600, '#767685', ha='right', va='center', zorder=6)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Hierarchy in Use', 'Headlines that lead, captions that follow')
    fig, ax = d.page('Child vs parent mode', 'Different voices, same hierarchy logic')
    U.gradient_rect(ax, 6, 48, 43, 18, 14, '#4F6BF5', '#7A5BF5', zorder=3)
    U.text(ax, 10, 61.5, 'Good morning, Mia!', 'Baloo 2', 17, 700, '#FFFFFF', zorder=6)
    U.text(ax, 10, 57.5, 'Drink your water task', 'Quicksand', 11, 700, '#DDE5FF', zorder=6)
    U.text(ax, 10, 54.5, '8:00 am \u00b7 Health', 'Nunito', 8, 600, '#D6DCFE', zorder=6)
    U.text(ax, 10, 51.5, '+5 coins on completion', 'Nunito', 8, 600, '#C4F6E8', zorder=6)
    U.card(ax, 53, 48, 41, 18, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 57, 61.5, 'Family Dashboard', 'Nunito', 14, 800, '#191A24', zorder=6)
    U.text(ax, 57, 57.5, 'Mon, 3 Aug 2026', 'Nunito', 9, 600, '#767685', zorder=6)
    U.text(ax, 57, 53.5, 'Task completion', 'Nunito', 9.5, 700, '#191A24', zorder=6)
    U.text(ax, 57, 50.5, '81% this week \u00b7 +6%', 'Nunito', 8, 600, '#2FAE66', zorder=6)
    for ln in U.wrap(ax, 'Child mode leads with Baloo 2 headlines in the header gradient; parent mode leads with Nunito titles on white. Body and captions share the same scale.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 36, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Numbers & Totals', 'Coin counts need rhythm')
    fig, ax = d.page('Tabular figures', 'Stable totals, no jitter')
    U.card(ax, 8, 52, 42, 14, r=14, fc='#FFF7E0', level=1, zorder=3)
    U.text(ax, 12, 62.5, 'Coin balance', 'Nunito', 9, 700, '#8A5A00', zorder=6)
    U.text(ax, 12, 57.5, '240', 'Nunito', 26, 800, '#0E1E5C', zorder=6)
    U.card(ax, 54, 52, 38, 14, r=14, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 58, 62.5, 'Weekly total', 'Nunito', 9, 700, '#767685', zorder=6)
    U.text(ax, 58, 57.5, '1,042', 'Nunito', 20, 800, '#191A24', zorder=6)
    U.text(ax, 58, 54.5, 'Quicksand tabular numerals', 'Nunito', 7.5, 600, '#767685', zorder=6)
    for ln in U.wrap(ax, 'All numeric totals use Quicksand for child mode and Nunito for parent mode, with tabular figures enabled so counts line up in lists and leaderboards.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 42, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'Good Practice', 'Rules that keep text legible')
    fig, ax = d.page('Do & don\u2019t', 'Typography hygiene')
    dos = [('Do', 'Use sentence case everywhere \u2013 this is a friendly app.', '#2FAE66'),
           ('Do', 'Truncate with ellipses; never let text overflow cards.', '#2FAE66'),
           ('Do', 'Keep line length under 66 characters for body text.', '#2FAE66'),
           ('Don\u2019t', 'Don\u2019t use ALL CAPS outside buttons and chips.', '#E5484D'),
           ('Don\u2019t', 'Don\u2019t mix more than two families on one screen.', '#E5484D'),
           ('Don\u2019t', 'Don\u2019t scale display type below 24dp \u2013 it becomes mud.', '#E5484D')]
    y = 62
    for t, v, col in dos:
        PL.tag(ax, 10, y, t, bg=U.hx(col, 0.14), fg=col)
        for ln in U.wrap(ax, v, 'Nunito', 9, 600, 66, 2):
            U.text(ax, 28, y, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
        y -= 6.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 4 COMPONENTS
def guide_components():
    d = PL.Doc(os.path.join(OUT, 'Component_Library.pdf'), 'Component Library')
    d.cover('Component Library', 'Every building block, specified',
            ['Buttons', 'Cards', 'Chips & status', 'Inputs', 'Navigation',
             'Charts & progress', 'Dialogs & snackbars', 'Avatars', 'Typography', 'Colour', 'Spacing'])
    boards = [('01', 'Buttons & Actions', '01_buttons.png'), ('02', 'Cards & Containers', '02_cards.png'),
              ('03', 'Chips, Badges & Status', '03_chips.png'), ('04', 'Inputs & Forms', '04_inputs.png'),
              ('05', 'Navigation & App Chrome', '05_navigation.png'), ('06', 'Charts & Progress', '06_charts.png'),
              ('07', 'Dialogs, Snackbars & Empty', '07_dialogs.png'), ('08', 'Avatars, Mascot & Icons', '08_avatars.png'),
              ('09', 'Typography Scale', '09_typography.png'), ('10', 'Colour Palette', '10_colors.png'),
              ('11', 'Spacing & Layout', '11_spacing.png')]
    for num, nm, img in boards:
        d.chapter(num, nm, 'From the component boards')
        fig, ax = d.page('Component: ' + nm, 'Full reference board')
        embed(ax, os.path.join(COMPS, img), 3, 5, 94, 61)
        fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Implementation checklist', 'When you build a screen')
    items = ['Every card uses a component, never a bespoke rectangle.',
             'Buttons are 48dp high with 16dp radius; FABs are 56dp.',
             'Statuses use the six-state palette with icon + label.',
             'Coin chips show numbers in Quicksand tabular figures.',
             'Touch targets are 48dp, spacing follows the 8dp grid.',
             'Dark mode swaps to the DARK token set automatically.']
    y = 62
    for it in items:
        U._circle(ax, 10, y, 1.4, '#2FAE66', zorder=5)
        U.text(ax, 15, y, it, 'Nunito', 9.5, 600, '#191A24', va='center', zorder=5)
        y -= 7.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 5 ANIMATION
def guide_animation():
    d = PL.Doc(os.path.join(OUT, 'Animation_Guide.pdf'), 'Animation Guide')
    d.cover('Animation Guide', 'Motion that feels like magic, never noise',
            ['Principles', 'Duration & curves', 'Micro-interactions', 'Loading & celebration', 'Reference table'])
    d.chapter(1, 'Principles', 'Why motion matters')
    fig, ax = d.page('Three principles', 'Purposeful, fast, joyful')
    prin = [('Purposeful', 'Every animation explains something: where the coins went, what unlocked, what changed. If it adds no meaning, remove it.', '#4F6BF5'),
            ('Fast', 'UI motion stays under 350ms. Celebrations may reach 750ms but only for a reason.', '#FF8A3D'),
            ('Joyful', 'Springs and bounce give earned moments life. Confetti rewards success instead of decorating defaults.', '#E8A500')]
    for i, (t, desc, col) in enumerate(prin):
        y = 58 - i * 12
        PL.card(ax, 6, y, 88, 11, title=t)
        U.icon_badge_circle(ax, 12, y + 6, 3, ['target', 'lightning', 'sparkle'][i], U.hx(col, 0.14), fg=col, ic=3.2, zorder=5)
        for ln in U.wrap(ax, desc, 'Nunito', 9, 600, 72, 3):
            U.text(ax, 18, y + 2.6, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'Duration & Curves', 'The tempo of the app')
    fig, ax = d.page('Durations', 'Seven reference speeds')
    durs = [('Instant', 50, 'Hover, press feedback'), ('Fast', 150, 'Icon changes, toggles'),
            ('Normal', 250, 'Card entrances, transitions'), ('Gentle', 350, 'Dialogs, sheets'),
            ('Slow', 500, 'Large containers'), ('Extra', 750, 'Celebrations, confetti')]
    y = 62
    for nm, ms, use in durs:
        U.text(ax, 10, y, nm, 'Nunito', 9, 800, '#191A24', zorder=6)
        U.text(ax, 24, y, '%dms' % ms, 'Nunito', 9, 700, '#4F6BF5', zorder=6)
        U.rr(ax, 40, y - 1.2, min(44, ms / 750 * 44), 2.2, 1.1, fc='#4F6BF5', zorder=5)
        U.text(ax, 88, y, use, 'Nunito', 8, 600, '#767685', ha='right', va='center', zorder=6)
        y -= 6.0
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Easing curves', 'Cubic-bezier charts for our easings')
    curves = [('Standard', (0.2, 0.0, 0.0, 1.0), '#4F6BF5'),
              ('Emphasized', (0.3, 0.0, 0.1, 1.0), '#FF8A3D'),
              ('Decelerate', (0.0, 0.0, 0.2, 1.0), '#2FAE66'),
              ('Accelerate', (0.4, 0.0, 1.0, 1.0), '#E5484D')]
    for i, (nm, (x1, y1, x2, y2), col) in enumerate(curves):
        col_i, row = i % 2, i // 2
        x = 8 + col_i * 45
        y = 56 - row * 20
        PL.card(ax, x, y, 41, 18, title=nm)
        pts = []
        for t in np.linspace(0, 1, 60):
            mt = 1 - t
            px = 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t
            py = 3 * mt * mt * t * y1 + 3 * mt * t * t * y2 + t * t * t
            pts.append((x + 4 + px * 33, y + 3 + py * 12))
        U._line(ax, [(x + 4, y + 3), (x + 4, y + 15), (x + 37, y + 15)], '#E9EAF6', 1.2, zorder=4)
        U._line(ax, pts, col, 2.2, zorder=5)
        U.text(ax, x + 4, y + 15.8, 'cubic-bezier(%s)' % ', '.join(str(v) for v in (x1, y1, x2, y2)),
               'Nunito', 6.5, 600, '#767685', va='top', zorder=6)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Micro-interactions', 'The details users feel')
    fig, ax = d.page('Signature moments', 'Specified for implementation')
    anims = ['Coin fly: coin pops at task card, arcs to the header balance, then the total counts up over 450ms with a bounce.',
             'Check draw: the check mark draws itself over 500ms while the card pulses green; a coin flies immediately after.',
             'Confetti: bursts from the task card on completion; particles fall and rotate for 750ms with the standard curve.',
             'Badge unlock: the badge scales 0 to 1 with a golden glow ring over 600ms bounce.',
             'Reward claim: card lifts, confetti at the top, then a check stamp appears for 500ms.',
             'Tab switch: content cross-fades 250ms while the active pill slides under the destination.']
    y = 62
    for i, a in enumerate(anims):
        U._circle(ax, 10, y, 1.5, ['#FFC93C', '#2FAE66', '#FF7BA9', '#E8A500', '#A98BFF', '#4F6BF5'][i], zorder=5)
        yy = y
        for ln in U.wrap(ax, a, 'Nunito', 9, 600, 80, 3):
            U.text(ax, 15, yy, ln, 'Nunito', 9, 600, '#191A24', zorder=6)
            yy -= 4.2
        y = yy - 3.6
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Loading & Celebration', 'Worth waiting for')
    fig, ax = d.page('Loading patterns', 'Never a frozen frame')
    for i, (nm, desc, col) in enumerate((('Spinner coin', 'A coin spins with a soft pulse, 1000ms loop, decelerate.', '#FFC93C'),
                                         ('Bouncing dots', 'Three dots bounce in sequence under any empty content.', '#4F6BF5'),
                                         ('Skeleton cards', 'Rounded bars shimmer at 8% opacity sweep, 900ms.', '#B9BAC6'))):
        x = 8 + i * 30
        PL.card(ax, x, 46, 26, 14, title=nm)
        U._circle(ax, x + 13, 53, 3.4, col, zorder=5)
        U._circle(ax, x + 13, 53, 1.8, U.hx('#FFFFFF', 0.85), zorder=6)
        for ln in U.wrap(ax, desc, 'Nunito', 8, 600, 22, 4):
            U.text(ax, x + 2, 48.6, ln, 'Nunito', 8, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    fig, ax = d.page('Celebration levels', 'Match the moment')
    levels = [('Small', 'Coin pop +5 on every completed task', 'sparkle', '#FFC93C'),
              ('Medium', 'Badge unlock banner with glow ring', 'badge', '#E8A500'),
              ('Large', 'Full confetti + toast for 7-day streaks', 'trophy', '#FF7BA9')]
    for i, (nm, desc, ic, col) in enumerate(levels):
        y = 56 - i * 11
        PL.card(ax, 6, y, 88, 10, title=nm + ' celebration')
        U.icon_badge_circle(ax, 14, y + 6, 3.4, ic, U.hx(col, 0.14), fg=col, ic=3.6, zorder=5)
        for ln in U.wrap(ax, desc, 'Nunito', 9, 600, 72, 2):
            U.text(ax, 20, y + 2.4, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    for ln in U.wrap(ax, 'Respect \u201creduce motion\u201d: swap springs and confetti for simple cross-fades and no motion.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 20, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'Reference Table', 'Every animation token')
    fig, ax = d.page('Animation tokens', 'Name \u00b7 duration \u00b7 curve \u00b7 behaviour')
    y = 61.5
    U.text(ax, 8, y, 'Animation', 'Nunito', 8, 800, '#191A24', zorder=6)
    U.text(ax, 30, y, 'ms', 'Nunito', 8, 800, '#191A24', zorder=6)
    U.text(ax, 42, y, 'Curve', 'Nunito', 8, 800, '#191A24', zorder=6)
    U.text(ax, 88, y, 'Behaviour', 'Nunito', 8, 800, '#191A24', ha='right', zorder=6)
    y -= 3.4
    for nm, dta in T.ANIMATIONS.items():
        if y < 8:
            break
        U.text(ax, 8, y, nm, 'Nunito', 7.5, 700, '#4F6BF5', zorder=6)
        U.text(ax, 30, y, str(dta['duration']), 'Nunito', 7.5, 600, '#191A24', zorder=6)
        U.text(ax, 42, y, dta['curve'], 'Nunito', 7, 600, '#767685', zorder=6)
        U.text(ax, 88, y, dta['desc'][:40], 'Nunito', 7, 600, '#767685', ha='right', zorder=6)
        y -= 3.7
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 6 RESPONSIVE
def guide_responsive():
    d = PL.Doc(os.path.join(OUT, 'Responsive_Guide.pdf'), 'Responsive Guide')
    d.cover('Responsive Guide', 'One app, every screen size',
            ['Breakpoints', 'Layouts', 'Grid system', 'Adaptive components', 'Best practices'])
    d.chapter(1, 'Breakpoints', 'Three tiers, tablet-first')
    fig, ax = d.page('Breakpoint table', 'Width in dp')
    rows = [('Compact', '< 600dp', 'Phone portrait', 'Single column, bottom nav condenses to 4 items, headers shrink.', '4F6BF5'),
            ('Medium', '600 \u2013 840dp', 'Tablet portrait (primary)', '6-column grid, full child header, 5-item bottom nav.', '2FAE66'),
            ('Expanded', '> 840dp', 'Tablet landscape & desktop', '12-column grid, side navigation optional, content max 880dp.', 'E8A500')]
    y = 58
    for nm, rng, dev, use, col in rows:
        PL.card(ax, 6, y, 88, 13, title=nm)
        U.text(ax, 10, y + 8.6, rng, 'Nunito', 10, 800, '#' + col, zorder=6)
        U.text(ax, 26, y + 8.6, dev, 'Nunito', 9, 700, '#191A24', zorder=6)
        for ln in U.wrap(ax, use, 'Nunito', 8.5, 600, 62, 2):
            U.text(ax, 52, y + 8.6, ln, 'Nunito', 8.5, 600, '#43434F', zorder=6); break
        y -= 15.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'Layouts', 'How screens reflow')
    fig, ax = d.page('Phone vs tablet', 'Same content, different rhythm')
    def phone(ax, x, y, w, h, label):
        U.rr(ax, x, y, w, h, 10, fc='#FFFFFF', ec='#E9EAF6', lw=1.4, zorder=3)
        U.rr(ax, x + 2, y + h - 6, w - 4, 5, 4, fc='#4F6BF5', zorder=4)
        U.rr(ax, x + 2, y + 2, w - 4, h - 11, 4, fc='#F1F2FB', zorder=3.5)
        U.rr(ax, x + 2, y + 2, w - 4, 3.4, 4, fc='#FFFFFF', zorder=4)
        U.rr(ax, x + 3, y + 2.6, w * 0.5, 2.2, 2, fc='#DDE5FF', zorder=5)
        U.rr(ax, x + w - 3 - w * 0.28, y + 2.6, w * 0.28, 2.2, 2, fc='#FFE0C7', zorder=5)
    phone(ax, 8, 26, 24, 38, 'Phone')
    phone(ax, 40, 16, 34, 50, 'Tablet')
    U.card(ax, 78, 22, 16, 38, r=10, fc='#FFFFFF', level=1, zorder=3)
    U.text(ax, 86, 54, 'Desktop', 'Nunito', 8, 700, '#191A24', ha='center', va='center', zorder=5)
    U.rr(ax, 80, 34, 12, 20, 4, fc='#EEF0F8', zorder=4)
    U.rr(ax, 80, 52, 12, 4, 2, fc='#FFE0C7', zorder=4)
    for ln in U.wrap(ax, 'On phones the dashboard stacks vertically with a compact header. On tablet portrait content spreads across a 6-column grid; the reward grid goes 2\u00d72. On desktop, the content stays centred and never exceeds 880dp.',
                     'Nunito', 8.5, 600, 86, 4):
        U.text(ax, 8, 14, ln, 'Nunito', 8.5, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Grid System', 'Consistent rhythm at every width')
    fig, ax = d.page('Column math', 'Margins and gutters scale with width')
    U.text(ax, 8, 62, 'Compact < 600dp \u00b7 4 columns \u00b7 margin 16 \u00b7 gutter 12', 'Nunito', 8.5, 700, '#191A24', zorder=6)
    U.rr(ax, 6, 50, 88, 8, 6, fc='#FFFFFF', ec='#E9EAF6', lw=1, zorder=3)
    for i in range(4):
        U.rr(ax, 8 + i * 21.8, 51, 18, 6, 4, fc='#DDE5FF', zorder=4)
    U.text(ax, 8, 42, 'Medium 600-840dp \u00b7 6 columns \u00b7 margin 24 \u00b7 gutter 16', 'Nunito', 8.5, 700, '#191A24', zorder=6)
    U.rr(ax, 6, 30, 88, 8, 6, fc='#FFFFFF', ec='#E9EAF6', lw=1, zorder=3)
    for i in range(6):
        U.rr(ax, 8 + i * 14.4, 31, 11.6, 6, 4, fc='#DDE5FF', zorder=4)
    U.text(ax, 8, 22, 'Expanded > 840dp \u00b7 12 columns \u00b7 margin 48 \u00b7 gutter 16', 'Nunito', 8.5, 700, '#191A24', zorder=6)
    U.rr(ax, 6, 10, 88, 8, 6, fc='#FFFFFF', ec='#E9EAF6', lw=1, zorder=3)
    for i in range(12):
        U.rr(ax, 8 + i * 7.2, 11, 5.6, 6, 4, fc='#DDE5FF', zorder=4)
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Adaptive Components', 'Components that know the screen')
    fig, ax = d.page('What changes at each tier', 'The component playbook')
    ad = [('Bottom nav', '5 items on tablet; 4 items with \u201cMore\u201d on phone.', '#4F6BF5'),
          ('Child header', 'Full gradient + greeting on tablet; compact row on phone.', '#FF8A3D'),
          ('Card grids', 'Rewards 2\u00d72 on tablet; single column on phone; 3\u00d72 on desktop.', '#2FAE66'),
          ('Charts', 'Full charts on tablet; sparklines on phone with a \u201cView report\u201d link.', '#A98BFF'),
          ('Dialog width', 'Cards cap at 360dp; centred on all tiers.', '#E8A500')]
    y = 62
    for nm, desc, col in ad:
        PL.tag(ax, 10, y, nm, bg=U.hx(col, 0.14), fg=col)
        for ln in U.wrap(ax, desc, 'Nunito', 9, 600, 66, 2):
            U.text(ax, 32, y, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
        y -= 7.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'Best Practices', 'Responsive hygiene')
    fig, ax = d.page('Rules to remember', 'Keep it simple at every size')
    for i, r in enumerate(['Design for the tablet portrait first, then scale down then up.',
                           'Never hide important actions behind a size threshold \u2013 adapt, don\u2019t remove.',
                           'Use FluidContent with min/max so text wraps instead of truncating.',
                           'Test at 320dp, 600dp, 800dp, 1024dp and 1280dp before releasing.']):
        y = 60 - i * 8
        U._circle(ax, 10, y, 1.4, '#2FAE66', zorder=5)
        for ln in U.wrap(ax, r, 'Nunito', 9.5, 600, 76, 2):
            U.text(ax, 15, y, ln, 'Nunito', 9.5, 600, '#191A24', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ 7 WIDGET
def guide_widget():
    d = PL.Doc(os.path.join(OUT, 'Widget_Guide.pdf'), 'Widget Guide')
    d.cover('Widget Guide', 'From design tokens to Flutter widgets',
            ['Component to widget map', 'Widget trees', 'Naming & structure', 'Theming', 'State & coins', 'Packages'])
    d.chapter(1, 'Component to Widget Map', 'A direct translation')
    fig, ax = d.page('Mapping table', 'Design component to Flutter widget')
    rows = [('Button', 'FilledButton / OutlinedButton', 'ElevatedButton.styleFrom, minimumSize 48'),
            ('Card', 'Card + Container', 'BorderRadius 20, elevation per level'),
            ('Chip', 'Chip / InputChip', 'shape StadiumBorder, 44dp height'),
            ('Toggle', 'Switch', 'activeColor #2FAE66'),
            ('Input', 'TextField', 'filled: true, outlineInputBorder radius 16'),
            ('Bottom nav', 'NavigationBar', 'NavigationDestination, 5 items'),
            ('App bar', 'Custom AppBar', 'gradient container 64dp'),
            ('Progress ring', 'CircularProgressIndicator', 'strokeCap round, custom painter'),
            ('Donut', 'CustomPaint', 'pie slices with rounded caps'),
            ('Avatar', 'CircleAvatar', 'initials with theme colour'),
            ('Badge', 'Badge widget', 'smallLabel, child icon'),
            ('Snackbar', 'SnackBar', 'behavior floating, rounded')]
    y = 61.5
    U.text(ax, 8, y, 'Component', 'Nunito', 8, 800, '#191A24', zorder=6)
    U.text(ax, 34, y, 'Flutter widget', 'Nunito', 8, 800, '#191A24', zorder=6)
    U.text(ax, 88, y, 'Notes', 'Nunito', 8, 800, '#191A24', ha='right', zorder=6)
    y -= 3.2
    for c, fw, n in rows:
        if y < 7:
            break
        U.text(ax, 8, y, c, 'Nunito', 7.5, 700, '#4F6BF5', zorder=6)
        U.text(ax, 34, y, fw, 'Nunito', 7.5, 600, '#191A24', zorder=6)
        U.text(ax, 88, y, n, 'Nunito', 6.8, 600, '#767685', ha='right', zorder=6)
        y -= 3.6
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(2, 'Widget Trees', 'Structure before paint')
    fig, ax = d.page('Dashboard widget tree', 'How a child dashboard is composed')
    def node(ax, x, y, label, col='#4F6BF5', w=None):
        w = w or (2.6 + len(label) * 0.42)
        U.rr(ax, x - w / 2, y - 1.4, w, 2.8, 1.4, fc=col, zorder=5)
        U.text(ax, x, y, label, 'Nunito', 5.8, 700, '#FFFFFF', ha='center', va='center', zorder=6)
        return x, y, w
    def link(ax, x1, y1, x2, y2):
        U._line(ax, [(x1, y1 - 1.4), (x2, y2 + 1.4)], '#C7C8D4', 1.0, zorder=4)
    n = node(ax, 50, 62, 'ChildHomeScreen', '#4F6BF5', 20)
    xs = [14, 30, 50, 70, 86]
    children = ['Header', 'ProgressHero', 'TaskList', 'WeeklyChart', 'BottomNav']
    for lx, c in zip(xs, children):
        link(ax, 50, 62, lx, 55)
        n2 = node(ax, lx, 51, c, '#FF8A3D', 12)
    for lx, c in zip([20, 38, 62, 80], ['CoinChip', 'StreakPill', 'TaskCard', 'RingStat']):
        link(ax, 30, 51, lx, 44) if c == 'CoinChip' else link(ax, 70, 51, lx, 44)
        node(ax, lx, 40, c, '#2FAE66', 10)
    for ln in U.wrap(ax, 'Keep screens shallow: one stateful screen builds stateless child widgets. Data flows down, callbacks flow up. Nothing reaches into the coin service from inside a card.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 26, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(3, 'Naming & Structure', 'Consistency at the file level')
    fig, ax = d.page('Folders and files', 'Scalable from day one')
    tree = ['lib/',
            '  screens/  <name>_screen.dart',
            '  widgets/  <name>_widget.dart',
            '  theme/    app_theme.dart, tokens.dart',
            '  models/   task_model.dart, reward_model.dart',
            '  services/ coin_service.dart, pin_service.dart',
            '  data/     local_store.dart',
            '  assets/icons/ sch_icon_*.svg',
            '  assets/illustrations/ sch_ill_*.svg',
            'Naming: UpperCamelCase classes, snake_case files,',
            '        constants UPPER_SNAKE_CASE, tokens sch_ prefixed.']
    y = 60
    for ln in tree:
        U.text(ax, 10, y, ln, 'Nunito', 8.5, 500 if ln.endswith('/') else 700, '#43434F' if ln.endswith('/') else '#191A24', zorder=6)
        y -= 4.6
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(4, 'Theming', 'Tokens become ThemeData')
    fig, ax = d.page('Token to Theme mapping', 'One source of truth')
    U.rr(ax, 6, 18, 88, 44, 14, fc='#1B1C25', zorder=3)
    rows = ['ColorScheme.fromSeed(seedColor: Color(0xFF4F6BF5))',
            'primary   = tokens.primary',
            'secondary = tokens.secondary',
            'tertiary  = tokens.tertiary',
            'surface, surfaceVariant, outline, error \u2026 all mapped',
            'TextTheme: display \u2013 Baloo 2, body \u2013 Nunito',
            'fontFamily for numerals \u2013 Quicksand (tabularFigures)',
            'CardTheme: shape RoundedRectangleBorder(20), elevation 1-3',
            'NavigationBarTheme: indicator pill 0.14 alpha primary']
    y = 58
    for r in rows:
        U.text(ax, 12, y, r, 'Nunito', 8.5, 500 if not r.startswith('Color') else 700, '#C4F6E8', zorder=6)
        y -= 4.6
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(5, 'State & Coins', 'Coins are the reward engine')
    fig, ax = d.page('Coin flow', 'Where value lives')
    steps = [('1. Task approved', 'Parent taps Approve on the pending screen.'),
             ('2. CoinService grants', 'A CoinLedger entry is appended (+value, reason, child).'),
             ('3. UI reacts', 'Snackbar shows \u201cTask approved +10 coins\u201d; balance animates.'),
             ('4. Goals check', 'Milestones and badges evaluate; confetti may fire.'),
             ('5. Offline sync', 'Everything is written to the local store first.')]
    y = 60
    for i, (t, dsc) in enumerate(steps):
        U.icon_badge_circle(ax, 12, y, 2.8, str(i + 1), '#4F6BF5', fg='#FFFFFF', ic=3, zorder=5)
        U.text(ax, 18, y, t, 'Nunito', 9.5, 800, '#191A24', zorder=6)
        for ln in U.wrap(ax, dsc, 'Nunito', 8.5, 600, 70, 2):
            U.text(ax, 30, y, ln, 'Nunito', 8.5, 600, '#43434F', zorder=6); break
        y -= 8.4
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.chapter(6, 'Packages', 'A minimal, offline-friendly stack')
    fig, ax = d.page('Recommended packages', 'Small and dependable')
    pkgs = [('google_fonts', 'Loads Baloo 2, Quicksand, Nunito at runtime.'),
            ('flutter_animate', 'Declarative entrance, coin-fly and confetti.'),
            ('flutter_riverpod', 'Predictable state for tasks, coins and approvals.'),
            ('flutter_secure_storage', 'Parent PIN and child PIN storage.'),
            ('path_provider + sqlite', 'Local, offline-first persistence.'),
            ('confetti / custom_paint', 'Celebration particles.')]
    y = 60
    for pkg, dsc in pkgs:
        PL.tag(ax, 10, y, pkg, bg='#DDE5FF', fg='#0E1E5C')
        for ln in U.wrap(ax, dsc, 'Nunito', 9, 600, 66, 2):
            U.text(ax, 32, y, ln, 'Nunito', 9, 600, '#43434F', zorder=6); break
        y -= 7.2
    for ln in U.wrap(ax, 'The app runs 100% offline. No analytics, no accounts, no network permissions required at runtime.',
                     'Nunito', 9, 600, 86, 3):
        U.text(ax, 8, 14, ln, 'Nunito', 9, 700, '#2FAE66', zorder=6); break
    fig.savefig(d.pdf, format='pdf'); plt.close(fig)
    d.close()

# ================================================================ main
if __name__ == '__main__':
    guide_ui_style()
    guide_color()
    guide_typography()
    guide_components()
    guide_animation()
    guide_responsive()
    guide_widget()
    print('All 7 style guides written.')
