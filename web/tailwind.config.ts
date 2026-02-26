import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./design-system/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#f0f9ff",
          100: "#e0f2fe",
          500: "#0ea5e9",
          600: "#0284c7",
          700: "#0369a1"
        },
        neutral: {
          50: "#f8fafc",
          100: "#f1f5f9",
          200: "#e2e8f0",
          400: "#94a3b8",
          600: "#475569",
          700: "#334155",
          900: "#0f172a"
        }
      },
      spacing: {
        1: "4px",
        2: "8px",
        3: "12px",
        4: "16px",
        5: "20px",
        6: "24px",
        8: "32px",
        10: "40px"
      },
      borderRadius: {
        sm: "8px",
        md: "12px",
        lg: "16px"
      },
      boxShadow: {
        card: "0 4px 16px rgba(15, 23, 42, 0.08)",
        sheet: "0 -8px 24px rgba(15, 23, 42, 0.16)"
      },
      fontSize: {
        xs: ["12px", "16px"],
        sm: ["14px", "20px"],
        base: ["16px", "24px"],
        lg: ["18px", "28px"],
        xl: ["20px", "30px"],
        "2xl": ["24px", "34px"]
      }
    }
  },
  plugins: []
};

export default config;
