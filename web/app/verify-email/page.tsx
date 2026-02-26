import { Card } from "@/design-system/primitives";

export default function VerifyEmailPage() {
  return (
    <Card>
      <h1 className="text-xl font-semibold">Verify email</h1>
      <p className="mt-2 text-sm text-neutral-600">Use the code from your email in the mobile app or backend auth endpoint.</p>
    </Card>
  );
}
