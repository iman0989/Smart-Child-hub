"""Chapter One: Introduction."""
from dwb import H, P, RICH, B, NL, TBL, add_cross_ref


def build():
    H('CHAPTER ONE', 1)
    H('INTRODUCTION', 2)

    H('1.1 Background of the Study', 2)
    P('Children in the modern family are surrounded by digital technology, yet the tools designed to '
      'support their daily routines rarely consider families in which the child does not own a '
      'smartphone. Popular habit-tracking and gamified parenting applications assume that every child '
      'can install an application, create an account and carry a personal mobile device. In reality, '
      'many households, particularly those concerned about screen time, online safety and data cost, '
      'prefer that their children use technology only inside the home and under direct parental '
      'supervision.')
    P('The Smart Child Daily Activity Tracking System addresses this gap by providing an offline family '
      'dashboard that runs on a single shared tablet or touchscreen device placed in the home. Children '
      'are never expected to log in to a personal phone. Instead, a child simply chooses his or her own '
      'profile from the tablet and the system adapts the entire interface to that child. Parents, acting '
      'as administrators of the family system, manage every aspect of the dashboard: they create '
      'children, define tasks, set schedules, assign coin values, approve or reject completed work, '
      'create rewards and badges, and monitor performance through daily, weekly, monthly and yearly '
      'reports.')
    P('The system combines behaviour-modification theory with practical family management. Children earn '
      'coins for completing tasks, collect badges for consistent effort, and exchange coins for rewards '
      'that the parent defines. Two verification models are supported: self-check, in which a child '
      'receives coins immediately, and parent approval, in which a child receives temporary coins that '
      'are only retained if the parent later approves the task. Because the entire platform operates on '
      'a local network without an internet connection, the system is private, secure and usable in '
      'homes with limited or no broadband connectivity.')
    P('Technologically, the system is a three-tier application. The front-end is built with Flutter and '
      'runs on the family tablet. The back-end is a Laravel (PHP) REST API served on a home computer '
      'acting as a local server, and all persistent data is stored in a MySQL database. All '
      'communication takes place over the home Wi-Fi network, and no data ever leaves the household.')

    H('1.2 Problem Statement', 2)
    P('Existing child habit and chore applications are designed around the assumption that the child owns '
      'a smartphone. This assumption creates a number of problems for families who do not wish to give '
      'their children personal devices:')
    B([
        ('Device ownership barrier: ', 'children without smartphones cannot use most existing applications.'),
        ('Account management overload: ', 'managing separate accounts and passwords for each child is burdensome and unsafe.'),
        ('Internet dependency: ', 'cloud-based applications stop working when the home network is offline.'),
        ('Weak supervision: ', 'parents cannot verify that a task was actually completed because most applications rely on the child\u2019s own claim without an approval channel.'),
        ('Lack of flexible scheduling: ', 'fixed chore lists do not support weekend, Friday-only or custom schedules such as attending Jummah prayer or visiting grandparents.'),
        ('No family-level reporting: ', 'parents cannot compare children or generate period-based progress reports easily.'),
        ('Reward handling is arbitrary: ', 'there is no transparent coin ledger, so earning and spending of rewards is unclear to both parent and child.'),
    ])
    P('Consequently, parents who want to encourage responsibility and good habits must fall back on '
      'paper charts, verbal reminders and manual record keeping, which are difficult to maintain '
      'consistently and produce no useful statistics. There is therefore a clear need for an offline, '
      'shared-device system that places control firmly in the hands of the parent while motivating the '
      'child through a transparent coin, badge and reward economy.')

    H('1.3 Aim of the Study', 2)
    P('The aim of this study is to analyse, design and document a Smart Child Daily Activity Tracking '
      'System \u2014 an offline family dashboard that runs on one shared home tablet, allows parents to '
      'manage tasks, coins, badges and rewards, and allows children to track and complete their daily '
      'activities without owning a personal smartphone.')

    H('1.4 Objectives of the Study', 2)
    P('The specific objectives of the study are to:')
    NL([
        'analyse the requirements of an offline, shared-device family activity tracking system and document them as clear functional and non-functional requirements;',
        'design the complete architecture of the system, including use cases, data flow diagrams, entity-relationship model, class diagram, navigation structure, deployment model and database schema;',
        'design a motivating coin, badge and reward economy with self-check and parent-approval verification workflows;',
        'design periodic reporting (daily, weekly, monthly and yearly) that includes completed, rejected, pending and missed tasks, coins, badges, completion rate and top-child ranking;',
        'prepare a professional project management plan covering schedule, resources, budget, risks, quality, communication and testing; and',
        'produce a complete Software Analysis and Design (SAD) document ready for university submission.',
    ])

    H('1.5 Research Questions', 2)
    P('The study is guided by the following research questions:')
    NL([
        'RQ1: What are the functional and non-functional requirements of an offline shared-tablet system for tracking children\u2019s daily activities in homes where children do not own smartphones?',
        'RQ2: How can a coin, badge and reward economy be designed to motivate children while remaining fully controlled and verifiable by parents?',
        'RQ3: How can self-check and parent-approval verification workflows be modelled so that coins are awarded fairly and consistently?',
        'RQ4: What data must be stored and analysed to produce meaningful daily, weekly, monthly and yearly progress reports?',
        'RQ5: How can the system be architected to operate entirely within a home local network without an internet connection?',
    ])

    H('1.6 Significance of the Study', 2)
    P('The study is significant in several ways. For parents, it offers a practical, private and '
      'supervised tool that improves children\u2019s habits without introducing personal smartphones into '
      'the household. For children, it provides a fair and transparent reward system that makes '
      'responsibility visible and enjoyable. For the field of software engineering, the study '
      'demonstrates the complete analysis and design of a small-scale, offline-first family application '
      'using industry-standard techniques, including structured analysis, object-oriented modelling and '
      'relational database design. Finally, the document serves as a complete academic submission that '
      'shows the application of software engineering principles from requirements capture through to '
      'implementation planning.')

    H('1.7 Scope of the Study', 2)
    P('The scope of this study covers the complete analysis and design of the Smart Child Daily Activity '
      'Tracking System. The design covers two user roles \u2014 the parent (administrator) and the child. '
      'It includes the management of children, tasks, schedules, coins, rewards, badges, verification, '
      'messages, notifications, settings and periodic reports. The system is designed to run entirely '
      'offline on a home local network using a Flutter client, a Laravel PHP REST API and a MySQL '
      'database. The document does not include actual implementation code; it is restricted to the '
      'software analysis and design deliverables: requirements, use cases, DFDs, ER model, class and '
      'sequence diagrams, navigation, architecture, deployment, database design, UI wireframes, and the '
      'project management plan.')

    H('1.8 Limitations of the Study', 2)
    P('The following limitations apply to the study:')
    B([
        ('Single-household deployment: ', 'the system is designed for one home and one local server, not for multi-household cloud hosting.'),
        ('No internet or cloud features: ', 'remote monitoring outside the home network is deliberately out of scope.'),
        ('One shared device: ', 'the design assumes a single shared tablet; multi-device family use is not covered.'),
        ('Design phase only: ', 'the document presents analysis and design; the actual coding, deployment and operational testing are covered in the implementation plan but not performed here.'),
        ('Generalisability: ', 'reward values, badge criteria and report thresholds are configurable defaults that each family can adjust.'),
    ])

    H('1.9 Definition of Terms', 2)
    TBL(
        ['Term', 'Definition'],
        [
            ['Administrator', 'The parent role that manages all configuration, verification and reporting in the system.'],
            ['Assignment', 'A single instance of a task assigned to a specific child for a specific date.'],
            ['Badge', 'A visual achievement awarded by the parent for consistent performance, such as \u201cReading Hero\u201d.'],
            ['Child', 'A non-administrator user who selects a profile on the shared tablet and completes tasks.'],
            ['Coin', 'The internal currency earned for completing tasks and used to redeem rewards.'],
            ['Completion Rate', 'The percentage of assigned tasks that were completed and verified within a reporting period.'],
            ['Kiosk Mode', 'The child-facing interface that requires only profile selection, not a personal login.'],
            ['Offline Local Network', 'A home Wi-Fi network where the tablet, server and database communicate without internet access.'],
            ['Parent Approval', 'A verification type in which coins are temporary until the parent approves the task.'],
            ['Redemption', 'The process of exchanging coins for a reward, which the parent must approve.'],
            ['Self-Check', 'A verification type in which the child\u2019s completion is accepted immediately and coins are awarded at once.'],
            ['Task', 'An activity (daily, weekly, monthly, custom, weekend or specific-days) that a child must complete.'],
            ['Verification', 'The process of confirming that a completed task is accepted or rejected.'],
        ],
        col_widths=[3.0, 3.3],
        caption='Definition of Key Terms',
    )

    H('1.10 Organisation of the Document', 2)
    P('This document is organised into five chapters. Chapter One introduces the study. Chapter Two '
      'presents the literature review, including existing systems, a comparison and the research gap. '
      'Chapter Three contains the full system analysis and design, including requirements, use cases, '
      'DFDs, database design, UML diagrams, architecture and UI wireframes. Chapter Four presents the '
      'project management plan, covering methodology, schedule, resources, budget, risk, quality, '
      'communication and testing. Chapter Five describes the implementation plan and concludes the '
      'document. The references and appendices follow.')
