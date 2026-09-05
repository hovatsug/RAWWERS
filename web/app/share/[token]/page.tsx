import { EmptyState } from "@/design-system/primitives";
import { Flag } from "@/lib/flags/provider";

export default function ShareGalleryPage() {
  return (
    <Flag name="share_gallery_enabled" fallback={<EmptyState title="Sharing disabled" />}>
      <EmptyState title="Shared gallery" body="Watermarked previews and selected finals appear here." />
    </Flag>
  );
}
