import { ReactNode } from "react";

export interface Column<T> {
  key: string;
  title: string;
  render: (row: T) => ReactNode;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  rows: T[];
  onRowClick?: (row: T) => void;
}

export function DataTable<T>({ columns, rows, onRowClick }: DataTableProps<T>) {
  return (
    <div className="overflow-hidden rounded-xl border border-borderSubtle">
      <table className="min-w-full bg-surface text-sm">
        <thead className="bg-surface2 text-left text-xs uppercase tracking-wide text-textSecondary">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="px-4 py-3 font-medium">
                {column.title}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, idx) => (
            <tr
              key={idx}
              className="border-t border-borderSubtle transition hover:bg-surface2/50"
              onClick={() => onRowClick?.(row)}
            >
              {columns.map((column) => (
                <td key={column.key} className="px-4 py-3 align-top">
                  {column.render(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
