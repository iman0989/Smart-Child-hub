"""Chapter Two: Literature Review."""
from dwb import H, P, RICH, B, NL, TBL


def build():
    H('CHAPTER TWO', 1)
    H('LITERATURE REVIEW', 2)

    H('2.1 Introduction', 2)
    P('This chapter reviews the body of work and products related to child habit tracking and '
      'gamification in the family context. It first discusses the theoretical background, then examines '
      'representative existing systems, compares them against the needs of families whose children do '
      'not own smartphones, identifies the research gap and finally presents the proposed solution and '
      'its advantages and disadvantages.')

    H('2.2 Theoretical Background', 2)
    P('The design of the proposed system draws on established behavioural and design theory. '
      'Gamification, defined as the use of game design elements in non-game contexts, has been shown to '
      'increase motivation for routine tasks when rewards are immediate, predictable and meaningful. '
      'Token economies, used widely in child behaviour management, operate on the principle that '
      'positive behaviours are strengthened when they are followed by a tangible token that can later be '
      'exchanged for a valued reward. The proposed system operationalises this through coins (tokens), '
      'rewards (back-up reinforcers) and badges (achievement markers).')
    P('Habit formation theory also informs the task-scheduling design. Research on habit formation '
      'emphasises consistency and cue-repetition; therefore the system supports daily, weekly, monthly, '
      'weekend, Friday-only and custom schedules so that routines are matched to the natural rhythm of '
      'the family and the religious or cultural obligations of the household.')

    H('2.3 Review of Existing Systems', 2)
    P('A number of commercial and research applications target the same broad goal of motivating '
      'children. The most representative are reviewed below.')

    H('2.3.1 Habitica', 3)
    P('Habitica is a gamified habit tracker that turns daily routines into an online role-playing game. '
      'Users create a character and lose or gain health and experience based on completing or missing '
      'habits. It is widely praised for its strong gamification, but it is designed for individual adult '
      'users, requires an account and an internet connection, and offers no parent approval or '
      'verification workflow suitable for young children.')

    H('2.3.2 ChoreMonster', 3)
    P('ChoreMonster allows parents to assign chores, children complete them on their own devices, and '
      'the children earn points that can be exchanged for rewards chosen by the parent. It captures the '
      'coin-and-reward model well, but it is a cloud-based mobile application that assumes each child '
      'has (or shares) a device with internet access. It does not support an offline local network, and '
      'verification is limited to the child\u2019s self-report with a simple parent confirm action.')

    H('2.3.3 OurHome', 3)
    P('OurHome focuses on family organisation, assigning tasks to each family member and awarding '
      'points automatically when tasks are marked complete. It includes a family feed and rewards. '
      'Although it supports multiple children on shared devices, it still requires a cloud account and '
      'internet connection, and the scheduling options (daily, specific days, custom) are less '
      'structured than the requirement for Friday-only and weekend-only routines described in this '
      'project.')

    H('2.3.4 Parental Control and Monitoring Applications', 3)
    P('Applications such as FamilyTime and Qustodio focus on screen-time limits, location tracking and '
      'usage monitoring rather than positive habit formation. They provide parents with powerful '
      'oversight but do not address daily routines, task verification or a rewards economy, and they '
      'are fundamentally cloud services.')

    H('2.4 Comparison of Existing Systems', 2)
    TBL(
        ['Feature', 'Habitica', 'ChoreMonster', 'OurHome', 'Parental Control Apps'],
        [
            ['Primary purpose', 'Habit / RPG tracker', 'Chores & rewards', 'Family tasks & points', 'Monitoring & limits'],
            ['Shared tablet (no child phone)', 'No', 'No', 'Partial', 'No'],
            ['Offline / local network', 'No', 'No', 'No', 'No'],
            ['Parent approval & rejection', 'No', 'Partial', 'No', 'No'],
            ['Coin / reward economy', 'Yes (XP/HP)', 'Yes', 'Yes', 'No'],
            ['Badges', 'Yes', 'Partial', 'No', 'No'],
            ['Flexible scheduling (Friday-only, weekend)', 'Partial', 'No', 'Partial', 'No'],
            ['Periodic family reports', 'Personal only', 'No', 'Limited', 'Usage reports'],
            ['Top-child comparison', 'No', 'No', 'No', 'No'],
            ['Runs entirely in the home', 'No', 'No', 'No', 'No'],
        ],
        col_widths=[2.5, 1.0, 1.1, 1.0, 1.3],
        caption='Comparison of Existing Child Habit Tracking Systems',
    )

    H('2.5 Research Gap', 2)
    P('The review shows that no existing application combines all of the following characteristics: '
      '(1) operation on a single shared tablet without any child smartphone, (2) complete offline '
      'operation on a home local network, (3) a full parent-approval workflow in which temporary coins '
      'are automatically removed when a task is rejected, (4) flexible cultural and religious '
      'scheduling such as Friday-only and weekend-only tasks, (5) a transparent coin ledger with '
      'bonus and deduction records, and (6) daily, weekly, monthly and yearly family reports with '
      'completion rate and top-child ranking. This combination represents a genuine research and '
      'product gap that the proposed system fills.')

    H('2.6 Proposed Solution', 2)
    P('The proposed Smart Child Daily Activity Tracking System is an offline family dashboard running on '
      'one shared tablet. A Laravel PHP REST API and a MySQL database run on a home computer, and all '
      'communication stays on the local network. Children select their profile and interact with '
      'child-friendly screens, while parents manage the entire system through an administrator '
      'interface. Tasks carry schedules and coin values; verification is either self-check or parent '
      'approval; coins, badges and rewards are fully parent-controlled; and the system generates '
      'periodic reports with charts and analytics.')

    H('2.7 Advantages of the Proposed System', 2)
    B([
        'Removes the need for children to own smartphones.',
        'Works completely offline, preserving privacy and avoiding data-cost concerns.',
        'Gives parents full control of tasks, verification, coins, rewards and badges.',
        'Provides transparent handling of temporary coins with automatic removal on rejection.',
        'Supports cultural schedules (Friday, weekend, custom and specific days).',
        'Generates daily, weekly, monthly and yearly reports with completion rate and top-child ranking.',
        'Uses a familiar, child-friendly kiosk interface with avatars and badges.',
        'Is built on a maintainable three-tier architecture (Flutter / Laravel / MySQL).',
    ])

    H('2.8 Disadvantages of the Proposed System', 2)
    B([
        'Single-household scope \u2014 no remote monitoring when away from home.',
        'Requires a home computer to act as the local server, which must remain powered.',
        'Manual data backup responsibility rests with the parent.',
        'Multi-device family use is not supported in the initial design.',
        'Limited to the analysis and design documented here until implementation and operational testing are completed.',
    ])

    H('2.9 Overall Comparison: Existing vs Proposed', 2)
    TBL(
        ['Criterion', 'Existing Systems', 'Proposed System'],
        [
            ['Child device requirement', 'Child smartphone / account', 'Shared home tablet only'],
            ['Connectivity', 'Internet required', 'Offline local network'],
            ['Verification', 'Self-report or none', 'Self-check + parent approval with rejection reason'],
            ['Coin integrity', 'Manual / unclear', 'Ledger with automatic deduction on rejection'],
            ['Scheduling', 'Simple', 'Daily, weekly, monthly, weekend, Friday, custom, specific days'],
            ['Reporting', 'None or usage only', 'Daily\u2013yearly reports, completion rate, top child'],
            ['Data privacy', 'Cloud storage', 'Stays in the home'],
        ],
        col_widths=[1.8, 2.2, 2.3],
        caption='Summary Comparison \u2013 Existing Systems versus Proposed System',
    )

    H('2.10 Summary', 2)
    P('This chapter reviewed the theoretical foundations and representative existing systems. The '
      'comparison confirms a clear gap for an offline, shared-tablet family dashboard with parent '
      'verification, flexible cultural scheduling and periodic reporting. The proposed system is '
      'designed specifically to close this gap, and the following chapter presents its full analysis '
      'and design.')
