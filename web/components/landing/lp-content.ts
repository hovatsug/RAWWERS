import type { SceneItem } from "@/components/landing/ScenesGrid";

export type PactTemplate = {
  id: string;
  title: string;
  rule: string;
  schedule: string;
  enforcement: string;
  difficulty: "Low" | "Medium" | "High";
};

export type LandingContent = {
  slug: "adhd" | "founder" | "fitness";
  badge: string;
  heroTitle: string;
  heroSubheadline: string;
  heroTrust: string[];
  mirrorTitle: string;
  mirrorBullets: string[];
  mechanismTitle: string;
  mechanismBlocks: string[];
  scenes: SceneItem[];
  proofTitle: string;
  proofBullets: string[];
  featureTitle: string;
  features: string[];
  trialTitle: string;
  trialBullets: string[];
  faq: { id: string; title: string; content: string }[];
  finalClose: string[];
  templates: PactTemplate[];
};

const sharedFaq = [
  { id: "faq-1", title: "Is this another habit tracker?", content: "No. PACT is an accountability enforcement system. It records what happened at decision points and after deadlines." },
  { id: "faq-2", title: "What if I ignore tasks?", content: "Negotiation is data: snooze, postpone, and ignore are recorded. Deadline misses move to overdue resolution instead of disappearing." },
  { id: "faq-3", title: "Do I need the dashboard?", content: "Telegram handles fast action. The dashboard reveals pattern-level behavior you cannot see in short chats." },
  { id: "faq-4", title: "How long does setup take?", content: "Most people complete Start + /link in around two minutes." },
  { id: "faq-5", title: "Is there a free tier?", content: "PACT runs on a 14-day trial so you can test full workflow before committing." },
  { id: "faq-6", title: "Can I use this with a team?", content: "The architecture is team-ready. Multi-user coordination can be layered on top of the same enforcement mechanics." },
  { id: "faq-7", title: "Do you store my data?", content: "PACT stores timeline and state data required for accountability, reporting, and integrity checks." },
  { id: "faq-8", title: "What platforms are supported?", content: "Telegram bot for action. Web dashboard for setup, linking, analytics, and review." },
  { id: "faq-9", title: "Is this medical treatment?", content: "No. PACT is a support tool for structure and accountability, not a medical device or therapy replacement." }
];

