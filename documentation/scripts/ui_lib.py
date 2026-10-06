"""Shared UI render engine: draws premium Material-3 glass mockups in matplotlib."""
import os
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import font_manager as fm
from matplotlib.path import Path
from matplotlib.patches import PathPatch, Circle, Rectangle, Ellipse, Polygon
from matplotlib.collections import LineCollection
from matplotlib.colors import LinearSegmentedColormap, to_rgba
from matplotlib.font_manager import FontProperties

import tokens as T

W = 100.0      # logical width
H = 133.3333   # logical height (3:4 tablet portrait)

# ---------------------------------------------------------------- FONTS
_FONT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'fonts')
for _f in os.listdir(_FONT_DIR):
    if _f.endswith('.ttf'):
        try:
            fm.fontManager.addfont(os.path.join(_FONT_DIR, _f))
        except Exception:
            pass

plt.rcParams['font.family'] = 'Nunito'
plt.rcParams['axes.linewidth'] = 0

# ---------------------------------------------------------------- COLOR
def hx(c, a=1.0):
    return to_rgba(c, a)

def blend(c1, c2, t):
    a = np.array(hx(c1)[:3]); b = np.array(hx(c2)[:3])
    return '#%02X%02X%02X' % tuple(np.round(a + (b - a) * t).astype(int))

def soft(c, t=0.12):
    return blend('#FFFFFF', c, t) if False else c

# ---------------------------------------------------------------- PATHS
def rr_path(x, y, w, h, r):
    r = max(0.0, min(float(r), w / 2.0, h / 2.0))
    if r <= 0:
        return Path([(x, y), (x + w, y), (x + w, y + h), (x, y + h), (x, y)])
    d = 0.5523 * r
    verts = [
        (x + r, y), (x + w - r, y),
        (x + w - r, y + d), (x + w, y + r - d), (x + w, y + r),
        (x + w, y + h - r),
        (x + w, y + h - r + d), (x + w - r + d, y + h), (x + w - r, y + h),
        (x + r, y + h),
        (x + r - d, y + h), (x, y + h - r + d), (x, y + h - r),
        (x, y + r),
        (x, y + r - d), (x + r - d, y), (x + r, y),
    ]
    codes = [Path.MOVETO, Path.LINETO,
             Path.CURVE4, Path.CURVE4, Path.CURVE4,
             Path.LINETO,
             Path.CURVE4, Path.CURVE4, Path.CURVE4,
             Path.LINETO,
             Path.CURVE4, Path.CURVE4, Path.CURVE4,
             Path.LINETO,
             Path.CURVE4, Path.CURVE4, Path.CURVE4]
    return Path(verts, codes)

def rr(ax, x, y, w, h, r, fc='#FFFFFF', ec=None, lw=0, alpha=1.0, zorder=2):
    p = PathPatch(rr_path(x, y, w, h, r), fc=hx(fc, alpha),
                  ec=hx(ec, alpha) if ec else 'none', lw=lw, zorder=zorder)
    ax.add_patch(p)
    return p

_rr = rr
_rr.__doc__ = 'alias for rr'

def shadow(ax, x, y, w, h, r, level=1, zorder=1, color='#0E1E5C'):
    if level <= 0:
        return
    s = T.ELEVATION[level]
    for f, k in ((0.25, 0.28), (0.55, 0.62), (1.0, 1.0)):
        rr(ax, x, y - s['y'] * f, w, h, r, fc=color, alpha=s['alpha'] * k, zorder=zorder)

def card(ax, x, y, w, h, r=20, fc='#FFFFFF', level=1, ec='#E9EAF6', lw=1, alpha=1.0, zorder=2):
    shadow(ax, x, y, w, h, r, level, zorder=zorder - 0.5)
    rr(ax, x, y, w, h, r, fc=fc, ec=ec, lw=lw, alpha=alpha, zorder=zorder)

def gradient_rect(ax, x, y, w, h, r, c1, c2, alpha=1.0, zorder=0, vertical=True):
    clip = None
    if r > 0:
        clip = PathPatch(rr_path(x, y, w, h, r), transform=ax.transData, fc='none', ec='none')
    data = (np.linspace(0, 1, 256)[:, None] if vertical else np.linspace(0, 1, 256)[None, :])
    cmap = LinearSegmentedColormap.from_list('g', [c1, c2])
    im = ax.imshow(data, extent=[x, x + w, y, y + h], origin='lower', aspect='auto',
                   cmap=cmap, alpha=alpha, zorder=zorder)
    if clip is not None:
        im.set_clip_path(clip)

def blob(ax, cx, cy, rx, ry, color, alpha=0.5, rot=0, zorder=1):
    ax.add_patch(Ellipse((cx, cy), 2 * rx, 2 * ry, angle=rot,
                         fc=hx(color, alpha), ec='none', zorder=zorder))

# ---------------------------------------------------------------- TEXT
def text(ax, x, y, s, family='Nunito', size=14, weight=400, color='#191A24',
         ha='left', va='top', alpha=1.0, ls=1.2, zorder=5, rot=0):
    ax.text(x, y, s, family=family, fontsize=size, fontweight=weight,
            color=hx(color, alpha), ha=ha, va=va, zorder=zorder,
            linespacing=ls, rotation=rot)

def _renderer(ax):
    return ax.get_figure().canvas.get_renderer()

def text_w(ax, s, family='Nunito', size=14, weight=400):
    if not s:
        return 0.0
    fp = FontProperties(family=family, size=size, weight=weight)
    t = ax.text(0, 0, s, fontproperties=fp)
    bb = t.get_window_extent(renderer=_renderer(ax))
    t.remove()
    inv = ax.transData.inverted()
    (x0, _), (x1, _) = inv.transform([(bb.x0, bb.y0), (bb.x1, bb.y1)])
    return x1 - x0

def wrap(ax, s, family, size, weight, maxw, maxlines=99):
    words = s.split(' ')
    lines, cur = [], ''
    for wd in words:
        trial = (cur + ' ' + wd).strip()
        if text_w(ax, trial, family, size, weight) <= maxw or not cur:
            cur = trial
        else:
            lines.append(cur); cur = wd
    if cur:
        lines.append(cur)
    return lines[:maxlines]

