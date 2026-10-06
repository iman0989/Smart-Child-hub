"""Generate clean SVG icon set + illustration assets for the design system."""
import os

ICON_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'icons')
ILL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'illustrations')
os.makedirs(ICON_DIR, exist_ok=True)
os.makedirs(ILL_DIR, exist_ok=True)

HEAD = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="none" stroke="currentColor" stroke-width="2" '
        'stroke-linecap="round" stroke-linejoin="round">')
TAIL = '</svg>'

# line-style helpers
L = '<path d="{d}"/>'
P = '<path d="{d}" fill="currentColor" stroke="none"/>'
C = '<circle cx="{x}" cy="{y}" r="{r}" fill="currentColor" stroke="none"/>'
W = '<path d="{d}" stroke="#FFFFFF" stroke-width="2" fill="none"/>'

ICONS = {
    'home': L.format(d='M3 10.5 12 3l9 7.5') + '<rect x="5" y="10" width="14" height="11" rx="2"/>',
    'tasks': P.format(d='M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z') +
             W.format(d='M8 12l2.5 2.5L16 9') + '<path d="M8 17h5" stroke="#FFF" stroke-width="2" stroke-linecap="round"/>',
    'trophy': P.format(d='M7 4h10v5.5A5 5 0 0 1 7 9.5z') +
              L.format(d='M7 6H4a3 3 0 0 0 3 4M17 6h3a3 3 0 0 1-3 4') +
              L.format(d='M12 14.5V18M9 21h6'),
    'medal': C.format(x=12, y=8.5, r=5) + P.format(d='M9.6 12.3 6.5 20l5.5-3 5.5 3-3.1-7.7'),
    'badge': P.format(d='M12 3l7 2.5V11c0 4.5-3 8-7 10-4-2-7-5.5-7-10V5.5z') +
             P.format(d='m12 8.2.9 2 2.1.3-1.5 1.5.4 2.1-1.9-1-1.9 1 .4-2.1-1.5-1.5 2.1-.3z'),
    'star': P.format(d='m12 3 2.6 5.6 6.2.7-4.6 4.2 1.3 6-5.5-3-5.5 3 1.3-6L3.2 9.3l6.2-.7z'),
    'sparkle': P.format(d='m12 2 2.4 7.6L22 12l-7.6 2.4L12 22l-2.4-7.6L2 12l7.6-2.4z'),
    'sun': C.format(x=12, y=12, r=4.5) +
           L.format(d='M12 2.5V5M12 19v2.5M2.5 12H5M19 12h2.5M5 5l1.8 1.8M17.2 17.2 19 19M19 5l-1.8 1.8M6.8 17.2 5 19'),
    'moon': P.format(d='M20 15.2A8.5 8.5 0 1 1 8.8 4a7 7 0 0 0 11.2 11.2z'),
    'coin': C.format(x=12, y=12, r=10) + C.format(x=12, y=12, r=6.2) +
            P.format(d='m12 9.2.9 2 2.1.3-1.5 1.5.4 2.1-1.9-1-1.9 1 .4-2.1-1.5-1.5 2.1-.3z'),
    'gear': C.format(x=12, y=12, r=3.6) +
            L.format(d='M12 2.5V5M12 19v2.5M2.5 12H5M19 12h2.5M5 5l1.8 1.8M17.2 17.2 19 19M19 5l-1.8 1.8M6.8 17.2 5 19'),
    'bell': P.format(d='M6 8a6 6 0 0 1 12 0c0 5.5 2 5.5 2 6.5H4c0-1 2-1 2-6.5z') +
            P.format(d='M10 19a2 2 0 0 0 4 0'),
    'mail': P.format(d='M3 5h18a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z') +
            W.format(d='m4 7 8 6 8-6'),
    'chart': P.format(d='M5 21h14a1 1 0 0 0 1-1v-1H4v1a1 1 0 0 0 1 1z') +
             '<rect x="5.5" y="13" width="3.2" height="5" rx="1" fill="currentColor" stroke="none"/>' +
             '<rect x="10.4" y="8.5" width="3.2" height="9.5" rx="1" fill="currentColor" stroke="none"/>' +
             '<rect x="15.3" y="4.5" width="3.2" height="13.5" rx="1" fill="currentColor" stroke="none"/>',
    'lock': P.format(d='M5 10.5h14a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8a1 1 0 0 1 1-1z') +
            L.format(d='M8 10.5V7a4 4 0 0 1 8 0v3.5'),
    'person': C.format(x=12, y=7.5, r=3.6) + P.format(d='M5 20a7 7 0 0 1 14 0z'),
    'child': C.format(x=12, y=7.5, r=3.6) +
             L.format(d='M7.2 5.5 5.6 3.8M12 4V1.5M16.8 5.5 18.4 3.8') +
             P.format(d='M5 20a7 7 0 0 1 14 0z'),
    'parent': C.format(x=12, y=7.5, r=3.6) + P.format(d='M5 20a7 7 0 0 1 14 0z') +
              '<path d="M5 9 3.5 6M19 9l1.5-3" stroke="currentColor" stroke-width="2"/>',
    'add_child': C.format(x=9.5, y=8, r=3.4) + P.format(d='M3.5 19a6 6 0 0 1 12 0z') +
                 L.format(d='M17.5 8v5M15 10.5h5'),
    'edit': P.format(d='M4 20l1-4L17.5 3.6a2.1 2.1 0 0 1 3 3L8 19z'),
    'trash': L.format(d='M4 7h16M9 7V5h6v2M6 7l1 13h10l1-13') +
             L.format(d='M10 11v5M14 11v5'),
    'calendar': P.format(d='M3.5 5.5h17A1.5 1.5 0 0 1 22 7v13.5a1.5 1.5 0 0 1-1.5 1.5h-17A1.5 1.5 0 0 1 2 20.5V7A1.5 1.5 0 0 1 3.5 5.5z') +
                W.format(d='M7 3v4M17 3v4M2.5 10.5h19'),
    'clock': '<circle cx="12" cy="12" r="8.5"/>' +
             L.format(d='M12 7v5l3.5 2'),
    'heart': P.format(d='M12 20C5.2 15.2 3 11 3 8.5A4.5 4.5 0 0 1 12 6a4.5 4.5 0 0 1 9 2.5C21 11 18.8 15.2 12 20z'),
    'search': '<circle cx="10.5" cy="10.5" r="6"/>' + L.format(d='m15.5 15.5 5 5'),
    'eye': '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/>' +
           C.format(x=12, y=12, r=3),
    'shield': P.format(d='M12 2.5 20 5.5V11c0 4.5-3 8-8 10.5C7 19 4 15.5 4 11V5.5z'),
    'verified': P.format(d='M12 2.5 20 5.5V11c0 4.5-3 8-8 10.5C7 19 4 15.5 4 11V5.5z') +
                W.format(d='m9 12 2.2 2.2L15.5 9.5'),
    'book': L.format(d='M12 6C9.5 4.2 6 4 4 4v14c2 0 5.5.2 8 2 2.5-1.8 6-2 8-2V4c-2 0-5.5.2-8 2z'),
    'water': P.format(d='M12 2.5S5 10 5 14.5a7 7 0 0 0 14 0C19 10 12 2.5 12 2.5z'),
    'run': C.format(x=13.5, y=4.5, r=2.2) +
           L.format(d='M13.5 7.5v5M13.5 9.5l-4 1.5M13.5 12.5 16.5 15l.8 5M13.5 12.5 10 15'),
    'bed': P.format(d='M3 10h18v7.5a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 17.5z') +
           L.format(d='M3 17.5V8a1.5 1.5 0 0 1 1.5-1.5H9V10M18 10V6.5'),
    'plants': L.format(d='M12 22V12') + P.format(d='M12 13.5C6 13.5 5 7.5 12 7.5c7 0 6 6 0 6z') +
              P.format(d='M12 16.5c-3 0-3.8-3 0-3 3.8 0 3 3 0 3z'),
    'pets': P.format(d='M4.8 10c-1.5 0-2.6-1.5-2.1-2.9.5-1.4 2-1.4 2.6 0 .4 1-.1 2.9-.5 2.9zM19.2 10c1.5 0 2.6-1.5 2.1-2.9-.5-1.4-2-1.4-2.6 0-.4 1 .1 2.9.5 2.9zM9 8.2C7.6 8.2 6.9 6.2 7.4 4.9c.5-1.3 2-1.2 2.4.2.3 1.1-.1 3.1-.8 3.1zM15 8.2c1.4 0 2.1-2 1.6-3.3-.5-1.3-2-1.2-2.4.2-.3 1.1.1 3.1.8 3.1zM12 11.2c2.8 0 4.5 2.1 4.5 4.6 0 1.2-.8 2-2 2-.8 0-1.4-.4-2.5-.4s-1.7.4-2.5.4c-1.2 0-2-.8-2-2 0-2.5 1.7-4.6 4.5-4.6z'),
    'food': P.format(d='M3.5 11.5h17c0 5.3-3.5 8.5-8.5 8.5s-8.5-3.2-8.5-8.5z') +
            L.format(d='M4 7.5c.5-1.7 2-2.5 3.8-2.5M8.6 5c.5-1.7 2-2.5 3.8-2.5M13.2 5c.5-1.7 2-2.5 3.8-2.5'),
    'homework': P.format(d='M3 5.5A1.5 1.5 0 0 1 4.5 4h4.5v16H4.5A1.5 1.5 0 0 1 3 18.5z') +
                P.format(d='M13.5 3.5 21 7l-5 3-7.5-3.5z'),
    'music': L.format(d='M9 18V6l10-2v12') + C.format(x=6.5, y=18, r=2.5) + C.format(x=16.5, y=16, r=2.5),
    'paint': P.format(d='M12 3C6.5 3 2 7 2 12s4.5 8 10 8c1.5 0 2-1 2-2 0-.5-.3-1-.3-1.5 0-.8.6-1.5 1.5-1.5H17c3 0 5-2 5-5 0-4-4.5-7-10-7z') +
             C.format(x=7.5, y=10.5, r=1.3) + C.format(x=12, y=7.5, r=1.3) + C.format(x=16.5, y=10.5, r=1.3),
    'message': P.format(d='M4 4h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H9l-5 4z') +
               W.format(d='M8 10h8M8 14h5'),
    'info': C.format(x=12, y=12, r=8.5) + W.format(d='M12 11v5M12 7.6v.4'),
    'help': C.format(x=12, y=12, r=8.5) +
            '<path d="M9.5 9a2.5 2.5 0 0 1 5 0c0 1.6-2.5 2.1-2.5 3.9M12 16.5v.4" fill="none" stroke="#FFF" stroke-width="2" stroke-linecap="round"/>',
    'download': L.format(d='M12 3v11M7.5 9.5 12 14l4.5-4.5') + L.format(d='M4 21h16'),
    'target': '<circle cx="12" cy="12" r="8.2"/><circle cx="12" cy="12" r="4.6"/>' +
              C.format(x=12, y=12, r=1.6),
    'minus': L.format(d='M5 12h14'),
    'plus': L.format(d='M12 5v14M5 12h14'),
    'check': '<path d="m4.5 12.5 5 5.5L19.5 6" stroke-width="3" fill="none"/>',
    'cross': L.format(d='M6 6l12 12M18 6 6 18'),
    'chev_left': '<path d="m15 5-7 7 7 7" stroke-width="2.5" fill="none"/>',
    'chev_right': '<path d="m9 5 7 7-7 7" stroke-width="2.5" fill="none"/>',
    'chev_down': '<path d="m5 9 7 7 7-7" stroke-width="2.5" fill="none"/>',
    'send': P.format(d='m3 11 18-8-8 18-2.5-7.5z'),
    'lightning': P.format(d='M13 2 4 14h7l-1 8 10-13h-7z'),
}

