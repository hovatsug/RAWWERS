import Link from "next/link";
import { EmptyState } from "@/design-system/primitives";

export default function NotFound() {
  return (
    <div className="space-y-3">
      <EmptyState title="Page not found" body="The route does not exist." />
      <Link href="/">Go home</Link>
    </div>
  );
}
