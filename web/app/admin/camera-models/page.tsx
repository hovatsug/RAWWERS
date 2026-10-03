"use client";

import { useMemo, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
  admin,
  type CameraImportResult,
  type CameraModelList,
  type CameraModelRow,
  type SensorSize
} from "@/lib/api/admin";
import {
  AdminButton,
  ConfirmDialog,
  DataTable,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextArea,
  TextField,
  type Column,
  type Tone
} from "@/app/admin/_components/ui";

/**
 * Which camera bodies are full-frame.
 *
 * This list decides, on upload, whether a photographer's camera is verified
 * with nobody looking, refused with the reason, or sent to the gear queue for
 * a person. A body that is not listed always goes to the queue - so an empty
 * list breaks nothing visibly and verifies nobody, which is the state a new
 * database starts in.
 *
 * "Download CSV" and "Import CSV" use the same columns, so a list can be
 * taken from one database and loaded into another.
 */

const SENSOR: Record<SensorSize, { label: string; tone: Tone; effect: string }> = {
  full_frame: { label: "Full frame", tone: "positive", effect: "verified automatically" },
  crop: { label: "Crop", tone: "neutral", effect: "refused, with the reason that only full-frame qualifies" },
  medium_format: { label: "Medium format", tone: "info", effect: "refused, with the reason that only full-frame qualifies" }
};

const QUERY_KEY = ["admin", "camera-models"];

/** The same key the server builds, so the search finds "ILCE-7M4" from "ilce 7m4". */
const normalise = (value: string) => value.toLowerCase().replace(/[^a-z0-9]/g, "");

export default function AdminCameraModelsPage() {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState("");
  const [sensor, setSensor] = useState<"" | SensorSize>("");
  const [adding, setAdding] = useState(false);
  const [editing, setEditing] = useState<CameraModelRow | null>(null);
  const [importing, setImporting] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

  const query = useQuery({ queryKey: QUERY_KEY, queryFn: () => admin.cameraModels() });
  const list: CameraModelList | undefined = query.data?.ok ? query.data.data : undefined;
  const refresh = () => queryClient.invalidateQueries({ queryKey: QUERY_KEY });

  const rows = useMemo(() => {
    if (!list) return undefined;
    const text = search.trim().toLowerCase();
    const key = normalise(search);
    return list.items.filter(
      (row) =>
        (sensor === "" || row.sensor_size === sensor) &&
        (text === "" ||
          row.display_name.toLowerCase().includes(text) ||
          (row.make ?? "").toLowerCase().includes(text) ||
          (key !== "" && row.normalised_model.includes(key)))
    );
  }, [list, search, sensor]);

  const columns: Column<CameraModelRow>[] = [
    {
      header: "Model",
      cell: (row) => (
        <div>
          <p className="font-medium text-slate-50">{row.display_name}</p>
          <p className="font-mono text-xs text-slate-500" title="What a file's model is matched against">
            {row.normalised_model}
          </p>
        </div>
      )
    },
    { header: "Make", cell: (row) => row.make ?? <span className="text-slate-500">—</span> },
    {
      header: "Sensor",
      cell: (row) => <StatusBadge label={SENSOR[row.sensor_size].label} tone={SENSOR[row.sensor_size].tone} />
    },
    {
      header: "Updated",
      className: "whitespace-nowrap text-xs text-slate-400",
      cell: (row) => new Date(row.updated_at).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) => (
        <AdminButton tone="secondary" onClick={() => setEditing(row)}>
          Edit…
        </AdminButton>
      )
    }
  ];

  return (
    <>
      <PageHeader
        title="Camera reference"
        description={
          list === undefined
            ? "Which bodies are full-frame. Decides whether a photographer's camera verifies on upload."
            : `${list.total} model${list.total === 1 ? "" : "s"}, ${list.full_frame} full-frame. A body that is not listed goes to the gear queue.`
        }
        actions={
          <>
            <AdminButton tone="secondary" disabled={!list || list.total === 0} onClick={() => list && downloadCsv(list.items)}>
              Download CSV
            </AdminButton>
            <AdminButton tone="secondary" onClick={() => setImporting((open) => !open)}>
              Import CSV…
            </AdminButton>
            <AdminButton onClick={() => setAdding(true)}>Add model…</AdminButton>
          </>
        }
      />

      {list && list.full_frame === 0 ? (
        <div className="mb-4">
          <Notice tone="warning">
            {list.total === 0 ? "The list is empty" : "No body is listed as full-frame"}, so no camera is verified automatically: every
            submission waits in the gear queue for a person. Import the list to fix this.
          </Notice>
        </div>
      ) : null}
      {notice ? (
        <div className="mb-4">
          <Notice tone="success">{notice}</Notice>
        </div>
      ) : null}

      {importing ? (
        <ImportPanel
          onClose={() => setImporting(false)}
          onDone={(message) => {
            setImporting(false);
            setNotice(message);
            refresh();
          }}
        />
      ) : null}

      <div className="mb-3 flex flex-wrap gap-2">
        <div className="w-full max-w-xs">
          <TextField
            aria-label="Search models"
            placeholder="Search: A7 IV, ILCE-7M4, Canon…"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />
        </div>
        <div className="w-44">
          <SelectField aria-label="Sensor size" value={sensor} onChange={(event) => setSensor(event.target.value as "" | SensorSize)}>
            <option value="">All sensor sizes</option>
            <option value="full_frame">Full frame</option>
            <option value="crop">Crop</option>
            <option value="medium_format">Medium format</option>
          </SelectField>
        </div>
      </div>

      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.normalised_model}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={
          list && list.total > 0
            ? { title: "No matches", body: "Nothing in the list matches that search." }
            : { title: "No models listed", body: "Import a CSV, or add models one at a time." }
        }
      />

      {adding ? (
        <AddDialog
          onClose={() => setAdding(false)}
          onDone={(row) => {
            setNotice(`Added ${row.display_name}.`);
            refresh();
          }}
        />
      ) : null}
      {editing ? (
        <EditDialog
          row={editing}
          onClose={() => setEditing(null)}
          onDone={(row) => {
            setNotice(`Saved ${row.display_name}.`);
            refresh();
          }}
        />
      ) : null}
    </>
  );
}

