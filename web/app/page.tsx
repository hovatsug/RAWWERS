import Link from "next/link";
import { Badge, Button, Card } from "@/design-system/primitives";

export default function LandingPage() {
  return (
    <div className="space-y-4">
      <Badge>RAWWERS v1</Badge>
      <h1 className="text-2xl font-semibold">Mobile-first creator marketplace</h1>
      <Card className="space-y-3">
        <p className="text-sm text-neutral-600">Discovery, bookings, payments, proofs, extras, and delivery.</p>
        <div className="flex gap-2">
          <Link href="/discover"><Button>Discover Pros</Button></Link>
          <Link href="/login"><Button className="bg-neutral-700">Login</Button></Link>
        </div>
      </Card>
    </div>
  );
}
