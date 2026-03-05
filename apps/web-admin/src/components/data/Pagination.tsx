import { Button } from "@/components/forms/Button";

interface PaginationProps {
  page: number;
  pageSize: number;
  total: number;
  onPageChange: (next: number) => void;
}

export function Pagination({ page, pageSize, total, onPageChange }: PaginationProps) {
  const pageCount = Math.max(1, Math.ceil(total / pageSize));
  return (
    <div className="mt-4 flex items-center justify-between text-sm text-textSecondary">
      <span>
        Page {page} of {pageCount} ({total} total)
      </span>
      <div className="flex gap-2">
        <Button variant="secondary" onClick={() => onPageChange(page - 1)} disabled={page <= 1}>
          Previous
        </Button>
        <Button variant="secondary" onClick={() => onPageChange(page + 1)} disabled={page >= pageCount}>
          Next
        </Button>
      </div>
    </div>
  );
}
