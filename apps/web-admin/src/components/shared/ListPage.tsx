"use client";

import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Column, DataTable } from "@/components/data/DataTable";
import { EmptyState } from "@/components/feedback/EmptyState";
import { ErrorState } from "@/components/feedback/ErrorState";
import { Skeleton } from "@/components/feedback/Skeleton";
import { FiltersBar } from "@/components/data/FiltersBar";
import { Input } from "@/components/forms/Input";
import { Pagination } from "@/components/data/Pagination";
import { SectionCard } from "@/components/layout/SectionCard";
import { ApiErrorBanner } from "@/components/shared/ApiErrorBanner";
import { useListParams } from "@/components/shared/useListParams";

interface Paginated<T> {
  items: T[];
  page: number;
  pageSize: number;
  total: number;
}

interface ListPageProps<T> {
  queryKey: readonly unknown[];
  queryFn: (params: { page: number; pageSize: number; search?: string; [key: string]: unknown }) => Promise<Paginated<T>>;
  columns: Column<T>[];
  searchPlaceholder?: string;
  extraFilters?: React.ReactNode;
  onRowClick?: (row: T) => void;
}

export function ListPage<T>({ queryKey, queryFn, columns, searchPlaceholder, extraFilters, onRowClick }: ListPageProps<T>) {
  const { page, pageSize, search, setParam, setPage } = useListParams();
  const [searchInput, setSearchInput] = useState(search);

  const query = useQuery({
    queryKey: [...queryKey, { page, pageSize, search }],
    queryFn: () => queryFn({ page, pageSize, search })
  });

  const rows = useMemo(() => query.data?.items || [], [query.data]);

  return (
    <SectionCard>
      <ApiErrorBanner error={query.error} />
      <FiltersBar>
        <Input
          className="max-w-sm"
          placeholder={searchPlaceholder || "Search"}
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
          onBlur={() => setParam("search", searchInput)}
          onKeyDown={(e) => {
            if (e.key === "Enter") setParam("search", searchInput);
          }}
        />
        {extraFilters}
      </FiltersBar>

      {query.isLoading ? (
        <div className="space-y-2">
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-12 w-full" />
        </div>
      ) : query.isError ? (
        <ErrorState message={(query.error as any)?.message} onRetry={() => query.refetch()} />
      ) : rows.length === 0 ? (
        <EmptyState title="No records" description="Try adjusting your filters." />
      ) : (
        <>
          <DataTable columns={columns} rows={rows} onRowClick={onRowClick} />
          <Pagination
            page={query.data?.page || page}
            pageSize={query.data?.pageSize || pageSize}
            total={query.data?.total || rows.length}
            onPageChange={setPage}
          />
        </>
      )}
    </SectionCard>
  );
}
