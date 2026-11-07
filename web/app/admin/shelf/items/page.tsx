"use client";

import { useEffect, useMemo, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type ShelfItem, type ShelfItemInput, type ShelfPriceHelper } from "@/lib/api/admin";
import {
  AdminButton,
  DataTable,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextArea,
  TextField,
  money,
  type Column
} from "@/app/admin/_components/ui";

/**
 * The Shelf's items. The RAWW price is typed here; the helper beside it only
 * advises: a suggested price (street price less the shelf discount, at the
 * settings' GBP rate, over the RAWW value), what the typed price is worth,
 * the supplier's cost in euros and the margin, and a warning - not a block -
 * when the price sits outside its level's band.
 *
 * Compatibility comes from the camera catalogue. An item with no cameras
 * fits everyone (cards, SSDs, lights, merch); one with cameras is shown only
 * to photographers who own one of them.
 */

const EMPTY: ShelfItemInput = {
  title: "",
  brand: "",
  category: "",
  description: "",
  image_url: "",
  level: 1,
  price_raww: 0,
  street_price: "",
  street_currency: "GBP",
  supplier_cost: "",
  supplier_currency: "GBP",
  supplier_name: "",
  supplier_sku: "",
  supplier_url: "",
  stock_status: "in_stock",
  active: false,
  camera_models: []
};

function normalise(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]/g, "");
}

export default function ShelfItemsPage() {
  const queryClient = useQueryClient();
  const items = useQuery({ queryKey: ["admin", "shelf", "items"], queryFn: () => admin.shelfItems() });
  const cameras = useQuery({ queryKey: ["admin", "camera-models"], queryFn: () => admin.cameraModels() });
  const [editing, setEditing] = useState<{ id: string | null; form: ShelfItemInput } | null>(null);
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);

  const rows = items.data?.ok ? items.data.data.items : undefined;
  const cameraNames = useMemo(() => {
    const list = cameras.data?.ok ? cameras.data.data.items : [];
    return new Map(list.map((c) => [c.normalised_model, c.display_name]));
  }, [cameras.data]);

  const columns: Column<ShelfItem>[] = [
    { header: "Level", className: "w-px tabular-nums", cell: (row) => row.level },
    {
      header: "",
      className: "w-px",
      cell: (row) =>
        row.images?.[0]?.small_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={row.images[0].small_url} alt="" className="h-12 w-12 rounded object-cover" />
        ) : (
          <div className="h-12 w-12 rounded bg-white/5" title="No cover yet" />
        )
    },
    {
      header: "Item",
      cell: (row) => (
        <div>
          <div className="font-medium">{row.title}</div>
          <div className="text-xs text-slate-400">
            {[row.brand, row.category, row.camera_models.length ? `${row.camera_models.length} cameras` : "fits everyone"].filter(Boolean).join(" · ")}
          </div>
        </div>
      )
    },
    {
      header: "Price",
      className: "whitespace-nowrap tabular-nums",
      cell: (row) => (
        <div>
          <div>{row.price_raww} RAWW</div>
          <div className="text-xs text-slate-400">{money(row.helper.price_eur)} · suggested {row.helper.suggested_price_raww}</div>
        </div>
      )
    },
    { header: "Margin", className: "whitespace-nowrap tabular-nums", cell: (row) => money(row.helper.margin_eur) },
    {
      header: "",
      cell: (row) => (
        <div className="flex flex-wrap gap-1">
          {row.helper.band_warning ? <StatusBadge label={row.helper.band_warning} tone="attention" /> : null}
          {row.stock_status !== "in_stock" ? <StatusBadge label="Out of stock" tone="negative" /> : null}
          {!row.active ? <StatusBadge label="Hidden" tone="neutral" /> : null}
        </div>
      )
    },
    {
      header: "",
      className: "w-px text-right",
      cell: (row) => (
        <AdminButton tone="secondary" onClick={() => setEditing({ id: row.id, form: { ...row } })}>
          Edit
        </AdminButton>
      )
    }
  ];

  const save = async () => {
    if (!editing) return;
    const body = { ...editing.form, price_raww: Number(editing.form.price_raww) };
    const res = editing.id ? await admin.updateShelfItem(editing.id, body) : await admin.createShelfItem(body);
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text: `Saved "${res.data.title}".` });
    setEditing(null);
    queryClient.invalidateQueries({ queryKey: ["admin", "shelf", "items"] });
  };

  return (
    <>
      <PageHeader title="Shelf items" description="What photographers can spend RAWW on. Prices are typed in RAWW; the helper advises." />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        {editing ? (
          <ItemForm
            value={editing.form}
            isNew={editing.id === null}
            cameraNames={cameraNames}
            onChange={(form) => setEditing({ ...editing, form })}
            onCancel={() => setEditing(null)}
            onSave={save}
          />
        ) : null}
        {editing?.id ? (
          <ShelfPhotos
            item={rows?.find((r) => r.id === editing.id)}
            onChanged={() => queryClient.invalidateQueries({ queryKey: ["admin", "shelf", "items"] })}
            onMessage={setMessage}
          />
        ) : null}
        {!editing ? (
          <div className="flex justify-end">
            <AdminButton onClick={() => setEditing({ id: null, form: EMPTY })}>Add an item</AdminButton>
          </div>
        ) : null}
        <DataTable
          columns={columns}
          rows={rows}
          rowKey={(row) => row.id}
          loading={items.isLoading}
          error={items.data && !items.data.ok ? items.data.error.message : null}
          onRetry={() => items.refetch()}
          empty={{ title: "No items yet", body: "Add the first item for The Shelf." }}
        />
      </div>
    </>
  );
}

