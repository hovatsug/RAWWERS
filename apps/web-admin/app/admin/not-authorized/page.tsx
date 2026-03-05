import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";

export default function NotAuthorizedPage() {
  return (
    <div>
      <PageHeader title="Not authorized" subtitle="Your account does not have admin access." />
      <SectionCard>Contact a system administrator to request admin permissions.</SectionCard>
    </div>
  );
}
