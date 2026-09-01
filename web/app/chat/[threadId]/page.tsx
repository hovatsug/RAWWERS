"use client";

import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { Flag } from "@/lib/flags/provider";

export default function ChatThreadPage() {
  const [msg, setMsg] = useState("");
  const [messages, setMessages] = useState<string[]>(["Hello, I want to discuss the booking."]);

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Chat</h1>
      <Card className="space-y-2">
        {messages.map((m, i) => (
          <div key={i} className="rounded-md bg-neutral-100 p-2 text-sm">{m}</div>
        ))}
      </Card>
      <Flag name="ai_concierge_enabled" fallback={null}>
        <Card>
          <p className="text-sm">AI assistant suggestion: create booking request from this chat.</p>
          <Button className="mt-2 bg-neutral-700">Create booking CTA</Button>
        </Card>
      </Flag>
      <div className="flex gap-2">
        <Input value={msg} onChange={(e) => setMsg(e.target.value)} placeholder="Type a message" />
        <Button onClick={() => { if (msg.trim()) setMessages((v) => [...v, msg.trim()]); setMsg(""); }}>Send</Button>
      </div>
    </div>
  );
}
