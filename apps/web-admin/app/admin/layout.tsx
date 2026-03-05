import { PropsWithChildren } from "react";
import { AdminGate } from "@/core/auth/AdminGate";
import { Sidebar } from "@/components/layout/Sidebar";
import { Topbar } from "@/components/layout/Topbar";

export default function AdminLayout({ children }: PropsWithChildren) {
  return (
    <AdminGate>
      <div className="flex min-h-screen bg-bg">
        <Sidebar />
        <div className="min-w-0 flex-1">
          <Topbar />
          <main className="p-6">{children}</main>
        </div>
      </div>
    </AdminGate>
  );
}
