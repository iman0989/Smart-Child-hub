"""Smart Child Hub - Design Tokens (single source of truth)."""

BRAND = {
    'name': 'Smart Child Hub',
    'full': 'Smart Child Daily Activity Tracking System',
    'tagline': 'Your family\u2019s offline smart hub for happy daily habits',
    'mascot': 'Sunny \u2013 the smiling sun',
    'mode_parent': 'Family Manager',
    'mode_child': 'My Day',
}

# ---------------------------------------------------------------- COLOR LIGHT
LIGHT = {
    'primary': '#4F6BF5',
    'onPrimary': '#FFFFFF',
    'primaryContainer': '#DDE5FF',
    'onPrimaryContainer': '#0E1E5C',
    'secondary': '#FF8A3D',
    'onSecondary': '#FFFFFF',
    'secondaryContainer': '#FFE0C7',
    'onSecondaryContainer': '#45260A',
    'tertiary': '#1FBFA0',
    'onTertiary': '#FFFFFF',
    'tertiaryContainer': '#C4F6E8',
    'onTertiaryContainer': '#004534',
    'background': '#F7F8FE',
    'onBackground': '#191A24',
    'surface': '#FFFFFF',
    'onSurface': '#191A24',
    'surfaceVariant': '#E9EAF6',
    'onSurfaceVariant': '#43434F',
    'surfaceContainer': '#F1F2FB',
    'surfaceContainerHigh': '#E9EAF6',
    'outline': '#767685',
    'outlineVariant': '#D5D6E4',
    'error': '#E5484D',
    'onError': '#FFFFFF',
    'errorContainer': '#FFDAD6',
    'warning': '#FF9F0A',
    'warningContainer': '#FFF3D1',
    'success': '#2FAE66',
    'successContainer': '#D7F2E2',
    'info': '#2E7BF6',
    'infoContainer': '#DBE9FD',
}

ACCENT = {
    'sunshine': '#FFC93C',
    'candy': '#FF7BA9',
    'sky': '#54C3F6',
    'grape': '#A98BFF',
    'mint': '#3DDB9E',
    'peach': '#FFB37A',
}

STATUS = {
    'completed': '#2FAE66',
    'pending': '#FF9F0A',
    'rejected': '#E5484D',
    'verified': '#1FBFA0',
    'missed': '#8E8E99',
    'locked': '#B9BAC6',
}

BADGE_TIER = {
    'bronze': {'fg': '#C98A5B', 'bg': '#F5E0D1'},
    'silver': {'fg': '#9AA4B5', 'bg': '#E9EDF3'},
    'gold': {'fg': '#E8A500', 'bg': '#FCEFC8'},
    'diamond': {'fg': '#3FB9E0', 'bg': '#D8F3FB'},
}

DARK = {
    'primary': '#B7C4FF',
    'onPrimary': '#10225E',
    'primaryContainer': '#334798',
    'onPrimaryContainer': '#DCE4FF',
    'secondary': '#FFB37A',
    'onSecondary': '#5B2D0A',
    'secondaryContainer': '#7A3F10',
    'onSecondaryContainer': '#FFE0C7',
    'tertiary': '#57D8B9',
    'onTertiary': '#00382B',
    'tertiaryContainer': '#005244',
    'onTertiaryContainer': '#C4F6E8',
    'background': '#12131A',
    'onBackground': '#E6E6EE',
    'surface': '#1B1C25',
    'onSurface': '#E6E6EE',
    'surfaceVariant': '#30313D',
    'onSurfaceVariant': '#C7C8D4',
    'surfaceContainer': '#23242F',
    'surfaceContainerHigh': '#2C2D39',
    'outline': '#8B8C9A',
    'outlineVariant': '#3E3F4B',
    'error': '#FFB4AB',
    'onError': '#690005',
    'errorContainer': '#93000A',
    'warning': '#FFC661',
    'warningContainer': '#4A3400',
    'success': '#7DDBA5',
    'successContainer': '#1E5434',
    'info': '#9FC6FF',
    'infoContainer': '#234369',
}

# ---------------------------------------------------------------- TYPOGRAPHY
FONTS = {
    'brand_display': 'Baloo 2',
    'child_ui': 'Quicksand',
    'parent_ui': 'Nunito',
}

TYPES = [
    ('Display Large', 'Baloo 2', 57, 60, 800, 'Hero numbers, splash, welcome headline'),
    ('Display Medium', 'Baloo 2', 45, 48, 700, 'Screen hero titles in child mode'),
    ('Display Small', 'Baloo 2', 36, 40, 700, 'Welcome and celebration headlines'),
    ('Headline Large', 'Baloo 2', 32, 36, 700, 'Child dashboard main heading'),
    ('Headline Medium', 'Baloo 2', 28, 32, 700, 'Section titles, screen headers'),
    ('Headline Small', 'Baloo 2', 24, 28, 700, 'Card titles, dialog titles'),
    ('Title Large', 'Nunito', 22, 26, 700, 'Parent screen titles'),
    ('Title Medium', 'Nunito', 16, 24, 600, 'Card titles in parent mode'),
    ('Title Small', 'Nunito', 14, 20, 600, 'List item titles, nav items'),
    ('Body Large', 'Nunito', 16, 24, 400, 'Primary body text'),
    ('Body Medium', 'Nunito', 14, 20, 400, 'Secondary text, descriptions'),
    ('Body Small', 'Nunito', 12, 16, 400, 'Captions, meta information'),
    ('Label Large', 'Nunito', 14, 20, 600, 'Buttons, tabs'),
    ('Label Medium', 'Nunito', 12, 16, 600, 'Chips, badges, field labels'),
    ('Label Small', 'Nunito', 11, 16, 600, 'Overlines, timestamps'),
    ('Stat Large', 'Nunito', 48, 52, 800, 'Big numbers, coin totals (tabular)'),
    ('Stat Medium', 'Nunito', 28, 32, 800, 'Dashboard statistics'),
    ('Stat Small', 'Nunito', 18, 24, 700, 'Inline statistics, coins on cards'),
    ('Chart Label', 'Nunito', 11, 14, 600, 'Axis labels, legend, ticks'),
]

