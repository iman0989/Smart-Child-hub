"""Shared drawing library for generating professional software engineering diagrams."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Rectangle, Ellipse, Circle

plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['Segoe UI', 'Arial', 'DejaVu Sans']
plt.rcParams['axes.edgecolor'] = '#1F4E79'

# Color palette
BLUE = '#1F4E79'
BLUE2 = '#2E74B5'
LBLUE = '#DEEBF7'
LBLUE2 = '#EAF1FB'
ORANGE = '#C55A11'
LORANGE = '#FBE5D6'
GREEN = '#538135'
LGREEN = '#E2EFDA'
GRAY = '#7F7F7F'
LGRAY = '#F2F2F2'
RED = '#C00000'
LRED = '#FDE9E9'
PURPLE = '#7030A0'
LPURPLE = '#EAE1F4'
DARK = '#1A1A1A'


def new_fig(w, h):
    fig, ax = plt.subplots(figsize=(w, h), dpi=200)
    ax.axis('off')
    fig.patch.set_facecolor('white')
    return fig, ax


def save(fig, path, title=None):
    if title is not None:
        fig.suptitle(title, fontsize=14, color=BLUE, fontweight='bold', y=0.98)
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    svg = path[:-4] + '.svg'
    fig.savefig(svg, bbox_inches='tight', facecolor='white')
    plt.close(fig)


def _lines_in(text):
    if text is None:
        return []
    if isinstance(text, list):
        return text
    return str(text).split('\n')


def box(ax, x, y, w, h, text='', fc=LBLUE, ec=BLUE, lw=1.6, fs=9, tc=DARK,
        bold=False, header=None, header_fc=BLUE, header_tc='white', header_fs=9,
        rounding=0.5, zorder=3, align='center', line_spacing=1.35):
    """Draw a box. x,y = bottom-left. If header given, top strip is shaded."""
    patch = FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad=0,rounding_size={rounding}",
                           fc=fc, ec=ec, lw=lw, zorder=zorder)
    ax.add_patch(patch)
    if header is not None:
        hp = Rectangle((x, y + h - 0.32 * h), w, 0.32 * h, fc=header_fc, ec=ec, lw=lw, zorder=zorder + 1)
        ax.add_patch(hp)
        ax.text(x + w / 2.0, y + h - 0.16 * h, header, ha='center', va='center',
                fontsize=header_fs, color=header_tc, fontweight='bold', zorder=zorder + 2)
        body_y = y + (h * 0.32) / 2.0 - 0.5
    else:
        body_y = y + h / 2.0 - 0.5
    lines = _lines_in(text)
    n = len(lines)
    start = body_y + (n - 1) * (line_spacing * fs * 0.22)
    for i, ln in enumerate(lines):
        ax.text(x + w / 2.0, start - i * (line_spacing * fs * 0.22), ln,
                ha=align, va='center', fontsize=fs, color=tc, fontweight='bold' if bold else 'normal',
                zorder=zorder + 2)
    return (x, y, w, h)


def box_plain(ax, x, y, w, h, text='', fc=LBLUE, ec=BLUE, lw=1.6, fs=9, tc=DARK,
              bold=False, rounding=0.5, zorder=3):
    patch = FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad=0,rounding_size={rounding}",
                           fc=fc, ec=ec, lw=lw, zorder=zorder)
    ax.add_patch(patch)
    lines = _lines_in(text)
    n = len(lines)
    start = y + h / 2.0 + (n - 1) * (fs * 0.24)
    for i, ln in enumerate(lines):
        ax.text(x + w / 2.0, start - i * (fs * 0.24), ln, ha='center', va='center',
                fontsize=fs, color=tc, fontweight='bold' if bold else 'normal', zorder=zorder + 2)
    return (x, y, w, h)


def ellipse(ax, cx, cy, w, h, text='', fc=LBLUE, ec=BLUE, lw=1.6, fs=9, tc=DARK,
            bold=False, zorder=3):
    e = Ellipse((cx, cy), w, h, fc=fc, ec=ec, lw=lw, zorder=zorder)
    ax.add_patch(e)
    lines = _lines_in(text)
    n = len(lines)
    start = cy + (n - 1) * (fs * 0.24)
    for i, ln in enumerate(lines):
        ax.text(cx, start - i * (fs * 0.24), ln, ha='center', va='center',
                fontsize=fs, color=tc, fontweight='bold' if bold else 'normal', zorder=zorder + 2)


def actor(ax, x, y, label='', color=BLUE, fs=9, scale=1.0):
    """Standard UML stick actor. y = center of head."""
    s = scale
    head = Circle((x, y + 4.0 * s), 1.6 * s, fc='white', ec=color, lw=1.5, zorder=3)
    ax.add_patch(head)
    ax.plot([x, x], [y + 4.0 * s - 1.6 * s, y - 2.0 * s], color=color, lw=1.5, zorder=3)
    ax.plot([x - 3.0 * s, x + 3.0 * s], [y - 1.0 * s, y - 1.0 * s], color=color, lw=1.5, zorder=3)
    ax.plot([x, x - 2.6 * s], [y, y - 3.6 * s], color=color, lw=1.5, zorder=3)
    ax.plot([x, x + 2.6 * s], [y, y - 3.6 * s], color=color, lw=1.5, zorder=3)
    ax.text(x, y - 6.4 * s, label, ha='center', va='center', fontsize=fs, color=color,
            fontweight='bold', zorder=3)


def arrow(ax, x1, y1, x2, y2, text='', rad=0.0, color=BLUE, lw=1.6, fs=7.5,
          tc='#333', style='-|>', ls='-', text_dx=0, text_dy=0.6, text_ha='center',
          text_va='center', shrinkA=0, shrinkB=0, zorder=5, boxtext=False, ms=13):
    a = FancyArrowPatch((x1, y1), (x2, y2), connectionstyle=f"arc3,rad={rad}",
                        arrowstyle=style, color=color, lw=lw, linestyle=ls,
                        mutation_scale=ms, shrinkA=shrinkA, shrinkB=shrinkB, zorder=zorder)
    ax.add_patch(a)
    if text:
        mx, my = (x1 + x2) / 2.0 + text_dx, (y1 + y2) / 2.0 + text_dy
        kw = dict(ha=text_ha, va=text_va, fontsize=fs, color=tc, zorder=zorder + 2)
        if boxtext:
            kw['bbox'] = dict(boxstyle='round,pad=0.18', fc='white', ec='#BFBFBF', alpha=0.95)
        ax.text(mx, my, text, **kw)


def line(ax, x1, y1, x2, y2, color=BLUE, lw=1.6, ls='-', zorder=3):
    ax.plot([x1, x2], [y1, y2], color=color, lw=lw, linestyle=ls, zorder=zorder)


def datastore(ax, x, y, w, label='', ec=BLUE, fc='white', fs=8.5, tc=DARK, lw=1.6):
    """DFD data store: open-ended rectangle with label inside."""
    line(ax, x, y, x + w, y, color=ec, lw=lw)
    line(ax, x, y + 4, x + w, y + 4, color=ec, lw=lw)
    line(ax, x + w, y + 4, x + w, y, color=ec, lw=lw)
    ax.text(x + w / 2.0, y + 2.0, label, ha='center', va='center', fontsize=fs, color=tc, zorder=4)


def dashed_zone(ax, x, y, w, h, label='', lc=GRAY, fs=8.5, fc='none', lw=1.2):
    patch = Rectangle((x, y), w, h, fc=fc, ec=lc, lw=lw, linestyle=(0, (4, 3)), zorder=1)
    ax.add_patch(patch)
    if label:
        ax.text(x + 1, y + h - 1.5, label, ha='left', va='center', fontsize=fs, color=lc, fontweight='bold', zorder=2)


def text(ax, x, y, s, fs=9, color=DARK, bold=False, ha='center', va='center', zorder=6, style='normal'):
    ax.text(x, y, s, ha=ha, va=va, fontsize=fs, color=color,
            fontweight='bold' if bold else 'normal', fontstyle=style, zorder=zorder)