# ---------------------------------------------------------------- SHAPES
def pill(ax, cx, cy, w, h, label=None, bg='#E9EAF6', fg='#191A24',
         family='Nunito', size=12, weight=600, r=None, zorder=3, icon=None, ic=6,
         ec=None, eclw=1.2):
    r = r or h / 2
    tw = text_w(ax, label, family, size, weight) if label is not None else 0
    need = tw + (ic + 1.2 if (icon is not None and label is not None) else 0)
    need += ic if (icon is not None and label is None) else 0
    need += h * 0.7
    if need > w:
        w = need
    rr(ax, cx - w / 2, cy - h / 2, w, h, r, fc=bg, ec=ec, lw=eclw if ec else 0, zorder=zorder)
    ix = cx - ic / 2
    if label is not None and icon is not None:
        ix = cx - w / 2 + h * 0.35
    if icon:
        draw_icon(ax, icon, ix, cy - ic / 2, ic, fg, zorder=zorder + 1)
    if label is not None:
        lx = cx if icon is None else ix + ic + 1.2
        text(ax, lx, cy, label, family, size, weight, fg, ha='left', va='center', zorder=zorder + 1)

def coin_chip(ax, cx, cy, count, h=8.6, bg='#FFFFFF', fg='#0E1E5C',
              coin='#FFC93C', size=None, zorder=5):
    size = size or h * 0.68
    tw = text_w(ax, str(count), 'Quicksand', h * 0.74, 700)
    pad = h * 0.42
    w = size + pad + tw + pad * 0.6
    rr(ax, cx - w / 2, cy - h / 2, w, h, h / 2, fc=bg, zorder=zorder)
    draw_icon(ax, 'coin', cx - w / 2 + pad, cy - size / 2, size, coin, zorder=zorder + 1)
    text(ax, cx - w / 2 + pad + size + pad * 0.3, cy, str(count), 'Quicksand',
         h * 0.74, 700, fg, ha='left', va='center', zorder=zorder + 1)
    return w

def button(ax, x, y, w, h, label, bg='#4F6BF5', fg='#FFFFFF', family='Nunito',
           size=14, weight=700, r=16, level=1, zorder=3, icon=None, ic=None, ec=None):
    shadow(ax, x, y, w, h, r, level, zorder=zorder - 0.4)
    rr(ax, x, y, w, h, r, fc=bg, ec=ec, lw=1.6 if ec else 0, zorder=zorder)
    tw = text_w(ax, label, family, size, weight)
    x0 = x + w / 2 - tw / 2
    if icon:
        ic = ic or size
        draw_icon(ax, icon, x0 - ic * 0.9, y + (h - ic) / 2, ic, fg)
        x0 += ic * 0.7
    text(ax, x0, y + h / 2, label, family, size, weight, fg, ha='left', va='center', zorder=zorder + 1)

def avatar(ax, cx, cy, r, label, color, fg='#FFFFFF', size=None, zorder=3, ring=None, ring_lw=3):
    if ring:
        rr(ax, cx - r - ring_lw, cy - r - ring_lw, 2 * (r + ring_lw), 2 * (r + ring_lw), r + ring_lw,
           fc='none', ec=ring, lw=ring_lw, zorder=zorder)
    ax.add_patch(Circle((cx, cy), r, fc=hx(color), ec='none', zorder=zorder))
    text(ax, cx, cy, label, 'Nunito', size or r * 0.9, 800, fg, ha='center', va='center', zorder=zorder + 1)

def hbar(ax, x, y, w, h, pct, color, track='#E9EAF6', r=None, zorder=3):
    r = r or h / 2
    rr(ax, x, y, w, h, r, fc=track, zorder=zorder)
    if pct > 0:
        rr(ax, x, y, max(w * pct, h), h, r, fc=color, zorder=zorder + 0.4)

def ring(ax, cx, cy, r, pct, color, track='#EDEFFB', width=9, zorder=3, start=-90, center_txt=None):
    step = 2
    track_segs = [[(cx + r * np.cos(np.radians(t)), cy + r * np.sin(np.radians(t))),
                   (cx + r * np.cos(np.radians(t + step)), cy + r * np.sin(np.radians(t + step)))]
                  for t in range(0, 360, step)]
    lc = LineCollection(track_segs, colors=[hx(track)] * len(track_segs), linewidths=width,
                        capstyle='round', zorder=zorder)
    clip = PathPatch(Circle((cx, cy), r + width / 2 + 0.4).get_path().transformed(
        ax.transData.inverted()), transform=ax.transData, fc='none', ec='none')
    ax.add_collection(lc)
    lc.set_clip_path(clip)
    if pct > 0:
        segs = []
        ang = pct * 360.0
        for t in np.arange(0, ang, step):
            a0 = start + t; a1 = start + min(t + step, ang)
            segs.append([(cx + r * np.cos(np.radians(a0)), cy + r * np.sin(np.radians(a0))),
                         (cx + r * np.cos(np.radians(a1)), cy + r * np.sin(np.radians(a1)))])
        if segs:
            lc2 = LineCollection(segs, colors=[hx(color)] * len(segs), linewidths=width,
                                 capstyle='round', zorder=zorder + 0.5)
            ax.add_collection(lc2)
            lc2.set_clip_path(clip)
    if center_txt is not None:
        v, s = center_txt
        text(ax, cx, cy + 2.4, v, 'Nunito', 20, 800, '#191A24', ha='center', va='center', zorder=zorder + 1)
        text(ax, cx, cy - 2.6, s, 'Nunito', 8.5, 600, '#767685', ha='center', va='center', zorder=zorder + 1)

def bars(ax, x0, y0, w, h, values, color, radius=5, gap=2, track='#E9EAF6',
         maxv=None, zorder=3, labels=None):
    n = len(values)
    maxv = maxv or max(values) or 1
    colors = color if isinstance(color, (list, tuple)) else [color] * n
    bw = (w - gap * (n - 1)) / n
    for i, v in enumerate(values):
        bh = max((v / maxv) * h, 0)
        bx = x0 + i * (bw + gap)
        rr(ax, bx, y0, bw, h, radius, fc=track, zorder=zorder)
        if v > 0:
            rr(ax, bx, y0, bw, bh, radius, fc=colors[i % len(colors)], zorder=zorder + 0.4)
        if labels:
            text(ax, bx + bw / 2, y0 + h + 1.6, labels[i], 'Nunito', 8.5, 600, '#767685',
                 ha='center', va='bottom', zorder=zorder + 1)

