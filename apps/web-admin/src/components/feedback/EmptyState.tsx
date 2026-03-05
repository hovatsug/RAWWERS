export function EmptyState({ title, description }: { title: string; description?: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-borderSubtle bg-surface2 p-10 text-center">
      <h3 className="text-base font-semibold">{title}</h3>
      {description ? <p className="mt-2 text-sm text-textSecondary">{description}</p> : null}
    </div>
  );
}
