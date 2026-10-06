"""Shared PDF page builder for the design-system style guides."""
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

import ui_lib as U
import tokens as T

HL = U.HLAND  # 75 landscape height
W = U.W


class Doc:
    def __init__(self, path, guide_name, version='1.0.0'):
        self.path = path
        self.guide = guide_name
        self.version = version
        self.pdf = PdfPages(path)
        self.pg = 0

    def _fig(self, gradient=None, bg='#FFFFFF'):
        fig = plt.figure(figsize=(10, 7.5), dpi=150)
        fig.patch.set_facecolor(bg)
        ax = fig.add_axes([0, 0, 1, 1])
        ax.set_xlim(0, W); ax.set_ylim(0, HL)
        ax.set_aspect('equal'); ax.axis('off')
        if gradient:
            U.gradient_rect(ax, 0, 0, W, HL, 0, gradient[0], gradient[1], zorder=0)
        else:
            U.rr(ax, 0, 0, W, HL, 0, fc=bg, zorder=0)
        return fig, ax

    def _footer(self, ax, fg='#B9BAC6'):
        U.text(ax, 6, 2.0, 'Smart Child Hub \u00b7 Design System \u00b7 ' + self.guide,
               'Nunito', 7, 600, fg, zorder=6)
        U.text(ax, 94, 2.0, 'v' + self.version + ' \u00b7 ' + str(self.pg).zfill(2),
               'Nunito', 7, 600, fg, ha='right', va='top', zorder=6)

    def cover(self, title, subtitle, chapters):
        self.pg += 1
        fig, ax = self._fig(gradient=('#4F6BF5', '#7A5BF5'))
        U.blob(ax, 10, 70, 24, 16, '#FFFFFF', 0.07, rot=30, zorder=0.5)
        U.blob(ax, 92, 8, 24, 18, '#FFC93C', 0.10, rot=15, zorder=0.5)
        U.draw_icon(ax, 'sparkle', 78, 60, 8, '#FFC93C', zorder=2)
        U.draw_icon(ax, 'sparkle', 16, 14, 6, '#FFFFFF', zorder=2)
        U.logo(ax, 50, 56, 12)
        U.text(ax, 50, 34, title, 'Baloo 2', 30, 800, '#FFFFFF', ha='center', va='center', zorder=5)
        U.text(ax, 50, 28.5, subtitle, 'Nunito', 11, 600, '#DDE5FF', ha='center', va='center', zorder=5)
        for i, ln in enumerate(chapters):
            U.pill(ax, 50, 22 - i * 4.0, 46, 3.4, ln, bg=U.hx('#FFFFFF', 0.14), fg='#FFFFFF',
                   size=8.5, weight=600, zorder=5)
        U.text(ax, 50, 6, 'Smart Child Daily Activity Tracking System \u00b7 Version ' + self.version,
               'Nunito', 7.5, 600, '#D6DCFE', ha='center', va='center', zorder=5)
        fig.savefig(self.pdf, format='pdf'); plt.close(fig)

    def chapter(self, number, title, sub):
        self.pg += 1
        fig, ax = self._fig(gradient=('#4F6BF5', '#7A5BF5'))
        U.text(ax, 8, 40, str(number).zfill(2), 'Baloo 2', 90, 800, U.hx('#FFFFFF', 0.18),
               ha='left', va='center', zorder=4)
        U.text(ax, 8, 44, title, 'Baloo 2', 26, 800, '#FFFFFF', zorder=5)
        U.text(ax, 8, 39.4, sub, 'Nunito', 11, 600, '#DDE5FF', zorder=5)
        U.draw_icon(ax, 'sparkle', 88, 44, 8, '#FFC93C', zorder=5)
        fig.savefig(self.pdf, format='pdf'); plt.close(fig)

    def page(self, title, sub=None, content=None):
        self.pg += 1
        fig, ax = self._fig(bg='#F7F8FE')
        U.blob(ax, 4, 73, 12, 7, '#DDE5FF', 0.5, rot=8, zorder=0.5)
        U.blob(ax, 96, 72, 10, 7, '#FFE0C7', 0.4, rot=-12, zorder=0.5)
        U.rr(ax, 0, 69.4, W, 5.6, 0, fc='#FFFFFF', ec='#E9EAF6', lw=1, zorder=1)
        U.text(ax, 6, 72.6, title, 'Nunito', 15, 800, '#0E1E5C', zorder=5)
        if sub:
            U.text(ax, 6, 70.0, sub, 'Nunito', 8.5, 600, '#767685', zorder=5)
        self._footer(ax)
        return fig, ax

    def close(self):
        self.pdf.close()
        print('wrote', self.path)


# ---------------------------------------------------------------- helpers
def block(ax, x, y, w, text, title=None, size=9, family='Nunito', weight=600,
          color='#43434F', tcolor='#191A24'):
    if title:
        U.text(ax, x, y, title, family, size + 2.5, 800, tcolor, zorder=5)
        y -= size + 5.0
    lines = U.wrap(ax, text, family, size, weight, w)
    for ln in lines:
        U.text(ax, x, y, ln, family, size, weight, color, zorder=5)
        y -= size + 3.2

def card(ax, x, y, w, h, title=None):
    U.card(ax, x, y, w, h, r=14, fc='#FFFFFF', level=1, zorder=3)
    if title:
        U.text(ax, x + 2.4, y + h - 2.2, title, 'Nunito', 9.5, 800, '#191A24', zorder=5)

def swatch(ax, x, y, w, h, color, name=None, hexv=None, r=8, zorder=4):
    U.rr(ax, x, y, w, h, r, fc=color, ec='#FFFFFF', lw=1, zorder=zorder)
    if name:
        U.text(ax, x + 1.6, y + h - 1.8, name, 'Nunito', 7.5, 800, '#FFFFFF', zorder=zorder + 1)
        U.text(ax, x + 1.6, y + 1.6, hexv or color, 'Nunito', 6.5, 600, U.hx('#FFFFFF', 0.9), zorder=zorder + 1)

def ruler(ax, y, color='#E9EAF6'):
    U.divider(ax, 6, y, 88, color, lw=1.2, zorder=3)

def tag(ax, x, y, label, bg='#EEF0F8', fg='#43434F'):
    U.pill(ax, x, y, 0, 4.6, label, bg=bg, fg=fg, size=7.5, weight=700, zorder=5)