def line_chart(ax, x0, y0, w, h, values, color, fill=True, zorder=3):
    xs = np.linspace(x0, x0 + w, len(values))
    ys = y0 + h * (np.array(values) - min(values)) / (max(values) - min(values) or 1)
    if fill:
        ax.fill_between(xs, ys, y0, color=hx(color, 0.16), zorder=zorder)
    ax.plot(xs, ys, color=hx(color), lw=2.4, zorder=zorder + 0.5, solid_capstyle='round')
    ax.plot([xs[-1]], [ys[-1]], 'o', ms=5, color=hx(color), zorder=zorder + 0.6)

def donut(ax, cx, cy, r, data, colors, width, zorder=3):
    ax.pie(data, center=(cx, cy), radius=r, colors=colors, wedgeprops=dict(width=width, edgecolor='none'),
           startangle=90, counterclock=False)
    y0, y1 = ax.get_ylim()
    ax.set_xlim(0, W); ax.set_ylim(y0, y1)

# ---------------------------------------------------------------- CHROME
def status_bar(ax, y=130.4, fg='#FFFFFF', time='9:41', zorder=6):
    text(ax, 6, y, time, 'Nunito', 11, 700, fg, va='center', zorder=zorder)
    bx = 72.0
    for i, hh in enumerate((5, 8, 11, 14)):
        rr(ax, bx + i * 2.4, y - hh / 2, 1.7, hh, 0.8, fc=fg, zorder=zorder)
    bx = 83.0
    for i, a in enumerate((0.35, 0.55, 0.8)):
        cx = bx + i * 2.8
        rr(ax, cx - 0.9, y - 1.2, 1.8, 2.4, 0.9, fc=hx(fg, a), zorder=zorder)
    rx, ry, rw, rh = 89.0, y - 5.5, 9.5, 5.5
    rr(ax, rx, ry, rw, rh, 1.8, fc='none', ec=hx(fg, 0.9), lw=1.1, zorder=zorder)
    rr(ax, rx + 0.8, ry + 0.8, rw - 2.6, rh - 1.6, 1.0, fc=fg, zorder=zorder)
    rr(ax, rx + rw + 0.8, ry + 1.6, 0.8, rh - 3.2, 0.4, fc=hx(fg, 0.9), zorder=zorder)

def header_child(ax, greeting, name, coin, coin_delta=0, avatar_c='#FFC93C',
                 avatar_l='L', date='Mon, 3 Aug', bell=2, msg=1, zorder=4):
    gradient_rect(ax, 0, 96.0, 100, 37.4, 0, '#4F6BF5', '#7A5BF5', zorder=2)
    blob(ax, 92, 128, 18, 14, '#FFFFFF', 0.10, rot=30, zorder=2.1)
    blob(ax, 6, 98, 14, 10, '#FFFFFF', 0.08, rot=10, zorder=2.1)
    rr(ax, 0, 100.4, 100, 33, 26, fc='#4F6BF5', ec='#4F6BF5', zorder=2.2)
    text(ax, 6, 112.6, greeting, 'Quicksand', 13, 600, '#DDE5FF', zorder=5)
    text(ax, 6, 119.8, name, 'Baloo 2', 23, 700, '#FFFFFF', zorder=5)
    text(ax, 6, 128.6, date, 'Nunito', 9.5, 600, '#D6DCFE', zorder=5)
    avatar(ax, 21.5, 116.0, 6.6, avatar_l, avatar_c, '#45260A', size=9, zorder=5,
           ring='#FFFFFF', ring_lw=1.6)
    coin_chip(ax, 70.5, 116.0, coin, h=8.6, bg='#FFFFFF', fg='#0E1E5C', zorder=5)
    if coin_delta:
        text(ax, 70.5, 123.6, '+%d' % coin_delta, 'Quicksand', 9, 700, '#C4F6E8', ha='center', zorder=5)
    bw = 10.4
    pill(ax, 88.0, 116.0, bw, 9.6, None, bg=hx('#FFFFFF', 0.16), fg='#FFFFFF', zorder=5, icon='bell', ic=5.6)
    if bell:
        ax.add_patch(Circle((91.0, 120.2), 2.3, fc='#FF5A5F', ec='#FFFFFF', lw=1, zorder=6))
        text(ax, 91.0, 120.2, str(bell), 'Nunito', 6.5, 800, '#FFFFFF', ha='center', va='center', zorder=6)

def header_parent(ax, title, subtitle=None, fg='#191A24', zorder=4, back=True, bell=0):
    tx = 22.0 if back else 6.0
    text(ax, tx, 126.6, title, 'Nunito', 18, 800, fg, zorder=zorder)
    if subtitle:
        text(ax, tx, 121.4, subtitle, 'Nunito', 10.5, 600, '#767685', zorder=zorder)
    if back:
        circle_bg = '#E9EAF6'
        ax.add_patch(Circle((12.5, 123.0), 6.5, fc=hx(circle_bg), ec='none', zorder=zorder))
        draw_icon(ax, 'chev_left', 9.6, 120.1, 5.8, '#191A24')
    if bell:
        ax.add_patch(Circle((89.5, 123.0), 6.5, fc=hx('#E9EAF6'), ec='none', zorder=zorder))
        draw_icon(ax, 'bell', 86.6, 120.1, 5.8, '#191A24')

def bottom_nav(ax, items, active, fg='#191A24', accent='#4F6BF5', y=0, h=15.2, zorder=4):
    shadow(ax, 0, y, 100, h, 24, 3, zorder=zorder - 0.6)
    rr(ax, 0, y, 100, h, 24, fc='#FFFFFF', zorder=zorder - 0.4)
    n = len(items)
    sw = 100 / n
    for i, (icon_name, label) in enumerate(items):
        cx = sw * i + sw / 2
        active_i = (i == active)
        cy = y + h / 2 + 1.4
        if active_i:
            rr(ax, cx - 17, cy - 3.6, 34, 7.2, 7.2, fc=hx(accent, 0.14), zorder=zorder + 0.2)
            draw_icon(ax, icon_name, cx - 3, cy - 3, 6, accent)
            text(ax, cx, cy - 4.6, label, 'Nunito', 8.5, 700, accent, ha='center', va='center', zorder=zorder + 1)
        else:
            draw_icon(ax, icon_name, cx - 3, cy - 3, 6, hx(fg, 0.55))
            text(ax, cx, cy - 4.6, label, 'Nunito', 8.5, 600, hx(fg, 0.55), ha='center', va='center', zorder=zorder + 1)

