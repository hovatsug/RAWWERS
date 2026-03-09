"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState, Input, Skeleton, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProGigChatPage() {
  const { gigId } = useParams<{ gigId: string }>();
  const { accessToken } = useAuth();
  const [threadId, setThreadId] = useState("");
  const [message, setMessage] = useState("");

  const threadQ = useQuery({ queryKey: ["pro", "thread", threadId], queryFn: () => proApi.getProThread(threadId, accessToken), enabled: !!accessToken && !!threadId });
  const sendM = useMutation({ mutationFn: () => proApi.sendProMessage(threadId, { content: message }, accessToken), onSuccess: () => threadQ.refetch() });
  const draftM = useMutation({ mutationFn: () => proApi.getAIDraft(threadId, { context: { gig_id: gigId } }, accessToken) });

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Gig Chat</h1>
      <Input placeholder="Thread id" value={threadId} onChange={(e) => setThreadId(e.target.value)} />
      {threadQ.isLoading ? <Skeleton className="h-24" /> : null}
      {threadQ.data?.ok ? <Card><pre className="overflow-auto text-xs">{JSON.stringify(threadQ.data.data, null, 2)}</pre></Card> : null}
      {!threadId ? <EmptyState title="Paste thread id" /> : null}
      <Card className="space-y-2">
        <Textarea value={message} onChange={(e) => setMessage(e.target.value)} placeholder="Write message" />
        <div className="flex gap-2">
          <Button disabled={!threadId || !message || sendM.isPending} onClick={() => sendM.mutate()}>{sendM.isPending ? "Sending..." : "Send"}</Button>
          <Button className="bg-neutral-700" disabled={!threadId || draftM.isPending} onClick={() => draftM.mutate()}>{draftM.isPending ? "Generating..." : "AI Draft"}</Button>
        </div>
      </Card>
    </div>
  );
}
