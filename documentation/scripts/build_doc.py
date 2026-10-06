"""Builds the complete professional SAD .docx document."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from docx.enum.section import WD_SECTION_START
import dwb
from dwb import H, P, TBL, add_toc, add_lot, add_lof, page_break, spacer
import front
import ch1
import ch2
import ch3
import ch4
import back

DIAG = os.path.normpath(os.path.join(HERE, '..', 'diagrams'))
OUT = os.path.normpath(os.path.join(HERE, '..', 'output',
                                    'SAD_Smart_Child_Daily_Activity_Tracking_System.docx'))


def main():
    dwb.setup(DIAG)
    dwb.set_update_fields()

    # --------------------------------------------------------- Section 1: front matter
    sec1 = dwb.doc.sections[0]
    sec1.different_first_page_header_footer = True
    dwb.footer_pagenum(sec1, fmt='lowerRoman', start=1)

    front.build_cover()
    page_break()
    front.build_declaration()
    page_break()
    front.build_approval()
    page_break()
    front.build_abstract()
    page_break()
    front.build_acknowledgements()
    page_break()
    add_toc('TABLE OF CONTENTS')
    page_break()
    add_lot('LIST OF TABLES')
    page_break()
    add_lof('LIST OF FIGURES')

    # --------------------------------------------------------- Section 2: main content
    sec2 = dwb.doc.add_section(WD_SECTION_START.NEW_PAGE)
    dwb.footer_pagenum(sec2, fmt='decimal', start=1)
    dwb.header_text(sec2, 'Smart Child Daily Activity Tracking System \u2013 SAD Documentation')

    ch1.build()
    ch2.build()
    ch3.build()
    ch4.build()
    back.build_ch5()

    # --------------------------------------------------------- Section 3: references & appendices
    sec3 = dwb.doc.add_section(WD_SECTION_START.NEW_PAGE)
    dwb.footer_pagenum(sec3, fmt='decimal')
    dwb.header_text(sec3, 'Smart Child Daily Activity Tracking System \u2013 SAD Documentation')

    back.build_refs()
    back.build_appendix_a()
    back.build_appendix_b()
    back.build_appendix_c()
    back.build_appendix_d()

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    dwb.doc.save(OUT)
    print('Saved document:', OUT)
    print('Total figures:', dwb.FIG)
    print('Total tables :', dwb.TAB)


if __name__ == '__main__':
    main()