def section(ax, x, y, title, more=None, color='#191A24', family='Baloo 2', size=18, zorder=5):
    text(ax, x, y, title, family, size, 700, color, zorder=zorder)
    if more:
        text(ax, 96, y, more, 'Nunito', 10.5, 700, '#4F6BF5', ha='right', va='top', zorder=zorder)

def fab(ax, cx, cy, r, icon='plus', color='#FF8A3D', fg='#FFFFFF', zorder=5, level=3):
    shadow(ax, cx - r, cy - r, 2 * r, 2 * r, r, level, zorder=zorder - 0.5)
    ax.add_patch(Circle((cx, cy), r, fc=hx(color), ec='none', zorder=zorder))
    s = r * 0.9
    draw_icon(ax, icon, cx - s / 2, cy - s / 2, s, fg, zorder=zorder + 1)

def toggle(ax, x, y, w, h, on=True, color='#2FAE66', zorder=4):
    rr(ax, x, y, w, h, h / 2, fc=hx(color, 0.9 if on else 0.28), zorder=zorder)
    c = x + w - h if on else x + h
    ax.add_patch(Circle((c, y + h / 2), h / 2 - 1.4, fc='#FFFFFF', ec=hx('#FFFFFF', 0.35), lw=0.6, zorder=zorder + 0.5))

def divider(ax, x, y, w, color='#E9EAF6', lw=1.2, zorder=3):
    ax.plot([x, x + w], [y, y], color=hx(color), lw=lw, zorder=zorder, solid_capstyle='round')

# ---------------------------------------------------------------- ICONS
def _star_pts(cx, cy, R, r):
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rad = R if i % 2 == 0 else r
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
    return pts

def _poly(ax, pts, c, closed=True, lw=0, zorder=6, alpha=1.0):
    ax.add_patch(Polygon(pts, closed=closed, fc=hx(c, alpha), ec=hx(c, alpha), lw=lw, zorder=zorder))

def _circle(ax, cx, cy, r, c, lw=0, zorder=6, alpha=1.0, fill=True, ec=None):
    ax.add_patch(Circle((cx, cy), r, fc=hx(c, alpha) if fill else 'none',
                        ec=ec if ec is not None else (hx(c, alpha) if not fill else 'none'),
                        lw=lw, zorder=zorder))

def _line(ax, pts, c, lw=2.4, zorder=6, cap='round'):
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    ax.plot(xs, ys, color=hx(c), lw=lw, zorder=zorder, solid_capstyle=cap, solid_joinstyle='round')

def _icon_chev_left(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.32, y + s * 0.5), (x + s * 0.66, y + s * 0.18), (x + s * 0.66, y + s * 0.82)], c, lw)

def _icon_chev_right(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.34, y + s * 0.18), (x + s * 0.68, y + s * 0.5), (x + s * 0.34, y + s * 0.82)], c, lw)

def _icon_chev_down(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.2, y + s * 0.36), (x + s * 0.5, y + s * 0.66), (x + s * 0.8, y + s * 0.36)], c, lw)

def _icon_plus(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.5, y + s * 0.22), (x + s * 0.5, y + s * 0.78)], c, lw)
    _line(ax, [(x + s * 0.22, y + s * 0.5), (x + s * 0.78, y + s * 0.5)], c, lw)

def _icon_check(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.2, y + s * 0.52), (x + s * 0.44, y + s * 0.72), (x + s * 0.8, y + s * 0.26)], c, lw)

def _icon_cross(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.25, y + s * 0.25), (x + s * 0.75, y + s * 0.75)], c, lw)
    _line(ax, [(x + s * 0.75, y + s * 0.25), (x + s * 0.25, y + s * 0.75)], c, lw)

def _icon_star(ax, x, y, s, c, lw):
    _poly(ax, _star_pts(x + s / 2, y + s / 2, s * 0.5, s * 0.2), c)