TAG_META = {
    'outline': ['home', 'chart', 'lock', 'calendar', 'clock', 'search', 'eye', 'help',
                'minus', 'plus', 'check', 'cross', 'chev_left', 'chev_right', 'chev_down',
                'download', 'target', 'run', 'bed', 'music', 'edit', 'trash', 'book', 'moon'],
    'filled': ['star', 'sparkle', 'sun', 'coin', 'person', 'child', 'parent', 'add_child',
               'mail', 'bell', 'heart', 'water', 'plants', 'pets', 'food', 'paint', 'message',
               'info', 'send', 'lightning', 'tasks', 'trophy', 'medal', 'badge', 'gear',
               'shield', 'verified', 'homework', 'moon'],
}


def write_icon(name, body):
    size = 24
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" '
           f'width="{size}" height="{size}" fill="none" '
           'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
           f'{body}</svg>')
    with open(os.path.join(ICON_DIR, f'sch_icon_{name}.svg'), 'w', encoding='utf-8') as f:
        f.write(svg)


def write_illustration(name, body, width=400, height=400):
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" '
           f'width="{width}" height="{height}">{body}</svg>')
    with open(os.path.join(ILL_DIR, f'sch_ill_{name}.svg'), 'w', encoding='utf-8') as f:
        f.write(svg)


