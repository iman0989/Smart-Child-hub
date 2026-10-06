"""Instantiate variable Google Fonts at static weights for rendering and delivery."""
import os
import shutil
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

SRC = r'C:\Users\hp\AppData\Local\Temp\opencode\fonts'
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'fonts')
os.makedirs(DST, exist_ok=True)

PLAN = {
    'Quicksand.ttf': [400, 500, 600, 700],
    'Nunito.ttf': [400, 500, 600, 700, 800],
    'Baloo2.ttf': [400, 500, 600, 700, 800],
}
NAMES = {'Quicksand.ttf': 'Quicksand', 'Nunito.ttf': 'Nunito', 'Baloo2.ttf': 'Baloo 2'}

for src, weights in PLAN.items():
    path = os.path.join(SRC, src)
    font = TTFont(path)
    family = NAMES[src]
    for w in weights:
        f = instantiateVariableFont(font, {'wght': w}, inplace=False)
        out = os.path.join(DST, f'{family}-{w}.ttf'.replace(' ', '_'))
        f.save(out)
        print('wrote', out)

shutil.copy(os.path.join(SRC, 'Quicksand.ttf'), os.path.join(DST, 'Quicksand-Variable.ttf'))
shutil.copy(os.path.join(SRC, 'Nunito.ttf'), os.path.join(DST, 'Nunito-Variable.ttf'))
shutil.copy(os.path.join(SRC, 'Baloo2.ttf'), os.path.join(DST, 'Baloo2-Variable.ttf'))
print('done ->', DST)