function AddDialog({ onClose, onDone }: { onClose: () => void; onDone: (row: CameraModelRow) => void }) {
  const [model, setModel] = useState("");
  const [make, setMake] = useState("");
  const [name, setName] = useState("");
  const [sensor, setSensor] = useState<"" | SensorSize>("");

  return (
    <ConfirmDialog
      open
      title="Add a camera model"
      confirmLabel="Add model"
      canConfirm={normalise(model) !== "" && sensor !== ""}
      onClose={onClose}
      onConfirm={async () => {
        const res = await admin.addCameraModel({
          model: model.trim(),
          make: make.trim() || null,
          display_name: name.trim() || null,
          sensor_size: sensor as SensorSize
        });
        if (!res.ok) return res.error.message;
        onDone(res.data);
        return null;
      }}
    >
      <div>
        <FieldLabel htmlFor="camera-model">Model, as the camera writes it</FieldLabel>
        <TextField id="camera-model" value={model} placeholder="e.g. ILCE-7M4" onChange={(e) => setModel(e.target.value)} />
        <p className="mt-1 text-xs text-slate-500">
          The Model field of a file from this camera. Spacing, dashes and capitals do not matter.
        </p>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <FieldLabel htmlFor="camera-make">Make</FieldLabel>
          <TextField id="camera-make" value={make} placeholder="Sony" onChange={(e) => setMake(e.target.value)} />
        </div>
        <div>
          <FieldLabel htmlFor="camera-name">Name people know</FieldLabel>
          <TextField id="camera-name" value={name} placeholder="Sony A7 IV" onChange={(e) => setName(e.target.value)} />
        </div>
      </div>
      <div>
        <FieldLabel htmlFor="camera-sensor">Sensor size</FieldLabel>
        <SelectField id="camera-sensor" value={sensor} onChange={(e) => setSensor(e.target.value as "" | SensorSize)}>
          <option value="">Choose…</option>
          <option value="full_frame">Full frame</option>
          <option value="crop">Crop</option>
          <option value="medium_format">Medium format</option>
        </SelectField>
      </div>
      {sensor ? <p>From now on, a file from this camera is {SENSOR[sensor].effect}.</p> : null}
    </ConfirmDialog>
  );
}