# ---------------------------------------------------------------- illustrations
def sunny_body(cx=200, cy=180, r=60):
    halo = (f'<circle cx="{cx}" cy="{cy}" r="{r * 1.45}" fill="#FFE9B0" opacity="0.7"/>'
            f'<circle cx="{cx}" cy="{cy}" r="{r * 1.2}" fill="#FFD873" opacity="0.85"/>')
    face = f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#FFC93C"/>'
    eyes = f'<circle cx="{cx - r * 0.32}" cy="{cy - r * 0.08}" r="{r * 0.09}" fill="#5B4200"/>' \
           f'<circle cx="{cx + r * 0.32}" cy="{cy - r * 0.08}" r="{r * 0.09}" fill="#5B4200"/>'
    smile = (f'<path d="M {cx - r * 0.3} {cy + r * 0.26} Q {cx} {cy + r * 0.55} {cx + r * 0.3} {cy + r * 0.26}" '
             f'stroke="#5B4200" stroke-width="{r * 0.07}" fill="none" stroke-linecap="round"/>')
    cheeks = (f'<circle cx="{cx - r * 0.6}" cy="{cy + r * 0.12}" r="{r * 0.09}" fill="#FF9E5E" opacity="0.7"/>'
              f'<circle cx="{cx + r * 0.6}" cy="{cy + r * 0.12}" r="{r * 0.09}" fill="#FF9E5E" opacity="0.7"/>')
    return halo + face + eyes + smile + cheeks


