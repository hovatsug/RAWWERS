"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { listInviteWaves, createInviteWave, generateInviteWaveCodes, listInviteCodes, revokeInviteCode } from "@/api/routes/adminInvites";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { Button } from "@/components/forms/Button";
import { Input } from "@/components/forms/Input";
import { ListPage } from "@/components/shared/ListPage";

export default function InvitesPage() {
  const queryClient = useQueryClient();
  const waves = useQuery({ queryKey: ["admin", "invite-waves"], queryFn: listInviteWaves });
  const [waveName, setWaveName] = useState("");
  const create = useMutation({ mutationFn: () => createInviteWave({ name: waveName }), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "invite-waves"] }) });
  const generate = useMutation({ mutationFn: (waveId: string) => generateInviteWaveCodes(waveId), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "invite-codes"] }) });
  const revoke = useMutation({ mutationFn: (code: string) => revokeInviteCode(code), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "invite-codes"] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Invites" subtitle="Manage invite waves and code lifecycle." />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Waves</h3>
        <div className="mb-3 flex gap-2">
          <Input placeholder="Wave name" value={waveName} onChange={(e) => setWaveName(e.target.value)} />
          <Button onClick={() => create.mutate()}>Create Wave</Button>
        </div>
        <div className="space-y-2">
          {(Array.isArray(waves.data) ? waves.data : (waves.data as any)?.items || []).map((wave: any) => (
            <div key={wave.wave_id || wave.id} className="flex items-center justify-between rounded-xl border border-borderSubtle p-3">
              <span>{wave.name || wave.wave_id || wave.id}</span>
              <Button variant="secondary" onClick={() => generate.mutate(String(wave.wave_id || wave.id))}>Generate Codes</Button>
            </div>
          ))}
        </div>
      </SectionCard>
      <ListPage
        queryKey={["admin", "invite-codes"]}
        queryFn={listInviteCodes}
        columns={[
          { key: "code", title: "Code", render: (r: any) => r.code || r.id || "-" },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          { key: "actions", title: "", render: (r: any) => <Button variant="danger" onClick={(e) => { e.stopPropagation(); revoke.mutate(String(r.code || r.id)); }}>Revoke</Button> }
        ]}
      />
    </div>
  );
}
