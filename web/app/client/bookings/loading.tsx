import { Skeleton } from "@/design-system/primitives";

export default function LoadingClientBookings() {
  return (
    <div className="space-y-2">
      <Skeleton className="h-8 w-1/3" />
      <Skeleton className="h-16 w-full" />
      <Skeleton className="h-16 w-full" />
    </div>
  );
}
