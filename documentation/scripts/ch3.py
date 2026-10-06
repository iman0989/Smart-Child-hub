"""Chapter Three: System Analysis and Design."""
import os
import dwb
from dwb import (H, P, RICH, B, NL, TBL, img, ref_para, spacer)


def _f(name):
    return os.path.join(dwb.DIAGRAM_DIR, name)


def build():
    H('CHAPTER THREE', 1)
    H('SYSTEM ANALYSIS AND DESIGN', 2)

    H('3.1 Introduction', 2)
    P('This chapter presents the full analysis and design of the Smart Child Daily Activity Tracking '
      'System. It begins with an analysis of the current manual system and its problems, then defines '
      'the functional and non-functional requirements and business rules. The system is then modelled '
      'using structured and object-oriented techniques: actors and use cases, activity, sequence and '
      'state diagrams, workflows, context diagram, DFDs, ER model, database design, class diagram, '
      'navigation structure, system architecture and deployment model. The chapter closes with UI '
      'wireframes for every major screen.')

    # ---------------------------------------------------------- 3.2 current system
    H('3.2 Current System Analysis', 2)
    H('3.2.1 Overview of the Current (Manual) System', 3)
    P('In the target households, children\u2019s daily activities are currently managed manually. Parents '
      'create paper charts or simple lists that show expected tasks for each day. A typical chart might '
      'list morning routines such as brushing teeth, praying, making the bed, completing homework and '
      'playing outside, with boxes to tick for each day of the week. When a child completes a task, the '
      'parent or the child places a tick. At the end of the week the parent inspects the chart and may '
      'reward the child informally with treats, extra play time or money. Reminders are delivered '
      'verbally, and there is no record of the child\u2019s consistency over time.')

    H('3.2.2 Problems with the Current System', 3)
    TBL(
        ['#', 'Problem', 'Effect'],
        [
            ['P1', 'Paper charts are easily lost, torn or ignored.', 'No reliable long-term record.'],
            ['P2', 'Tracking is manual and time-consuming for parents.', 'Parents abandon tracking within weeks.'],
            ['P3', 'There is no consistent reward rule.', 'Children lose motivation and trust.'],
            ['P4', 'Verification is impossible on paper.', 'Children may tick tasks that were not done.'],
            ['P5', 'No statistics or completion rates exist.', 'Parents cannot measure improvement.'],
            ['P6', 'Schedules such as Friday-only or weekend-only are not handled.', 'Cultural routines are missed.'],
            ['P7', 'Comparison across children is difficult.', 'Fairness between siblings is unclear.'],
            ['P8', 'No reminders are possible.', 'Routines depend entirely on memory.'],
        ],
        col_widths=[0.8, 3.2, 2.3],
        caption='Problems of the Current Manual System',
    )

    H('3.3 Proposed System Requirements', 2)
    P('The proposed system was specified through requirement elicitation that included a review of '
      'existing applications, a structured questionnaire completed by parents, and interviews with '
      'parents and a child-development specialist (see Appendices A and B). The resulting requirements '
      'are grouped into functional requirements (FR), non-functional requirements (NFR) and business '
      'rules (BR).')

    # ---------------------------------------------------------- 3.4 FR
    H('3.4 Functional Requirements', 2)
    P('The functional requirements describe the behaviour the system must provide. Each requirement has '
      'a unique identifier used in the Requirement Traceability Matrix in Chapter Four.')
    TBL(
        ['ID', 'Requirement', 'Category'],
        [
            ['FR-01', 'The parent shall log in securely using a username/password and a four-digit PIN.', 'Authentication'],
            ['FR-02', 'Only the parent shall be able to access administrator functions.', 'Authentication'],
            ['FR-03', 'The parent shall add, edit and delete child profiles (name, avatar, date of birth).', 'Children'],
            ['FR-04', 'The child shall select his or her own profile from the shared tablet without a login.', 'Children'],
            ['FR-05', 'The parent shall create, edit, delete and deactivate tasks.', 'Tasks'],
            ['FR-06', 'Each task shall have a title, description, schedule type, repeat days and coin value.', 'Tasks'],
            ['FR-07', 'The system shall support daily, weekly, monthly, custom, weekend and specific-day schedules.', 'Scheduling'],
            ['FR-08', 'The system shall generate assignments (task instances) for each child on the relevant dates.', 'Scheduling'],
            ['FR-09', 'Each task shall be assigned either self-check or parent-approval verification.', 'Verification'],
            ['FR-10', 'Self-check completion shall award coins immediately and mark the task verified.', 'Verification'],
            ['FR-11', 'Parent-approval completion shall award temporary coins and mark the task \u201cpending verification\u201d.', 'Verification'],
            ['FR-12', 'The parent shall approve or reject pending tasks; rejection shall require a reason.', 'Verification'],
            ['FR-13', 'Rejection shall automatically remove the temporary coins and record a ledger deduction.', 'Verification'],
            ['FR-14', 'Uncompleted tasks past their due date shall be marked \u201cmissed\u201d.', 'Verification'],
            ['FR-15', 'The parent shall add bonus coins and remove coins for any child with a recorded reason.', 'Coins'],
            ['FR-16', 'Every coin credit and debit shall be recorded in a transaction ledger.', 'Coins'],
            ['FR-17', 'The parent shall create, edit and deactivate rewards with a coin cost.', 'Rewards'],
            ['FR-18', 'The child shall view available rewards and request redemption if coins are sufficient.', 'Rewards'],
            ['FR-19', 'Redemption requests shall require parent approval before coins are deducted.', 'Rewards'],
            ['FR-20', 'The parent shall create badges and assign them to children.', 'Badges'],
            ['FR-21', 'The child shall view earned badges on the dashboard.', 'Badges'],
            ['FR-22', 'The system shall generate daily, weekly, monthly and yearly reports.', 'Reports'],
            ['FR-23', 'Reports shall include completed, rejected, pending and missed tasks, coins, badges, completion rate and top child.', 'Reports'],
            ['FR-24', 'The parent shall view charts and analytics for any child and period.', 'Reports'],
            ['FR-25', 'The parent shall send messages that the child can read on the tablet.', 'Messages'],
            ['FR-26', 'The system shall record reminders and show notifications on the tablet.', 'Notifications'],
            ['FR-27', 'The parent shall configure settings including PIN, notification preferences and task defaults.', 'Settings'],
            ['FR-28', 'All child-facing screens shall use a child-friendly kiosk interface.', 'Children'],
        ],
        col_widths=[1.1, 4.4, 1.0],
        caption='Functional Requirements',
    )

    # ---------------------------------------------------------- 3.5 NFR
    H('3.5 Non-Functional Requirements', 2)
    TBL(
        ['ID', 'Category', 'Requirement'],
        [
            ['NFR-01', 'Offline Operation', 'The system shall operate entirely on the home local network with no internet dependency.'],
            ['NFR-02', 'Performance', 'Screens shall respond within two seconds on a typical home tablet and server.'],
            ['NFR-03', 'Usability', 'The child interface shall be usable by children aged 4\u201312 without text-heavy instructions.'],
            ['NFR-04', 'Security', 'Parent functions shall require authentication; child data shall never leave the home.'],
            ['NFR-05', 'Reliability', 'The system shall remain available while the home server and tablet are powered on.'],
            ['NFR-06', 'Data Integrity', 'Coin balances must always match the sum of ledger transactions.'],
            ['NFR-07', 'Maintainability', 'The modular architecture (presentation, API, services, data) shall allow independent changes.'],
            ['NFR-08', 'Portability', 'The Flutter client shall run on Android and iOS tablets.'],
            ['NFR-09', 'Scalability', 'The design shall comfortably support a family of up to eight children.'],
            ['NFR-10', 'Backup', 'The parent shall be able to back up the database to a local file.'],
            ['NFR-11', 'Compatibility', 'The API shall use standard REST/JSON over HTTP on the local network.'],
        ],
        col_widths=[1.1, 1.8, 3.6],
        caption='Non-Functional Requirements',
    )

    # ---------------------------------------------------------- 3.6 BR
    H('3.6 Business Rules', 2)
    TBL(
        ['ID', 'Business Rule'],
        [
            ['BR-01', 'A child cannot be deleted if the child has verified assignments; the parent must deactivate the child instead.'],
            ['BR-02', 'A task can only be created with a valid schedule type and a coin value greater than zero.'],
            ['BR-03', 'Self-check tasks are verified immediately and cannot be rejected later.'],
            ['BR-04', 'A parent-approval task can only be approved or rejected while its status is \u201cpending verification\u201d.'],
            ['BR-05', 'Rejection always requires a reason and always reverses the temporary coins.'],
            ['BR-06', 'A reward redemption is only possible if the child\u2019s current balance is at least the reward cost.'],
            ['BR-07', 'Coins can only be deducted through rejection reversal, parent removal or approved redemption.'],
            ['BR-08', 'A child earns each badge only once unless the parent explicitly awards it again.'],
            ['BR-09', 'A missed task cannot be completed after the due date unless the parent re-activates it.'],
            ['BR-10', 'Report periods are computed from local dates: daily (1 day), weekly (Mon\u2013Sun), monthly (1st\u2013last), yearly (Jan\u2013Dec).'],
        ],
        col_widths=[1.2, 5.3],
        caption='Business Rules',
    )

    # ---------------------------------------------------------- 3.7 actors
    H('3.7 Actors', 2)
    TBL(
        ['Actor', 'Role', 'Goals'],
        [
            ['Parent (Administrator)', 'Owns and administers the entire system; the only actor with write access to configuration.', 'Login securely; manage children, tasks, coins, rewards, badges; approve or reject tasks; review reports and settings.'],
            ['Child', 'Non-administrator end-user of the shared tablet; selects a profile and interacts with the kiosk interface.', 'View and complete tasks; earn coins; view badges, rewards and progress; read messages.'],
            ['System Clock', 'Internal actor that generates assignments and marks missed tasks automatically.', 'Create assignments on scheduled dates and mark overdue tasks missed.'],
        ],
        col_widths=[2.0, 2.5, 2.4],
        caption='Actors of the System',
    )

    # ---------------------------------------------------------- 3.8 use cases
    H('3.8 Use Case Modelling', 2)
    H('3.8.1 Use Case Diagram', 3)
    uc_fig = img(_f('f06_use_case.png'), 6.2, 'Use Case Diagram of the System', 'uc_diagram')
    ref_para('The use case diagram (Figure ', 'uc_diagram', uc_fig,
             ') shows the two human actors and the internal system-clock actor together with the main '
             'use cases of the system. The parent interacts with all administrative use cases, while '
             'the child interacts with the kiosk use cases. The dashed \u201cinclude\u201d relationship shows '
             'that coin-awarding behaviour is shared by the task-completion and approval use cases.')

    H('3.8.2 Use Case Descriptions', 3)
    P('The most important use cases are described in detail below. Each description identifies the '
      'actor, preconditions, trigger, main flow, alternate flow, post-conditions and priority.')

    def uc(ucid, name, actor, pre, trig, main, alt, post, prio):
        TBL(
            ['Field', 'Description'],
            [
                ['Use Case ID', ucid],
                ['Use Case Name', name],
                ['Actor(s)', actor],
                ['Preconditions', pre],
                ['Trigger', trig],
                ['Main Flow', main],
                ['Alternate Flow', alt],
                ['Post-conditions', post],
                ['Priority', prio],
            ],
            col_widths=[1.7, 4.8],
        )
        spacer()

    uc('UC-01', 'Secure Login (Parent)', 'Parent',
       'The tablet is running and the system clock is synchronised.',
       'The parent opens the application.',
       '1. System displays the login screen.\n2. Parent enters username and password.\n3. System validates credentials.\n4. Parent enters the four-digit PIN.\n5. System validates the PIN and opens the parent dashboard.',
       'A1: Invalid credentials \u2014 system shows an error and logs the failed attempt.\nA2: Forgotten PIN \u2014 parent resets the PIN using the security answer.',
       'Parent session starts; administrator functions are unlocked.',
       'High')

    uc('UC-02', 'Manage Children', 'Parent',
       'Parent is logged in.',
       'Parent selects the Children option from the menu.',
       '1. System lists existing children.\n2. Parent chooses Add, Edit or Delete.\n3. Parent enters name, avatar and date of birth.\n4. System saves the child profile.',
       'A1: Editing \u2014 updates are saved and logged.\nA2: Deleting a child with verified records \u2014 system blocks deletion and suggests deactivation (BR-01).',
       'Child profile is created, updated or deactivated.',
       'High')

    uc('UC-03', 'Create Task with Schedule', 'Parent',
       'Parent is logged in.',
       'Parent selects the Tasks option and presses Add Task.',
       '1. System shows the task form.\n2. Parent enters title and description.\n3. Parent selects schedule type (daily, weekly, monthly, custom, weekend, specific days).\n4. Parent sets repeat days and coin value.\n5. Parent selects verification type (self-check or parent approval).\n6. System saves the task.',
       'A1: Invalid schedule or zero coins \u2014 system rejects with a message (BR-02).',
       'Task is stored and assignments are generated for the relevant dates (FR-08).',
       'High')

    uc('UC-04', 'Complete Task (Self-Check)', 'Child',
       'The child has selected a profile and the task is available for today.',
       'The child presses the Complete button on a self-check task.',
       '1. System asks for confirmation.\n2. Child confirms.\n3. System credits coins immediately.\n4. System sets status to \u201cverified\u201d.\n5. System records a ledger transaction and updates the balance.',
       'A1: Task already completed \u2014 system prevents double completion (BR-04).',
       'Task verified; balance increased by the task coin value.',
       'High')

    uc('UC-05', 'Complete Task (Parent Approval) and Approve / Reject', 'Child, Parent',
       'The child has selected a profile; the task requires parent approval.',
       'The child submits the task for verification.',
       '1. Child submits the task.\n2. System credits temporary coins and sets status to \u201cpending verification\u201d.\n3. Parent reviews the task in the dashboard.\n4. Parent approves \u2014 system finalises coins and sets status to \u201cverified\u201d.\n5. Parent rejects \u2014 system selects a reason, removes the temporary coins and sets status to \u201crejected\u201d.',
       'A1: Rejection \u2014 coins are automatically deducted and recorded (FR-13).\nA2: No action \u2014 task remains pending until the parent acts.',
       'Task is either verified with final coins or rejected with a reason and reversed coins.',
       'High')

    uc('UC-06', 'Redeem Reward', 'Child, Parent',
       'The child has a profile and at least one active reward exists.',
       'The child selects a reward and presses Redeem.',
       '1. System checks the child\u2019s balance against the reward cost.\n2. If sufficient, system creates a redemption request with status \u201cpending\u201d.\n3. Parent approves the request.\n4. System deducts the coins, grants the reward and notifies the child.',
       'A1: Insufficient balance \u2014 system shows \u201cnot enough coins\u201d (BR-06).\nA2: Parent rejects \u2014 request is cancelled with no deduction.',
       'Redemption completed or cancelled; ledger reflects any deduction.',
       'Medium')

    uc('UC-07', 'Generate Reports', 'Parent',
       'Parent is logged in and child data exists.',
       'Parent opens the Reports screen and selects a period.',
       '1. Parent selects period (daily, weekly, monthly, yearly) and optionally a child.\n2. System computes completed, rejected, pending and missed tasks, coins, badges, completion rate and top child.\n3. System displays charts and tables.\n4. Parent may print or export the report.',
       'A1: No data for the period \u2014 system displays an empty-state message.',
       'Report generated and displayed.',
       'High')

    uc('UC-08', 'Assign Badges and Bonus Coins', 'Parent',
       'Parent is logged in and at least one child exists.',
       'Parent selects a child and chooses Assign Badge or Bonus Coins.',
       '1. Parent selects the badge from the library or creates a new one.\n2. Parent assigns the badge to the child.\n3. Alternatively, parent enters a bonus amount and a reason.\n4. System records the award or credit and notifies the child.',
       'A1: Duplicate badge \u2014 system warns unless explicitly re-awarded (BR-08).',
       'Badge awarded or coins credited with a ledger record.',
       'Medium')

    H('3.8.3 Activity Diagram', 3)
    P('The activity diagram below models the task-completion and verification process. It shows the '
      'decision on verification type, the immediate awarding of coins for self-check tasks, and the '
      'approval loop with automatic coin reversal on rejection for parent-approval tasks.')
    img(_f('f09_activity_diagram.png'), 6.1, 'Activity Diagram \u2013 Task Completion and Verification', 'activity_diagram')

    H('3.8.4 Sequence Diagram', 3)
    P('The sequence diagram below illustrates the interactions between the child-facing tablet UI, the '
      'Flutter application, the Laravel REST API and the MySQL database during task completion and '
      'parental verification. All calls use JSON over HTTP on the local network.')
    img(_f('f08_sequence_diagram.png'), 6.2, 'Sequence Diagram \u2013 Task Completion and Parent Approval', 'sequence_diagram')

    H('3.8.5 State Diagram', 3)
    P('The state diagram below models the lifecycle of an assignment (a single task instance). A task '
      'may be pending, completed, submitted, verified, rejected or missed, with well-defined '
      'transitions triggered by child actions, parent decisions or the system clock.')
    img(_f('f10_state_diagram.png'), 6.1, 'State Diagram \u2013 Assignment Lifecycle', 'state_diagram')

    H('3.8.6 Workflow Diagrams', 3)
    P('The following workflow diagrams detail the coin, approval, reward, parent and child processes '
      'that define the behaviour of the system.')
    img(_f('f15_coin_workflow.png'), 6.0, 'Coin Workflow', 'coin_workflow')
    img(_f('f16_approval_workflow.png'), 5.8, 'Approval Workflow', 'approval_workflow')
    img(_f('f17_reward_workflow.png'), 6.0, 'Reward Workflow', 'reward_workflow')
    img(_f('f18_parent_workflow.png'), 6.2, 'Parent Workflow', 'parent_workflow')
    img(_f('f19_child_workflow.png'), 6.0, 'Child Workflow', 'child_workflow')

    # ---------------------------------------------------------- 3.9 DFD
    H('3.9 Data Flow Analysis', 2)
    H('3.9.1 Context Diagram', 3)
    P('The context diagram below shows the entire system as a single process together with its two '
      'external entities \u2014 the parent and the child \u2014 and the main data flows between them. No data '
      'flows leave the home network.')
    img(_f('f01_context.png'), 6.2, 'Context Diagram of the System', 'context_diagram')

    H('3.9.2 Data Flow Diagram \u2013 Level 0', 3)
    dfd0_fig = img(_f('f02_dfd_level0.png'), 6.2, 'DFD Level 0', 'dfd0')
    ref_para('The level-0 diagram (Figure ', 'dfd0', dfd0_fig,
             ') decomposes the context diagram into the main system process and its principal data '
             'stores. The system exchanges management inputs and reports with the parent, and task, '
             'coin and reward data with the child, while reading and updating its stores.')

    H('3.9.3 Data Flow Diagram \u2013 Level 1', 3)
    dfd1_fig = img(_f('f03_dfd_level1.png'), 6.3, 'DFD Level 1 \u2013 Main Processes', 'dfd1')
    ref_para('The level-1 diagram (Figure ', 'dfd1', dfd1_fig,
             ') expands the system into eight major processes: authentication, child and profile '
             'management, task management and scheduling, verification and approval, coin and reward '
             'management, badge management, reports and analytics, and notifications and messages. '
             'Each process reads from and writes to the shared data stores.')

    H('3.9.4 Data Flow Diagram \u2013 Level 2', 3)
    dfd2_fig = img(_f('f04_dfd_level2.png'), 6.2, 'DFD Level 2 \u2013 Verification and Approval', 'dfd2')
    ref_para('The level-2 diagram (Figure ', 'dfd2', dfd2_fig,
             ') explodes the verification and approval process (Process 4.0) to show the detailed '
             'flows for self-check completion, submission, approval, rejection and coin issuing or '
             'deduction.')

    # ---------------------------------------------------------- 3.10 data design
    H('3.10 Data Design', 2)
    H('3.10.1 Entity-Relationship Diagram', 3)
    er_fig = img(_f('f05_er_diagram.png'), 6.3, 'Entity-Relationship Diagram (Logical Design)', 'er_diagram')
    ref_para('The ER diagram (Figure ', 'er_diagram', er_fig,
             ') models the data of the system in third normal form. Thirteen entities capture parents, '
             'children, tasks, assignments, coin transactions, rewards, redemptions, badges, badge '
             'awards, messages, notifications, reminders and settings, together with their '
             'relationships and cardinalities.')

    H('3.10.2 Database Design and Data Dictionary', 3)
    P('The logical design is implemented in MySQL as the relational schema described below. Each entity '
      'becomes a table with a primary key, and relationships become foreign keys. The data dictionary '
      'lists every column with its data type, key role and description.')
    TBL(
        ['Table', 'Column', 'Data Type', 'Key', 'Description'],
        [
            ['parents', 'parent_id', 'INT', 'PK', 'Unique parent identifier'],
            ['parents', 'full_name', 'VARCHAR(100)', '\u2013', 'Parent full name'],
            ['parents', 'email', 'VARCHAR(120)', '\u2013', 'Contact email (optional)'],
            ['parents', 'phone', 'VARCHAR(20)', '\u2013', 'Contact phone (optional)'],
            ['parents', 'username', 'VARCHAR(50)', 'UQ', 'Login username'],
            ['parents', 'password_hash', 'VARCHAR(255)', '\u2013', 'Hashed password'],
            ['parents', 'pin', 'VARCHAR(255)', '\u2013', 'Hashed four-digit PIN'],
            ['parents', 'role', 'ENUM', '\u2013', 'Administrator role'],
            ['children', 'child_id', 'INT', 'PK', 'Unique child identifier'],
            ['children', 'parent_id', 'INT', 'FK', 'Owning parent'],
            ['children', 'first_name', 'VARCHAR(50)', '\u2013', 'Child first name'],
            ['children', 'last_name', 'VARCHAR(50)', '\u2013', 'Child last name'],
            ['children', 'avatar', 'VARCHAR(255)', '\u2013', 'Avatar image path'],
            ['children', 'date_of_birth', 'DATE', '\u2013', 'Date of birth'],
            ['children', 'total_coins', 'INT', '\u2013', 'Current coin balance'],
            ['children', 'status', 'ENUM', '\u2013', 'Active / inactive'],
            ['tasks', 'task_id', 'INT', 'PK', 'Unique task identifier'],
            ['tasks', 'parent_id', 'INT', 'FK', 'Creating parent'],
            ['tasks', 'title', 'VARCHAR(100)', '\u2013', 'Task title'],
            ['tasks', 'description', 'TEXT', '\u2013', 'Task description'],
            ['tasks', 'schedule_type', 'ENUM', '\u2013', 'Daily / weekly / monthly / custom / weekend / specific days'],
            ['tasks', 'repeat_days', 'VARCHAR(50)', '\u2013', 'Days of week for repeating schedules'],
            ['tasks', 'coins_reward', 'INT', '\u2013', 'Coins earned on completion'],
            ['tasks', 'verification_type', 'ENUM', '\u2013', 'Self-check / parent approval'],
            ['tasks', 'is_active', 'BOOLEAN', '\u2013', 'Task enabled or not'],
            ['assignments', 'assignment_id', 'INT', 'PK', 'Unique assignment identifier'],
            ['assignments', 'child_id', 'INT', 'FK', 'Assigned child'],
            ['assignments', 'task_id', 'INT', 'FK', 'Source task'],
            ['assignments', 'due_date', 'DATE', '\u2013', 'Scheduled date'],
            ['assignments', 'status', 'ENUM', '\u2013', 'Pending / completed / submitted / verified / rejected / missed'],
            ['assignments', 'completed_at', 'DATETIME', '\u2013', 'Completion timestamp'],
            ['assignments', 'verified_at', 'DATETIME', '\u2013', 'Verification timestamp'],
            ['assignments', 'rejection_reason', 'VARCHAR(255)', '\u2013', 'Reason when rejected'],
            ['assignments', 'coins_awarded', 'INT', '\u2013', 'Final coins for this assignment'],
            ['coin_transactions', 'transaction_id', 'INT', 'PK', 'Unique transaction identifier'],
            ['coin_transactions', 'child_id', 'INT', 'FK', 'Affected child'],
            ['coin_transactions', 'assignment_id', 'INT', 'FK', 'Related assignment (nullable)'],
            ['coin_transactions', 'type', 'ENUM', '\u2013', 'Earn / bonus / redeem / deduction'],
            ['coin_transactions', 'amount', 'INT', '\u2013', 'Signed coin amount'],
            ['coin_transactions', 'reason', 'VARCHAR(255)', '\u2013', 'Human-readable reason'],
            ['coin_transactions', 'created_by', 'VARCHAR(20)', '\u2013', 'parent / system'],
            ['coin_transactions', 'created_at', 'DATETIME', '\u2013', 'Ledger timestamp'],
            ['rewards', 'reward_id', 'INT', 'PK', 'Unique reward identifier'],
            ['rewards', 'parent_id', 'INT', 'FK', 'Creating parent'],
            ['rewards', 'title', 'VARCHAR(100)', '\u2013', 'Reward name'],
            ['rewards', 'description', 'TEXT', '\u2013', 'Reward description'],
            ['rewards', 'cost_coins', 'INT', '\u2013', 'Coins required'],
            ['rewards', 'is_active', 'BOOLEAN', '\u2013', 'Available or not'],
            ['redemptions', 'redemption_id', 'INT', 'PK', 'Unique redemption identifier'],
            ['redemptions', 'child_id', 'INT', 'FK', 'Requesting child'],
            ['redemptions', 'reward_id', 'INT', 'FK', 'Requested reward'],
            ['redemptions', 'status', 'ENUM', '\u2013', 'Pending / approved / rejected / granted'],
            ['redemptions', 'requested_at', 'DATETIME', '\u2013', 'Request time'],
            ['redemptions', 'granted_at', 'DATETIME', '\u2013', 'Grant time'],
            ['badges', 'badge_id', 'INT', 'PK', 'Unique badge identifier'],
            ['badges', 'parent_id', 'INT', 'FK', 'Creating parent'],
            ['badges', 'name', 'VARCHAR(100)', '\u2013', 'Badge name'],
            ['badges', 'description', 'TEXT', '\u2013', 'Badge description'],
            ['badges', 'criterion', 'VARCHAR(255)', '\u2013', 'Award criterion'],
            ['badge_awards', 'award_id', 'INT', 'PK', 'Unique award identifier'],
            ['badge_awards', 'child_id', 'INT', 'FK', 'Awarded child'],
            ['badge_awards', 'badge_id', 'INT', 'FK', 'Awarded badge'],
            ['badge_awards', 'awarded_at', 'DATETIME', '\u2013', 'Award time'],
            ['badge_awards', 'awarded_by', 'VARCHAR(20)', '\u2013', 'Awarding actor'],
            ['messages', 'message_id', 'INT', 'PK', 'Unique message identifier'],
            ['messages', 'parent_id', 'INT', 'FK', 'Sender'],
            ['messages', 'child_id', 'INT', 'FK', 'Recipient child'],
            ['messages', 'subject', 'VARCHAR(120)', '\u2013', 'Message subject'],
            ['messages', 'body', 'TEXT', '\u2013', 'Message body'],
            ['messages', 'is_read', 'BOOLEAN', '\u2013', 'Read status'],
            ['messages', 'sent_at', 'DATETIME', '\u2013', 'Sent time'],
            ['notifications', 'notification_id', 'INT', 'PK', 'Unique notification identifier'],
            ['notifications', 'parent_id', 'INT', 'FK', 'Recipient parent (nullable)'],
            ['notifications', 'child_id', 'INT', 'FK', 'Recipient child (nullable)'],
            ['notifications', 'message', 'VARCHAR(255)', '\u2013', 'Notification text'],
            ['notifications', 'type', 'ENUM', '\u2013', 'Approval / coins / reward / badge / reminder'],
            ['notifications', 'is_read', 'BOOLEAN', '\u2013', 'Read status'],
            ['notifications', 'created_at', 'DATETIME', '\u2013', 'Creation time'],
            ['reminders', 'reminder_id', 'INT', 'PK', 'Unique reminder identifier'],
            ['reminders', 'parent_id', 'INT', 'FK', 'Creating parent'],
            ['reminders', 'task_id', 'INT', 'FK', 'Related task'],
            ['reminders', 'remind_time', 'TIME', '\u2013', 'Daily reminder time'],
            ['reminders', 'frequency', 'VARCHAR(30)', '\u2013', 'Daily / specific days'],
            ['reminders', 'is_enabled', 'BOOLEAN', '\u2013', 'Enabled or not'],
            ['settings', 'setting_id', 'INT', 'PK', 'Unique setting identifier'],
            ['settings', 'parent_id', 'INT', 'FK', 'Owning parent'],
            ['settings', 'setting_key', 'VARCHAR(60)', '\u2013', 'Setting name'],
            ['settings', 'setting_value', 'VARCHAR(255)', '\u2013', 'Setting value'],
            ['settings', 'updated_at', 'DATETIME', '\u2013', 'Last update time'],
        ],
        col_widths=[1.5, 1.4, 1.0, 0.7, 2.3],
        caption='Data Dictionary of the MySQL Schema',
        size=8.5,
    )

    H('3.10.3 Database Relationship Diagram', 3)
    dbr_fig = img(_f('f14_database_relationship.png'), 6.3, 'Database Relationship Diagram', 'db_relationship')
    ref_para('The database relationship diagram (Figure ', 'db_relationship', dbr_fig,
             ') shows the implemented tables with their primary and foreign keys. Referential '
             'integrity is enforced by foreign-key constraints so that orphaned records cannot occur.')

    # ---------------------------------------------------------- 3.11 class
    H('3.11 Class Diagram', 2)
    cls_fig = img(_f('f07_class_diagram.png'), 6.3, 'Class Diagram (Domain Model)', 'class_diagram')
    ref_para('The class diagram (Figure ', 'class_diagram', cls_fig,
             ') presents the domain model of the system. It shows the principal classes, their '
             'attributes and operations, and the associations with multiplicity between parents, '
             'children, tasks, assignments, coins, rewards, redemptions, badges and the report service.')

    # ---------------------------------------------------------- 3.12 navigation
    H('3.12 Navigation Structure', 2)
    nav_fig = img(_f('f11_navigation.png'), 6.3, 'Navigation Structure of the Application', 'navigation')
    ref_para('The navigation diagram (Figure ', 'navigation', nav_fig,
             ') defines the screen structure of both the parent application and the child kiosk '
             'application. The parent flow starts at a secure login and branches through the '
             'administration modules, while the child flow starts at profile selection and branches '
             'through tasks, coins, badges, rewards, progress and messages.')

    # ---------------------------------------------------------- 3.13 arch
    H('3.13 System Architecture', 2)
    arch_fig = img(_f('f12_system_architecture.png'), 6.2, 'System Architecture \u2013 Five-Layer Stack', 'architecture')
    ref_para('The system uses a five-layer architecture (Figure ', 'architecture', arch_fig,
             '). The presentation layer is a Flutter client running on the shared tablet in either '
             'parent or child mode. The API layer exposes a Laravel REST API, the business-logic layer '
             'contains the service classes, the data-access layer uses Eloquent ORM, and the database '
             'layer is MySQL. All layers communicate over the offline local network.')

    # ---------------------------------------------------------- 3.14 deployment
    H('3.14 Deployment Architecture', 2)
    dep_fig = img(_f('f13_deployment_diagram.png'), 6.3, 'Deployment Architecture', 'deployment')
    ref_para('The deployment diagram (Figure ', 'deployment', dep_fig,
             ') shows the physical nodes: the shared family tablet hosting the Flutter client, the '
             'home computer or server hosting the Laravel API and MySQL database, and the home Wi-Fi '
             'network that links them. There is no external internet dependency, and all data remains '
             'within the home.')

    # ---------------------------------------------------------- 3.15 wireframes
    H('3.15 User Interface Design (Wireframes)', 2)
    H('3.15.1 Design Guidelines', 3)
    P('The user interface follows simple, consistent guidelines. The parent interface uses a structured '
      'administration layout with a navigation menu, data cards, approval queues and charts. The child '
      'interface is a kiosk: large touch targets, avatars, bright colours, immediate feedback and no '
      'text-heavy screens. All screens are designed for a portrait tablet with at least a 10-inch '
      'screen. The wireframes below illustrate the visual structure of each screen.')

    H('3.15.2 Login / PIN Screen', 3)
    wf1 = img(_f('f21_wireframe_login.png'), 5.2, 'Login / PIN Screen \u2013 Wireframe', 'wf_login')
    ref_para('The login screen (Figure ', 'wf_login', wf1,
             ') is used only by the parent. The child-facing mode is entered through a separate kiosk '
             'button that leads to profile selection without any authentication.')

    H('3.15.3 Parent Dashboard', 3)
    wf2 = img(_f('f22_wireframe_parent_dashboard.png'), 6.3, 'Parent Dashboard \u2013 Wireframe', 'wf_parent')
    ref_para('The parent dashboard (Figure ', 'wf_parent', wf2,
             ') combines a navigation drawer, an overview of children, a pending approval queue and '
             'quick actions.')

    H('3.15.4 Child Dashboard', 3)
    wf3 = img(_f('f23_wireframe_child_dashboard.png'), 5.4, 'Child Dashboard \u2013 Wireframe', 'wf_child')
    ref_para('The child dashboard (Figure ', 'wf_child', wf3,
             ') greets the child by name, summarises coins, badges and progress, and lists the tasks '
             'for today.')

    H('3.15.5 Task Screen', 3)
    wf4 = img(_f('f24_wireframe_tasks.png'), 5.4, 'Task Screen \u2013 Wireframe', 'wf_tasks')
    ref_para('The task screen (Figure ', 'wf_tasks', wf4,
             ') lists each task with its schedule tag, coin value and verification type, together with '
             'a Complete or Submit action.')

    H('3.15.6 Reports Screen', 3)
    wf5 = img(_f('f25_wireframe_reports.png'), 6.3, 'Reports Screen \u2013 Wireframe', 'wf_reports')
    ref_para('The reports screen (Figure ', 'wf_reports', wf5,
             ') provides period filters, summary cards, charts and the top-child table, with an export '
             'option.')

    H('3.15.7 Coins Screen', 3)
    wf6 = img(_f('f26_wireframe_coins.png'), 5.4, 'Coins Screen \u2013 Wireframe', 'wf_coins')
    ref_para('The coins screen (Figure ', 'wf_coins', wf6,
             ') shows the balance and ledger history, and gives the parent tools to add bonus coins or '
             'remove coins with a reason.')

    H('3.15.8 Rewards Screen', 3)
    wf7 = img(_f('f27_wireframe_rewards.png'), 5.4, 'Rewards Screen \u2013 Wireframe', 'wf_rewards')
    ref_para('The rewards screen (Figure ', 'wf_rewards', wf7,
             ') presents the rewards shop with coin costs and redeem or locked states, plus the '
             'child\u2019s current balance.')

    H('3.15.9 Settings Screen', 3)
    wf8 = img(_f('f28_wireframe_settings.png'), 5.4, 'Settings Screen \u2013 Wireframe', 'wf_settings')
    ref_para('The settings screen (Figure ', 'wf_settings', wf8,
             ') allows the parent to change the PIN, manage notifications, set task defaults, manage '
             'libraries, check the offline sync status and back up data.')

    H('3.16 Summary', 2)
    P('This chapter analysed the current manual system and specified the proposed system through '
      'functional requirements, non-functional requirements, business rules, actors and use cases. The '
      'system was then modelled with DFDs, an ER model, a full database schema, UML diagrams, '
      'navigation, architecture and deployment views, and every major screen was designed as a '
      'wireframe. The next chapter presents the project management plan that will govern the '
      'implementation of this design.')