function EditDialog({ row, onClose, onDone }: { row: CameraModelRow; onClose: () => void; onDone: (row: CameraModelRow) => void }) {
  const [make, setMake] = useState(row.make ?? "");
  const [name, setName] = useState(row.display_name);
  const [sensor, setSensor] = useState<SensorSize>(row.sensor_size);
  const sensorChanged = sensor !== row.sensor_size;
  const changed = sensorChanged || name.trim() !== row.display_name || (make.trim() || null) !== row.make;

  return (
    <ConfirmDialog
      open
      title={`Edit ${row.display_name}`}
      confirmLabel="Save"
      tone={sensorChanged ? "danger" : "primary"}
      canConfirm={changed && name.trim() !== ""}
      reason={sensorChanged ? { label: "Reason — kept in the audit log", placeholder: "e.g. This body is APS-C, not full-frame" } : undefined}
      onClose={onClose}
      onConfirm={async (reason) => {
        const res = await admin.editCameraModel(row.normalised_model, {
          make: make.trim() || null,
          display_name: name.trim(),
          sensor_size: sensor,
          reason: reason || null
        });
        if (!res.ok) return res.error.message;
        onDone(res.data);
        return null;
      }}
    >
      <p className="font-mono text-xs text-slate-500">{row.normalised_model}</p>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <FieldLabel htmlFor="edit-make">Make</FieldLabel>
          <TextField id="edit-make" value={make} onChange={(e) => setMake(e.target.value)} />
        </div>
        <div>
          <FieldLabel htmlFor="edit-name">Name people know</FieldLabel>
          <TextField id="edit-name" value={name} onChange={(e) => setName(e.target.value)} />
        </div>
      </div>
      <div>
        <FieldLabel htmlFor="edit-sensor">Sensor size</FieldLabel>
        <SelectField id="edit-sensor" value={sensor} onChange={(e) => setSensor(e.target.value as SensorSize)}>
          <option value="full_frame">Full frame</option>
          <option value="crop">Crop</option>
          <option value="medium_format">Medium format</option>
        </SelectField>
      </div>
      {sensorChanged ? (
        <Notice tone="warning">
          {SENSOR[row.sensor_size].label} → {SENSOR[sensor].label}. From now on a file from this camera is {SENSOR[sensor].effect}.
          Gear already verified or refused is not decided again.
        </Notice>
      ) : null}
    </ConfirmDialog>
  );
}

/**
 * Two steps, so nothing is written until the admin has seen what will change:
 * the server checks the whole file and reports it row by row, and only a
 * clean file can then be imported - all of it, or none.
 */