function ItemForm({
  value,
  isNew,
  cameraNames,
  onChange,
  onCancel,
  onSave
}: {
  value: ShelfItemInput;
  isNew: boolean;
  cameraNames: Map<string, string>;
  onChange: (value: ShelfItemInput) => void;
  onCancel: () => void;
  onSave: () => void;
}) {
  const [helper, setHelper] = useState<ShelfPriceHelper | null>(null);
  const [search, setSearch] = useState("");
  const set = <K extends keyof ShelfItemInput>(key: K, v: ShelfItemInput[K]) => onChange({ ...value, [key]: v });

  // The helper is the server's arithmetic, asked again as the form changes.
  useEffect(() => {
    if (!value.street_price || !value.supplier_cost) return setHelper(null);
    const timer = setTimeout(async () => {
      const res = await admin.shelfPriceHelper({
        level: Number(value.level),
        price_raww: Number(value.price_raww) || null,
        street_price: value.street_price,
        street_currency: value.street_currency,
        supplier_cost: value.supplier_cost,
        supplier_currency: value.supplier_currency
      });
      setHelper(res.ok ? res.data : null);
    }, 300);
    return () => clearTimeout(timer);
  }, [value.level, value.price_raww, value.street_price, value.street_currency, value.supplier_cost, value.supplier_currency]);

  const matches = useMemo(() => {
    const key = normalise(search);
    if (!key) return [];
    return [...cameraNames.entries()]
      .filter(([model, name]) => !value.camera_models.includes(model) && (model.includes(key) || normalise(name).includes(key)))
      .slice(0, 8);
  }, [search, cameraNames, value.camera_models]);

  const text = (key: keyof ShelfItemInput, label: string) => (
    <div>
      <FieldLabel htmlFor={key}>{label}</FieldLabel>
      <TextField id={key} value={(value[key] as string | null) ?? ""} onChange={(e) => set(key, e.target.value as never)} />
    </div>
  );

  return (
    <Panel className="space-y-4 p-4">
      <h2 className="text-sm font-semibold">{isNew ? "New item" : `Editing ${value.title}`}</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {text("title", "Title")}
        {text("brand", "Brand")}
        {text("category", "Category (battery, charger, card, ssd, light, merch...)")}
        {text("image_url", "Image URL")}
        {text("supplier_name", "Supplier")}
        {text("supplier_sku", "Supplier SKU")}
        {text("supplier_url", "Supplier link")}
        <div>
          <FieldLabel htmlFor="level">Level</FieldLabel>
          <SelectField id="level" value={value.level} onChange={(e) => set("level", Number(e.target.value))}>
            {[1, 2, 3, 4, 5].map((l) => (
              <option key={l} value={l}>
                Level {l}
              </option>
            ))}
          </SelectField>
        </div>
        <div>
          <FieldLabel htmlFor="stock">Stock</FieldLabel>
          <SelectField id="stock" value={value.stock_status} onChange={(e) => set("stock_status", e.target.value)}>
            <option value="in_stock">In stock</option>
            <option value="out_of_stock">Out of stock</option>
          </SelectField>
        </div>
      </div>
      <div>
        <FieldLabel htmlFor="description">Description</FieldLabel>
        <TextArea id="description" rows={3} value={value.description ?? ""} onChange={(e) => set("description", e.target.value)} />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div>
          <FieldLabel htmlFor="street">Street price</FieldLabel>
          <div className="flex gap-2">
            <TextField id="street" inputMode="decimal" value={value.street_price} onChange={(e) => set("street_price", e.target.value)} />
            <SelectField value={value.street_currency} onChange={(e) => set("street_currency", e.target.value)}>
              <option>GBP</option>
              <option>EUR</option>
            </SelectField>
          </div>
        </div>
        <div>
          <FieldLabel htmlFor="cost">Supplier cost</FieldLabel>
          <div className="flex gap-2">
            <TextField id="cost" inputMode="decimal" value={value.supplier_cost} onChange={(e) => set("supplier_cost", e.target.value)} />
            <SelectField value={value.supplier_currency} onChange={(e) => set("supplier_currency", e.target.value)}>
              <option>GBP</option>
              <option>EUR</option>
            </SelectField>
          </div>
        </div>
        <div>
          <FieldLabel htmlFor="price">Price (RAWW)</FieldLabel>
          <TextField id="price" inputMode="numeric" value={value.price_raww || ""} onChange={(e) => set("price_raww", Number(e.target.value.replace(/\D/g, "")))} />
        </div>
        <div className="text-sm">
          {helper ? (
            <div className="space-y-1 pt-5">
              <div>
                Suggested <strong>{helper.suggested_price_raww} RAWW</strong>{" "}
                <button type="button" className="text-xs underline" onClick={() => set("price_raww", helper.suggested_price_raww)}>
                  use it
                </button>
              </div>
              {helper.price_eur ? (
                <div className="text-slate-400">
                  Worth {money(helper.price_eur)} · cost {money(helper.supplier_cost_eur)} · margin {money(helper.margin_eur)}
                </div>
              ) : null}
              {helper.band_warning ? <StatusBadge label={helper.band_warning} tone="attention" /> : null}
            </div>
          ) : (
            <p className="pt-5 text-slate-400">Enter the street price and the cost for a suggestion.</p>
          )}
        </div>
      </div>

      <div className="space-y-2">
        <FieldLabel htmlFor="camera-search">Fits these cameras (none: fits everyone)</FieldLabel>
        <div className="flex flex-wrap gap-2">
          {value.camera_models.map((model) => (
            <button
              key={model}
              type="button"
              className="rounded border border-white/20 px-2 py-1 text-xs"
              onClick={() => set("camera_models", value.camera_models.filter((m) => m !== model))}
            >
              {cameraNames.get(model) ?? model} ✕
            </button>
          ))}
        </div>
        <TextField id="camera-search" placeholder="Search the camera catalogue" value={search} onChange={(e) => setSearch(e.target.value)} />
        {matches.length ? (
          <div className="flex flex-wrap gap-2">
            {matches.map(([model, name]) => (
              <AdminButton
                key={model}
                tone="secondary"
                onClick={() => {
                  set("camera_models", [...value.camera_models, model]);
                  setSearch("");
                }}
              >
                + {name}
              </AdminButton>
            ))}
          </div>
        ) : null}
      </div>

      <div className="flex items-center justify-between">
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={value.active} onChange={(e) => set("active", e.target.checked)} />
          Shown on The Shelf
        </label>
        <div className="flex gap-2">
          <AdminButton tone="secondary" onClick={onCancel}>
            Cancel
          </AdminButton>
          <AdminButton onClick={onSave} disabled={!value.title.trim() || !value.price_raww}>
            Save item
          </AdminButton>
        </div>
      </div>
    </Panel>
  );
}


