import { Card } from "@/design-system/primitives";

const FEATURES = [
  "Commitment contracts",
  "Snooze/Postpone/Ignore telemetry",
  "Consequences engine",
  "Permanent audit trail",
  "Reputation and streak integrity",
  "Pattern analytics",
  "Teams-ready architecture"
];

export function FeatureGrid() {
  return (
    <div className="grid gap-3 sm:grid-cols-2">
      {FEATURES.map((feature) => (
        <Card key={feature} className="border border-neutral-200 p-5">
          <h3 className="text-base font-semibold text-neutral-900">{feature}</h3>
        </Card>
      ))}
    </div>
  );
}