def _icon_sparkle(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    R, r = s * 0.52, s * 0.13
    pts = []
    for i in range(8):
        ang = -math.pi / 2 + i * math.pi / 4
        rad = R if i % 2 == 0 else r
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
    _poly(ax, pts, c)

def _icon_sun(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    _circle(ax, cx, cy, s * 0.22, c)
    for i in range(8):
        ang = i * math.pi / 4
        x0 = cx + math.cos(ang) * s * 0.34; y0 = cy + math.sin(ang) * s * 0.34
        x1 = cx + math.cos(ang) * s * 0.48; y1 = cy + math.sin(ang) * s * 0.48
        _line(ax, [(x0, y0), (x1, y1)], c, max(lw, s * 0.07))

def _icon_moon(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    ax.add_patch(Ellipse((cx + s * 0.09, cy), s * 0.5, s * 0.62, fc=hx(c), ec='none', zorder=6))

def _icon_coin(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    _circle(ax, cx, cy, s * 0.42, c)
    _circle(ax, cx, cy, s * 0.26, hx('#FFFFFF', 0.85), lw=0)

def _icon_star_small(ax, x, y, s, c, lw):
    _icon_star(ax, x, y, s, c, lw)

def _icon_home(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    roof = [(x + s * 0.06, cy + s * 0.18), (cx, y + s * 0.06), (x + s * 0.94, cy + s * 0.18)]
    _poly(ax, roof, c)
    _poly(ax, [(x + s * 0.22, cy + s * 0.16), (x + s * 0.22, y + s * 0.92),
               (x + s * 0.78, y + s * 0.92), (x + s * 0.78, cy + s * 0.16)], c)

def _icon_tasks(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.18, y + s * 0.12), (x + s * 0.9, y + s * 0.12), (x + s * 0.9, y + s * 0.88),
               (x + s * 0.18, y + s * 0.88)], c)
    _line(ax, [(x + s * 0.34, y + s * 0.36), (x + s * 0.46, y + s * 0.5), (x + s * 0.72, y + s * 0.28)],
          hx('#FFFFFF', 0.95), lw * 1.1)
    _line(ax, [(x + s * 0.32, y + s * 0.62), (x + s * 0.7, y + s * 0.62)], hx('#FFFFFF', 0.95), lw * 0.9)
    _line(ax, [(x + s * 0.32, y + s * 0.76), (x + s * 0.58, y + s * 0.76)], hx('#FFFFFF', 0.95), lw * 0.9)

def _icon_trophy(ax, x, y, s, c, lw):
    cx = x + s / 2
    _poly(ax, [(x + s * 0.22, y + s * 0.06), (x + s * 0.78, y + s * 0.06),
               (x + s * 0.72, y + s * 0.52), (cx, y + s * 0.62), (x + s * 0.28, y + s * 0.52)], c)
    _poly(ax, [(x + s * 0.3, y + s * 0.5), (x + s * 0.5, y + s * 0.66), (x + s * 0.7, y + s * 0.5),
               (x + s * 0.8, y + s * 0.5), (x + s * 0.8, y + s * 0.12), (x + s * 0.2, y + s * 0.12),
               (x + s * 0.2, y + s * 0.5)], c)
    _line(ax, [(cx, y + s * 0.66), (cx, y + s * 0.82)], c, lw * 1.1)
    _line(ax, [(x + s * 0.34, y + s * 0.9), (x + s * 0.66, y + s * 0.9)], c, lw * 1.1)

def _icon_medal(ax, x, y, s, c, lw):
    cx = x + s / 2
    _circle(ax, cx, y + s * 0.38, s * 0.24, c)
    _poly(ax, [(cx - s * 0.1, y + s * 0.52), (x + s * 0.22, y + s * 0.9), (cx, y + s * 0.74),
               (x + s * 0.78, y + s * 0.9), (cx + s * 0.1, y + s * 0.52)], c)

def _icon_badge(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.12, y + s * 0.12), (x + s * 0.88, y + s * 0.12),
               (x + s * 0.88, y + s * 0.62), (x + s * 0.5, y + s * 0.9), (x + s * 0.12, y + s * 0.62)], c)
    _poly(ax, _star_pts(x + s / 2, y + s * 0.44, s * 0.2, s * 0.08), hx('#FFFFFF', 0.95))

def _icon_gear(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    for i in range(8):
        ang = i * math.pi / 4
        ax.add_patch(Rectangle((cx + math.cos(ang) * s * 0.2 - s * 0.07, cy + math.sin(ang) * s * 0.2 - s * 0.07),
                               s * 0.14, s * 0.14, fc=hx(c), ec='none', zorder=6))
    _circle(ax, cx, cy, s * 0.38, c)
    _circle(ax, cx, cy, s * 0.16, hx('#FFFFFF', 0.9), lw=0)

def _icon_bell(ax, x, y, s, c, lw):
    cx = x + s / 2
    _line(ax, [(cx - s * 0.12, y + s * 0.34), (cx - s * 0.12, y + s * 0.22), (cx, y + s * 0.08),
               (cx + s * 0.12, y + s * 0.22), (cx + s * 0.12, y + s * 0.34)], c, lw * 1.05)
    _poly(ax, [(cx - s * 0.3, y + s * 0.34), (cx + s * 0.3, y + s * 0.34),
               (cx + s * 0.2, y + s * 0.56), (cx - s * 0.2, y + s * 0.56)], c)

def _icon_mail(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.12, y + s * 0.2), (x + s * 0.88, y + s * 0.2),
               (x + s * 0.88, y + s * 0.8), (x + s * 0.12, y + s * 0.8)], c)
    _poly(ax, [(x + s * 0.12, y + s * 0.2), (x + s * 0.5, y + s * 0.5), (x + s * 0.88, y + s * 0.2)],
          hx('#FFFFFF', 0.95))

def _icon_chart(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.2, y + s * 0.86), (x + s * 0.2, y + s * 0.3), (x + s * 0.28, y + s * 0.3),
               (x + s * 0.28, y + s * 0.86)], c)
    _poly(ax, [(x + s * 0.44, y + s * 0.86), (x + s * 0.44, y + s * 0.1), (x + s * 0.52, y + s * 0.1),
               (x + s * 0.52, y + s * 0.86)], c)
    _poly(ax, [(x + s * 0.68, y + s * 0.86), (x + s * 0.68, y + s * 0.5), (x + s * 0.76, y + s * 0.5),
               (x + s * 0.76, y + s * 0.86)], c)

def _icon_lock(ax, x, y, s, c, lw):
    cx = x + s / 2
    _poly(ax, [(x + s * 0.26, y + s * 0.52), (x + s * 0.26, y + s * 0.3),
               (cx, y + s * 0.16), (x + s * 0.74, y + s * 0.3), (x + s * 0.74, y + s * 0.52)], c)
    _poly(ax, [(x + s * 0.18, y + s * 0.52), (x + s * 0.82, y + s * 0.52),
               (x + s * 0.82, y + s * 0.86), (x + s * 0.18, y + s * 0.86)], c)

def _icon_person(ax, x, y, s, c, lw):
    cx = x + s / 2
    _circle(ax, cx, y + s * 0.26, s * 0.17, c)
    ax.add_patch(Ellipse((cx, y + s * 0.72), s * 0.52, s * 0.36, fc=hx(c), ec='none', zorder=6))

def _icon_child(ax, x, y, s, c, lw):
    cx = x + s / 2
    _circle(ax, cx, y + s * 0.24, s * 0.19, c)
    for i, ang in enumerate((0.45, 1.1, 2.0, 2.65)):
        _poly(ax, _star_pts(cx + math.cos(ang) * s * 0.16, y + s * 0.24 + math.sin(ang) * s * 0.16,
                            s * 0.06, s * 0.03), c)
    ax.add_patch(Ellipse((cx, y + s * 0.7), s * 0.5, s * 0.34, fc=hx(c), ec='none', zorder=6))

def _icon_parent(ax, x, y, s, c, lw):
    _icon_person(ax, x, y, s, c, lw)
    _line(ax, [(x + s * 0.06, y + s * 0.6), (x + s * 0.94, y + s * 0.6)], hx('#FFFFFF', 0.95), lw * 0.7)

def _icon_add_child(ax, x, y, s, c, lw):
    cx = x + s / 2
    _circle(ax, cx, y + s * 0.26, s * 0.17, c)
    ax.add_patch(Ellipse((cx, y + s * 0.68), s * 0.46, s * 0.32, fc=hx(c), ec='none', zorder=6))
    _line(ax, [(x + s * 0.82, y + s * 0.14), (x + s * 0.82, y + s * 0.46)], c, lw * 0.9)
    _line(ax, [(x + s * 0.66, y + s * 0.3), (x + s * 0.98, y + s * 0.3)], c, lw * 0.9)

