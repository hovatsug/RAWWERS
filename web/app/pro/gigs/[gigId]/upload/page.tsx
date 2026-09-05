"use client";

import { Button, Card, Input } from "@/design-system/primitives";
import { useState } from "react";

export default function ProGigUploadPage() {
  const [uploaded, setUploaded] = useState(0);

  return (
    <div className="space-y-3">
      <Card>
        <h1 className="text-xl font-semibold">Upload proofs</h1>
        <p className="text-sm text-neutral-600">Upload watermarked previews and prepare selection set.</p>
      </Card>
      <Card className="space-y-2">
        <Input type="file" multiple onChange={(e) => setUploaded(e.target.files?.length || 0)} />
        <p className="text-sm">Files selected: {uploaded}</p>
        <a href="../publish"><Button>Continue to publish</Button></a>
      </Card>
    </div>
  );
}
