"""Entry point to generate all diagrams."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

OUT = os.path.abspath(os.path.join(HERE, '..', 'diagrams'))
os.makedirs(OUT, exist_ok=True)

import diagrams_analysis
import diagrams_misc

if __name__ == '__main__':
    diagrams_analysis.run(OUT)
    diagrams_misc.run(OUT)
    print('All diagrams generated in', OUT)
