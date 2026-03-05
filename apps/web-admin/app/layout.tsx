import "./globals.css";
import { PropsWithChildren } from "react";
import { AppQueryProvider } from "@/core/providers/queryProvider";
import { PageViewTracker } from "@/components/shared/PageViewTracker";

export const metadata = {
  title: "RAWWERS Admin",
  description: "RAWWERS control panel"
};

export default function RootLayout({ children }: PropsWithChildren) {
  return (
    <html lang="en">
      <body>
        <AppQueryProvider>
          <PageViewTracker />
          {children}
        </AppQueryProvider>
      </body>
    </html>
  );
}