function ImportPanel({ onClose, onDone }: { onClose: () => void; onDone: (message: string) => void }) {
  const [text, setText] = useState("");
  const [checking, setChecking] = useState(false);
  const [checkError, setCheckError] = useState<string | null>(null);
  const [plan, setPlan] = useState<CameraImportResult | null>(null);
  const [confirming, setConfirming] = useState(false);

  const check = async () => {
    setChecking(true);
    setCheckError(null);
    setPlan(null);
    const res = await admin.importCameraModels(text, false);
    setChecking(false);
    if (!res.ok) return setCheckError(res.error.message);
    setPlan(res.data);
  };

  const errors = plan?.lines.filter((line) => line.outcome === "error") ?? [];
  const updates = plan?.lines.filter((line) => line.outcome === "update") ?? [];
  const writes = plan ? plan.create + plan.update : 0;

  return (
    <Panel className="mb-4 space-y-3 p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm font-medium text-slate-100">Import a CSV</p>
          <p className="text-xs text-slate-500">
            Columns: <code>make</code>, <code>model</code>, <code>display_name</code>, <code>sensor_size</code> (
            <code>full_frame</code>, <code>crop</code> or <code>medium_format</code>). The same columns &ldquo;Download CSV&rdquo; writes.
          </p>
        </div>
        <AdminButton tone="quiet" onClick={onClose}>
          Close
        </AdminButton>
      </div>
      <input
        type="file"
        accept=".csv,text/csv"
        aria-label="CSV file"
        className="block text-xs text-slate-400 file:mr-3 file:rounded-md file:border-0 file:bg-white/[0.08] file:px-3 file:py-1.5 file:text-slate-200"
        onChange={async (event) => {
          const file = event.target.files?.[0];
          if (!file) return;
          setText(await file.text());
          setPlan(null);
        }}
      />
      <div>
        <FieldLabel htmlFor="import-text">Or paste it</FieldLabel>
        <TextArea
          id="import-text"
          rows={5}
          className="font-mono text-xs"
          value={text}
          placeholder={"make,model,display_name,sensor_size\nSony,ILCE-7M4,Sony A7 IV,full_frame"}
          onChange={(event) => {
            setText(event.target.value);
            setPlan(null);
          }}
        />
      </div>
      <AdminButton tone="secondary" disabled={text.trim() === "" || checking} onClick={check}>
        {checking ? "Checking…" : "Check file"}
      </AdminButton>
      {checkError ? <Notice tone="error">{checkError}</Notice> : null}

      {plan ? (
        <div className="space-y-3">
          <p className="text-sm text-slate-300">
            {plan.create} new · {plan.update} changed · {plan.unchanged} already the same
            {plan.errors ? ` · ${plan.errors} with problems` : ""}
          </p>
          {errors.length ? (
            <Notice tone="error">
              Nothing can be imported until these are fixed:
              <ul className="mt-1 space-y-0.5">
                {errors.map((line) => (
                  <li key={line.line}>
                    Line {line.line}
                    {line.model ? ` (${line.model})` : ""}: {line.error}
                  </li>
                ))}
              </ul>
            </Notice>
          ) : null}
          {updates.length ? (
            <div>
              <p className="mb-1 text-xs font-medium uppercase tracking-wide text-slate-500">Changes to models already listed</p>
              <ul className="max-h-48 space-y-1 overflow-y-auto rounded-lg border border-white/10 p-3 text-xs">
                {updates.map((line) => (
                  <li key={line.line} className="flex justify-between gap-3">
                    <span className="text-slate-300">{line.display_name}</span>
                    <span className={line.before?.sensor_size !== line.sensor_size ? "text-amber-300" : "text-slate-100"}>
                      {describeChange(line.before, line)}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
          <AdminButton disabled={errors.length > 0 || writes === 0} onClick={() => setConfirming(true)}>
            {writes === 0 ? "Nothing to import" : `Import ${writes} model${writes === 1 ? "" : "s"}…`}
          </AdminButton>
        </div>
      ) : null}

      <ConfirmDialog
        open={confirming && plan !== null}
        title={`Import ${writes} camera model${writes === 1 ? "" : "s"}?`}
        confirmLabel="Import"
        tone={plan?.changes_sensor_size ? "danger" : "primary"}
        reason={
          plan?.changes_sensor_size
            ? { label: "Reason — this changes sensor sizes already listed", placeholder: "e.g. Correcting rows imported wrong" }
            : undefined
        }
        onClose={() => setConfirming(false)}
        onConfirm={async (reason) => {
          const res = await admin.importCameraModels(text, true, reason || null);
          if (!res.ok) return res.error.message;
          onDone(`Imported: ${res.data.create} added, ${res.data.update} changed.`);
          return null;
        }}
      >
        <p>
          {plan?.create ?? 0} model{plan?.create === 1 ? "" : "s"} added and {plan?.update ?? 0} changed. Files from these cameras are
          decided by the new list from the next upload on; gear already decided is not decided again.
        </p>
      </ConfirmDialog>
    </Panel>
  );
}

function describeChange(
  before: { make: string | null; display_name: string; sensor_size: SensorSize } | null,
  after: { make: string | null; display_name: string; sensor_size: string | null }
): string {
  if (!before) return "";
  const parts: string[] = [];
  if (before.sensor_size !== after.sensor_size) {
    parts.push(`${SENSOR[before.sensor_size].label} → ${SENSOR[after.sensor_size as SensorSize]?.label ?? after.sensor_size}`);
  }
  if (before.display_name !== after.display_name) parts.push(`“${before.display_name}” → “${after.display_name}”`);
  if (before.make !== after.make) parts.push(`make ${before.make ?? "—"} → ${after.make ?? "—"}`);
  return parts.join(" · ");
}

/** The columns the import reads, so the file can be loaded into another database as it is. */
function downloadCsv(items: CameraModelRow[]) {
  const cell = (value: string | null) => {
    const text = value ?? "";
    return /[",\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
  };
  const lines = [
    "make,model,display_name,sensor_size",
    ...items.map((row) => [row.make, row.normalised_model, row.display_name, row.sensor_size].map(cell).join(","))
  ];
  const blob = new Blob([lines.join("\n") + "\n"], { type: "text/csv" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "camera-reference.csv";
  link.click();
  URL.revokeObjectURL(url);
}
