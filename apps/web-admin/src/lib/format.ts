export function formatDate(value?: string | null) {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-US", {
    dateStyle: "medium",
    timeStyle: "short"
  }).format(date);
}

export function formatCurrency(amount?: number | null, currency = "USD") {
  if (amount == null || Number.isNaN(amount)) return "-";
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(amount);
}
