import { Accordion } from "@/components/landing/Accordion";

export function FAQAccordion({ items }: { items: { id: string; title: string; content: string }[] }) {
  return <Accordion items={items} />;
}
