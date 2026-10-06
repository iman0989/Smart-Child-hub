"""Chapter Five, References and Appendices."""
from docx.shared import Pt, Cm
from dwb import H, P, RICH, B, NL, TBL


def build_ch5():
    H('CHAPTER FIVE', 1)
    H('IMPLEMENTATION PLAN AND CONCLUSION', 2)

    H('5.1 Introduction', 2)
    P('This chapter presents the plan that will carry the design of Chapter Three into a working '
      'system. It covers the implementation strategy, the testing strategy, deployment, maintenance, '
      'future improvements and the expected results of the system, and closes with the conclusion of '
      'the study.')

    H('5.2 Implementation Strategy', 2)
    P('Implementation will proceed in four parallel-track increments, guided by the frozen '
      'requirements and the traceability matrix of Chapter Four:')
    B([
        ('Database first: ', 'the MySQL schema is created from the data dictionary in Section 3.10.2, including all primary keys, foreign keys, unique constraints and seed data for default rewards and badges.'),
        ('Back-end first: ', 'the Laravel REST API is implemented next, exposing the documented endpoints (auth, children, tasks, assignments, verification, coins, rewards, badges, reports, messages, notifications, settings), each validated against the business rules.'),
        ('Front-end second: ', 'the Flutter client implements the parent and child screens from the wireframes in Section 3.15, consuming the API over the local network.'),
        ('Integration and offline verification: ', 'the client and server are connected, and every workflow (self-check, approval, redemption, reporting) is exercised end-to-end to confirm that the system runs entirely offline on the home network.'),
    ])
    P('Code will follow the conventions defined in the quality plan, and every major unit will be '
      'committed to a local Git repository daily.')

    H('5.3 Testing Strategy', 2)
    P('Testing will follow the four levels defined in Section 4.10. Unit tests will cover the coin '
      'and approval services; integration tests will verify every API endpoint against a test '
      'database; system tests will walk complete scenarios on the tablet; and a one-week user '
      'acceptance run with a real family will confirm that tasks, coins, approvals, rewards and '
      'reports behave as specified. Defects found will be logged, triaged and fixed before the '
      'acceptance sign-off at milestone M4.')

    H('5.4 Deployment Plan', 2)
    P('Deployment targets the home local network described in Section 3.14. The steps are:')
    NL([
        'install MySQL 8 and create the production database and user on the home server;',
        'install PHP 8.2 and Laravel 11, configure the environment file, and migrate the schema;',
        'start the Laravel API so it listens on the LAN address;',
        'install the Flutter application on the shared tablet;',
        'configure the tablet to connect to the API over Wi-Fi; and',
        'verify offline behaviour by disconnecting the internet and confirming full functionality.',
    ])

    H('5.5 Maintenance Plan', 2)
    P('After deployment, the parent will back up the database weekly to removable storage using the '
      'backup function in the settings screen. The developer will document a simple maintenance '
      'runbook covering database backup and restore, API restart and log inspection. Minor fixes and '
      'configuration changes (new tasks, rewards and badges) are handled by the parent through the '
      'administration screens without developer involvement.')

    H('5.6 Future Improvements', 2)
    B([
        'Remote access for parents through an authenticated web portal.',
        'Voice reminders and a child-friendly text-to-speech assistant on the tablet.',
        'Multi-device support so siblings can use the system on a second tablet.',
        'Export of reports to PDF and printable certificates for children.',
        'Predictive insights that identify declining completion rates early.',
        'Optional cloud sync with end-to-end encryption for parents who request it.',
    ])

    H('5.7 Expected Results', 2)
    P('On completion, the system is expected to:')
    NL([
        'allow children without smartphones to track daily activities on one shared offline tablet;',
        'award coins fairly through self-check and parent-approval verification with automatic reversal on rejection;',
        'motivate children through badges and a parent-controlled reward shop;',
        'provide parents with complete daily, weekly, monthly and yearly reports including completion rate and top-child ranking; and',
        'operate fully offline on the home network with the database remaining entirely in the household.',
    ])

    H('5.8 Conclusion', 2)
    P('This study analysed and designed the Smart Child Daily Activity Tracking System, an offline '
      'family dashboard that places the parent in full control while motivating children through '
      'coins, badges and rewards. The analysis captured complete functional and non-functional '
      'requirements and business rules; the design produced use cases, DFDs, an ER model and a full '
      'MySQL schema, UML diagrams, navigation, architecture and deployment views, and wireframes for '
      'every screen. A complete project management plan \u2014 schedule, budget, risk, quality, '
      'communication and testing \u2014 supports delivery within the four-week period. The document '
      'therefore provides a complete, university-ready software analysis and design deliverable that '
      'can be implemented directly by developers.')