# ---------------------------------------------------------------- SPACING
SPACING = {
    4: 'Tight gaps between icon and label inside small chips',
    8: 'Gaps between elements inside cards; icon padding',
    12: 'Default internal card padding; small section gaps',
    16: 'Default screen padding; gaps between cards',
    20: 'Gap between groups of related cards',
    24: 'Section spacing; dialog padding; card padding (large)',
    32: 'Spacing between major sections of a screen',
    40: 'Spacing before/after a screen header or hero',
    48: 'Page-level gutters on large screens; splash spacing',
    64: 'Hero area spacing; separation of distinct screen zones',
}

RADII = {
    'xs': 8, 'sm': 12, 'md': 16, 'lg': 20, 'xl': 24, 'xxl': 32, 'full': 999,
}

ELEVATION = {
    0: {'y': 0, 'blur': 0, 'alpha': 0.00, 'use': 'resting flat elements'},
    1: {'y': 2, 'blur': 6, 'alpha': 0.10, 'use': 'cards at rest'},
    2: {'y': 4, 'blur': 12, 'alpha': 0.14, 'use': 'floating cards, FAB'},
    3: {'y': 8, 'blur': 24, 'alpha': 0.18, 'use': 'dialogs, bottom sheets'},
    4: {'y': 12, 'blur': 32, 'alpha': 0.22, 'use': 'overlays, snackbars'},
}

ICON_SIZES = {
    'xs': 16, 'sm': 20, 'md': 24, 'lg': 32, 'xl': 40, 'xxl': 48, 'hero': 64,
}

# ---------------------------------------------------------------- MOTION
CURVES = {
    'standard': 'cubic-bezier(0.2, 0.0, 0.0, 1.0)',
    'emphasized': 'cubic-bezier(0.3, 0.0, 0.1, 1.0)',
    'decelerate': 'cubic-bezier(0.0, 0.0, 0.2, 1.0)',
    'accelerate': 'cubic-bezier(0.4, 0.0, 1.0, 1.0)',
    'spring': 'spring(weight: 0.9, damping: 14)',
    'bounce': 'cubic-bezier(0.34, 1.56, 0.64, 1.0)',
}

DURATION = {
    'instant': 50, 'fast': 150, 'normal': 250, 'gentle': 350,
    'slow': 500, 'extra': 750,
}

ANIMATIONS = {
    'splash': {'duration': 900, 'curve': 'decelerate', 'desc': 'Sunny spins in with a glowing halo; logo scales 0.9\u21921.0.'},
    'welcome': {'duration': 500, 'curve': 'emphasized', 'desc': 'Hero illustration rises with cards fading in staggered.'},
    'card_entrance': {'duration': 300, 'curve': 'emphasized', 'desc': 'Cards translate up 24px and fade, staggered by index.'},
    'coin_fly': {'duration': 450, 'curve': 'bounce', 'desc': 'Coin pops at source, arcs to the balance chip, balance counts up.'},
    'confetti': {'duration': 750, 'curve': 'standard', 'desc': 'Confetti burst from task card; particles fall with rotation.'},
    'badge_unlock': {'duration': 600, 'curve': 'bounce', 'desc': 'Badge scales from 0 to 1 with golden glow ring.'},
    'reward_claim': {'duration': 500, 'curve': 'bounce', 'desc': 'Reward card lifts, confetti at top, check stamp appears.'},
    'button_ripple': {'duration': 350, 'curve': 'standard', 'desc': 'Ripple expands from touch point and fades.'},
    'task_complete': {'duration': 500, 'curve': 'bounce', 'desc': 'Check mark draws itself; card pulses green; coin flies.'},
    'progress': {'duration': 900, 'curve': 'decelerate', 'desc': 'Ring stroke animates from 0 to value with rounded caps.'},
    'loading': {'duration': 1000, 'curve': 'standard', 'desc': 'Three bouncing dots or a spinning coin with soft pulse.'},
    'screen_transition': {'duration': 300, 'curve': 'emphasized', 'desc': 'Fade-through with 8% horizontal slide between screens.'},
    'hero': {'duration': 400, 'curve': 'emphasized', 'desc': 'Card image morphs and flies to its destination screen.'},
    'tab_switch': {'duration': 250, 'curve': 'standard', 'desc': 'Content cross-fades while the indicator slides.'},
}

# ---------------------------------------------------------------- BREAKPOINTS
BREAKPOINTS = {
    'compact': '< 600 dp \u2013 phone portrait (not primary, still usable)',
    'medium': '600\u2013840 dp \u2013 tablet portrait (primary target)',
    'expanded': '> 840 dp \u2013 tablet landscape and large screens',
}

LAYOUT = {
    'screen_padding': 24,
    'card_padding': 20,
    'grid_gap': 16,
    'grid_columns_medium': 6,
    'grid_columns_expanded': 12,
    'content_max_width': 880,
    'touch_target_min': 48,
    'bottom_nav_height': 80,
    'app_bar_height': 64,
}

NAMING = {
    'file_case': 'snake_case',
    'class_case': 'UpperCamelCase',
    'const_case': 'UPPER_SNAKE_CASE',
    'asset_prefix': 'sch_',
    'screen_suffix': '_screen',
    'widget_suffix': '_widget',
    'color_suffix': '_color',
}
