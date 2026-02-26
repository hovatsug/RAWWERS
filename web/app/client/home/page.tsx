import Link from "next/link";
import { Card } from "@/design-system/primitives";

export default function ClientHomePage() {
  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Client Home</h1>
      <Card><Link href="/discover">Discover pros</Link></Card>
      <Card><Link href="/client/bookings">My bookings</Link></Card>
      <Card><Link href="/client/notifications">Notifications</Link></Card>
    </div>
  );
}
