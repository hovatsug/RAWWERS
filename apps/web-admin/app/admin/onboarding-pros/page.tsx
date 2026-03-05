"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
  listOnboardingPros,
  approveOnboardingPro,
  rejectOnboardingPro,
  setOnboardingProStatus,
  updateProKyc
} from "@/api/routes/adminOnboardingPros";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";

export default function OnboardingProsPage() {
  const queryClient = useQueryClient();
  const [kycUserId, setKycUserId] = useState("");
  const [kycStatus, setKycStatus] = useState("approved");
  const [kycOpen, setKycOpen] = useState(false);

  const approve = useMutation({ mutationFn: (id: string) => approveOnboardingPro(id), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "onboarding-pros"] }) });
  const reject = useMutation({ mutationFn: (id: string) => rejectOnboardingPro(id), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "onboarding-pros"] }) });
  const setStatus = useMutation({ mutationFn: ({ id, status }: { id: string; status: string }) => setOnboardingProStatus(id, { status }), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "onboarding-pros"] }) });
  const kyc = useMutation({ mutationFn: () => updateProKyc(kycUserId, { status: kycStatus }), onSuccess: () => setKycOpen(false) });

  return (
    <div className="space-y-4">
      <PageHeader title="Onboarding Pros" subtitle="KYC and onboarding approvals" />
      <ListPage
        queryKey={["admin", "onboarding-pros"]}
        queryFn={listOnboardingPros}
        columns={[
          { key: "id", title: "Pro User", render: (r: any) => String(r.pro_user_id || r.user_id || r.id || "-") },
          { key: "stage", title: "Stage", render: (r: any) => r.stage || r.status || "-" },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => {
              const id = String(r.pro_user_id || r.user_id || r.id);
              return (
                <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                  <Button onClick={() => approve.mutate(id)}>Approve</Button>
                  <Button variant="secondary" onClick={() => reject.mutate(id)}>Reject</Button>
                  <Button variant="secondary" onClick={() => setStatus.mutate({ id, status: "in_review" })}>Set Status</Button>
                  <Button variant="secondary" onClick={() => { setKycUserId(id); setKycOpen(true); }}>KYC</Button>
                </div>
              );
            }
          }
        ]}
      />
      <Modal open={kycOpen} onClose={() => setKycOpen(false)} title="Update KYC">
        <div className="space-y-3">
          <Input value={kycUserId} readOnly />
          <Input value={kycStatus} onChange={(e) => setKycStatus(e.target.value)} placeholder="approved/rejected" />
          <Button onClick={() => kyc.mutate()} loading={kyc.isPending}>Save KYC</Button>
        </div>
      </Modal>
    </div>
  );
}
