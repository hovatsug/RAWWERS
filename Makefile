# Repo-wide tasks. Each part keeps its own (api/Makefile and so on).

.PHONY: brand
# Regenerates every logo, icon and launch image from the design tokens.
brand:
	cd tools/brand && npm ci --no-audit --no-fund && npm run generate
