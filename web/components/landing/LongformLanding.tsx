"use client";

import { useEffect } from "react";
import Image from "next/image";
import { Badge, Button, Card } from "@/design-system/primitives";
import { track } from "@/lib/analytics/client";
import { ScrollProgress } from "@/components/landing/ScrollProgress";
import { StickyHeaderCTA } from "@/components/landing/StickyHeaderCTA";
import { StickyMobileCTA } from "@/components/landing/StickyMobileCTA";
import { ChapterSection } from "@/components/landing/ChapterSection";
import { HowItWorksQuickStart } from "@/components/landing/HowItWorksQuickStart";
import { BotDashboardToggle } from "@/components/landing/BotDashboardToggle";
import { FAQAccordion } from "@/components/landing/FAQAccordion";
import { FinalCTA } from "@/components/landing/FinalCTA";
import { ScenesGrid } from "@/components/landing/ScenesGrid";
import { primaryCta, secondaryCta } from "@/components/landing/cta-utils";
import type { LandingContent } from "@/components/landing/lp-content";

export function LongformLanding({ content }: { content: LandingContent }) {
  useEffect(() => {
    track("lp_view", { page: content.slug });
  }, [content.slug]);

  return (
    <div className="bg-neutral-50">
      <ScrollProgress />
      <StickyHeaderCTA onPrimary={() => primaryCta("sticky_header")} onSecondary={() => secondaryCta("sticky_header")} />

      <main className="mx-auto w-full max-w-3xl space-y-8 px-4 pb-24 pt-6">
        <section id="chapter-problem" className="space-y-5 py-8">
          <Badge className="bg-brand-100 px-3 py-1 text-xs font-semibold uppercase tracking-[0.1em] text-brand-700">{content.badge}</Badge>
          <h1 className="max-w-[22ch] text-[32px] font-semibold leading-tight text-neutral-900 md:text-[48px]">{content.heroTitle}</h1>
          <p className="max-w-[62ch] text-[17px] text-neutral-700 md:text-lg">{content.heroSubheadline}</p>
          <div className="flex flex-col gap-3 sm:flex-row">
            <Button className="py-3 text-sm font-semibold focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600" onClick={() => primaryCta("hero")} aria-label="Start in Telegram">
              Start in Telegram
            </Button>
            <Button className="bg-neutral-100 py-3 text-sm text-neutral-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600" onClick={() => secondaryCta("hero")} aria-label="Connect dashboard">
              Connect dashboard
            </Button>
          </div>
          <p className="text-sm text-neutral-600">Start in Telegram. Connect the dashboard in 2 minutes. Start your 14-day trial.</p>
          <div className="grid gap-2 text-sm text-neutral-700 sm:grid-cols-3">
            {content.heroTrust.map((item) => (
              <Card key={item} className="border border-neutral-200 p-4">
                {item}
              </Card>
            ))}
          </div>
        </section>

        <ChapterSection id="mirror" kicker="Chapter: Problem" title={content.mirrorTitle} ctaLabel="Start in Telegram" ctaSubcopy="No motivation feed. Just accountability state." onCta={() => primaryCta("mirror")}>
          <ul className="list-disc space-y-2 pl-5 text-base text-neutral-700">
            {content.mirrorBullets.map((line) => (
              <li key={line}>{line}</li>
            ))}
          </ul>
        </ChapterSection>

        <ChapterSection id="mechanism" kicker="Chapter: Mechanism" title={content.mechanismTitle} ctaLabel="Start in Telegram" ctaSubcopy="Permanent history. No reset." onCta={() => primaryCta("mechanism")}>
          <div className="space-y-3">
            {content.mechanismBlocks.map((block) => (
              <p key={block} className="max-w-[62ch] text-base text-neutral-700">
                {block}
              </p>
            ))}
          </div>
        </ChapterSection>

        <ChapterSection id="how-it-works" kicker="Chapter: How it Works" title="30-second Quick Start" ctaLabel="Connect dashboard" ctaSubcopy="Link bot + dashboard once." onCta={() => secondaryCta("how_it_works")}>
          <HowItWorksQuickStart />
        </ChapterSection>

        <ChapterSection id="scenes" kicker="Chapter: Scenes" title="Real usage scenes from one normal week" ctaLabel="Start in Telegram" ctaSubcopy="Treat negotiation as data, not drama." onCta={() => primaryCta("scenes")}>
          <ScenesGrid scenes={content.scenes} onSceneCta={(id) => primaryCta(id)} />
        </ChapterSection>

        <ChapterSection id="proof" kicker="Chapter: Proof" title={content.proofTitle} ctaLabel="Connect dashboard" ctaSubcopy="See what changed, not what you intended." onCta={() => secondaryCta("proof")}>
          <div className="space-y-4">
            <BotDashboardToggle />
            <div className="grid gap-3 sm:grid-cols-2">
              <Card className="border border-neutral-200 p-3">
                <Image src="/assets/sample-week-timeline.png" alt="Sample week timeline placeholder" width={1200} height={720} className="h-auto w-full rounded-md" loading="lazy" />
                <p className="mt-2 text-sm text-neutral-700">Sample week timeline</p>
              </Card>
              <Card className="border border-neutral-200 p-3">
                <Image src="/assets/pattern-analytics.png" alt="Pattern analytics view placeholder" width={1200} height={720} className="h-auto w-full rounded-md" loading="lazy" />
                <p className="mt-2 text-sm text-neutral-700">Pattern analytics view</p>
              </Card>
            </div>
            <ul className="list-disc space-y-2 pl-5 text-sm text-neutral-700">
              {content.proofBullets.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </div>
        </ChapterSection>

        <ChapterSection id="features" kicker="Chapter: Features" title={content.featureTitle} ctaLabel="Start in Telegram" ctaSubcopy="Dashboard exposes patterns you can’t argue with." onCta={() => primaryCta("features")}>
          <div className="grid gap-3 sm:grid-cols-2">
            {content.features.map((feature) => (
              <Card key={feature} className="border border-neutral-200 p-6">
                <h3 className="text-base font-semibold text-neutral-900">{feature}</h3>
              </Card>
            ))}
          </div>
        </ChapterSection>

        <ChapterSection id="templates" kicker="Chapter: Pact Examples" title="Realistic pact examples (no fake penalties)" ctaLabel="Start in Telegram" ctaSubcopy="Choose one and launch it in the bot." onCta={() => primaryCta("templates")}>
          <div className="space-y-3">
            {content.templates.map((tpl) => (
              <Card key={tpl.id} className="space-y-3 border border-neutral-200 p-6">
                <h3 className="text-lg font-semibold text-neutral-900">{tpl.title}</h3>
                <p className="text-sm text-neutral-700">
                  <span className="font-semibold text-neutral-900">Rule:</span> {tpl.rule}
                </p>
                <p className="text-sm text-neutral-700">
                  <span className="font-semibold text-neutral-900">Schedule:</span> {tpl.schedule}
                </p>
                <p className="text-sm text-neutral-700">
                  <span className="font-semibold text-neutral-900">Enforcement:</span> {tpl.enforcement}
                </p>
                <p className="text-xs font-semibold uppercase tracking-[0.08em] text-brand-700">Difficulty: {tpl.difficulty}</p>
                <Button
                  className="w-full bg-neutral-100 py-3 text-sm text-neutral-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
                  onClick={() => {
                    track("template_select", { template_id: tpl.id });
                    primaryCta(`template_${tpl.id}`);
                  }}
                  aria-label={`Select template ${tpl.title}`}
                >
                  Use this template in Telegram
                </Button>
              </Card>
            ))}
          </div>
        </ChapterSection>

        <ChapterSection id="trial" kicker="Chapter: Trial" title={content.trialTitle} ctaLabel="Start in Telegram" ctaSubcopy="14-day trial. Full dashboard included." onCta={() => primaryCta("trial")}>
          <Card className="space-y-3 border border-neutral-200 p-6">
            <ul className="list-disc space-y-1 pl-5 text-sm text-neutral-700">
              {content.trialBullets.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
            <Button className="w-full bg-neutral-100 py-3 text-sm text-neutral-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600" onClick={() => secondaryCta("trial")} aria-label="Connect dashboard">
              Connect dashboard
            </Button>
          </Card>
        </ChapterSection>

        <ChapterSection id="faq" kicker="Chapter: FAQ" title="Questions before you start" ctaLabel="Start in Telegram" ctaSubcopy="If the mechanism fits, begin now." onCta={() => primaryCta("faq")}>
          <FAQAccordion items={content.faq} />
        </ChapterSection>

        <section id="final" className="py-8">
          <FinalCTA onPrimary={() => primaryCta("final")} onSecondary={() => secondaryCta("final")} />
          <div className="mt-5 space-y-2">
            {content.finalClose.map((line) => (
              <p key={line} className="max-w-[62ch] text-base text-neutral-700">
                {line}
              </p>
            ))}
          </div>
        </section>
      </main>

      <StickyMobileCTA onClick={() => primaryCta("mobile_sticky_footer")} />
    </div>
  );
}

