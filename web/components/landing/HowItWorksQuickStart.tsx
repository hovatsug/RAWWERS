import { Card } from "@/design-system/primitives";
import { Accordion } from "@/components/landing/Accordion";

const STEPS = [
  {
    step: "Step 1",
    title: "Start bot",
    text: "Open Telegram and press Start. This creates your command channel."
  },
  {
    step: "Step 2",
    title: "Generate code in web settings",
    text: "Open the dashboard settings and generate your one-time link code."
  },
  {
    step: "Step 3",
    title: "/link CODE in Telegram",
    text: "Return to Telegram and run /link CODE to bind bot + dashboard."
  }
];

export function HowItWorksQuickStart() {
  return (
    <div className="space-y-4">
      <div className="grid gap-3 md:grid-cols-3">
        {STEPS.map((item) => (
          <Card key={item.step} className="space-y-2 border border-neutral-200 p-5">
            <p className="text-xs font-semibold uppercase tracking-[0.12em] text-brand-700">{item.step}</p>
            <h3 className="text-lg font-semibold text-neutral-900">{item.title}</h3>
            <p className="text-sm text-neutral-700">{item.text}</p>
          </Card>
        ))}
      </div>

      <Accordion
        items={[
          {
            id: "detailed-setup",
            title: "Show the full setup",
            content: [
              "After linking, create a pact in the dashboard for full config and review.",
              "Or create directly in Telegram with /create.",
              "For multiple commitments at once, use /bulk.",
              "Use dashboard analytics to inspect postpone/ignore behavior over time."
            ]
          }
        ]}
      />
    </div>
  );
}
