import { Input } from "@/components/forms/Input";

interface DateRangeProps {
  from?: string;
  to?: string;
  onChange: (next: { from?: string; to?: string }) => void;
}

export function DateRange({ from, to, onChange }: DateRangeProps) {
  return (
    <div className="flex gap-2">
      <Input
        type="date"
        value={from || ""}
        onChange={(e) => onChange({ from: e.target.value || undefined, to })}
      />
      <Input
        type="date"
        value={to || ""}
        onChange={(e) => onChange({ from, to: e.target.value || undefined })}
      />
    </div>
  );
}
