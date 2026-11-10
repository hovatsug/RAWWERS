"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type AdminShelfOrder } from "@/lib/api/admin";
import {
  AdminButton,
  DataTable,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextField,
  money,
  type Column,
  type Tone
} from "@/app/admin/_components/ui";

/**
 * Orders from The Shelf, fulfilled by hand in the beta (one supplier,
 * dropship, UK only, free shipping). Each order moves on with what the step
 * needs: the supplier's reference to mark it ordered, the tracking code to
 * mark it shipped. Cancelling before it ships gives the photographer every
 * RAWW back at once and needs a reason; "out of stock" also marks the item
 * out of stock. After it ships there is no cancel: a return is a RAWW
 * adjustment on the RAWW ledger page. Every change is logged with the admin
 * and the time, and the photographer gets an in-app notification.
 */

const CANCEL_REASONS: { value: string; label: string }[] = [
  { value: "out_of_stock", label: "Out of stock (marks the item out of stock)" },
  { value: "supplier_problem", label: "Supplier problem" },
  { value: "address_problem", label: "Address problem" },
  { value: "photographer_asked", label: "The photographer asked" },
  { value: "other", label: "Other" }
];

function tone(status: string): Tone {
  return status === "placed" ? "attention" : status === "delivered" ? "positive" : status === "refunded" ? "neutral" : "info";
}

function when(value: string): string {
  return new Date(value).toLocaleString("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
}

export default function ShelfOrdersPage() {
  const queryClient = useQueryClient();
  const [status, setStatus] = useState("placed");
  const [open, setOpen] = useState<AdminShelfOrder | null>(null);
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const query = useQuery({ queryKey: ["admin", "shelf", "orders", status], queryFn: () => admin.shelfOrders(status || undefined) });
  const rows = query.data?.ok ? query.data.data.items : undefined;

  const done = (res: Awaited<ReturnType<typeof admin.shelfOrderDelivered>>, text: string) => {
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text });
    setOpen(res.data);
    queryClient.invalidateQueries({ queryKey: ["admin", "shelf", "orders"] });
  };

  const columns: Column<AdminShelfOrder>[] = [
    { header: "Placed", className: "whitespace-nowrap", cell: (row) => when(row.placed_at) },
    {
      header: "Item",
      cell: (row) => (
        <div>
          <div className="font-medium">{row.title}</div>
          <div className="text-xs text-slate-400">
            {row.supplier_name}
            {row.supplier_sku ? ` · ${row.supplier_sku}` : ""}
          </div>
        </div>
      )
    },
    { header: "Photographer", cell: (row) => row.pro_name ?? row.pro_user_id.slice(0, 8) },
    {
      header: "RAWW",
      className: "whitespace-nowrap tabular-nums",
      cell: (row) => (
        <div>
          {row.price_raww}
          <div className="text-xs text-slate-400">{money(row.price_eur)}</div>
        </div>
      )
    },
    { header: "Status", cell: (row) => <StatusBadge label={row.status} tone={tone(row.status)} /> },
    {
      header: "",
      className: "w-px text-right",
      cell: (row) => (
        <AdminButton tone="secondary" onClick={() => setOpen(row)}>
          Open
        </AdminButton>
      )
    }
  ];

  return (
    <>
      <PageHeader title="Shelf orders" description="Order from the supplier, add tracking, mark delivered. Cancel before shipping refunds every RAWW." />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        <Panel className="flex items-end gap-4 p-4">
          <div>
            <FieldLabel htmlFor="status">Status</FieldLabel>
            <SelectField id="status" value={status} onChange={(e) => setStatus(e.target.value)}>
              <option value="placed">Placed (to order)</option>
              <option value="ordered">Ordered</option>
              <option value="shipped">Shipped</option>
              <option value="delivered">Delivered</option>
              <option value="refunded">Cancelled and refunded</option>
              <option value="">All</option>
            </SelectField>
          </div>
        </Panel>
        {open ? <OrderPanel order={open} onClose={() => setOpen(null)} onDone={done} /> : null}
        <DataTable
          columns={columns}
          rows={rows}
          rowKey={(row) => row.id}
          loading={query.isLoading}
          error={query.data && !query.data.ok ? query.data.error.message : null}
          onRetry={() => query.refetch()}
          empty={{ title: "No orders here", body: "Orders photographers place on The Shelf show here." }}
        />
      </div>
    </>
  );
}

