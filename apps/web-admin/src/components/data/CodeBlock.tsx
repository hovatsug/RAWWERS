export function CodeBlock({ value }: { value: unknown }) {
  return (
    <pre className="max-h-96 overflow-auto rounded-xl border border-borderSubtle bg-surface2 p-4 text-xs leading-5">
      {JSON.stringify(value, null, 2)}
    </pre>
  );
}
