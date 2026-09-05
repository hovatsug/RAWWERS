"use client";

import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, GlassCard, Input, Select } from "@/design-system/primitives";
import { apiGet, apiPost } from "@/lib/api/client";

/**
 * The one part of the marketing site that does real work.
 *
 * The waitlist decides which city opens next, so an entry that does not
 * say whether the person holds a camera is close to worthless: two
 * hundred names in a city means nothing until you know how many of them
 * can actually take a booking. Role is therefore required here, and the
 * backend rejects anything it does not recognise rather than filing it as
 * a client.
 *
 * Unauthenticated on purpose: POST /v1/client/waitlist is public, and this
 * component never touches the admin proxy.
 */
type Niche = { id: string; slug: string; name: string };

export function WaitlistForm() {
  const [role, setRole] = useState<"client" | "pro">("client");
  const [email, setEmail] = useState("");
  const [city, setCity] = useState("");
  const [country, setCountry] = useState("");
  const [niche, setNiche] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [joined, setJoined] = useState(false);

  const niches = useQuery({
    queryKey: ["public", "niches"],
    queryFn: () => apiGet<Niche[]>("/niches"),
    staleTime: 60 * 60 * 1000
  });

  const join = useMutation({
    mutationFn: () =>
      apiPost<{ accepted: boolean }>("/client/waitlist", {
        email: email.trim(),
        country: country.trim(),
        city: city.trim(),
        role,
        // Only meaningful for photographers: a client waiting for a city
        // does not need to commit to a genre.
        niche_slug: role === "pro" ? niche || null : null
      }),
    onSuccess: (res) => {
      if (!res.ok) {
        setError(res.error.message);
        return;
      }
      setError(null);
      setJoined(true);
    }
  });

  if (joined) {
    return (
      <GlassCard className="p-6">
        <p className="font-medium">You are on the list.</p>
        <p className="mt-1 text-sm text-neutral-400">
          We will email you when {city.trim() || "your city"} opens. We do not send anything else.
        </p>
      </GlassCard>
    );
  }

  const missing: string[] = [];
  if (!email.trim().includes("@")) missing.push("a valid email");
  if (!city.trim()) missing.push("your city");
  if (country.trim().length !== 2) missing.push("a two-letter country code");
  if (role === "pro" && !niche) missing.push("what you shoot");
  const ready = missing.length === 0;

  return (
    <GlassCard className="space-y-4 p-6">
      <div className="flex gap-2">
        {(["client", "pro"] as const).map((option) => (
          <button
            key={option}
            type="button"
            onClick={() => setRole(option)}
            className={
              "rounded-xl border px-4 py-2 text-sm transition " +
              (role === option
                ? "border-white/40 bg-white/10 text-white"
                : "border-white/10 text-neutral-400 hover:text-white")
            }
            aria-pressed={role === option}
          >
            {option === "client" ? "I want to book someone" : "I am a photographer"}
          </button>
        ))}
      </div>

      <Input
        placeholder="Email"
        type="email"
        autoComplete="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <div className="grid gap-3 sm:grid-cols-[1fr_140px]">
        <Input
          placeholder="City"
          autoComplete="address-level2"
          value={city}
          onChange={(e) => setCity(e.target.value)}
        />
        <Input
          placeholder="Country (PT)"
          autoComplete="country"
          maxLength={2}
          value={country}
          onChange={(e) => setCountry(e.target.value.toUpperCase())}
        />
      </div>

      {role === "pro" ? (
        <Select value={niche} onChange={(e) => setNiche(e.target.value)}>
          <option value="">What do you mostly shoot?</option>
          {(niches.data?.ok ? niches.data.data : []).map((n) => (
            <option key={n.slug} value={n.slug}>
              {n.name}
            </option>
          ))}
        </Select>
      ) : null}

      {error ? <p className="text-sm text-amber-400">{error}</p> : null}

      <Button onClick={() => join.mutate()} disabled={!ready || join.isPending}>
        {join.isPending ? "Adding you…" : "Join the waitlist"}
      </Button>

      {!ready ? (
        // Says what is missing rather than greying out silently.
        <p className="text-xs text-neutral-500">Still need {missing.join(", ")}.</p>
      ) : null}
    </GlassCard>
  );
}
