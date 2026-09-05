import { Button, Card } from "@/design-system/primitives";

export type SceneItem = {
  id: string;
  title: string;
  hook: string;
  story: string;
  pactDoes: string[];
  outcome: string;
};

export function ScenesGrid({ scenes, onSceneCta }: { scenes: SceneItem[]; onSceneCta: (sceneId: string) => void }) {
  return (
    <div className="space-y-4">
      {scenes.map((scene, idx) => (
        <Card key={scene.id} className="reveal space-y-3 border border-neutral-200 p-6">
          <p className="text-xs font-semibold uppercase tracking-[0.12em] text-brand-700">Scene {idx + 1}</p>
          <h3 className="text-xl font-semibold text-neutral-900">{scene.title}</h3>
          <p className="text-sm font-semibold text-neutral-900">{scene.hook}</p>
          <p className="max-w-[62ch] text-base text-neutral-700">{scene.story}</p>
          <div>
            <p className="text-sm font-semibold text-neutral-900">What PACT does:</p>
            <ul className="list-disc space-y-1 pl-5 text-sm text-neutral-700">
              {scene.pactDoes.map((line) => (
                <li key={line}>{line}</li>
              ))}
            </ul>
          </div>
          <p className="text-sm font-semibold text-neutral-900">{scene.outcome}</p>
          <Button
            className="w-full py-3 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
            onClick={() => onSceneCta(scene.id)}
            aria-label="Start in Telegram"
          >
            Start in Telegram
          </Button>
        </Card>
      ))}
    </div>
  );
}

