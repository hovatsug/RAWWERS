"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getRepairPartners,
  createRepairPartner,
  updateRepairPartner,
  setRepairPartnerActive,
  recomputeRepairPartnerScore,
  getRepairPolicy,
  updateRepairPolicy,
  listRepairTickets,
  assignRepairTicketPartner,
  setRepairTicketQuote,
  setRepairTicketStatus,
  listRepairLoaners,
  setRepairLoanerStatus,
  setRepairOverride
} from "@/api/routes/adminRepairs";
import { PageHeader } from "@/components/layout/PageHeader";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { ListPage } from "@/components/shared/ListPage";

export default function RepairsPage() {
  const queryClient = useQueryClient();
  const [partnerId, setPartnerId] = useState("");
  const [ticketId, setTicketId] = useState("");
  const [loanerId, setLoanerId] = useState("");
  const [proUserId, setProUserId] = useState("");
  const [payload, setPayload] = useState("{}");

  const partners = useQuery({ queryKey: ["admin", "repairs-partners"], queryFn: getRepairPartners });
  const policy = useQuery({ queryKey: ["admin", "repairs-policy"], queryFn: getRepairPolicy });

  const cPartner = useMutation({ mutationFn: () => createRepairPartner(JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "repairs-partners"] }) });
  const uPartner = useMutation({ mutationFn: () => updateRepairPartner(partnerId, JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "repairs-partners"] }) });
  const pActive = useMutation({ mutationFn: () => setRepairPartnerActive(partnerId, JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "repairs-partners"] }) });
  const pScore = useMutation({ mutationFn: () => recomputeRepairPartnerScore(partnerId), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "repairs-partners"] }) });
  const tAssign = useMutation({ mutationFn: () => assignRepairTicketPartner(ticketId, JSON.parse(payload || "{}")) });
  const tQuote = useMutation({ mutationFn: () => setRepairTicketQuote(ticketId, JSON.parse(payload || "{}")) });
  const tStatus = useMutation({ mutationFn: () => setRepairTicketStatus(ticketId, JSON.parse(payload || "{}")) });
  const lStatus = useMutation({ mutationFn: () => setRepairLoanerStatus(loanerId, JSON.parse(payload || "{}")) });
  const override = useMutation({ mutationFn: () => setRepairOverride(proUserId, JSON.parse(payload || "{}")) });

  return (
    <div className="space-y-4">
      <PageHeader title="Repairs" subtitle="Partners, policies, tickets, loaners and overrides." />
      <SectionCard><h3 className="mb-3 font-semibold">Partners</h3><CodeBlock value={partners.data || {}} /></SectionCard>
      <JsonEditorCard title="Repairs Policy" value={policy.data || {}} onSave={updateRepairPolicy} />
      <ListPage queryKey={["admin", "repairs-tickets"]} queryFn={listRepairTickets} columns={[{ key: "ticket", title: "Ticket", render: (r: any) => String(r.ticket_id || r.id || "-") }, { key: "status", title: "Status", render: (r: any) => r.status || "-" }, { key: "partner", title: "Partner", render: (r: any) => String(r.partner_id || "-") }]} />
      <ListPage queryKey={["admin", "repairs-loaners"]} queryFn={listRepairLoaners} columns={[{ key: "loaner", title: "Loaner Request", render: (r: any) => String(r.loaner_request_id || r.id || "-") }, { key: "status", title: "Status", render: (r: any) => r.status || "-" }]} />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Quick Actions</h3>
        <div className="space-y-2">
          <Input placeholder="Partner ID" value={partnerId} onChange={(e) => setPartnerId(e.target.value)} />
          <Input placeholder="Ticket ID" value={ticketId} onChange={(e) => setTicketId(e.target.value)} />
          <Input placeholder="Loaner Request ID" value={loanerId} onChange={(e) => setLoanerId(e.target.value)} />
          <Input placeholder="Pro user ID" value={proUserId} onChange={(e) => setProUserId(e.target.value)} />
          <Input placeholder='JSON payload' value={payload} onChange={(e) => setPayload(e.target.value)} />
        </div>
        <div className="mt-3 flex flex-wrap gap-2">
          <Button onClick={() => cPartner.mutate()}>Create Partner</Button>
          <Button onClick={() => uPartner.mutate()}>Update Partner</Button>
          <Button onClick={() => pActive.mutate()}>Set Active</Button>
          <Button onClick={() => pScore.mutate()}>Recompute Score</Button>
          <Button onClick={() => tAssign.mutate()}>Assign Ticket Partner</Button>
          <Button onClick={() => tQuote.mutate()}>Set Ticket Quote</Button>
          <Button onClick={() => tStatus.mutate()}>Set Ticket Status</Button>
          <Button onClick={() => lStatus.mutate()}>Set Loaner Status</Button>
          <Button onClick={() => override.mutate()}>Set Override</Button>
        </div>
      </SectionCard>
    </div>
  );
}
