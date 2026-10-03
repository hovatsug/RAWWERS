"use client";

import Link from "next/link";
import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type GearQueueRow } from "@/lib/api/admin";
import {
  AdminButton,
  ConfirmDialog,
  DataTable,
  FieldLabel,
  PageHeader,
  SelectField,
  StatusBadge,
  type Column
} from "@/app/admin/_components/ui";

/**
 * Gear a machine could not decide.
 *
 * Three things end up here, and the row says which: a camera model that is not
 * in the reference list, a body that publishes no serial number (every Sony
 * tried, so expect these), and a lens whose aperture the file did not state.
 * Everything else was verified or rejected on upload and never reaches this
 * queue.
 *
 * Approving has to leave a row that satisfies the floor, so only the answers
 * that do are offered: full-frame for a body, a prime or fixed-aperture zoom
 * for a lens. Anything else is a rejection, and needs a reason the
 * photographer will read. Both go through a confirmation.
 */
export default function AdminGearPage() {
  const queryClient = useQueryClient();
  const [approving, setApproving] = useState<GearQueueRow | null>(null);
  const [rejecting, setRejecting] = useState<GearQueueRow | null>(null);

  const query = useQuery({ queryKey: ["admin", "gear-queue"], queryFn: () => admin.gearQueue() });
  const items = query.data?.ok ? query.data.data.items : undefined;
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "gear-queue"] });

  const columns: Column<GearQueueRow>[] = [
    {
      header: "Item",
      cell: (row) => (
        <div className="space-y-1">
          <StatusBadge label={CATEGORY_LABEL[row.category]} tone="info" />
          <p className="font-medium text-slate-50">{[row.make, row.model].filter(Boolean).join(" ") || "Unnamed"}</p>
        </div>
      )
    },
    {
      header: "Photographer",
      cell: (row) => (
        <Link href={`/admin/pros/${row.pro_user_id}`} className="hover:underline">
          {row.pro_display_name || "Photographer"}
        </Link>
      )
    },
    {
      // Why it is here, in the words the machine gave.
      header: "Why it needs you",
      cell: (row) => <span className="text-amber-200">{row.review_reason}</span>
    },
    {
      header: "Details",
      cell: (row) => (
        <div className="space-y-1 text-xs text-slate-400">
          <p>{row.serial_number ? `Serial ${row.serial_number}` : "No serial number published"}</p>
          {focal(row) || row.max_aperture ? (
            <p>
              {[focal(row), row.max_aperture ? `f/${row.max_aperture}` : null].filter(Boolean).join(" · ")}
            </p>
          ) : null}
          {row.evidence_url ? (
            <a href={row.evidence_url} className="text-violet-300 hover:underline">
              Open the file (link expires in five minutes)
            </a>
          ) : null}
        </div>
      )
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) => (
        <div className="flex justify-end gap-2">
          <AdminButton onClick={() => setApproving(row)}>Approve…</AdminButton>
          <AdminButton tone="secondary" onClick={() => setRejecting(row)}>
            Reject…
          </AdminButton>
        </div>
      )
    }
  ];

  return (
    <>
      <PageHeader
        title="Gear awaiting review"
        description={
          items === undefined
            ? "Gear the machine could not decide on its own."
            : items.length === 0
              ? "Nothing waiting."
              : `${items.length} waiting on a decision, oldest first.`
        }
      />
      <DataTable
        columns={columns}
        rows={items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "Queue is clear", body: "Items appear here when a file's gear could not be decided automatically." }}
      />

      {approving ? <ApproveDialog row={approving} onClose={() => setApproving(null)} onDone={refresh} /> : null}

      <ConfirmDialog
        open={rejecting !== null}
        title={`Reject ${rejecting ? describe(rejecting) : ""}?`}
        confirmLabel="Reject"
        tone="danger"
        reason={{ label: "Reason — the photographer reads this", placeholder: "e.g. This lens is not a fixed-aperture zoom" }}
        onClose={() => setRejecting(null)}
        onConfirm={async (reason) => {
          if (!rejecting) return null;
          const res = await admin.rejectGear(rejecting.id, reason);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        <p>It will not count towards their verified gear. They see your reason and can submit another file.</p>
      </ConfirmDialog>
    </>
  );
}

function ApproveDialog({ row, onClose, onDone }: { row: GearQueueRow; onClose: () => void; onDone: () => void }) {
  const isBody = row.category === "camera_body";
  const [sensor, setSensor] = useState<string>(row.sensor_size ?? "");
  const [aperture, setAperture] = useState<string>(row.aperture_type ?? "");
  const [teach, setTeach] = useState(false);
  // The one field the machine could not fill in must be filled in here.
  const answered = isBody ? sensor !== "" : aperture !== "";

  return (
    <ConfirmDialog
      open
      title={`Approve ${describe(row)}?`}
      confirmLabel="Approve"
      canConfirm={answered}
      onClose={onClose}
      onConfirm={async () => {
        const res = await admin.approveGear(row.id, {
          ...(isBody ? { sensor_size: sensor as "full_frame" } : { aperture_type: aperture as "prime" | "fixed_zoom" }),
          add_to_reference: teach
        });
        if (!res.ok) return res.error.message;
        onDone();
        return null;
      }}
    >
      <p>It counts as verified gear for {row.pro_display_name || "this photographer"}.</p>
      <div>
        <FieldLabel htmlFor="gear-answer">{isBody ? "Sensor size" : "Lens type"}</FieldLabel>
        {isBody ? (
          <SelectField id="gear-answer" value={sensor} onChange={(e) => setSensor(e.target.value)}>
            <option value="">Choose…</option>
            <option value="full_frame">Full frame</option>
          </SelectField>
        ) : (
          <SelectField id="gear-answer" value={aperture} onChange={(e) => setAperture(e.target.value)}>
            <option value="">Choose…</option>
            <option value="prime">Prime</option>
            <option value="fixed_zoom">Zoom, fixed maximum aperture</option>
          </SelectField>
        )}
        {!answered ? (
          <p className="mt-1 text-xs text-slate-500">
            {isBody ? "This model is not in the reference list: choose its sensor size." : "The file did not state the aperture: choose the lens type."}
          </p>
        ) : null}
      </div>
      <label className="flex items-center gap-2 text-sm text-slate-300">
        <input type="checkbox" checked={teach} onChange={(e) => setTeach(e.target.checked)} />
        Add this model to the reference list, so the next one is verified automatically
      </label>
    </ConfirmDialog>
  );
}

const CATEGORY_LABEL: Record<GearQueueRow["category"], string> = {
  camera_body: "Camera body",
  lens: "Lens",
  lighting: "Lighting"
};

function describe(row: GearQueueRow): string {
  return [row.make, row.model].filter(Boolean).join(" ") || CATEGORY_LABEL[row.category].toLowerCase();
}

function focal(row: GearQueueRow): string | null {
  if (!row.min_focal_mm || !row.max_focal_mm) return null;
  return row.min_focal_mm === row.max_focal_mm ? `${row.min_focal_mm} mm` : `${row.min_focal_mm}–${row.max_focal_mm} mm`;
}
