import { UnsubscribeForm } from "./unsubscribe-form";

/**
 * The page an email's unsubscribe link opens. Public: no sign-in. Opening it
 * changes nothing (mail scanners open every link); its button does.
 */
export default function UnsubscribePage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const one = (key: string) => {
    const value = searchParams[key];
    return typeof value === "string" ? value : "";
  };
  return <UnsubscribeForm u={one("u")} t={one("t")} k={one("k")} s={one("s")} />;
}
