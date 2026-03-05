"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getStorePolicy,
  updateStorePolicy,
  getStorePartners,
  createStorePartner,
  updateStorePartner,
  syncStorePartner,
  listStoreProducts,
  createStoreProduct,
  updateStoreProduct,
  getStorePriceRules,
  createStorePriceRule,
  updateStorePriceRule,
  updateStoreOrderStatus,
  setStoreOverride
} from "@/api/routes/adminStore";
import { PageHeader } from "@/components/layout/PageHeader";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { ListPage } from "@/components/shared/ListPage";

export default function StorePage() {
  const queryClient = useQueryClient();
  const policy = useQuery({ queryKey: ["admin", "store-policy"], queryFn: getStorePolicy });
  const partners = useQuery({ queryKey: ["admin", "store-partners"], queryFn: getStorePartners });
  const rules = useQuery({ queryKey: ["admin", "store-price-rules"], queryFn: getStorePriceRules });

  const [payload, setPayload] = useState("{}");
  const [entityId, setEntityId] = useState("");
  const [orderId, setOrderId] = useState("");
  const [overrideUserId, setOverrideUserId] = useState("");

  const createPartner = useMutation({ mutationFn: () => createStorePartner(JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-partners"] }) });
  const savePartner = useMutation({ mutationFn: () => updateStorePartner(entityId, JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-partners"] }) });
  const syncPartner = useMutation({ mutationFn: () => syncStorePartner(entityId), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-partners"] }) });
  const createProduct = useMutation({ mutationFn: () => createStoreProduct(JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-products"] }) });
  const saveProduct = useMutation({ mutationFn: () => updateStoreProduct(entityId, JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-products"] }) });
  const createRule = useMutation({ mutationFn: () => createStorePriceRule(JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-price-rules"] }) });
  const saveRule = useMutation({ mutationFn: () => updateStorePriceRule(entityId, JSON.parse(payload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "store-price-rules"] }) });
  const updateOrder = useMutation({ mutationFn: () => updateStoreOrderStatus(orderId, JSON.parse(payload || "{}")) });
  const override = useMutation({ mutationFn: () => setStoreOverride(overrideUserId, JSON.parse(payload || "{}")) });

  return (
    <div className="space-y-4">
      <PageHeader title="Store" subtitle="Policy, partners, products, pricing and overrides" />
      <JsonEditorCard title="Store Policy" value={policy.data || {}} onSave={updateStorePolicy} />
      <SectionCard><h3 className="mb-3 font-semibold">Partners</h3><CodeBlock value={partners.data || {}} /></SectionCard>
      <ListPage queryKey={["admin", "store-products"]} queryFn={listStoreProducts} columns={[{ key: "id", title: "Product", render: (r: any) => String(r.product_id || r.id || "-") }, { key: "name", title: "Name", render: (r: any) => r.name || "-" }, { key: "status", title: "Status", render: (r: any) => r.status || "-" }]} />
      <SectionCard><h3 className="mb-3 font-semibold">Price Rules</h3><CodeBlock value={rules.data || {}} /></SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Quick Actions</h3>
        <div className="space-y-2">
          <Input placeholder="Entity ID (partner/product/rule)" value={entityId} onChange={(e) => setEntityId(e.target.value)} />
          <Input placeholder="Order ID" value={orderId} onChange={(e) => setOrderId(e.target.value)} />
          <Input placeholder="Pro user ID for override" value={overrideUserId} onChange={(e) => setOverrideUserId(e.target.value)} />
          <Input placeholder='JSON payload e.g. {"status":"active"}' value={payload} onChange={(e) => setPayload(e.target.value)} />
        </div>
        <div className="mt-3 flex flex-wrap gap-2">
          <Button onClick={() => createPartner.mutate()}>Create Partner</Button>
          <Button onClick={() => savePartner.mutate()}>Update Partner</Button>
          <Button onClick={() => syncPartner.mutate()}>Sync Partner</Button>
          <Button onClick={() => createProduct.mutate()}>Create Product</Button>
          <Button onClick={() => saveProduct.mutate()}>Update Product</Button>
          <Button onClick={() => createRule.mutate()}>Create Rule</Button>
          <Button onClick={() => saveRule.mutate()}>Update Rule</Button>
          <Button onClick={() => updateOrder.mutate()}>Update Order Status</Button>
          <Button onClick={() => override.mutate()}>Set Override</Button>
        </div>
      </SectionCard>
    </div>
  );
}