def _icon_edit(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.12, y + s * 0.84), (x + s * 0.2, y + s * 0.58),
               (x + s * 0.66, y + s * 0.16), (x + s * 0.86, y + s * 0.32), (x + s * 0.42, y + s * 0.76)], c)
    _line(ax, [(x + s * 0.58, y + s * 0.24), (x + s * 0.78, y + s * 0.42)], hx('#FFFFFF', 0.95), lw * 0.8)

def _icon_trash(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.2, y + s * 0.18), (x + s * 0.36, y + s * 0.18),
               (x + s * 0.42, y + s * 0.08), (x + s * 0.58, y + s * 0.08),
               (x + s * 0.64, y + s * 0.18), (x + s * 0.8, y + s * 0.18),
               (x + s * 0.76, y + s * 0.86), (x + s * 0.24, y + s * 0.86)], c)
    _line(ax, [(x + s * 0.4, y + s * 0.32), (x + s * 0.4, y + s * 0.7)], hx('#FFFFFF', 0.95), lw * 0.7)
    _line(ax, [(x + s * 0.6, y + s * 0.32), (x + s * 0.6, y + s * 0.7)], hx('#FFFFFF', 0.95), lw * 0.7)

def _icon_calendar(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.12, y + s * 0.2), (x + s * 0.88, y + s * 0.2), (x + s * 0.88, y + s * 0.86),
               (x + s * 0.12, y + s * 0.86)], c)
    _line(ax, [(x + s * 0.12, y + s * 0.38), (x + s * 0.88, y + s * 0.38)], hx('#FFFFFF', 0.95), lw * 0.8)
    _line(ax, [(x + s * 0.3, y + s * 0.08), (x + s * 0.3, y + s * 0.26)], hx('#FFFFFF', 0.95), lw * 0.8)
    _line(ax, [(x + s * 0.7, y + s * 0.08), (x + s * 0.7, y + s * 0.26)], hx('#FFFFFF', 0.95), lw * 0.8)

def _icon_clock(ax, x, y, s, c, lw):
    cx, cy = x + s / 2, y + s / 2
    _circle(ax, cx, cy, s * 0.42, c)
    _line(ax, [(cx, cy), (cx, cy + s * 0.24)], hx('#FFFFFF', 0.95), lw * 0.9)
    _line(ax, [(cx, cy), (cx + s * 0.2, cy)], hx('#FFFFFF', 0.95), lw * 0.9)

def _icon_heart(ax, x, y, s, c, lw):
    cx = x + s / 2
    _poly(ax, [(cx, y + s * 0.8), (x + s * 0.08, y + s * 0.42), (x + s * 0.2, y + s * 0.16),
               (cx - s * 0.1, y + s * 0.1), (cx, y + s * 0.28), (cx + s * 0.1, y + s * 0.1),
               (x + s * 0.8, y + s * 0.16), (x + s * 0.92, y + s * 0.42)], c)

def _icon_search(ax, x, y, s, c, lw):
    cx = x + s * 0.42; cy = y + s * 0.42
    _circle(ax, cx, cy, s * 0.26, c)
    _line(ax, [(x + s * 0.6, y + s * 0.6), (x + s * 0.86, y + s * 0.86)], c, lw * 1.1)

def _icon_eye(ax, x, y, s, c, lw):
    cx = x + s / 2; cy = y + s / 2
    _poly(ax, [(x + s * 0.06, cy), (x + s * 0.5, y + s * 0.12), (x + s * 0.94, cy),
               (x + s * 0.5, y + s * 0.88)], c)
    _circle(ax, cx, cy, s * 0.16, hx('#FFFFFF', 0.95), lw=0)

def _icon_shield(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.2, y + s * 0.08), (x + s * 0.8, y + s * 0.08), (x + s * 0.8, y + s * 0.56),
               (x + s * 0.5, y + s * 0.92), (x + s * 0.2, y + s * 0.56)], c)
    _line(ax, [(x + s * 0.34, y + s * 0.46), (x + s * 0.48, y + s * 0.6), (x + s * 0.68, y + s * 0.32)],
          hx('#FFFFFF', 0.95), lw * 0.9)

def _icon_verified(ax, x, y, s, c, lw):
    _icon_shield(ax, x, y, s, c, lw)
    _line(ax, [(x + s * 0.34, y + s * 0.46), (x + s * 0.48, y + s * 0.6), (x + s * 0.68, y + s * 0.32)],
          hx('#FFFFFF', 0.95), lw * 0.9)

def _icon_book(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.28, y + s * 0.1), (x + s * 0.5, y + s * 0.22), (x + s * 0.72, y + s * 0.1),
               (x + s * 0.86, y + s * 0.16), (x + s * 0.86, y + s * 0.86), (x + s * 0.72, y + s * 0.8),
               (x + s * 0.5, y + s * 0.9), (x + s * 0.28, y + s * 0.8), (x + s * 0.14, y + s * 0.86),
               (x + s * 0.14, y + s * 0.16)], c)
    _line(ax, [(x + s * 0.5, y + s * 0.22), (x + s * 0.5, y + s * 0.9)], hx('#FFFFFF', 0.95), lw * 0.7)

def _icon_water(ax, x, y, s, c, lw):
    cx = x + s / 2
    _poly(ax, [(cx, y + s * 0.08), (x + s * 0.74, y + s * 0.52), (x + s * 0.62, y + s * 0.88),
               (x + s * 0.38, y + s * 0.88), (x + s * 0.26, y + s * 0.52)], c)
    _poly(ax, [(cx - s * 0.05, y + s * 0.42), (cx + s * 0.05, y + s * 0.42),
               (cx + s * 0.08, y + s * 0.62), (cx - s * 0.08, y + s * 0.62)], hx('#FFFFFF', 0.9))

def _icon_run(ax, x, y, s, c, lw):
    cx = x + s / 2
    _circle(ax, cx, y + s * 0.2, s * 0.14, c)
    _line(ax, [(cx, y + s * 0.34), (cx, y + s * 0.56)], c, lw * 0.9)
    _line(ax, [(cx, y + s * 0.4), (x + s * 0.32, y + s * 0.56)], c, lw * 0.9)
    _line(ax, [(cx, y + s * 0.56), (x + s * 0.64, y + s * 0.7), (x + s * 0.78, y + s * 0.9)], c, lw * 0.9)
    _line(ax, [(cx, y + s * 0.56), (x + s * 0.46, y + s * 0.8)], c, lw * 0.9)

