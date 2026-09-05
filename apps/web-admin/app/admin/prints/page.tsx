"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  listPrintOrders,
  getPrintOrder,
  setPrintOrderStatus,
  setPrintOrderTracking,
  getPrintCatalogProducts,
  updatePrintCatalogProducts,
  getPrintPartners,
  updatePrintPartners
} from "@/api/routes/adminPrints";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Drawer } from "@/components/overlays/Drawer";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Button } from "@/components/forms/Button";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";

export default function PrintsPage() {
  const queryClient = useQueryClient();
  const [orderId, setOrderId] = useState<string | null>(null);
  const [statusOpen, setStatusOpen] = useState(false);
  const [trackingOpen, setTrackingOpen] = useState(false);
  const [statusValue, setStatusValue] = useState("");
  const [trackingValue, setTrackingValue] = useState("");

  const detail = useQuery({ queryKey: ["admin", "print-order", orderId], queryFn: () => getPrintOrder(orderId || ""), enabled: !!orderId });
  const products = useQuery({ queryKey: ["admin", "prints-products"], queryFn: getPrintCatalogProducts });
  const partners = useQuery({ queryKey: ["admin", "prints-partners"], queryFn: getPrintPartners });

  const setStatus = useMutation({ mutationFn: () => setPrintOrderStatus(orderId || "", { status: statusValue }), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "prints-orders"] }) });
  const setTracking = useMutation({ mutationFn: () => setPrintOrderTracking(orderId || "", { tracking: trackingValue }), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "prints-orders"] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Prints" subtitle="Orders, catalog, and partners." />
      <ListPage
        queryKey={["admin", "prints-orders"]}
        queryFn={listPrintOrders}
        columns={[
          { key: "id", title: "Order", render: (r: any) => String(r.order_id || r.id || "-") },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => (
              <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                <Button variant="secondary" onClick={() => { setOrderId(String(r.order_id || r.id)); setStatusOpen(true); }}>Set Status</Button>
                <Button variant="secondary" onClick={() => { setOrderId(String(r.order_id || r.id)); setTrackingOpen(true); }}>Set Tracking</Button>
              </div>
            )
          }
        ]}
        onRowClick={(row: any) => setOrderId(String(row.order_id || row.id))}
      />
      <Drawer open={!!orderId} onClose={() => setOrderId(null)} title={`Order ${orderId || ""}`}>
        <CodeBlock value={detail.data || {}} />
      </Drawer>
      <Modal open={statusOpen} onClose={() => setStatusOpen(false)} title="Set print order status">
        <Input value={statusValue} onChange={(e) => setStatusValue(e.target.value)} placeholder="Status" />
        <div className="mt-3"><Button onClick={() => { setStatus.mutate(); setStatusOpen(false); }}>Save</Button></div>
      </Modal>
      <Modal open={trackingOpen} onClose={() => setTrackingOpen(false)} title="Set print tracking">
        <Input value={trackingValue} onChange={(e) => setTrackingValue(e.target.value)} placeholder="Tracking" />
        <div className="mt-3"><Button onClick={() => { setTracking.mutate(); setTrackingOpen(false); }}>Save</Button></div>
      </Modal>
      <JsonEditorCard title="Catalog Products" value={products.data || {}} onSave={updatePrintCatalogProducts} />
      <JsonEditorCard title="Partners" value={partners.data || {}} onSave={updatePrintPartners} />
    </div>
  );
}