function OrderPanel({
  order,
  onClose,
  onDone
}: {
  order: AdminShelfOrder;
  onClose: () => void;
  onDone: (res: Awaited<ReturnType<typeof admin.shelfOrderDelivered>>, text: string) => void;
}) {
  const [ref, setRef] = useState("");
  const [tracking, setTracking] = useState("");
  const [trackingUrl, setTrackingUrl] = useState("");
  const [shipping, setShipping] = useState(order.shipping_cost_eur ?? "");
  const shippingOk = shipping.trim() === "" || /^\d{1,5}(\.\d{1,2})?$/.test(shipping.trim());
  const [reason, setReason] = useState("out_of_stock");
  const [note, setNote] = useState("");
  const address = order.address;

  return (
    <Panel className="space-y-4 p-4">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold">
          {order.title} · <StatusBadge label={order.status} tone={tone(order.status)} />
        </h2>
        <AdminButton tone="secondary" onClick={onClose}>
          Close
        </AdminButton>
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="text-sm">
          <div className="text-xs uppercase text-slate-400">Ship to</div>
          {address ? (
            <pre className="whitespace-pre-wrap font-sans">
              {[address.name, address.line1, address.line2, address.city, address.region, address.postal_code, address.country, address.phone]
                .filter(Boolean)
                .join("\n")}
            </pre>
          ) : (
            <p className="text-slate-400">The address could not be read.</p>
          )}
        </div>
        <div className="text-sm">
          <div className="text-xs uppercase text-slate-400">History</div>
          <ul className="space-y-1">
            {order.events.map((e, i) => (
              <li key={i}>
                {when(e.created_at)} · {e.to_status} by {e.actor_type}
                {e.note ? ` · ${e.note}` : ""}
              </li>
            ))}
          </ul>
          {order.supplier_order_ref ? <p className="mt-2">Supplier ref: {order.supplier_order_ref}</p> : null}
          {order.tracking_code ? <p>Tracking: {order.tracking_code}</p> : null}
          <p className="mt-2 text-slate-300">
            Cost to us:{" "}
            {order.supplier_cost ? (
              <>
                {order.supplier_cost} {order.supplier_currency}
                {order.supplier_currency !== "EUR" && order.cost_eur_rate ? ` at ${order.cost_eur_rate}` : ""}
                {order.cost_estimated ? <span className="text-slate-500"> (estimated: the item&apos;s cost when this was recorded)</span> : null}
              </>
            ) : (
              <span className="text-slate-500">not set</span>
            )}
            {" · "}shipping {order.shipping_cost_eur ? `€${order.shipping_cost_eur}` : <span className="text-slate-500">not entered</span>}
          </p>
        </div>
      </div>

      {order.status === "placed" ? (
        <div className="flex flex-wrap items-end gap-3 border-t border-white/10 pt-3">
          <div>
            <FieldLabel htmlFor="ref">Supplier&apos;s order reference</FieldLabel>
            <TextField id="ref" value={ref} onChange={(e) => setRef(e.target.value)} />
          </div>
          <AdminButton disabled={!ref.trim()} onClick={async () => onDone(await admin.shelfOrderOrdered(order.id, ref), "Marked ordered.")}>
            Mark ordered
          </AdminButton>
        </div>
      ) : null}
      {order.status === "ordered" ? (
        <div className="flex flex-wrap items-end gap-3 border-t border-white/10 pt-3">
          <div>
            <FieldLabel htmlFor="tracking">Tracking code</FieldLabel>
            <TextField id="tracking" value={tracking} onChange={(e) => setTracking(e.target.value)} />
          </div>
          <div className="min-w-72">
            <FieldLabel htmlFor="tracking-url">Tracking link (optional)</FieldLabel>
            <TextField id="tracking-url" value={trackingUrl} onChange={(e) => setTrackingUrl(e.target.value)} />
          </div>
          <div>
            <FieldLabel htmlFor="shipping">Shipping cost, € (optional)</FieldLabel>
            <TextField id="shipping" inputMode="decimal" placeholder="0.00" value={shipping} onChange={(e) => setShipping(e.target.value)} />
          </div>
          <AdminButton
            disabled={!tracking.trim() || !shippingOk}
            onClick={async () =>
              onDone(await admin.shelfOrderShipped(order.id, tracking, trackingUrl || null, shipping.trim() || null), "Marked shipped.")
            }
          >
            Mark shipped
          </AdminButton>
        </div>
      ) : null}
      {order.status === "shipped" ? (
        <div className="border-t border-white/10 pt-3">
          <AdminButton onClick={async () => onDone(await admin.shelfOrderDelivered(order.id), "Marked delivered.")}>Mark delivered</AdminButton>
        </div>
      ) : null}
      {order.status === "placed" || order.status === "ordered" ? (
        <div className="flex flex-wrap items-end gap-3 border-t border-white/10 pt-3">
          <div>
            <FieldLabel htmlFor="reason">Cancel because</FieldLabel>
            <SelectField id="reason" value={reason} onChange={(e) => setReason(e.target.value)}>
              {CANCEL_REASONS.map((r) => (
                <option key={r.value} value={r.value}>
                  {r.label}
                </option>
              ))}
            </SelectField>
          </div>
          <div className="min-w-72 flex-1">
            <FieldLabel htmlFor="note">Note (optional)</FieldLabel>
            <TextField id="note" value={note} onChange={(e) => setNote(e.target.value)} />
          </div>
          <AdminButton
            tone="secondary"
            onClick={async () =>
              onDone(await admin.shelfOrderCancel(order.id, reason, note), `Cancelled. ${order.price_raww} RAWW are back with the photographer.`)
            }
          >
            Cancel and refund
          </AdminButton>
        </div>
      ) : null}
      {order.status === "shipped" || order.status === "delivered" ? (
        <div className="flex flex-wrap items-end gap-3 border-t border-white/10 pt-3">
          <div>
            <FieldLabel htmlFor="shipping-edit">Shipping cost, €</FieldLabel>
            <TextField id="shipping-edit" inputMode="decimal" placeholder="0.00" value={shipping} onChange={(e) => setShipping(e.target.value)} />
          </div>
          <AdminButton
            tone="secondary"
            disabled={!shippingOk || shipping.trim() === (order.shipping_cost_eur ?? "")}
            onClick={async () => onDone(await admin.shelfOrderShippingCost(order.id, shipping.trim() || null), "Shipping cost saved.")}
          >
            Save shipping cost
          </AdminButton>
        </div>
      ) : null}
      {order.status === "shipped" || order.status === "delivered" ? (
        <p className="text-xs text-slate-400">A return after shipping is a RAWW adjustment, with a note, on the RAWW ledger page.</p>
      ) : null}
    </Panel>
  );
}