def _icon_bed(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.1, y + s * 0.3), (x + s * 0.9, y + s * 0.3), (x + s * 0.9, y + s * 0.46),
               (x + s * 0.1, y + s * 0.46)], c)
    _poly(ax, [(x + s * 0.1, y + s * 0.5), (x + s * 0.9, y + s * 0.5), (x + s * 0.9, y + s * 0.88),
               (x + s * 0.1, y + s * 0.88)], c)
    _circle(ax, x + s * 0.28, y + s * 0.38, s * 0.06, hx('#FFFFFF', 0.95), lw=0)

def _icon_plants(ax, x, y, s, c, lw):
    cx = x + s / 2
    _line(ax, [(cx, y + s * 0.4), (cx, y + s * 0.88)], c, lw * 0.9)
    _poly(ax, [(cx, y + s * 0.4), (x + s * 0.26, y + s * 0.24), (x + s * 0.24, y + s * 0.52),
               (cx, y + s * 0.5)], c)
    _poly(ax, [(cx, y + s * 0.4), (x + s * 0.78, y + s * 0.26), (x + s * 0.8, y + s * 0.54),
               (cx, y + s * 0.5)], c)

def _icon_pets(ax, x, y, s, c, lw):
    for (dx, dy, rr) in ((0.28, 0.34, 0.12), (0.44, 0.2, 0.12), (0.6, 0.34, 0.12), (0.72, 0.24, 0.1),
                         (0.5, 0.5, 0.2)):
        _circle(ax, x + s * dx, y + s * dy, s * rr, c)

def _icon_food(ax, x, y, s, c, lw):
    cx = x + s / 2
    _poly(ax, [(x + s * 0.1, y + s * 0.36), (x + s * 0.9, y + s * 0.36), (x + s * 0.8, y + s * 0.88),
               (x + s * 0.2, y + s * 0.88)], c)
    _line(ax, [(x + s * 0.16, y + s * 0.14), (x + s * 0.16, y + s * 0.3)], hx('#FFFFFF', 0.95), lw * 0.8)
    _line(ax, [(x + s * 0.5, y + s * 0.08), (x + s * 0.5, y + s * 0.3)], hx('#FFFFFF', 0.95), lw * 0.8)
    _line(ax, [(x + s * 0.84, y + s * 0.14), (x + s * 0.84, y + s * 0.3)], hx('#FFFFFF', 0.95), lw * 0.8)

def _icon_homework(ax, x, y, s, c, lw):
    _icon_book(ax, x, y + s * 0.14, s, c, lw)
    _poly(ax, [(x + s * 0.64, y + s * 0.36), (x + s * 0.8, y + s * 0.5), (x + s * 0.68, y + s * 0.66),
               (x + s * 0.52, y + s * 0.52)], c)

def _icon_music(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.4, y + s * 0.24), (x + s * 0.76, y + s * 0.1), (x + s * 0.76, y + s * 0.5)],
          c, lw * 0.9)
    _circle(ax, x + s * 0.3, y + s * 0.62, s * 0.14, c)
    _circle(ax, x + s * 0.66, y + s * 0.62, s * 0.14, c)

def _icon_paint(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.12, y + s * 0.2), (x + s * 0.86, y + s * 0.2), (x + s * 0.86, y + s * 0.62),
               (x + s * 0.58, y + s * 0.62), (x + s * 0.5, y + s * 0.82), (x + s * 0.42, y + s * 0.62),
               (x + s * 0.12, y + s * 0.62)], c)
    _circle(ax, x + s * 0.3, y + s * 0.36, s * 0.06, hx('#FFFFFF', 0.95), lw=0)
    _circle(ax, x + s * 0.5, y + s * 0.36, s * 0.06, hx('#FFFFFF', 0.95), lw=0)
    _circle(ax, x + s * 0.7, y + s * 0.36, s * 0.06, hx('#FFFFFF', 0.95), lw=0)

def _icon_message(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.1, y + s * 0.14), (x + s * 0.9, y + s * 0.14), (x + s * 0.9, y + s * 0.66),
               (x + s * 0.5, y + s * 0.66), (x + s * 0.16, y + s * 0.84), (x + s * 0.22, y + s * 0.66),
               (x + s * 0.1, y + s * 0.66)], c)
    _line(ax, [(x + s * 0.26, y + s * 0.3), (x + s * 0.74, y + s * 0.3)], hx('#FFFFFF', 0.95), lw * 0.7)
    _line(ax, [(x + s * 0.26, y + s * 0.44), (x + s * 0.6, y + s * 0.44)], hx('#FFFFFF', 0.95), lw * 0.7)

def _icon_info(ax, x, y, s, c, lw):
    cx = x + s / 2; cy = y + s / 2
    _circle(ax, cx, cy, s * 0.42, c)
    _circle(ax, cx, cy + s * 0.12, s * 0.06, hx('#FFFFFF', 0.95), lw=0)
    _poly(ax, [(cx - s * 0.05, cy - s * 0.02), (cx + s * 0.05, cy - s * 0.02),
               (cx + s * 0.05, cy - s * 0.26), (cx - s * 0.05, cy - s * 0.26)], hx('#FFFFFF', 0.95))

def _icon_help(ax, x, y, s, c, lw):
    cx = x + s / 2; cy = y + s / 2
    _circle(ax, cx, cy, s * 0.42, c)
    _line(ax, [(cx - s * 0.06, cy + s * 0.18), (cx - s * 0.06, cy + s * 0.08),
               (cx, cy - s * 0.02), (cx + s * 0.1, cy - s * 0.1)],
          hx('#FFFFFF', 0.95), lw * 0.75)
    _circle(ax, cx + s * 0.06, cy - s * 0.22, s * 0.035, hx('#FFFFFF', 0.95), lw=0)

def _icon_download(ax, x, y, s, c, lw):
    cx = x + s / 2
    _line(ax, [(cx, y + s * 0.12), (cx, y + s * 0.5)], c, lw * 0.9)
    _line(ax, [(cx - s * 0.16, y + s * 0.36), (cx, y + s * 0.56), (cx + s * 0.16, y + s * 0.36)], c, lw * 0.9)
    _line(ax, [(x + s * 0.2, y + s * 0.8), (x + s * 0.8, y + s * 0.8)], c, lw * 0.9)

def _icon_target(ax, x, y, s, c, lw):
    cx = x + s / 2; cy = y + s / 2
    _circle(ax, cx, cy, s * 0.42, c)
    _circle(ax, cx, cy, s * 0.24, c)
    _circle(ax, cx, cy, s * 0.07, hx('#FFFFFF', 0.95), lw=0)

