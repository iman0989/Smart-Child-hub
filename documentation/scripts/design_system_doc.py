"""Builds Design_System_Guide.docx - the professional Phase 2 design system document."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from docx.enum.section import WD_SECTION_START
from docx.shared import Pt
import dwb
from dwb import H, P, TBL, B, NL, RICH, add_toc, add_lof, page_break, spacer, img, shade

ROOT = os.path.normpath(os.path.join(HERE, '..'))
MOCK = os.path.join(ROOT, 'mockups')
COMP = os.path.join(ROOT, 'components')
DSYS = os.path.join(ROOT, 'design-system')
OUT = os.path.join(DSYS, 'Design_System_Guide.docx')

IM = 'Times New Roman'
HD = 'Arial'

MOCKUPS = [
    ('01_splash', 'Splash', 'Brand reveal: Sunny the mascot spins in, the Smart Child Hub logo scales to rest, then the app transitions into the welcome screen. Child mode tone immediately.'),
    ('02_welcome', 'Welcome', 'Hero illustration, the product tagline and two clear entry points \u201cI am a parent\u201d and \u201cI am a child\u201d. No login is required for the child path.'),
    ('03_choose_profile', 'Choose Profile', 'Kiosk profile picker: large round avatars with names, an \u201cAdd new profile\u201d tile, and a parent-lock affordance. Profiles are touch-first and 96 px tall.'),
    ('04_child_pin', 'Child PIN', 'Optional four-digit PIN gate protecting a specific child profile. Numeric keypad with large keys, gentle shake on error and a back affordance.'),
    ('05_child_dashboard', 'Child Dashboard', 'The daily hub in child mode: greeting with Sunny, today\u2019s progress ring, a task checklist with status pills, a coins balance chip and the bottom navigation bar.'),
    ('06_task_screen', 'Task Screen', 'Task detail with a bright illustration, step hints, a big completed button and a coin reward badge. Supports self-check and parent-approval variants.'),
    ('07_rewards', 'Rewards', 'Rewards shop for the child: reward cards with illustrations, coin prices, available/claimed states and a confirmation dialog before a redemption is submitted.'),
    ('08_coins', 'Coins', 'Coin ledger: current balance card, earn/spend breakdown, a daily history list with icons and the running total in tabular figures.'),
    ('09_badges', 'Badges', 'Badge collection in child mode: bronze, silver, gold and diamond tiers with locked and unlocked states and progress hints.'),
    ('10_achievements', 'Achievements', 'Streak and milestone view: week strip with completion days, milestone progress bars, confetti moment when a new tier is reached.'),
    ('11_messages', 'Messages', 'Parent-child messages: simple positive notes with big icons, read states and a quick-reply composer. Encourages communication without a phone.'),
    ('12_reports_child', 'Child Reports', 'Child-facing summary: weekly completion percentage, coins earned, badges gained and a simple line chart of the last seven days.'),
    ('13_parent_login', 'Parent Login', 'Parent access gate: PIN pad in the professional parent theme, wrong-PIN lockout messaging and a hint about recovery.'),
    ('14_parent_dashboard', 'Parent Dashboard', 'Family manager overview: child summary cards with completion rates, pending approvals badge, coin circulation totals and a navigation rail.'),
    ('15_manage_children', 'Manage Children', 'Parent administration of profiles: add/edit/remove children, avatars, PINs and active/inactive state. Full-row touch targets in the parent theme.'),
    ('16_manage_tasks', 'Manage Tasks', 'Task management: list of tasks with frequency, coin value, verification type and assignee chips; add, edit, duplicate and archive actions.'),
    ('17_pending_approval', 'Pending Approval', 'Approval queue: each card shows the child\u2019s submission with proof photo thumbnail, approve and reject buttons and reason input on reject.'),
    ('18_rewards_management', 'Rewards Management', 'Rewards administration: create rewards with illustration, coin price and stock; review redemption requests and approve or decline them.'),
    ('19_coin_management', 'Coin Management', 'Coin ledger for the parent: per-child balances, manual adjust, transaction history filters and export. Tabular numerals keep totals stable.'),
    ('20_reports_parent', 'Parent Reports', 'Period reports: daily, weekly, monthly and yearly tabs with completion rates, missed tasks, top-child ranking and export to PDF.'),
    ('21_settings', 'Settings', 'Family settings: schedule defaults, verification rules, notification preferences, theme (light/dark) and data backup within the home network.'),
    ('22_about', 'About', 'About screen: product story, version, credits, the offline/privacy statement and a link to this design system.'),
]

SCREEN_MODE = {
    '01': 'Child', '02': 'Shared', '03': 'Child', '04': 'Child', '05': 'Child',
    '06': 'Child', '07': 'Child', '08': 'Child', '09': 'Child', '10': 'Child',
    '11': 'Child', '12': 'Child', '13': 'Parent', '14': 'Parent', '15': 'Parent',
    '16': 'Parent', '17': 'Parent', '18': 'Parent', '19': 'Parent', '20': 'Parent',
    '21': 'Parent', '22': 'Parent',
}

COMPONENTS = [
    ('01_buttons', 'Buttons', 'Filled, tonal, outlined, text and FAB variants in primary, secondary and tertiary colours. Every button respects the 48 px minimum touch target.'),
    ('02_cards', 'Cards', 'Filled and outlined cards across the four elevation levels, plus the soft shadow style used on child-mode screens.'),
    ('03_chips', 'Chips', 'Status chips for the six task states, badge-tier chips, selectable filter chips and coin chips with the flying-coin pattern.'),
    ('04_inputs', 'Inputs', 'Text fields, numeric keypads, dropdowns, toggles, radio groups, search bars and a colour/value stepper, all with the soft focus ring.'),
    ('05_navigation', 'Navigation', 'Bottom navigation bar, navigation rail, app bar, tabs, back affordances and the FAB. Consistent 64 px bars and 48 px targets.'),
    ('06_charts', 'Charts', 'Progress ring, progress bar, line chart, bar chart and donut with rounded caps, soft gridlines and tabular numeral labels.'),
    ('07_dialogs', 'Dialogs', 'Confirmation, success, PIN, date-picker and bottom-sheet dialogs with safe rounded corners and elevation level three shadows.'),
    ('08_avatars', 'Avatars', 'Profile avatars, Sunny the mascot, initial fallback avatars, status rings and the child/parent header lockups.'),
    ('09_typography', 'Typography', 'The complete 19-style type scale with family, size, line-height and weight, used exactly as specified in the Typography Guide.'),
    ('10_colors', 'Colors', 'The full light and dark palettes with brand, accent, semantic and status colours and their exact hex values.'),
    ('11_spacing', 'Spacing', 'The 4\u201364 px spacing scale, radii xs\u2013full, elevation levels 0\u20134 and the 6/12 column grid with 16 px gutters.'),
]


def _color_row(key, light, dark):
    return [key, light, dark]


def build_cover():
    from dwb import P as _P
    _P('', align='center', space_after=60)
    _P('[SMART CHILD HUB LOGO PLACEHOLDER]', align='center', size=12, space_after=40)
    _P('DESIGN SYSTEM', align='center', bold=True, size=28, space_after=4)
    _P('User Interface and User Experience Guide', align='center', size=15, space_after=16)
    _P('Smart Child Daily Activity Tracking System', align='center', bold=True, size=20, space_after=2)
    _P('An Offline Family Dashboard for Monitoring Children\u2019s Daily Habits', align='center',
       size=13, space_after=30)
    _P('Phase 2 \u2013 UI/UX Design System (Material 3 \u00b7 Glassmorphism \u00b7 Soft UI)',
       align='center', size=12, space_after=40)
    _P('Prepared for the development team', align='center', size=12, space_after=2)
    _P('Version 1.0.0', align='center', size=12, space_after=2)
    _P('August 2026', align='center', size=12, space_after=0)


def ch1():
    H('CHAPTER ONE', 1)
    H('INTRODUCTION', 2)
    H('1.1 Purpose of the Design System', 3)
    P('The Smart Child Hub design system is the single source of truth for the user interface and user '
      'experience of the Smart Child Daily Activity Tracking System. It defines the visual language, '
      'design tokens, colour palettes, typography, spacing, motion, components, icons, illustrations '
      'and screen layouts that will be used to build the application in Flutter during Phase 3. Every '
      'pixel of every screen, every component and every animation shown in this document is specified '
      'with exact values so that implementation is deterministic and does not require creative '
      'interpretation.')
    P('The system deliberately blends three contemporary UI styles: a Material 3 foundation for '
      'consistency and accessibility, a glassmorphism treatment (translucent frosted panels over soft '
      'gradients) for a modern, layered feel, and soft UI (large rounded shapes, gentle shadows and '
      'friendly colours) so that the interface feels warm and approachable for young children. The '
      'result is a playful child mode and a professional parent mode that share one underlying token '
      'system.')
    H('1.2 Scope', 3)
    P('This design system covers the complete visual and interaction design of the application. It '
      'includes two colour themes (light and dark), a 19-style type scale built from three fonts '
      '(Baloo 2, Quicksand and Nunito), a 4\u201364 px spacing scale, four elevation levels, six motion '
      'curves and seven reference durations, eleven component boards, twenty-two full-screen mockups, '
      'fifty-two custom SVG icons and five illustrations. The scope is strictly visual and '
      'interactional; no Flutter, PHP, MySQL or API implementation code is included in this phase.')
    H('1.3 How to Use This Guide', 3)
    B([
        ('Designers ', 'use the mockups and component boards to validate new screens against the visual language.'),
        ('Developers ', 'read the design tokens and widget guide to map every token to a Flutter theme before writing widgets.'),
        ('Reviewers ', 'check screens against the accessibility rules, contrast minimums and touch-target minimums defined in Chapter 3 and Chapter 9.'),
    ])
    H('1.4 Deliverables Overview', 3)
    TBL(
        ['Deliverable', 'Location', 'Count / Format'],
        [
            ['Design tokens', 'scripts/tokens.py', '1 source file'],
            ['UI Style Guide', 'style-guide/UI_Style_Guide.pdf', '15 pages'],
            ['Color Palette', 'style-guide/Color_Palette.pdf', '16 pages'],
            ['Typography Guide', 'style-guide/Typography_Guide.pdf', '11 pages'],
            ['Component Library', 'style-guide/Component_Library.pdf', '24 pages'],
            ['Animation Guide', 'style-guide/Animation_Guide.pdf', '13 pages'],
            ['Responsive Guide', 'style-guide/Responsive_Guide.pdf', '11 pages'],
            ['Widget Guide', 'style-guide/Widget_Guide.pdf', '13 pages'],
            ['Component boards', 'components/', '11 PNG boards'],
            ['Screen mockups', 'mockups/', '22 PNG screens'],
            ['Icons', 'assets/icons/', '52 SVG files'],
            ['Illustrations', 'assets/illustrations/', '5 SVG files'],
            ['Screen specifications', 'design-system/specs/', 'docx + markdown'],
            ['Navigation flow', 'design-system/specs/', 'docx + markdown'],
        ],
        col_widths=[2.4, 2.6, 1.3],
        caption='Phase 2 deliverables at a glance',
        bookmark='tbl-deliverables',
    )
    H('1.5 Design Personas and Modes', 3)
    P('The interface has two distinct visual voices backed by one token system. Child mode is bright, '
      'big and joyful: Baloo 2 display type, the Sunny mascot, candy accents, large cards and '
      'confetti. Parent mode is calm and professional: Nunito type, tighter spacing, data-dense charts '
      'and tabular numerals. The switch is automatic based on the active profile, never a setting the '
      'child can change.')
    TBL(
        ['Characteristic', 'Child Mode (My Day)', 'Parent Mode (Family Manager)'],
        [
            ['Display type', 'Baloo 2 (700\u2013800)', 'Nunito (600\u2013800)'],
            ['Body type', 'Quicksand (500\u2013700)', 'Nunito (400\u2013600)'],
            ['Numerals', 'Quicksand tabular', 'Nunito tabular'],
            ['Layout density', 'Spacious (16\u201332 px)', 'Compact (8\u201316 px)'],
            ['Navigation', 'Bottom bar', 'Navigation rail + app bar'],
            ['Accents', 'Candy, sky, grape', 'Primary blue, success green'],
            ['Motifs', 'Sunny, coins, stars', 'Charts, tables, approvals'],
        ],
        col_widths=[1.6, 2.3, 2.4],
        caption='Child mode versus parent mode',
        bookmark='tbl-modes',
    )


def ch2():
    H('CHAPTER TWO', 1)
    H('DESIGN PRINCIPLES AND VISUAL LANGUAGE', 2)
    H('2.1 The Four Design Principles', 3)
    NL([
        'Playful \u2013 big rounded shapes, the friendly Sunny mascot and warm colours make routines feel like games, never chores. Everything in child mode is scaled, spaced and coloured for delight first.',
        'Clear \u2013 one primary action per screen, big type and generous spacing mean a four-year-old and a parent both understand the screen instantly. No hidden gestures, no ambiguous icons.',
        'Safe \u2013 parent-only zones sit behind a PIN. The app runs completely offline with no accounts, no ads and no internet dependency, keeping the family\u2019s data private inside the home.',
        'Rewarding \u2013 coins, badges and confetti celebrate every win and turn effort into visible, motivating progress. Positive reinforcement is the core emotional loop.',
    ])
    H('2.2 Visual Language', 3)
    B([
        ('Frosted glass (glassmorphism) ', 'panels with soft translucent fills over a subtle gradient backdrop create depth without heavy borders.'),
        ('Soft UI ', 'rounded rectangles (8\u201332 px radii), low-contrast soft shadows and muted surface tints keep the interface gentle on the eye.'),
        ('Gradients ', 'reserved for hero areas, the splash, celebrations and the Sunny mascot; content surfaces stay clean and flat.'),
        ('Illustration ', 'the Sunny mascot and five supporting illustrations carry the personality; they never carry critical information.'),
    ])
    H('2.3 The Mascot: Sunny', 3)
    P('Sunny is a smiling sun used across the brand, the splash screen, empty states, celebrations and '
      'the child dashboard. Sunny is drawn in flat vector style with the brand colours, an orange '
      'glow, rosy cheeks and a friendly closed-mouth smile. The mascot animates with a gentle '
      'bobbing motion on idle screens and spins into the splash screen. Sunny is always a supporter, '
      'never a judge: on error states Sunny appears helpful and calm.')
    H('2.4 Voice and Tone', 3)
    B([
        ('Child voice ', 'short positive sentences, encouraging words (\u201cGreat job!\u201d, \u201cYou did it!\u201d), never shame or negative framing for missed tasks.'),
        ('Parent voice ', 'clear, factual and reassuring (\u201c3 approvals pending\u201d, \u201cBackup completed\u201d).'),
        ('Error tone ', 'constructive: explain what happened and the one action that fixes it, never blame the child.'),
    ])


def ch3():
    H('CHAPTER THREE', 1)
    H('COLOUR SYSTEM AND DESIGN TOKENS', 2)
    H('3.1 Token Philosophy', 3)
    P('All colours are stored as semantic tokens, not raw hex values. Screens and components reference '
      'token names such as primary, surface and success so that theming (light, dark, brand tweaks) is '
      'a single point of change. The complete token set is defined in scripts/tokens.py and rendered '
      'as reference boards in components/10_colors.png.')
    H('3.2 Brand Palette', 3)
    TBL(
        ['Token', 'Light Value', 'Purpose'],
        [
            _color_row('primary', '#4F6BF5', 'Primary actions, selected states'),
            _color_row('onPrimary', '#FFFFFF', 'Content on primary'),
            _color_row('primaryContainer', '#DDE5FF', 'Soft primary backgrounds'),
            _color_row('onPrimaryContainer', '#0E1E5C', 'Content on primary container'),
            _color_row('secondary', '#FF8A3D', 'Secondary actions, highlights'),
            _color_row('secondaryContainer', '#FFE0C7', 'Soft secondary backgrounds'),
            _color_row('tertiary', '#1FBFA0', 'Verified/success accents, brand pop'),
            _color_row('background', '#F7F8FE', 'Screen background (light)'),
            _color_row('surface', '#FFFFFF', 'Cards and surfaces'),
            _color_row('onSurface', '#191A24', 'Primary text'),
            _color_row('surfaceVariant', '#E9EAF6', 'Dividers, subtle fills'),
            _color_row('onSurfaceVariant', '#43434F', 'Secondary text'),
            _color_row('outline', '#767685', 'Borders, icons at rest'),
            _color_row('outlineVariant', '#D5D6E4', 'Light borders'),
        ],
        col_widths=[2.1, 1.5, 2.7],
        caption='Brand colour tokens (light theme)',
        bookmark='tbl-brand-colors',
    )
    H('3.3 Accent Colours', 3)
    TBL(
        ['Token', 'Value', 'Use'],
        [
            _color_row('sunshine', '#FFC93C', 'Coins, sparkles, celebration'),
            _color_row('candy', '#FF7BA9', 'Child avatars, playful accents'),
            _color_row('sky', '#54C3F6', 'Child avatars, weather-friendly tints'),
            _color_row('grape', '#A98BFF', 'Badges, child avatars'),
            _color_row('mint', '#3DDB9E', 'Success flourishes, fresh tints'),
            _color_row('peach', '#FFB37A', 'Warm tints, secondary highlights'),
        ],
        col_widths=[1.8, 1.5, 3.0],
        caption='Accent tokens for avatars, categories and delight',
        bookmark='tbl-accents',
    )
    H('3.4 Semantic and Status Colours', 3)
    P('Status is never communicated by colour alone; each task status pairs its colour with an icon '
      'and a text label. This keeps the interface accessible for colour-blind users.')
    TBL(
        ['Status', 'Value', 'Icon', 'Meaning'],
        [
            ['completed', '#2FAE66', 'check', 'Task done and verified'],
            ['pending', '#FF9F0A', 'clock', 'Waiting for parent approval'],
            ['rejected', '#E5484D', 'close', 'Submission rejected by parent'],
            ['verified', '#1FBFA0', 'shield', 'Self-checked and accepted'],
            ['missed', '#8E8E99', 'flag', 'Due date passed without completion'],
            ['locked', '#B9BAC6', 'lock', 'Task not yet available'],
        ],
        col_widths=[1.5, 1.5, 1.2, 2.1],
        caption='The six task status colours',
        bookmark='tbl-status',
    )
    H('3.5 Badge Tiers', 3)
    TBL(
        ['Tier', 'Foreground', 'Background', 'Feeling'],
        [
            ['bronze', '#C98A5B', '#F5E0D1', 'Getting started'],
            ['silver', '#9AA4B5', '#E9EDF3', 'Consistent effort'],
            ['gold', '#E8A500', '#FCEFC8', 'Outstanding streak'],
            ['diamond', '#3FB9E0', '#D8F3FB', 'Elite achievement'],
        ],
        col_widths=[1.5, 1.5, 1.7, 1.6],
        caption='Achievement badge tier colours',
        bookmark='tbl-badges',
    )
    H('3.6 Dark Theme', 3)
    P('The dark theme keeps the exact same token structure and hue families but shifts luminance. '
      'Surfaces become deep indigo-greys, primary becomes a light periwinkle (B7C4FF) so it stays '
      'legible on dark surfaces, and error shifts to a lighter red (FFB4AB). The full dark palette is '
      'rendered in the Color Palette guide and on the colour board.')
    H('3.7 Contrast and Accessibility', 3)
    B([
        ('Body text on surfaces ', 'must reach WCAG AA (4.5:1); the standard onSurface (#191A24) on surface (#FFFFFF) reaches 16.2:1.'),
        ('Large text (18+ px or 14 px bold) ', 'must reach 3:1; all display and headline styles exceed this.'),
        ('Status chips ', 'always pair colour with icon and label, never rely on colour alone.'),
        ('Focus states ', 'a visible 2 px primary ring with 8 px offset on all interactive elements.'),
    ])


def ch4():
    H('CHAPTER FOUR', 1)
    H('TYPOGRAPHY', 2)
    H('4.1 The Three-Family System', 3)
    P('Three complementary open-source font families create clear hierarchy and instantly distinguish '
      'the two modes. Baloo 2 is the rounded, friendly display face for headlines and numbers in '
      'child mode. Quicksand is the soft geometric face for child-mode body text and interface '
      'numerals. Nunito is the neutral, highly legible face for all parent-mode text and data.')
    TBL(
        ['Family', 'Role', 'Weights used'],
        [
            ['Baloo 2', 'Brand display, child headlines, hero numbers', '400, 500, 600, 700, 800'],
            ['Quicksand', 'Child body text, coins and numerals', '400, 500, 600, 700'],
            ['Nunito', 'Parent UI, body text, charts, labels', '400, 500, 600, 700, 800'],
        ],
        col_widths=[1.6, 3.2, 1.5],
        caption='The three font families and their roles',
        bookmark='tbl-fonts',
    )
    H('4.2 Type Scale', 3)
    P('The scale defines nineteen styles. Every style fixes the family, size, line height and weight. '
      'Implementations must use these exact values, not eyeballed approximations.')
    TBL(
        ['Style', 'Family', 'Size', 'Line', 'Weight', 'Use'],
        [
            ['Display Large', 'Baloo 2', '57', '60', '800', 'Hero numbers, splash'],
            ['Display Medium', 'Baloo 2', '45', '48', '700', 'Screen hero titles (child)'],
            ['Display Small', 'Baloo 2', '36', '40', '700', 'Welcome, celebration'],
            ['Headline Large', 'Baloo 2', '32', '36', '700', 'Dashboard main heading'],
            ['Headline Medium', 'Baloo 2', '28', '32', '700', 'Section titles, headers'],
            ['Headline Small', 'Baloo 2', '24', '28', '700', 'Card titles, dialogs'],
            ['Title Large', 'Nunito', '22', '26', '700', 'Parent screen titles'],
            ['Title Medium', 'Nunito', '16', '24', '600', 'Card titles (parent)'],
            ['Title Small', 'Nunito', '14', '20', '600', 'List items, nav items'],
            ['Body Large', 'Nunito', '16', '24', '400', 'Primary body text'],
            ['Body Medium', 'Nunito', '14', '20', '400', 'Secondary text'],
            ['Body Small', 'Nunito', '12', '16', '400', 'Captions, meta'],
            ['Label Large', 'Nunito', '14', '20', '600', 'Buttons, tabs'],
            ['Label Medium', 'Nunito', '12', '16', '600', 'Chips, badges, labels'],
            ['Label Small', 'Nunito', '11', '16', '600', 'Overlines, timestamps'],
            ['Stat Large', 'Nunito', '48', '52', '800', 'Coin totals (tabular)'],
            ['Stat Medium', 'Nunito', '28', '32', '800', 'Dashboard statistics'],
            ['Stat Small', 'Nunito', '18', '24', '700', 'Coins on cards'],
            ['Chart Label', 'Nunito', '11', '14', '600', 'Axis labels, legends'],
        ],
        col_widths=[1.7, 1.1, 0.8, 0.8, 0.9, 2.0],
        caption='The complete 19-style type scale',
        bookmark='tbl-type-scale',
    )
    H('4.3 Numerals and Tabular Figures', 3)
    P('All numeric totals, statistics and coin values use tabular figures (fixed-width numerals) so '
      'that numbers align in tables and count-up animations do not jitter. Quicksand is preferred for '
      'child-mode numerals; Nunito for parent-mode data.')
    H('4.4 Typography Hygiene', 3)
    B([
        'Never exceed two display words per line in child mode.',
        'Line height minimums from the scale are binding; do not compress for space.',
        'Text on glass panels uses the onSurface tokens, not pure white or black.',
        'Abbreviations and acronyms are spelled out in child mode (\u201ccoins\u201d not \u201ccoins.\u201d).',
    ])


def ch5():
    H('CHAPTER FIVE', 1)
    H('LAYOUT, GRID AND SPACING', 2)
    H('5.1 Breakpoints', 3)
    TBL(
        ['Tier', 'Width', 'Target'],
        [
            ['compact', 'Below 600 dp', 'Phone portrait \u2013 usable but not primary'],
            ['medium', '600\u2013840 dp', 'Tablet portrait \u2013 the primary target'],
            ['expanded', 'Above 840 dp', 'Tablet landscape and large screens'],
        ],
        col_widths=[1.6, 1.9, 2.8],
        caption='Responsive breakpoint tiers',
        bookmark='tbl-breakpoints',
    )
    H('5.2 The Grid', 3)
    B([
        ('Medium (600\u2013840 dp) ', 'a 6-column grid with 16 px gutters and 24 px screen padding.'),
        ('Expanded (above 840 dp) ', 'a 12-column grid, same 16 px gutters and 24 px padding, with a content max width of 880 dp.'),
        ('Compact ', 'a 4-column grid with 16 px gutters and 16 px padding.'),
    ])
    H('5.3 Spacing Scale', 3)
    TBL(
        ['Token', 'Value', 'Use'],
        [
            ['4', '4 px', 'Tight gaps between icon and label in small chips'],
            ['8', '8 px', 'Gaps between elements inside cards, icon padding'],
            ['12', '12 px', 'Default internal card padding, small gaps'],
            ['16', '16 px', 'Default screen padding, gaps between cards'],
            ['20', '20 px', 'Gaps between groups of related cards'],
            ['24', '24 px', 'Section spacing, dialog padding'],
            ['32', '32 px', 'Between major screen sections'],
            ['40', '40 px', 'Before/after a screen header or hero'],
            ['48', '48 px', 'Page gutters on large screens'],
            ['64', '64 px', 'Hero spacing, distinct screen zones'],
        ],
        col_widths=[1.2, 1.0, 4.1],
        caption='The 4\u201364 px spacing scale',
        bookmark='tbl-spacing',
    )
    H('5.4 Radii and Elevation', 3)
    TBL(
        ['Token', 'Value', 'Use'],
        [
            ['xs / sm / md', '8 / 12 / 16 px', 'Chips, small elements, inputs'],
            ['lg / xl', '20 / 24 px', 'Cards, dialogs, buttons'],
            ['xxl / full', '32 px / 999', 'Hero cards, FAB, avatar circles'],
        ],
        col_widths=[1.8, 1.7, 2.8],
        caption='Corner radius tokens',
        bookmark='tbl-radii',
    )
    TBL(
        ['Level', 'Shadow', 'Blur', 'Alpha', 'Use'],
        [
            ['0', '0', '0', '0.00', 'Resting flat elements'],
            ['1', '2', '6', '0.10', 'Cards at rest'],
            ['2', '4', '12', '0.14', 'Floating cards, FAB'],
            ['3', '8', '24', '0.18', 'Dialogs, bottom sheets'],
            ['4', '12', '32', '0.22', 'Overlays, snackbars'],
        ],
        col_widths=[1.1, 1.0, 1.0, 1.0, 2.2],
        caption='Elevation levels',
        bookmark='tbl-elevation',
    )
    H('5.5 Touch Targets', 3)
    P('Every interactive element has a minimum touch target of 48 \u00d7 48 dp. Visual size may be '
      'smaller, but the hit area never is. The bottom navigation bar is 80 dp tall and the app bar '
      '64 dp tall.')
    spacer(6)
    img(os.path.join(COMP, '11_spacing.png'), 6.2,
        'Spacing, radius, elevation and grid reference board', 'fig-spacing')


def ch6():
    H('CHAPTER SIX', 1)
    H('COMPONENT LIBRARY', 2)
    P('The component library contains eleven reference boards. Each board is the single visual spec '
      'for its component family; the full sizing, state and usage rules live in the Component Library '
      'PDF. The boards below are the authoritative visual reference.')
    for name, title, desc in COMPONENTS:
        img(os.path.join(COMP, f'{name}.png'), 6.2, title + ' \u2013 ' + desc,
            f'fig-comp-{name}')


def ch7():
    H('CHAPTER SEVEN', 1)
    H('ICONS AND ILLUSTRATIONS', 2)
    H('7.1 The Icon Set', 3)
    P('Fifty-two custom SVG icons cover navigation, tasks, rewards, coins, badges, reports, messages '
      'and settings. Icons follow a 24 \u00d7 24 viewBox, 2 px stroke weight, rounded caps and joins, '
      'and use the onSurfaceVariant colour at rest. Each icon is exported as a single standalone SVG '
      'file under assets/icons/ with the sch_icon_ prefix.')
    TBL(
        ['Category', 'Icons (naming root)', 'Count'],
        [
            ['Navigation', 'home, grid, list, back, close, search, menu', '7'],
            ['Tasks', 'check, clock, flag, lock, sparkle, star, calendar, repeat', '8'],
            ['Rewards & coins', 'coin, coins, gift, trophy, tag, cart, redeem', '7'],
            ['Badges', 'shield, award, medal, crown, diamond, flame, streak', '7'],
            ['Reports', 'chart, chart_line, chart_bar, chart_donut, download, export', '6'],
            ['People & profiles', 'person, person_add, child, parents, avatar, pin', '6'],
            ['Messages', 'chat, chat_dot, bell, mail, send', '5'],
            ['Settings & system', 'settings, tune, lock, theme, wifi, info, help, warning', '8'],
        ],
        col_widths=[2.2, 3.4, 0.8],
        caption='Icon categories and counts',
        bookmark='tbl-icons',
    )
    H('7.2 Illustrations', 3)
    P('Five SVG illustrations carry the personality of the product. Each is drawn in flat vector style '
      'with the brand palette and exports as a standalone SVG under assets/illustrations/.')
    TBL(
        ['Asset', 'File', 'Used on'],
        [
            ['Sunny mascot', 'sch_ill_sunny_mascot.svg', 'Splash, dashboard, about'],
            ['Empty state', 'sch_ill_empty_tasks.svg', 'Empty task lists'],
            ['Celebration', 'sch_ill_celebration.svg', 'Badge unlocks, achievements'],
            ['Welcome hero', 'sch_ill_welcome_hero.svg', 'Welcome screen'],
            ['Error state', 'sch_ill_error_state.svg', 'Offline/error screens'],
        ],
        col_widths=[2.0, 3.1, 2.2],
        caption='Illustration assets',
        bookmark='tbl-illustrations',
    )
    H('7.3 Asset Conventions', 3)
    B([
        'All assets carry the sch_ asset prefix so the whole family is discoverable.',
        'Icons ship as stroke SVGs; illustrations as flat-colour SVGs.',
        'SVGs are optimised, well-formed XML and render without external dependencies.',
        'Never rasterise SVG assets at design time; Flutter renders them natively.',
    ])


def ch8():
    H('CHAPTER EIGHT', 1)
    H('MOTION AND ANIMATION', 2)
    H('8.1 Principles', 3)
    NL([
        'Purposeful \u2013 every animation explains a state change; nothing moves for decoration.',
        'Fast \u2013 durations run 50\u2013900 ms so the interface never feels slow.',
        'Joyful \u2013 celebrations (coins, confetti, badge glow) reward success; errors animate calmly.',
    ])
    H('8.2 Durations and Curves', 3)
    TBL(
        ['Token', 'Duration', 'Curve'],
        [
            ['instant', '50 ms', 'None (hard cut)'],
            ['fast', '150 ms', 'standard'],
            ['normal', '250 ms', 'standard'],
            ['gentle', '350 ms', 'emphasized'],
            ['slow', '500 ms', 'emphasized'],
            ['extra', '750 ms', 'bounce'],
        ],
        col_widths=[1.4, 1.4, 2.6],
        caption='Reference durations and easing curves',
        bookmark='tbl-durations',
    )
    TBL(
        ['Curve', 'Specification'],
        [
            ['standard', 'cubic-bezier(0.2, 0.0, 0.0, 1.0)'],
            ['emphasized', 'cubic-bezier(0.3, 0.0, 0.1, 1.0)'],
            ['decelerate', 'cubic-bezier(0.0, 0.0, 0.2, 1.0)'],
            ['accelerate', 'cubic-bezier(0.4, 0.0, 1.0, 1.0)'],
            ['spring', 'spring(weight: 0.9, damping: 14)'],
            ['bounce', 'cubic-bezier(0.34, 1.56, 0.64, 1.0)'],
        ],
        col_widths=[1.6, 4.0],
        caption='Easing curves',
        bookmark='tbl-curves',
    )
    H('8.3 Signature Moments', 3)
    TBL(
        ['Animation', 'Duration', 'Behaviour'],
        [
            ['Coin fly', '450 ms', 'Coin pops at the task card, arcs to the balance chip, total counts up with bounce'],
            ['Check draw', '500 ms', 'Check mark draws itself; card pulses green; a coin flies'],
            ['Confetti', '750 ms', 'Bursts from the task card; particles fall and rotate'],
            ['Badge unlock', '600 ms', 'Badge scales 0 to 1 with a golden glow ring'],
            ['Reward claim', '500 ms', 'Reward card lifts, confetti at top, check stamp appears'],
            ['Screen transition', '300 ms', 'Fade-through with an 8% horizontal slide'],
        ],
        col_widths=[1.7, 1.1, 3.5],
        caption='Signature animations specified for implementation',
        bookmark='tbl-signature',
    )
    H('8.4 Loading Patterns', 3)
    P('Loading states use three bouncing dots or a gently pulsing spinning coin for 1000 ms loops. '
      'Never show a frozen frame; every asynchronous action has an animated placeholder.')


def ch9():
    H('CHAPTER NINE', 1)
    H('RESPONSIVE BEHAVIOUR AND DARK MODE', 2)
    H('9.1 What Changes at Each Tier', 3)
    TBL(
        ['Element', 'Compact (< 600)', 'Medium (600\u2013840)', 'Expanded (> 840)'],
        [
            ['Navigation', 'Bottom bar', 'Bottom bar', 'Rail + app bar'],
            ['Grid columns', '4', '6', '12'],
            ['Screen padding', '16 px', '24 px', '24 px + 880 max width'],
            ['Dashboard cards', '1 column', '2 columns', '3 columns'],
            ['Charts', 'Compact labels', 'Full labels', 'Full labels + legend'],
        ],
        col_widths=[1.8, 1.4, 1.5, 1.7],
        caption='Responsive playbook across breakpoints',
        bookmark='tbl-responsive',
    )
    H('9.2 Phone versus Tablet', 3)
    P('Phone is usable but the product is optimised for tablet portrait (medium tier), the typical '
      'family-kiosk orientation. On compact screens, multi-column card grids collapse to single '
      'columns, charts reduce label density, and dialogs become full-width bottom sheets.')
    H('9.3 Dark Mode', 3)
    P('The app respects a family-level theme setting (light, dark or follow the shared tablet). Both '
      'themes pass the same contrast minimums. Illustrations ship in both palettes or use '
      'theme-aware tokens so no asset looks wrong on the dark surfaces.')
    H('9.4 Rules to Remember', 3)
    B([
        'Keep it simple at every size; the same content exists on all tiers, only the rhythm changes.',
        'Never hide an action behind an extra tap on smaller screens; collapse, do not remove.',
        'Respect the 48 px minimum touch target in every tier.',
    ])


def ch10():
    H('CHAPTER TEN', 1)
    H('SCREEN MOCKUPS', 2)
    P('Twenty-two full-screen mockups define the complete application at 1440 \u00d7 1920. Each screen '
      'below includes its mode, purpose and the key elements that must be implemented. The mockups '
      'are the authoritative visual contract for Phase 3 development.')
    for name, title, desc in MOCKUPS:
        key = name.split('_')[0]
        mode = SCREEN_MODE.get(key, 'Shared')
        RICH([(f'{name} \u00b7 {title} \u00b7 {mode} mode  ', True),
              (desc, False)])
        spacer(4)
        img(os.path.join(MOCK, f'{name}.png'), 4.0,
            title + ' \u2013 ' + mode + ' mode', f'fig-{name}')


def ch11():
    H('CHAPTER ELEVEN', 1)
    H('NAMING CONVENTIONS AND ASSET STRUCTURE', 2)
    H('11.1 Naming Rules', 3)
    TBL(
        ['Element', 'Case', 'Example'],
        [
            ['Asset files', 'snake_case with sch_ prefix', 'sch_icon_coin.svg'],
            ['Classes and widgets', 'UpperCamelCase', 'RewardsScreen'],
            ['Constants and tokens', 'UPPER_SNAKE_CASE', 'APP_PADDING = 24'],
            ['Screen files', 'snake_case with _screen suffix', 'rewards_screen.dart'],
            ['Widget files', 'snake_case with _widget suffix', 'coin_chip_widget.dart'],
            ['Colour tokens', 'snake_case with _color suffix', 'success_color'],
        ],
        col_widths=[2.0, 2.1, 2.4],
        caption='Naming conventions',
        bookmark='tbl-naming',
    )
    H('11.2 Folder Structure', 3)
    P('The design deliverables are organised so that every artefact has one obvious home. The Phase 3 '
      'Flutter project should mirror this logic in lib/theme, lib/widgets, lib/screens and '
      'lib/assets.')
    B([
        'documentation/design-system \u2013 this guide and the screen specifications',
        'documentation/style-guide \u2013 the seven PDF guides',
        'documentation/mockups \u2013 the twenty-two screen mockups',
        'documentation/components \u2013 the eleven component boards',
        'documentation/assets/icons \u2013 the fifty-two SVG icons',
        'documentation/assets/illustrations \u2013 the five SVG illustrations',
        'documentation/scripts \u2013 the token source and all generator scripts',
    ])
    H('11.3 Token to Flutter Theme Mapping', 3)
    P('Design tokens map to a Material 3 ThemeData so implementation needs no design decisions. The '
      'primary seed is Color(0xFF4F6BF5); TextTheme maps display styles to Baloo 2 and body styles to '
      'Nunito; fontFamily for numerals uses Quicksand with tabular figures. The complete mapping is '
      'documented in the Widget Guide PDF.')


def ch12():
    H('CHAPTER TWELVE', 1)
    H('VALIDATION AND HANDOFF', 2)
    H('12.1 Quality Checklist', 3)
    NL([
        'Every screen exists as a mockup and every interactive element as a component board.',
        'All tokens are defined once in scripts/tokens.py and used by every renderer.',
        'Contrast minimums and 48 px touch targets hold across both themes.',
        'All PDFs, SVGs and PNGs open cleanly and are checked for missing glyphs or corrupt pages.',
        'Every naming convention in Chapter 11 is applied to the generated assets.',
    ])
    H('12.2 Handoff to Phase 3', 3)
    P('With this design system complete, Phase 3 can begin Flutter development with zero ambiguity. '
      'Developers start from scripts/tokens.py to build the ThemeData, then implement the eleven '
      'component families against their boards, and finally compose the twenty-two screens from the '
      'mockups. The Widget Guide provides the direct component-to-widget translation and the '
      'recommended packages for fonts, animation and secure storage.')
    spacer(6)
    H('APPENDIX A', 1)
    H('FILE INVENTORY', 2)
    rows = []
    for folder, label in [(MOCK, 'mockups'), (COMP, 'components'),
                          (os.path.join(ROOT, 'assets', 'icons'), 'assets/icons'),
                          (os.path.join(ROOT, 'assets', 'illustrations'), 'assets/illustrations'),
                          (os.path.join(ROOT, 'style-guide'), 'style-guide')]:
        for f in sorted(os.listdir(folder)):
            if f.lower().endswith(('.png', '.svg', '.pdf')):
                p = os.path.join(folder, f)
                size = os.path.getsize(p)
                kb = f'{size // 1024} KB'
                rows.append([label, f, kb])
    rows.append(['design-system', 'Design_System_Guide.docx', 'this document'])
    TBL(['Folder', 'File', 'Size'], rows,
        col_widths=[2.0, 3.4, 1.0], caption='Phase 2 file inventory', bookmark='tbl-inventory')
    P('End of Design System Guide. Version 1.0.0 \u00b7 August 2026', align='center', size=11)


def main():
    dwb.setup(ROOT)
    dwb.set_update_fields()

    sec1 = dwb.doc.sections[0]
    sec1.different_first_page_header_footer = True
    dwb.footer_pagenum(sec1, fmt='lowerRoman', start=1)

    build_cover()
    page_break()
    add_toc('TABLE OF CONTENTS')
    page_break()
    add_lof('LIST OF FIGURES')

    sec2 = dwb.doc.add_section(WD_SECTION_START.NEW_PAGE)
    dwb.footer_pagenum(sec2, fmt='decimal', start=1)
    dwb.header_text(sec2, 'Smart Child Hub \u2013 Design System Guide')

    ch1()
    ch2()
    ch3()
    ch4()
    ch5()
    ch6()
    ch7()
    ch8()
    ch9()
    ch10()
    ch11()
    ch12()

    os.makedirs(DSYS, exist_ok=True)
    dwb.doc.save(OUT)
    print('Saved document:', OUT)
    print('Total figures:', dwb.FIG)
    print('Total tables :', dwb.TAB)


if __name__ == '__main__':
    main()