ILLUST = {
    'sunny_mascot': f'<rect width="400" height="400" rx="40" fill="#4F6BF5"/>' +
                    f'<circle cx="200" cy="190" r="170" fill="#7A5BF5" opacity="0.35"/>' +
                    sunny_body(200, 190, 72) +
                    f'<text x="200" y="330" font-family="Arial" font-size="26" font-weight="bold" '
                    f'fill="#FFFFFF" text-anchor="middle">Sunny</text>',
    'empty_tasks': f'<rect width="400" height="400" rx="40" fill="#F7F8FE"/>' +
                   f'<rect x="120" y="120" width="160" height="40" rx="10" fill="#E9EAF6"/>' +
                   f'<rect x="120" y="180" width="160" height="40" rx="10" fill="#E9EAF6"/>' +
                   f'<rect x="120" y="240" width="160" height="40" rx="10" fill="#E9EAF6"/>' +
                   f'<circle cx="200" cy="90" r="46" fill="#DDE5FF"/>' +
                   f'<path d="M 200 70 L 205 84 L 220 85 L 209 95 L 212 110 L 200 102 L 188 110 L 191 95 L 180 85 L 195 84 Z" fill="#4F6BF5"/>' +
                   f'<text x="200" y="330" font-family="Arial" font-size="26" font-weight="bold" '
                   f'fill="#191A24" text-anchor="middle">Nothing here yet</text>',
    'celebration': f'<rect width="400" height="400" rx="40" fill="#FCEFC8"/>' +
                   f'<path d="M 60 60 l 12 -18 l 12 18 z" fill="#FF7BA9"/><path d="M 120 40 l 9 -14 l 9 14 z" fill="#FFC93C"/>' +
                   f'<path d="M 320 70 l 12 -18 l 12 18 z" fill="#54C3F6"/><path d="M 340 140 l 8 -12 l 8 12 z" fill="#3DDB9E"/>' +
                   f'<path d="M 60 150 l 8 -12 l 8 12 z" fill="#A98BFF"/>' +
                   f'<circle cx="200" cy="200" r="70" fill="#FFC93C"/>' +
                   f'<path d="M 200 168 L 207 192 L 232 194 L 214 210 L 220 234 L 200 221 L 180 234 L 186 210 L 168 194 L 193 192 Z" fill="#5B4200"/>' +
                   f'<path d="M 120 120 l 60 60 M 280 120 l -60 60 M 120 280 l 60 -60 M 280 280 l -60 -60" stroke="#FFD873" stroke-width="6" stroke-linecap="round"/>' +
                   f'<text x="200" y="330" font-family="Arial" font-size="26" font-weight="bold" '
                   f'fill="#45260A" text-anchor="middle">You did it!</text>',
    'welcome_hero': f'<rect width="400" height="400" rx="40" fill="#DDE5FF"/>' +
                    sunny_body(120, 150, 52) +
                    f'<circle cx="280" cy="190" r="30" fill="#FF8A3D"/><path d="M 280 174 q 8 14 0 22 M 280 174 q -8 14 0 22" stroke="#FFFFFF" stroke-width="6" fill="none" stroke-linecap="round"/>' +
                    f'<circle cx="280" cy="240" r="12" fill="#FF8A3D"/>' +
                    f'<rect x="140" y="230" width="60" height="10" rx="5" fill="#FFFFFF"/>' +
                    f'<circle cx="320" cy="170" r="6" fill="#FF7BA9"/><circle cx="340" cy="200" r="8" fill="#A98BFF"/>' +
                    f'<path d="M 140 150 l 40 0 l 0 40 l -40 0 z" fill="#FFC93C"/>' +
                    f'<text x="200" y="330" font-family="Arial" font-size="26" font-weight="bold" '
                    f'fill="#0E1E5C" text-anchor="middle">Happy family habits</text>',
    'error_state': f'<rect width="400" height="400" rx="40" fill="#FFF3D1"/>' +
                   f'<circle cx="200" cy="180" r="62" fill="#FFD873"/>' +
                   f'<circle cx="176" cy="170" r="8" fill="#5B4200"/><circle cx="224" cy="170" r="8" fill="#5B4200"/>' +
                   f'<path d="M 178 200 Q 200 216 222 200" stroke="#5B4200" stroke-width="7" fill="none" stroke-linecap="round"/>' +
                   f'<path d="M 160 130 l 10 10 M 150 140 l 10 10 M 240 130 l -10 10 M 250 140 l -10 10" stroke="#5B4200" stroke-width="5" stroke-linecap="round"/>' +
                   f'<text x="200" y="300" font-family="Arial" font-size="24" font-weight="bold" '
                   f'fill="#45260A" text-anchor="middle">Oops, no internet</text>' +
                   f'<text x="200" y="330" font-family="Arial" font-size="16" fill="#B26A00" text-anchor="middle">Your app works fully offline</text>',
}

for name, body in ICONS.items():
    write_icon(name, body)

for name, body in ILLUST.items():
    write_illustration(name, body)

index = ['# Smart Child Hub Icon Set\n',
         f'\n{len(ICONS)} hand-crafted icons, 24\u00d724 viewBox.\n',
         'Stroke icons: `stroke="currentColor"`, weight 2, round caps/joins.\n',
         'Filled icons: `fill="currentColor"` with white detail strokes.\n',
         'Naming: `sch_icon_<name>.svg` \u00b7 all lowercase, snake_case.\n\n',
         '| Icon | Name | Style |\n|------|------|-------|\n']
for name in sorted(ICONS):
    style = 'filled' if name in TAG_META['filled'] else 'outline'
    index.append(f'| `{name}` | {name} | {style} |\n')
with open(os.path.join(ICON_DIR, '_INDEX.md'), 'w', encoding='utf-8') as f:
    f.writelines(index)

print('Icons:', len(ICONS), 'Illustrations:', len(ILLUST))