def _icon_minus(ax, x, y, s, c, lw):
    _line(ax, [(x + s * 0.2, y + s * 0.5), (x + s * 0.8, y + s * 0.5)], c, lw)

def _icon_send(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.08, y + s * 0.5), (x + s * 0.92, y + s * 0.12), (x + s * 0.62, y + s * 0.88),
               (x + s * 0.5, y + s * 0.56)], c)

def _icon_trophy_small(ax, x, y, s, c, lw):
    _icon_trophy(ax, x, y, s, c, lw)

def _icon_lightning(ax, x, y, s, c, lw):
    _poly(ax, [(x + s * 0.56, y + s * 0.08), (x + s * 0.3, y + s * 0.54), (x + s * 0.5, y + s * 0.54),
               (x + s * 0.42, y + s * 0.92), (x + s * 0.72, y + s * 0.44), (x + s * 0.5, y + s * 0.44)], c)

ICONS = {
    'chev_left': _icon_chev_left, 'chev_right': _icon_chev_right, 'chev_down': _icon_chev_down,
    'plus': _icon_plus, 'check': _icon_check, 'cross': _icon_cross,
    'star': _icon_star, 'sparkle': _icon_sparkle, 'sun': _icon_sun, 'moon': _icon_moon,
    'coin': _icon_coin, 'home': _icon_home, 'tasks': _icon_tasks, 'trophy': _icon_trophy,
    'medal': _icon_medal, 'badge': _icon_badge, 'gear': _icon_gear, 'bell': _icon_bell,
    'mail': _icon_mail, 'chart': _icon_chart, 'lock': _icon_lock, 'person': _icon_person,
    'child': _icon_child, 'parent': _icon_parent, 'add_child': _icon_add_child,
    'edit': _icon_edit, 'trash': _icon_trash, 'calendar': _icon_calendar, 'clock': _icon_clock,
    'heart': _icon_heart, 'search': _icon_search, 'eye': _icon_eye, 'shield': _icon_shield,
    'verified': _icon_verified, 'book': _icon_book, 'water': _icon_water, 'run': _icon_run,
    'bed': _icon_bed, 'plants': _icon_plants, 'pets': _icon_pets, 'food': _icon_food,
    'homework': _icon_homework, 'music': _icon_music, 'paint': _icon_paint,
    'message': _icon_message, 'info': _icon_info, 'help': _icon_help, 'download': _icon_download,
    'target': _icon_target, 'minus': _icon_minus, 'send': _icon_send, 'lightning': _icon_lightning,
}

def draw_icon(ax, name, x, y, s, color, lw=None, zorder=6):
    fn = ICONS.get(name)
    if not fn:
        return
    _z = ax.text  # noop reference to keep imports
    old = None
    fn(ax, x, y, s, color, lw if lw is not None else max(2.2, s * 0.09))

def icon_badge_circle(ax, cx, cy, r, icon, bg, fg='#FFFFFF', zorder=4, ic=None):
    ax.add_patch(Circle((cx, cy), r, fc=hx(bg), ec='none', zorder=zorder))
    ic = ic or r * 1.05
    draw_icon(ax, icon, cx - ic / 2, cy - ic / 2, ic, fg, zorder=zorder + 1)

# ---------------------------------------------------------------- CANVAS
HLAND = 75.0

def canvas(bg=None, w=6.0, h=8.0, dpi=240, gradient=None, face=None, ylim=None):
    fig = plt.figure(figsize=(w, h), dpi=dpi)
    fig.patch.set_facecolor(face or '#F7F8FE')
    ax = fig.add_axes([0, 0, 1, 1])
    ymax = ylim if ylim is not None else H
    ax.set_xlim(0, W); ax.set_ylim(0, ymax)
    ax.set_aspect('equal'); ax.axis('off')
    if gradient:
        gradient_rect(ax, 0, 0, W, ymax, 0, gradient[0], gradient[1], zorder=0)
    else:
        rr(ax, 0, 0, W, ymax, 0, fc=bg or '#F7F8FE', zorder=0)
    return fig, ax

def decor(ax, a='#DDE5FF', b='#FFE0C7', c='#C4F6E8', z=0.8):
    blob(ax, -7, 130, 26, 18, a, 0.75, rot=24, zorder=z)
    blob(ax, 107, 128, 20, 24, b, 0.6, rot=-18, zorder=z)
    blob(ax, 106, 14, 26, 16, c, 0.55, rot=20, zorder=z)

def save(fig, path, dpi=240):
    fig.savefig(path, dpi=dpi, facecolor=fig.get_facecolor())
    plt.close(fig)
    print('saved', path)

def logo(ax, cx, cy, r, text=None, bg='#4F6BF5', fg='#FFFFFF'):
    # halo
    blob(ax, cx, cy, r * 1.55, r * 1.55, '#FFC93C', 0.28, zorder=3)
    blob(ax, cx, cy, r * 1.25, r * 1.25, '#FFC93C', 0.4, zorder=3.2)
    ax.add_patch(Circle((cx, cy), r, fc=hx('#FFC93C'), ec='#FFB800', lw=0, zorder=4))
    _circle(ax, cx - r * 0.3, cy - r * 0.08, r * 0.09, '#5B4200', zorder=5)
    _circle(ax, cx + r * 0.3, cy - r * 0.08, r * 0.09, '#5B4200', zorder=5)
    # smile
    ax.add_patch(PathPatch(Path([(cx - r * 0.28, cy + r * 0.28),
                                 (cx - r * 0.14, cy + r * 0.42),
                                 (cx, cy + r * 0.46),
                                 (cx + r * 0.14, cy + r * 0.42),
                                 (cx + r * 0.28, cy + r * 0.28)]),
                           fc='none', ec='#5B4200', lw=2.2, zorder=5))
    _circle(ax, cx - r * 0.55, cy + r * 0.05, r * 0.07, '#FFB800', zorder=4)
    _circle(ax, cx + r * 0.55, cy + r * 0.05, r * 0.07, '#FFB800', zorder=4)
    if text:
        text(ax, cx, cy - r * 1.75, text, 'Baloo 2', 22, 700, '#0E1E5C', ha='center', va='center', zorder=6)

def mascot(ax, cx, cy, r):
    """Small Sunny used in corner decorations."""
    logo(ax, cx, cy, r)
