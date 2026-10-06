"""Chapter Four: Project Management."""
import os
import dwb
from dwb import H, P, RICH, B, NL, TBL, img, ref_para


def _f(name):
    return os.path.join(dwb.DIAGRAM_DIR, name)


def build():
    H('CHAPTER FOUR', 1)
    H('PROJECT MANAGEMENT', 2)

    H('4.1 Introduction', 2)
    P('This chapter presents the management plan for the Smart Child Daily Activity Tracking System '
      'project. It defines the development methodology, the work breakdown structure, the project '
      'schedule with a Gantt chart and milestones, the required hardware and software resources, the '
      'estimated budget, the risk analysis with a risk matrix, and the quality, communication and '
      'testing plans. The chapter ends with the requirement traceability matrix that links every '
      'functional requirement to its design and test coverage.')

    H('4.2 Development Methodology', 2)
    P('The project follows a modified Waterfall methodology with an iterative design loop. Because the '
      'deliverable of this phase is a complete Software Analysis and Design document, a sequential '
      'lifecycle is appropriate: requirements are fully analysed and frozen in the analysis phase '
      'before design proceeds. However, the design phase uses short iterative cycles \u2014 modelling, '
      'review, and refinement \u2014 so that the diagrams, database schema and wireframes are validated '
      'against the requirements before implementation begins. This hybrid approach gives the '
      'documentation rigour of Waterfall with the responsiveness of iteration. The phases are:')
    NL([
        'Phase 1 \u2013 Initiation and planning (requirements capture, feasibility, project charter).',
        'Phase 2 \u2013 System analysis (current system, requirements, use cases, DFDs).',
        'Phase 3 \u2013 System design (ER model, database, classes, architecture, wireframes).',
        'Phase 4 \u2013 Implementation (Flutter client, Laravel API, MySQL schema, integration).',
        'Phase 5 \u2013 Testing and user acceptance (unit, integration, system, UAT).',
        'Phase 6 \u2013 Documentation, deployment and submission.',
    ])

    H('4.3 Work Breakdown Structure (WBS)', 2)
    P('The project is decomposed into manageable work packages in the Work Breakdown Structure below. '
      'Each package is used for scheduling, resourcing and budgeting.')
    TBL(
        ['WBS ID', 'Work Package', 'Deliverable', 'Responsible'],
        [
            ['1.0', 'Project Management', 'Project charter, schedule, budget, risk register', 'Project Lead'],
            ['1.1', 'Initiation & Planning', 'Feasibility and plan approved', 'Project Lead'],
            ['2.0', 'System Analysis', 'Requirements specification', 'Systems Analyst'],
            ['2.1', 'Requirements Elicitation', 'Questionnaire & interview results', 'Systems Analyst'],
            ['2.2', 'Requirement Specification', 'Functional & non-functional requirements', 'Systems Analyst'],
            ['3.0', 'System Design', 'Design models', 'Software Architect'],
            ['3.1', 'SAD Documentation', 'Chapters 1\u20135 of the SAD document', 'Project Team'],
            ['3.2', 'Database Design', 'ER model, schema, data dictionary', 'Database Engineer'],
            ['3.3', 'Architecture Design', 'Architecture & deployment diagrams', 'Software Architect'],
            ['3.4', 'UI/UX Wireframes', 'All screen wireframes', 'UI/UX Designer'],
            ['4.0', 'Implementation', 'Working system', 'Developers'],
            ['4.1', 'Database Implementation', 'MySQL schema and seeders', 'Database Engineer'],
            ['4.2', 'Backend API (Laravel)', 'REST API endpoints and services', 'Backend Developer'],
            ['4.3', 'Frontend (Flutter)', 'Parent and child screens', 'Frontend Developer'],
            ['4.4', 'Integration & Offline Mode', 'Connected, offline-capable client', 'Integration Developer'],
            ['5.0', 'Testing', 'Test evidence', 'QA Tester'],
            ['5.1', 'Unit & Integration Testing', 'Passed test reports', 'QA Tester'],
            ['5.2', 'System Testing & UAT', 'User acceptance sign-off', 'QA Tester + Users'],
            ['6.0', 'Documentation & Deployment', 'Final deliverables', 'Technical Writer'],
            ['6.1', 'Final Report', 'Final project report', 'Technical Writer'],
            ['6.2', 'Deployment & Submission', 'Installed system and submitted report', 'Project Team'],
        ],
        col_widths=[1.0, 2.2, 2.1, 1.4],
        caption='Work Breakdown Structure',
    )

    H('4.4 Project Schedule', 2)
    H('4.4.1 Gantt Chart', 3)
    P('The project runs from 03 August 2026 to 31 August 2026. The Gantt chart below shows the eleven '
      'main tasks, their start and end dates, and the five project milestones. Weekend days are shaded, '
      'so the chart reflects actual working days.')
    img(_f('f20_gantt_chart.png'), 6.3, 'Gantt Chart \u2013 Project Schedule (03\u201331 August 2026)', 'gantt')

    H('4.4.2 Timeline', 3)
    TBL(
        ['Task', 'Start', 'End', 'Working Days'],
        [
            ['Project Initiation & Planning', '03 Aug 2026', '05 Aug 2026', '3'],
            ['Requirements Analysis', '05 Aug 2026', '08 Aug 2026', '4'],
            ['Software Analysis & Design (SAD)', '08 Aug 2026', '13 Aug 2026', '4'],
            ['Database Design', '12 Aug 2026', '15 Aug 2026', '4'],
            ['API & Architecture Design', '13 Aug 2026', '16 Aug 2026', '4'],
            ['Frontend Development (Flutter)', '15 Aug 2026', '22 Aug 2026', '6'],
            ['Backend Development (Laravel)', '15 Aug 2026', '22 Aug 2026', '6'],
            ['Integration & Offline Verification', '22 Aug 2026', '25 Aug 2026', '3'],
            ['System Testing & User Acceptance', '24 Aug 2026', '27 Aug 2026', '4'],
            ['Final Documentation & Report', '24 Aug 2026', '29 Aug 2026', '6'],
            ['Deployment, Review & Submission', '28 Aug 2026', '31 Aug 2026', '4'],
        ],
        col_widths=[3.2, 1.2, 1.2, 1.2],
        caption='Project Timeline',
    )

    H('4.4.3 Milestones', 3)
    TBL(
        ['Milestone', 'Date', 'Deliverable / Sign-off'],
        [
            ['M1 \u2013 Requirements Approved', '08 Aug 2026', 'Approved requirements specification'],
            ['M2 \u2013 Design Approved', '14 Aug 2026', 'Completed SAD document and diagrams'],
            ['M3 \u2013 Development Complete', '22 Aug 2026', 'Working Flutter client and Laravel API'],
            ['M4 \u2013 Testing Complete', '27 Aug 2026', 'Test reports and UAT sign-off'],
            ['M5 \u2013 Final Submission', '31 Aug 2026', 'Submitted report and deployed system'],
        ],
        col_widths=[2.7, 1.4, 3.0],
        caption='Project Milestones',
    )

    H('4.5 Resource Planning', 2)
    H('4.5.1 Hardware Requirements', 3)
    TBL(
        ['Resource', 'Specification', 'Quantity', 'Purpose'],
        [
            ['Laptop / Development PC', 'Core i5, 8 GB RAM, 256 GB SSD, Windows 11', '1', 'Development and local server'],
            ['Shared Family Tablet', '10-inch Android/iOS tablet, Wi-Fi', '1', 'Family dashboard device'],
            ['Wi-Fi Router', 'Home wireless router', '1', 'Offline local network'],
            ['External Storage', 'USB drive / external HDD', '1', 'Backup of database and report'],
            ['Printer', 'Inkjet / laser printer', '1', 'Printing documentation and reports'],
        ],
        col_widths=[1.9, 2.6, 0.8, 2.1],
        caption='Hardware Requirements',
    )

    H('4.5.2 Software Requirements', 3)
    TBL(
        ['Software', 'Version', 'Purpose'],
        [
            ['Flutter SDK', '3.x', 'Cross-platform front-end development'],
            ['Dart', '3.x', 'Front-end programming language'],
            ['PHP', '8.2+', 'Back-end programming language'],
            ['Laravel', '11.x', 'Back-end REST API framework'],
            ['MySQL', '8.x', 'Relational database'],
            ['Apache / PHP built-in server', '2.4 / 8.2', 'Local web server'],
            ['Composer', '2.x', 'PHP dependency manager'],
            ['Android Studio / VS Code', 'Latest', 'IDE for Flutter development'],
            ['Git', '2.x', 'Version control'],
            ['Microsoft Word', 'Latest', 'Documentation and final report'],
        ],
        col_widths=[2.4, 1.1, 3.4],
        caption='Software Requirements',
    )

    H('4.5.3 Human Resources', 3)
    P('The project is executed by a small team. The principal roles are the project lead (also the '
      'software architect), the systems analyst (also the database engineer), and the developer (who '
      'covers both Flutter and Laravel). The technical writer produces the documentation. In a typical '
      'final-year project setting, one to three students fill these roles under the supervision of an '
      'academic supervisor.')

    H('4.6 Budget Estimation', 2)
    P('The budget estimates the cost of the four-week project. All tools and platforms used are open '
      'source, so there is no software licence cost. Amounts are estimates in US dollars and can be '
      'converted to the local currency at planning time. A 10% contingency covers unforeseen expenses.')
    TBL(
        ['Item', 'Estimated Cost (USD)', 'Basis of Estimate'],
        [
            ['Laptop (depreciation share)', '75.00', 'One month usage share of a USD 900 laptop'],
            ['Electricity', '40.00', 'Powering development PC, tablet and router'],
            ['Internet', '30.00', 'Setup and downloads (runtime is offline)'],
            ['Software', '0.00', 'Open-source tools (Flutter, Laravel, MySQL)'],
            ['Transportation', '50.00', 'Site visits, meetings, submission trips'],
            ['Printing', '25.00', 'Printing drafts and figures'],
            ['Binding', '15.00', 'Binding of final reports'],
            ['Stationery', '20.00', 'Paper, pens, folders'],
            ['Sub-total', '255.00', '\u2013'],
            ['Contingency (10%)', '25.50', 'Unforeseen expenses'],
            ['Total', '280.50', 'Overall project budget'],
        ],
        col_widths=[2.6, 1.5, 3.0],
        caption='Budget Estimation and Cost Breakdown',
    )

    H('4.7 Risk Analysis', 2)
    H('4.7.1 Risk Identification', 3)
    P('The risks below were identified through team brainstorming and analysis of the project plan. '
      'Likelihood and impact are rated Low, Medium or High; the overall rating combines the two.')
    TBL(
        ['ID', 'Risk', 'Likelihood', 'Impact', 'Rating', 'Mitigation Strategy'],
        [
            ['R1', 'Hardware failure of the development laptop', 'Low', 'High', 'Medium', 'Back up daily; use university PCs as fallback.'],
            ['R2', 'Scope creep during design', 'Medium', 'Medium', 'Medium', 'Frozen requirements after sign-off (M1); change control.'],
            ['R3', 'Data loss during development', 'Medium', 'High', 'High', 'Daily Git commits and database dumps.'],
            ['R4', 'Schedule slippage', 'Medium', 'Medium', 'Medium', 'Weekly progress reviews; buffer of 2 days before submission.'],
            ['R5', 'Flutter\u2013Laravel integration issues', 'Medium', 'Medium', 'Medium', 'Contract-first API; integration testing from week 2.'],
            ['R6', 'Child user acceptance is low', 'Low', 'Medium', 'Low', 'Involve a child in early wireframe testing.'],
            ['R7', 'Power outages', 'Medium', 'Low', 'Low', 'Work during stable power hours; UPS for the server.'],
            ['R8', 'API design changes late in the cycle', 'Low', 'High', 'Medium', 'API specification frozen at M2.'],
        ],
        col_widths=[0.8, 2.2, 1.0, 0.9, 0.9, 2.4],
        caption='Risk Identification and Analysis',
    )

    H('4.7.2 Risk Matrix', 3)
    P('The risk matrix below maps the combined likelihood and impact of each risk onto a three-level '
      'rating. Risks rated High (R3) receive the most attention in the quality and testing plans.')
    TBL(
        ['Impact \\ Likelihood', 'Low', 'Medium', 'High'],
        [
            ['High', 'Medium \u2013 monitor closely', 'High \u2013 R3, R8', 'High \u2013 immediate action'],
            ['Medium', 'Low', 'Medium \u2013 R1, R4, R5', 'High \u2013 R3'],
            ['Low', 'Low \u2013 R6, R7', 'Low', 'Medium'],
        ],
        col_widths=[2.0, 1.7, 1.8, 1.8],
        caption='Risk Matrix (Likelihood \u00d7 Impact)',
    )

    H('4.8 Quality Plan', 2)
    B([
        ('Requirements traceability: ', 'every functional requirement is traced to design artefacts and tests (see Section 4.11).'),
        ('Documentation standards: ', 'all documents follow the same template, numbering and referencing (APA 7th edition).'),
        ('Peer reviews: ', 'each design artefact is reviewed by at least one other team member before sign-off.'),
        ('Code conventions: ', 'Flutter and Laravel code follow the official style guides; no commented-out dead code.'),
        ('Data integrity: ', 'database constraints enforce referential integrity; the coin ledger must reconcile with balances.'),
        ('Acceptance criteria: ', 'each test case has explicit pass/fail criteria defined before execution.'),
    ])

    H('4.9 Communication Plan', 2)
    TBL(
        ['Stakeholder', 'Communication', 'Frequency', 'Channel', 'Responsibility'],
        [
            ['Project Team', 'Daily stand-up meeting', 'Daily', 'Face-to-face / messaging', 'Project Lead'],
            ['Project Team', 'Progress and issues review', 'Weekly', 'Meeting + minutes', 'Project Lead'],
            ['Supervisor', 'Progress report and feedback', 'Weekly', 'Meeting / email', 'Project Lead'],
            ['Supervisor', 'Design and report review', 'At M2 and M5', 'Submission + meeting', 'Technical Writer'],
            ['Test Users (family)', 'Usability and UAT sessions', 'At M4', 'Tablet demo session', 'Developer'],
            ['University', 'Final submission', '31 Aug 2026', 'Formal submission', 'Project Lead'],
        ],
        col_widths=[1.6, 2.0, 1.1, 1.7, 1.3],
        caption='Communication Plan',
    )

    H('4.10 Testing Plan', 2)
    H('4.10.1 Testing Strategy', 3)
    P('Testing follows four levels: unit, integration, system and user acceptance. Unit tests verify '
      'individual services; integration tests verify the API against the database; system tests verify '
      'complete flows through the Flutter client; and user acceptance tests verify the system against '
      'the business rules with the real users.')
    TBL(
        ['Level', 'Scope', 'Approach', 'Pass Criteria'],
        [
            ['Unit Testing', 'Services, validation rules, coin logic', 'Automated tests for each service method', '100% of core coin and approval tests pass'],
            ['Integration Testing', 'Laravel API + MySQL', 'API calls against a test database', 'All CRUD and workflow endpoints return expected results'],
            ['System Testing', 'Full client\u2013server flows', 'Manual end-to-end scenarios on the tablet', 'All scenarios complete without defects'],
            ['User Acceptance', 'Real family usage', 'Family uses the tablet for one week', 'Tasks, coins, approvals and reports work as specified'],
        ],
        col_widths=[1.5, 2.1, 2.1, 2.1],
        caption='Testing Strategy',
    )

    H('4.10.2 Sample Test Cases', 3)
    TBL(
        ['TC ID', 'Test Case', 'Steps', 'Expected Result'],
        [
            ['TC-01', 'Parent secure login', 'Enter username, password and PIN.', 'Parent dashboard opens; invalid credentials rejected.'],
            ['TC-02', 'Complete self-check task', 'Child selects a task and presses Complete.', 'Coins credited immediately; task verified (FR-10).'],
            ['TC-03', 'Approve pending task', 'Child submits; parent approves.', 'Temporary coins finalised; task verified (FR-12).'],
            ['TC-04', 'Reject pending task', 'Parent rejects and selects a reason.', 'Temporary coins removed; ledger deduction recorded (FR-13).'],
            ['TC-05', 'Redeem reward', 'Child requests a reward; parent approves.', 'Coins deducted; reward granted (FR-19).'],
            ['TC-06', 'Generate weekly report', 'Parent opens Reports, selects weekly.', 'Stats and top child shown for the period (FR-23).'],
        ],
        col_widths=[1.0, 1.9, 2.1, 2.2],
        caption='Sample Test Cases',
    )

    H('4.11 Requirement Traceability Matrix', 2)
    P('The traceability matrix links each functional requirement to the design artefact and test case '
      'that cover it, confirming that nothing specified in the analysis is lost during implementation.')
    TBL(
        ['Requirement', 'Design Artefact', 'Test Case'],
        [
            ['FR-01, FR-02', 'Use Case UC-01, Login wireframe, parents table', 'TC-01'],
            ['FR-03, FR-04, FR-28', 'UC-02, children table, Child dashboard wireframe', 'TC-01, TC-02'],
            ['FR-05 \u2013 FR-08', 'UC-03, tasks table, DFD Level 1 (P3.0)', 'TC-02'],
            ['FR-09 \u2013 FR-14', 'UC-04, UC-05, DFD Level 2, approval workflow, state diagram', 'TC-02, TC-03, TC-04'],
            ['FR-15, FR-16', 'Coin workflow, coin_transactions table', 'TC-04'],
            ['FR-17 \u2013 FR-19', 'UC-06, rewards & redemptions tables, reward workflow', 'TC-05'],
            ['FR-20, FR-21', 'UC-08, badges & badge_awards tables', 'TC-05'],
            ['FR-22 \u2013 FR-24', 'UC-07, ReportService, Reports wireframe', 'TC-06'],
            ['FR-25, FR-26', 'messages & notifications tables, DFD Level 1 (P8.0)', 'TC-06'],
            ['FR-27', 'settings table, Settings wireframe', 'TC-01'],
        ],
        col_widths=[1.7, 2.7, 1.3],
        caption='Requirement Traceability Matrix',
    )

    H('4.12 Summary', 2)
    P('This chapter established the project management framework for the system. A modified Waterfall '
      'methodology, a detailed WBS, a four-week schedule with milestones, hardware and software '
      'resources, a USD 280.50 budget, a risk register with a risk matrix, and quality, communication '
      'and testing plans were all defined. The requirement traceability matrix confirms that the design '
      'in Chapter Three completely covers the functional requirements. The next chapter presents the '
      'implementation plan and conclusion.')