def build_refs():
    H('REFERENCES', 1)
    P('References are formatted according to the APA 7th edition style, ordered alphabetically.',
      align='justify', italic=True)
    refs = [
        'ChoreMonster. (2026). ChoreMonster: Make chores fun. https://www.choremonster.com',
        'Dennis, A., Wixom, B. H., & Roth, R. M. (2019). Systems analysis and design (8th ed.). Wiley.',
        'Deterding, S., Dixon, D., Khaled, R., & Nacke, L. (2011). From game design elements to gamefulness: Defining \u201cgamification\u201d. In Proceedings of the 15th International Academic MindTrek Conference (pp. 9\u201315). ACM. https://doi.org/10.1145/2181037.2181040',
        'Elmasri, R., & Navathe, S. B. (2017). Fundamentals of database systems (7th ed.). Pearson.',
        'Fielding, R. T. (2000). Architectural styles and the design of network-based software architectures [Doctoral dissertation, University of California, Irvine].',
        'Flutter. (2026). Flutter documentation. https://docs.flutter.dev',
        'Fowler, M. (2004). UML distilled: A brief guide to the standard object modeling language (3rd ed.). Addison-Wesley.',
        'Habitica. (2026). Habitica: Your life, the role playing game. https://habitica.com',
        'Kazdin, A. E. (2013). Behavior modification in applied settings (7th ed.). Waveland Press.',
        'Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). How are habits formed: Modelling habit formation in the real world. European Journal of Social Psychology, 40(6), 998\u20131009. https://doi.org/10.1002/ejsp.674',
        'Laravel. (2026). Laravel documentation. https://laravel.com/docs',
        'Oracle. (2026). MySQL 8.0 reference manual. https://dev.mysql.com/doc/refman/8.0/en/',
        'OurHome. (2026). OurHome: The family organizer. https://www.ourhomeapp.com',
        'Pressman, R. S., & Maxim, B. R. (2020). Software engineering: A practitioner\u2019s approach (9th ed.). McGraw-Hill.',
        'Sommerville, I. (2016). Software engineering (10th ed.). Pearson.',
    ]
    for r in refs:
        p = P(r, align='left')
        p.paragraph_format.left_indent = Cm(1.27)
        p.paragraph_format.first_line_indent = Cm(-1.27)
        p.paragraph_format.space_after = Pt(8)


def build_appendix_a():
    H('APPENDIX A: QUESTIONNAIRE', 1)
    P('The questionnaire below was distributed to parents to elicit requirements for the Smart Child '
      'Daily Activity Tracking System. Twenty responses were collected during the analysis phase. '
      'Respondents indicated their agreement with each statement using a five-point Likert scale: '
      'SA = Strongly Agree, A = Agree, NS = Not Sure, D = Disagree, SD = Strongly Disagree.')
    TBL(
        ['No.', 'Statement', 'SA', 'A', 'NS', 'D', 'SD'],
        [
            ['1', 'My child does not own a personal smartphone.', '', '', '', '', ''],
            ['2', 'I prefer that my child uses technology only inside the home.', '', '', '', '', ''],
            ['3', 'A single shared tablet in the home would be convenient.', '', '', '', '', ''],
            ['4', 'Tracking my child\u2019s daily habits improves his or her responsibility.', '', '', '', '', ''],
            ['5', 'Coins and rewards motivate my child to complete tasks.', '', '', '', '', ''],
            ['6', 'I want to verify completed tasks before coins are kept.', '', '', '', '', ''],
            ['7', 'Some tasks (e.g., Friday prayer, weekend visits) repeat on specific days only.', '', '', '', '', ''],
            ['8', 'Badges encourage consistent effort.', '', '', '', '', ''],
            ['9', 'Daily, weekly, monthly and yearly reports are useful.', '', '', '', '', ''],
            ['10', 'Comparing children (top child) helps fairness.', '', '', '', '', ''],
            ['11', 'The system must work without internet access.', '', '', '', '', ''],
            ['12', 'Only the parent should manage tasks and rewards.', '', '', '', '', ''],
        ],
        col_widths=[0.8, 4.0, 0.6, 0.6, 0.6, 0.6, 0.6],
        caption='Parent Requirements Questionnaire',
    )


