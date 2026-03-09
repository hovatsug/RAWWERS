import { Button, Card } from "@/design-system/primitives";

export default function ProGigPublishPage() {
  return (
    <Card className="space-y-3">
      <h1 className="text-xl font-semibold">Publish proofs</h1>
      <p className="text-sm text-neutral-600">Review set, included count, and publish gallery to client.</p>
      <Button>Publish gallery</Button>
    </Card>
  );
}
