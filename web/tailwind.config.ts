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
        },
        canvas: "var(--canvas)",
        surface: "var(--surface)",
        "surface-2": "var(--surface-2)",
        "surface-3": "var(--surface-3)",
        line: "var(--line)",
        "line-2": "var(--line-2)",
        ink: "var(--text)",
        muted: "var(--muted)",
        faint: "var(--faint)",
        accent: "var(--accent)",
        "accent-soft": "var(--accent-soft)",
        ok: "var(--ok)",
        warn: "var(--warn)"
      },
      fontFamily: {
        display: ["var(--font-fraunces)", "ui-serif", "serif"],
        sans: ["var(--font-inter)", "ui-sans-serif", "system-ui", "sans-serif"]
      },
      transitionTimingFunction: {
        editorial: "cubic-bezier(0.16, 1, 0.3, 1)"
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
        lg: "16px",
        xl: "20px",
        "2xl": "24px",
        card: "18px",
        pill: "20px",
        control: "10px",
        avatar: "20px"
      },
      boxShadow: {
        card: "0 4px 16px rgba(15, 23, 42, 0.08)",
        sheet: "0 -8px 24px rgba(15, 23, 42, 0.16)",
        glass: "0 8px 32px rgba(0,0,0,0.40), inset 0 1px 0 rgba(255,255,255,0.08)",
        "glass-lg": "0 16px 64px rgba(0,0,0,0.50), inset 0 1px 0 rgba(255,255,255,0.10)",
        "glow-violet": "0 0 40px rgba(124,58,237,0.45)",
        "glow-violet-lg": "0 0 70px rgba(124,58,237,0.65)",
        "glow-blue": "0 0 40px rgba(59,130,246,0.40)",
        "glow-amber": "0 0 30px rgba(245,158,11,0.35)",
        "glow-sm": "0 0 20px rgba(124,58,237,0.30)"
      },
      backdropBlur: {
        xs: "4px",
        "3xl": "64px"
      },
      fontSize: {
        xs: ["12px", "16px"],
        sm: ["14px", "20px"],
        base: ["16px", "24px"],
        lg: ["18px", "28px"],
        xl: ["20px", "30px"],
        "2xl": ["24px", "34px"],
        "3xl": ["30px", "38px"],
        "4xl": ["36px", "44px"],
        "5xl": ["48px", "56px"]
      },
      animation: {
        float: "float 6s ease-in-out infinite",
        "pulse-glow": "pulseGlow 3s ease-in-out infinite",
        "fade-up": "fadeUp 0.5s ease-out both"
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-10px)" }
        },
        pulseGlow: {
          "0%, 100%": { boxShadow: "0 0 40px rgba(124,58,237,0.45)" },
          "50%": { boxShadow: "0 0 70px rgba(124,58,237,0.70)" }
        },
        fadeUp: {
          from: { opacity: "0", transform: "translateY(12px)" },
          to: { opacity: "1", transform: "translateY(0)" }
        }
      }
    }
  },
  plugins: []
};

export default config;
