export const tokens = {
  colors: {
    brand: { primary: "#0ea5e9", primaryDark: "#0369a1", surface: "#f0f9ff" },
    neutral: { bg: "#f8fafc", card: "#ffffff", text: "#0f172a", muted: "#475569", border: "#e2e8f0" },
    status: { success: "#15803d", warning: "#a16207", danger: "#b91c1c" }
  },
  spacing: { x1: 4, x2: 8, x3: 12, x4: 16, x6: 24, x8: 32 },
  radii: { sm: 8, md: 12, lg: 16 },
  typography: { xs: 12, sm: 14, base: 16, lg: 18, xl: 20, x2l: 24 }
} as const;

export type Tokens = typeof tokens;