def build_appendix_b():
    H('APPENDIX B: INTERVIEW QUESTIONS', 1)
    P('Semi-structured interviews were conducted with three parents and one child-development '
      'specialist. The guiding questions were:')
    NL([
        'How do you currently track your children\u2019s daily activities and routines?',
        'What problems have you experienced with paper charts or existing applications?',
        'Which tasks should the system support, and on which days do they repeat?',
        'Should the child receive coins immediately, or only after your approval? Explain.',
        'What kinds of rewards and badges would motivate your child?',
        'What information should a weekly or monthly report contain?',
        'How important is it that the system works without internet access?',
        'Who should be able to add or remove coins, and why?',
        'What happens when a child misses a task?',
        'Which features would you rank as the most important for a shared home tablet?',
    ])


def build_appendix_c():
    H('APPENDIX C: GLOSSARY', 1)
    TBL(
        ['Term', 'Definition'],
        [
            ['Administrator', 'The parent account that controls the whole system.'],
            ['Assignment', 'A task instance created for one child on one date.'],
            ['Completion rate', 'Percentage of assigned tasks completed and verified in a period.'],
            ['Crow\u2019s-foot notation', 'ER notation where three small lines denote a \u201cmany\u201d relationship.'],
            ['DFD', 'Data Flow Diagram \u2014 a structured model of processes and data movement.'],
            ['ER model', 'Entity-Relationship model \u2014 a conceptual data model.'],
            ['Kiosk mode', 'The child interface that only requires profile selection.'],
            ['Ledger', 'The transaction record that backs every coin balance.'],
            ['REST API', 'Representational State Transfer \u2014 a stateless web service style.'],
            ['Seed data', 'Default records inserted at installation, e.g., example badges.'],
            ['UML', 'Unified Modeling Language \u2014 a standard modelling notation.'],
            ['Wireframe', 'A low-fidelity visual layout of a screen.'],
        ],
        col_widths=[2.2, 4.3],
        caption='Glossary of Terms',
    )


def build_appendix_d():
    H('APPENDIX D: ABBREVIATIONS AND ACRONYMS', 1)
    TBL(
        ['Abbreviation', 'Full Form'],
        [
            ['API', 'Application Programming Interface'],
            ['APA', 'American Psychological Association'],
            ['CRUD', 'Create, Read, Update, Delete'],
            ['DFD', 'Data Flow Diagram'],
            ['ER', 'Entity-Relationship'],
            ['FR', 'Functional Requirement'],
            ['HTTP', 'HyperText Transfer Protocol'],
            ['IDE', 'Integrated Development Environment'],
            ['LAN', 'Local Area Network'],
            ['NFR', 'Non-Functional Requirement'],
            ['ORM', 'Object-Relational Mapping'],
            ['PIN', 'Personal Identification Number'],
            ['QA', 'Quality Assurance'],
            ['REST', 'Representational State Transfer'],
            ['RTM', 'Requirement Traceability Matrix'],
            ['SAD', 'Software Analysis and Design'],
            ['UAT', 'User Acceptance Testing'],
            ['UC', 'Use Case'],
            ['UML', 'Unified Modeling Language'],
            ['WBS', 'Work Breakdown Structure'],
        ],
        col_widths=[2.0, 4.5],
        caption='Abbreviations and Acronyms',
    )
