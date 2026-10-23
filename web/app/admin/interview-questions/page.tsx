"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type InterviewQuestion, type InterviewQuestionInput } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, TextArea, TextField } from "@/app/admin/_components/ui";

/**
 * The questions photographers answer for "Meet the photographer". Each change
 * is audited and reaches profiles on their next load: a new title is what
 * clients read, a retired question hides its answers (they are kept).
 */
const BLANK: InterviewQuestionInput = { prompt: "", title: "", hint: null, min_chars: 20, max_chars: 300, position: 0, is_active: true };

function valid(q: InterviewQuestionInput): string | null {
  if (!q.prompt.trim()) return "Write the question photographers are asked.";
  if (!q.title.trim()) return "Write the title clients read.";
  if (!(q.min_chars >= 0) || !(q.max_chars > q.min_chars)) return "The longest answer must be longer than the shortest.";
  return null;
}

function QuestionForm({
  initial,
  saveLabel,
  onSave
}: {
  initial: InterviewQuestionInput;
  saveLabel: string;
  onSave: (q: InterviewQuestionInput) => Promise<string | null>;
}) {
  const [q, setQ] = useState(initial);
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const problem = valid(q);
  const changed = JSON.stringify(q) !== JSON.stringify(initial);
  const id = (name: string) => `${saveLabel}-${initial.title || "new"}-${name}`.replace(/\W+/g, "-");
  return (
    <div className="grid gap-3">
      <div>
        <FieldLabel htmlFor={id("prompt")}>Question photographers are asked</FieldLabel>
        <TextField id={id("prompt")} value={q.prompt} onChange={(e) => setQ({ ...q, prompt: e.target.value })} />
      </div>
      <div>
        <FieldLabel htmlFor={id("title")}>Title clients read</FieldLabel>
        <TextField id={id("title")} value={q.title} onChange={(e) => setQ({ ...q, title: e.target.value })} />
      </div>
      <div>
        <FieldLabel htmlFor={id("hint")}>Hint shown while they write (optional)</FieldLabel>
        <TextArea id={id("hint")} rows={2} value={q.hint ?? ""} onChange={(e) => setQ({ ...q, hint: e.target.value || null })} />
      </div>
      <div className="grid grid-cols-3 gap-3">
        <div>
          <FieldLabel htmlFor={id("min")}>Shortest answer (characters)</FieldLabel>
          <TextField id={id("min")} inputMode="numeric" value={q.min_chars} onChange={(e) => setQ({ ...q, min_chars: Number(e.target.value) })} />
        </div>
        <div>
          <FieldLabel htmlFor={id("max")}>Longest answer (characters)</FieldLabel>
          <TextField id={id("max")} inputMode="numeric" value={q.max_chars} onChange={(e) => setQ({ ...q, max_chars: Number(e.target.value) })} />
        </div>
        <div>
          <FieldLabel htmlFor={id("position")}>Order</FieldLabel>
          <TextField id={id("position")} inputMode="numeric" value={q.position} onChange={(e) => setQ({ ...q, position: Number(e.target.value) })} />
        </div>
      </div>
      <label className="flex items-center gap-2 text-sm text-slate-300">
        <input type="checkbox" checked={q.is_active} onChange={(e) => setQ({ ...q, is_active: e.target.checked })} /> Asked (untick to retire it; answers are kept)
      </label>
      {problem && changed ? <p className="text-xs text-amber-300">{problem}</p> : null}
      {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
      <div>
        <AdminButton
          disabled={!changed || problem !== null}
          onClick={async () => {
            const error = await onSave(q);
            setMessage(error ? { tone: "error", text: error } : { tone: "success", text: "Saved." });
          }}
        >
          {saveLabel}
        </AdminButton>
      </div>
    </div>
  );
}

export default function InterviewQuestionsPage() {
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "interview-questions"], queryFn: () => admin.interviewQuestions() });
  const questions = query.data?.ok ? query.data.data : undefined;
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "interview-questions"] });
  const fields = (q: InterviewQuestion): InterviewQuestionInput => ({
    prompt: q.prompt, title: q.title, hint: q.hint, min_chars: q.min_chars, max_chars: q.max_chars, position: q.position, is_active: q.is_active
  });

  return (
    <>
      <PageHeader
        title="Interview questions"
        description='What photographers answer for "Meet the photographer" on their profile. Optional for them; never part of ranking.'
      />
      {query.data && !query.data.ok ? <Notice tone="error">{query.data.error.message}</Notice> : null}
      <div className="grid gap-4">
        {(questions ?? []).map((q) => (
          <Panel key={q.id} className="p-4" >
            <p className="mb-2 text-xs text-slate-500">{q.is_active ? "Asked" : "Retired"} · {q.key}</p>
            <QuestionForm
              initial={fields(q)}
              saveLabel="Save"
              onSave={async (body) => {
                const changes = Object.fromEntries(
                  Object.entries(body).filter(([k, v]) => v !== fields(q)[k as keyof InterviewQuestionInput])
                ) as Partial<InterviewQuestionInput>;
                const res = await admin.updateInterviewQuestion(q.id, changes);
                if (!res.ok) return res.error.message;
                refresh();
                return null;
              }}
            />
          </Panel>
        ))}
        {questions ? (
          <Panel className="p-4">
            <h2 className="mb-3 text-sm font-semibold text-slate-200">Add a question</h2>
            <QuestionForm
              initial={{ ...BLANK, position: questions.length }}
              saveLabel="Add question"
              onSave={async (body) => {
                const res = await admin.createInterviewQuestion(body);
                if (!res.ok) return res.error.message;
                refresh();
                return null;
              }}
            />
          </Panel>
        ) : null}
      </div>
    </>
  );
}