export const LANDING_CONTENT: Record<LandingContent["slug"], LandingContent> = {
  adhd: {
    slug: "adhd",
    badge: "PACT for ADHD structure",
    heroTitle: "Structure for ADHD days that drift before noon.",
    heroSubheadline:
      "Not motivation. Enforcement. Permanent history. No reset. Negotiation is data: snooze/postpone/ignore are recorded. Dashboard exposes patterns you can’t argue with.",
    heroTrust: ["Support tool for structure", "Permanent history, no delete", "Start in Telegram. Connect dashboard in 2 minutes."],
    mirrorTitle: "You are not failing because you forgot the goal. You are failing in the negotiation window.",
    mirrorBullets: ["Morning intention, afternoon drift.", "Task switching disguised as urgency.", "Invisible avoidance loops that feel rational in real time."],
    mechanismTitle: "Why this works when motivation spikes fail",
    mechanismBlocks: [
      "PACT tracks state transitions, not feelings. A commitment gets a deadline. At deadline, enforcement triggers automatically.",
      "You can snooze or postpone, but each action is recorded. No silent reset, no missing context, no erased week.",
      "Dashboard review turns vague guilt into observable behavior: failure time bands, negotiation chains, streak integrity, and unresolved debt queue."
    ],
    scenes: [
      {
        id: "adhd-scene-1",
        title: "The tab spiral at 10:40",
        hook: "You opened one task, then five tabs, then forgot the first commitment existed.",
        story:
          "By lunch, you remember the task but the day already feels broken. You postpone because 'today is messy anyway.' PACT logs the postpone chain and keeps the deadline context intact.",
        pactDoes: ["Captures postpone events with timestamps.", "Pushes unresolved pact back into required resolution flow."],
        outcome: "Outcome: you stop telling yourself the task vanished; you see exactly when focus broke."
      },
      {
        id: "adhd-scene-2",
        title: "The perfect-plan reset",
        hook: "You rebuild a new plan every morning and discard yesterday’s evidence.",
        story:
          "The fresh plan feels clean, but the pattern repeats by evening. PACT keeps permanent history so each day inherits the real trail, not a rewritten narrative.",
        pactDoes: ["Preserves timeline without reset.", "Shows streak integrity instead of optimistic restarts."],
        outcome: "Outcome: planning quality improves because evidence survives mood changes."
      },
      {
        id: "adhd-scene-3",
        title: "The silent ignore",
        hook: "You avoid opening the task to avoid feeling behind.",
        story:
          "Avoidance is subtle: you do adjacent work and call it productivity. PACT marks ignore states and overdue entries directly, making avoidance measurable.",
        pactDoes: ["Records ignore and overdue transitions.", "Triggers reminders until resolution is explicit."],
        outcome: "Outcome: avoidance loses its invisibility."
      },
      {
        id: "adhd-scene-4",
        title: "The weekly pattern reveal",
        hook: "You thought inconsistency was random.",
        story:
          "Dashboard review shows repeat failure windows after context switches and late-day scheduling. You adjust pact timing and scope with evidence, not self-blame.",
        pactDoes: ["Surfaces time-of-day failure clusters.", "Highlights negotiation-heavy commitments."],
        outcome: "Outcome: structure gets customized to your actual behavior."
      }
    ],
    proofTitle: "What you actually see each week",
    proofBullets: [
      "Bot command timeline: complete, snooze, postpone, ignore, overdue resolution.",
      "Sample week timeline: no missing days, no delete.",
      "Pattern analytics view: recurring failure windows and negotiation chains."
    ],
    featureTitle: "Core mechanics",
    features: [
      "Deadline-bound commitments",
      "Automatic enforcement state changes",
      "Snooze/postpone/ignore telemetry",
      "Permanent history with no reset",
      "Overdue debt queue and required resolution",
      "Reminder escalation",
      "Streak integrity and reputation signals",
      "Pattern analytics dashboard"
    ],
    trialTitle: "Start 14-day trial with full bot + dashboard access",
    trialBullets: ["Cancel anytime.", "No motivation feed.", "Built for evidence-based accountability."],
    faq: sharedFaq,
    finalClose: [
      "You do not need a louder pep talk.",
      "You need a system that records the negotiation moment and keeps the receipt.",
      "Start in Telegram. Connect dashboard in 2 minutes."
    ],
    templates: [
      { id: "adhd-t1", title: "Morning Focus Block", rule: "Start one 25-minute deep-work pact by 09:30.", schedule: "Weekdays at 09:00", enforcement: "Missed deadline is logged; pact moves to overdue queue until resolved.", difficulty: "Low" },
      { id: "adhd-t2", title: "Inbox Triage Window", rule: "Process inbox to zero triage labels before noon.", schedule: "Mon-Fri 11:30", enforcement: "Postpone/ignore chain recorded; reminder escalation until status resolved.", difficulty: "Medium" },
      { id: "adhd-t3", title: "Single Task Launch", rule: "Run /create and complete first high-priority task before opening social apps.", schedule: "Daily 08:30", enforcement: "Ignore is recorded; streak integrity drops until completion.", difficulty: "Medium" },
      { id: "adhd-t4", title: "Context Switch Cap", rule: "Maximum 3 postpones for one pact in a day.", schedule: "Daily", enforcement: "When cap exceeded, pact marked negotiation-heavy and flagged in dashboard.", difficulty: "High" },
      { id: "adhd-t5", title: "Admin Sweep", rule: "Resolve two overdue pacts before creating new ones.", schedule: "Daily 16:30", enforcement: "New pact creation deferred by your own rule until debt queue reduced.", difficulty: "High" },
      { id: "adhd-t6", title: "Shutdown Integrity", rule: "Mark every open pact complete/postpone/ignore before day end.", schedule: "Daily 20:30", enforcement: "Unresolved pacts are logged as carryover debt with reminders.", difficulty: "Medium" },
      { id: "adhd-t7", title: "Weekly Pattern Review", rule: "Review dashboard analytics every Sunday.", schedule: "Sunday 18:00", enforcement: "Missed review is logged; no reset of prior week timeline.", difficulty: "Low" },
      { id: "adhd-t8", title: "Planning With Evidence", rule: "Use /bulk only after checking last week failure windows.", schedule: "Monday 07:30", enforcement: "If skipped, dashboard flags plan-without-review pattern.", difficulty: "Medium" }
    ]
  },
  founder: {
    slug: "founder",
    badge: "PACT for founder execution",
    heroTitle: "Execution system for founders who negotiate with priorities mid-week.",
    heroSubheadline:
      "Not motivation. Enforcement. Permanent history. No reset. Negotiation is data: snooze/postpone/ignore are recorded. Dashboard exposes patterns you can’t argue with.",
    heroTrust: ["Decision-to-action trace", "No erased commitments", "Start in Telegram. Connect dashboard in 2 minutes."],
    mirrorTitle: "Roadmaps fail less from strategy and more from untracked negotiation.",
    mirrorBullets: ["Urgent requests hijack planned execution.", "Backlog expands, completed decisions shrink.", "Leadership narrative says progress; logs say drift."],
    mechanismTitle: "Execution discipline without adding management theater",
    mechanismBlocks: [
      "Each strategic commitment becomes a deadline-bound pact.",
      "At deadline, enforcement triggers automatically: resolve, postpone, or carry explicit debt. Nothing silently vanishes.",
      "Dashboard reveals operational truth: negotiation chains, chronic postpones, and priority integrity across the week."
    ],
    scenes: [
      {
        id: "founder-scene-1",
        title: "The investor update week",
        hook: "You promised shipment Friday, then let Slack urgency rewrite the week.",
        story:
          "Every interruption seemed justified. By Thursday, original commitments were unowned. PACT keeps the initial pact and every deviation in one chain.",
        pactDoes: ["Logs each postpone reason/state.", "Preserves deadline integrity across context switching."],
        outcome: "Outcome: you see where execution was traded away."
      },
      {
        id: "founder-scene-2",
        title: "The meeting flood",
        hook: "Calendar filled. Shipping died quietly.",
        story:
          "You still worked hard, but pact outcomes degraded. PACT marks unresolved delivery pacts as overdue debt instead of letting them disappear into next sprint planning.",
        pactDoes: ["Converts misses into explicit debt queue.", "Requires resolution choices, not passive carryover."],
        outcome: "Outcome: operational debt becomes visible before trust erosion."
      },
      {
        id: "founder-scene-3",
        title: "The fake done signal",
        hook: "A task looked done in chat, but the pact state stayed unresolved.",
        story:
          "Status language can hide incomplete outcomes. PACT separates claims from state transitions and forces close/overdue decisions at deadline.",
        pactDoes: ["Tracks explicit complete vs unresolved states.", "Keeps timeline audit trail for review."],
        outcome: "Outcome: less narrative drift, tighter execution truth."
      },
      {
        id: "founder-scene-4",
        title: "The pattern dashboard Monday",
        hook: "You thought missed priorities were random.",
        story:
          "Dashboard patterns show repeated misses after late-day strategy meetings and context overload blocks. You redesign scheduling from evidence.",
        pactDoes: ["Surfaces repeat failure windows.", "Highlights negotiation-heavy pacts and streak breaks."],
        outcome: "Outcome: better planning discipline with fewer surprises."
      }
    ],
    proofTitle: "Proof by mechanism, not slogans",
    proofBullets: [
      "Sample week timeline across leadership commitments.",
      "Dashboard pattern analytics for execution reliability.",
      "Bot-level state log showing negotiation decisions in sequence."
    ],
    featureTitle: "Execution stack",
    features: [
      "Deadline pacts with explicit state transitions",
      "Negotiation telemetry: snooze/postpone/ignore",
      "Automatic deadline enforcement and reminders",
      "Overdue queue with required resolution",
      "Permanent audit timeline",
      "Integrity and streak indicators",
      "Analytics for pattern-level correction",
      "Fast bot commands with dashboard orchestration"
    ],
    trialTitle: "Start 14-day trial and test execution integrity with real commitments",
    trialBullets: ["Full dashboard included.", "No distraction features.", "Built for teams-ready operational rhythm."],
    faq: sharedFaq,
    finalClose: [
      "Execution does not fail in planning docs. It fails in unrecorded negotiation moments.",
      "PACT gives you a permanent operational memory.",
      "Start in Telegram. Connect dashboard in 2 minutes."
    ],
    templates: [
      { id: "founder-t1", title: "Daily Shipping Pact", rule: "Ship one customer-visible improvement each workday.", schedule: "Mon-Fri 17:00", enforcement: "Miss logs as overdue and enters debt queue until resolved.", difficulty: "Medium" },
      { id: "founder-t2", title: "Top-3 Priority Lock", rule: "Finalize and execute top 3 priorities before noon.", schedule: "Daily 12:00", enforcement: "Postpone chains tracked; dashboard flags chronic reprioritization.", difficulty: "Medium" },
      { id: "founder-t3", title: "Fundraising Follow-up SLA", rule: "Respond to investor actions within 24 hours.", schedule: "Daily rolling deadline", enforcement: "Ignore/postpone history recorded with reminder escalation.", difficulty: "High" },
      { id: "founder-t4", title: "Hiring Pipeline Review", rule: "Process candidate stages twice weekly.", schedule: "Tue/Thu 16:00", enforcement: "Missed review becomes explicit overdue item.", difficulty: "Low" },
      { id: "founder-t5", title: "Revenue Risk Sweep", rule: "Review top churn-risk accounts and assign next action.", schedule: "Wednesday 15:00", enforcement: "Incomplete review logged and surfaced in weekly analytics.", difficulty: "Medium" },
      { id: "founder-t6", title: "Decision Closure", rule: "Every strategic decision must end in complete/postpone/ignore state by day end.", schedule: "Daily 20:00", enforcement: "Unresolved decisions roll to debt queue with required resolution.", difficulty: "High" },
      { id: "founder-t7", title: "Weekly Integrity Review", rule: "Review negotiation chains and streak breaks every Friday.", schedule: "Friday 18:00", enforcement: "Skipped review is logged; no weekly reset.", difficulty: "Low" },
      { id: "founder-t8", title: "Batch Creation Discipline", rule: "Use /bulk only after analytics review.", schedule: "Monday planning block", enforcement: "No review marker appears in dashboard if bypassed.", difficulty: "Medium" }
    ]
  },
  fitness: {
    slug: "fitness",
    badge: "PACT for fitness discipline",
    heroTitle: "Fitness consistency when excuses sound reasonable in the moment.",
    heroSubheadline:
      "Not motivation. Enforcement. Permanent history. No reset. Negotiation is data: snooze/postpone/ignore are recorded. Dashboard exposes patterns you can’t argue with.",
    heroTrust: ["No motivational feed", "Permanent training accountability log", "Start in Telegram. Connect dashboard in 2 minutes."],
    mirrorTitle: "Your training plan is not weak. Your negotiation loop is stronger.",
    mirrorBullets: ["One skipped session becomes a three-day slide.", "Postpone language hides avoidance.", "Weekly resets erase accountability memory."],
    mechanismTitle: "Discipline through state integrity",
    mechanismBlocks: [
      "Each workout or recovery action becomes a pact with deadline.",
      "You can complete, snooze, postpone, or ignore, but every decision is recorded permanently.",
      "Dashboard shows when discipline breaks: time bands, chain postpones, and streak integrity loss."
    ],
    scenes: [
      {
        id: "fitness-scene-1",
        title: "The 6am skip",
        hook: "You snoozed one session and called it recovery.",
        story:
          "By evening, training intent was gone. PACT records the snooze and forces explicit resolution instead of silent carryover.",
        pactDoes: ["Logs snooze with timestamp.", "Keeps missed session in overdue queue until resolved."],
        outcome: "Outcome: a skipped session becomes data, not denial."
      },
      {
        id: "fitness-scene-2",
        title: "The postpone chain",
        hook: "Morning moved to lunch, lunch moved to night, then disappeared.",
        story:
          "Postpone felt harmless each time. The chain proved otherwise. PACT surfaces repeated postpones and streak damage in the dashboard.",
        pactDoes: ["Captures postpone sequences.", "Highlights negotiation-heavy commitments in analytics."],
        outcome: "Outcome: you redesign schedule around reality, not optimism."
      },
      {
        id: "fitness-scene-3",
        title: "The clean Monday myth",
        hook: "You restarted every Monday and forgot Friday.",
        story:
          "Motivation spikes mask inconsistent execution. PACT keeps permanent history so each week starts with truth, not amnesia.",
        pactDoes: ["No reset timeline.", "Streak integrity and carryover debt visibility."],
        outcome: "Outcome: consistency improves because evidence accumulates."
      },
      {
        id: "fitness-scene-4",
        title: "The analytics wake-up",
        hook: "You thought you lacked discipline; actually you had predictable failure windows.",
        story:
          "Dashboard shows misses cluster after late workdays. You shift workout deadlines and reduce avoidable failures.",
        pactDoes: ["Pattern analytics by time-of-day.", "Repeat miss detection and reminder support."],
        outcome: "Outcome: fewer broken weeks, more stable execution."
      }
    ],
    proofTitle: "What accountability looks like in product",
    proofBullets: [
      "Bot timeline of complete/postpone/ignore decisions.",
      "Sample week training timeline with overdue resolution.",
      "Pattern analytics showing failure windows and streak integrity."
    ],
    featureTitle: "Discipline mechanics",
    features: [
      "Workout pacts with deadlines",
      "Automatic enforcement at deadline",
      "Snooze/postpone/ignore telemetry",
      "Permanent no-reset history",
      "Overdue debt queue",
      "Reminder escalation and required resolution",
      "Streak integrity tracking",
      "Pattern analytics dashboard"
    ],
    trialTitle: "Start 14-day trial and test your consistency with real logs",
    trialBullets: ["Cancel anytime.", "Full dashboard included.", "Built for execution, not inspiration."],
    faq: sharedFaq,
    finalClose: [
      "Discipline is not what you intend at 7am. It is what you execute at deadline.",
      "PACT records that truth and keeps it visible.",
      "Start in Telegram. Connect dashboard in 2 minutes."
    ],
    templates: [
      { id: "fitness-t1", title: "Morning Strength Pact", rule: "Complete 30-minute strength block before 08:00.", schedule: "Mon/Wed/Fri 08:00", enforcement: "Missed deadline logged; session enters overdue resolution queue.", difficulty: "Medium" },
      { id: "fitness-t2", title: "Cardio Baseline", rule: "Complete 20-minute cardio session.", schedule: "Tue/Thu 19:00", enforcement: "Postpone/ignore tracked with reminder escalation.", difficulty: "Low" },
      { id: "fitness-t3", title: "Mobility Recovery", rule: "Run mobility protocol after training day.", schedule: "Training days 21:00", enforcement: "Unresolved recovery pact appears in carryover debt queue.", difficulty: "Low" },
      { id: "fitness-t4", title: "Sleep Cutoff", rule: "Start wind-down and stop screens by cutoff.", schedule: "Daily 22:30", enforcement: "Ignore state logged and reflected in streak integrity.", difficulty: "Medium" },
      { id: "fitness-t5", title: "Nutrition Prep Block", rule: "Prepare next-day meals before 20:00.", schedule: "Sun-Thu 20:00", enforcement: "Miss is logged and flagged in weekly pattern analytics.", difficulty: "Medium" },
      { id: "fitness-t6", title: "Weekly Review", rule: "Review training week in dashboard and adjust next week pacts.", schedule: "Sunday 18:00", enforcement: "Skipped review remains recorded; no timeline reset.", difficulty: "Low" },
      { id: "fitness-t7", title: "Snooze Limit Pact", rule: "Limit workout snoozes to one per session.", schedule: "All workout pacts", enforcement: "Excess snoozes marked as negotiation chain in analytics.", difficulty: "High" },
      { id: "fitness-t8", title: "Bulk Planning Discipline", rule: "Use /bulk to schedule next week sessions only after weekly review.", schedule: "Sunday planning", enforcement: "Dashboard flags planning-without-review pattern.", difficulty: "Medium" }
    ]
  }
};