/**
 * An item's photos: 1 to 4, the first is the cover (no cover, no
 * activation). JPEG, PNG or WebP, at most 10 MB, at least 800 px on the long
 * edge; the server makes three sizes. Move a photo to reorder; delete it.
 */
function ShelfPhotos({
  item,
  onChanged,
  onMessage
}: {
  item: ShelfItem | undefined;
  onChanged: () => void;
  onMessage: (m: { tone: "error" | "success"; text: string }) => void;
}) {
  const [busy, setBusy] = useState(false);
  if (!item) return null;
  const images = item.images ?? [];

  const upload = async (file: File) => {
    setBusy(true);
    try {
      const started = await admin.startShelfImage(item.id, file.type, file.name);
      if (!started.ok) return onMessage({ tone: "error", text: started.error.message });
      const put = await fetch(started.data.upload_url, {
        method: started.data.method,
        headers: { ...started.data.headers, "Content-Type": file.type },
        body: file
      }).catch(() => null);
      if (!put || !put.ok) return onMessage({ tone: "error", text: "The upload did not reach storage. Try again." });
      const done = await admin.completeShelfImage(item.id, started.data.image_id);
      if (!done.ok) return onMessage({ tone: "error", text: done.error.message });
      onMessage({ tone: "success", text: "Photo added. Its sizes are being made." });
    } finally {
      setBusy(false);
      onChanged();
    }
  };

  const move = async (index: number, by: number) => {
    const ids = images.map((i) => i.id);
    const [moved] = ids.splice(index, 1);
    ids.splice(index + by, 0, moved);
    const res = await admin.orderShelfImages(item.id, ids);
    if (!res.ok) onMessage({ tone: "error", text: res.error.message });
    onChanged();
  };

  const remove = async (imageId: string) => {
    const res = await admin.deleteShelfImage(item.id, imageId);
    if (!res.ok) onMessage({ tone: "error", text: res.error.message });
    onChanged();
  };

  return (
    <Panel className="space-y-3 p-4">
      <h2 className="text-sm font-semibold">Photos of {item.title}</h2>
      <p className="text-xs text-slate-400">The first is the cover. JPEG, PNG or WebP, up to 10 MB, at least 800 px on the long edge. At most 4.</p>
      <div className="flex flex-wrap gap-3">
        {images.map((image, index) => (
          <div key={image.id} className="w-36 space-y-1">
            {image.medium_url ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={image.medium_url} alt="" className="h-36 w-36 rounded object-cover" />
            ) : (
              <div className="flex h-36 w-36 items-center justify-center rounded bg-white/5 text-xs text-slate-400">{image.status}</div>
            )}
            <div className="flex items-center gap-1">
              {index === 0 ? <StatusBadge label="Cover" tone="positive" /> : null}
              <AdminButton tone="secondary" disabled={index === 0} onClick={() => move(index, -1)}>
                ←
              </AdminButton>
              <AdminButton tone="secondary" disabled={index === images.length - 1} onClick={() => move(index, 1)}>
                →
              </AdminButton>
              <AdminButton tone="secondary" onClick={() => remove(image.id)}>
                Delete
              </AdminButton>
            </div>
          </div>
        ))}
      </div>
      {images.length < 4 ? (
        <label className="inline-block cursor-pointer text-sm text-slate-200">
          <input
            type="file"
            accept="image/jpeg,image/png,image/webp"
            className="hidden"
            disabled={busy}
            onChange={(e) => {
              const file = e.target.files?.[0];
              e.target.value = "";
              if (file) void upload(file);
            }}
          />
          <span className="rounded border border-white/15 px-3 py-1.5">{busy ? "Uploading…" : "Add a photo"}</span>
        </label>
      ) : null}
    </Panel>
  );
}
