import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        accent: "var(--accent)",
        bg: "var(--bg)",
        surface: "var(--surface)",
        surface2: "var(--surface2)",
        textPrimary: "var(--text-primary)",
        textSecondary: "var(--text-secondary)",
        borderSubtle: "var(--border-subtle)",
        danger: "#b42318"
      },
      borderRadius: {
        lg: "14px",
        xl: "16px",
        "2xl": "20px"
      },
      boxShadow: {
        soft: "0 10px 30px rgba(0,0,0,0.06)",
        card: "0 1px 2px rgba(0,0,0,0.05), 0 8px 24px rgba(0,0,0,0.04)"
      }
    }
  },
  plugins: []
};

export default config;
