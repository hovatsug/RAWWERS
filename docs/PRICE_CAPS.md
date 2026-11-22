# Price caps: euros today, pounds proposed

Written 2026-11-15. **The pound caps are PROVISIONAL: the owner has not approved them** (still so on 2026-11-22). They are a proposal to correct, not final. **2026-11-22: the owner approved them as PROVISIONAL for the test deploy only**; they stay marked provisional. The production bootstrap (`api/scripts/bootstrap_reference_data.py`) prints `PROVISIONAL` on their line; `--skip-price-caps` leaves them out.

## How caps work

- **What is capped:** a package's entry price, its price per photo (`ProPackage.price`), by niche, skill tier and currency (table `niche_package_price_cap`; `enforce_entry_price_cap` in `api/app/services/package_pricing.py`).
- **Currency:** a package is checked against the cap in its own currency only (MULTI_CURRENCY.md, decision M2).
- **Missing caps:**
  - A niche and tier with **no cap in any currency** is unrestricted.
  - A niche and tier with a cap in euros but **none in pounds refuses pound packages** (422 `no_price_cap_for_currency`). So the pound caps must exist before photographers priced in pounds can sell in the capped niches.
- **Master and minimums:** master is uncapped everywhere (empty `entry_price_max`). The minimum is 0.00 everywhere: there is no floor.
- **Where the caps live:** one file per currency, in the format the web admin's caps grid imports and downloads:
  - [api/data/price_caps/price-caps-EUR.csv](../api/data/price_caps/price-caps-EUR.csv)
  - [api/data/price_caps/price-caps-GBP.csv](../api/data/price_caps/price-caps-GBP.csv)

  The columns are `niche_slug,tier,entry_price_max,currency`. The dev seed (`api/scripts/seed_price_caps.py`) reads the same files.
- **How production gets them:** production has **zero cap rows** today, and the seed script refuses production by design. Production is loaded through the web admin, in **Settings > Price caps**:
  1. Choose **GBP**, then **Import CSV…** and load `price-caps-GBP.csv`. Then **Load into the grid**, **Review**, and **Save caps**.
  2. Choose **EUR** and do the same with `price-caps-EUR.csv`.

  Each line names its currency, so a file loaded into the wrong grid is refused whole ("Switch to GBP first"). This is in DEPLOY_CHECKLIST.md.

## The table

**How the pounds were worked out:** the euro cap at the ECB rate of 2026-11-13, **1 EUR = 0.83559 GBP**, rounded half up to the nearest **50p below £10** and to the **nearest pound from £10**. Every proposal is within 5% of the exact conversion, and every niche still rises with tier.

| Niche | Tier | EUR cap | Exact in GBP | **Proposed GBP cap** |
|---|---|---:|---:|---:|
| Corporate | rookie | 13.00 | 10.86 | **11.00** |
| | skilled | 22.00 | 18.38 | **18.00** |
| | pro | 35.00 | 29.25 | **29.00** |
| | elite | 58.00 | 48.46 | **48.00** |
| | master | uncapped | | uncapped |
| Events & Nightlife | rookie | 5.00 | 4.18 | **4.00** |
| | skilled | 8.00 | 6.68 | **6.50** |
| | pro | 14.00 | 11.70 | **12.00** |
| | elite | 24.00 | 20.05 | **20.00** |
| | master | uncapped | | uncapped |
| Family | rookie | 5.00 | 4.18 | **4.00** |
| | skilled | 8.00 | 6.68 | **6.50** |
| | pro | 13.00 | 10.86 | **11.00** |
| | elite | 23.00 | 19.22 | **19.00** |
| | master | uncapped | | uncapped |
| Food | rookie | 12.00 | 10.03 | **10.00** |
| | skilled | 18.00 | 15.04 | **15.00** |
| | pro | 30.00 | 25.07 | **25.00** |
| | elite | 50.00 | 41.78 | **42.00** |
| | master | uncapped | | uncapped |
| Portraits | rookie | 6.00 | 5.01 | **5.00** |
| | skilled | 10.00 | 8.36 | **8.50** |
| | pro | 17.00 | 14.21 | **14.00** |
| | elite | 28.00 | 23.40 | **23.00** |
| | master | uncapped | | uncapped |
| Product | rookie | 15.00 | 12.53 | **13.00** |
| | skilled | 25.00 | 20.89 | **21.00** |
| | pro | 40.00 | 33.42 | **33.00** |
| | elite | 67.00 | 55.98 | **56.00** |
| | master | uncapped | | uncapped |
| Real Estate | rookie | 8.00 | 6.68 | **6.50** |
| | skilled | 13.00 | 10.86 | **11.00** |
| | pro | 22.00 | 18.38 | **18.00** |
| | elite | 37.00 | 30.92 | **31.00** |
| | master | uncapped | | uncapped |
| Weddings | rookie | 4.00 | 3.34 | **3.50** |
| | skilled | 7.00 | 5.85 | **6.00** |
| | pro | 12.00 | 10.03 | **10.00** |
| | elite | 20.00 | 16.71 | **17.00** |
| | master | uncapped | | uncapped |
| Architecture | all | **not set** | | **not set** |
| Automotive | all | **not set** | | **not set** |
| Maternity | all | **not set** | | **not set** |
| Sports | all | **not set** | | **not set** |

## What looks odd

1. **Four active niches have no caps at all:** Architecture, Automotive, Maternity and Sports. Every tier is unrestricted in both currencies, so a rookie can charge any price there. DEPLOY_CHECKLIST.md requires every active niche and tier to have a row. **Not guessed here:** these need your figures.
2. **The euro caps themselves were never approved by you, as far as I can find.** They come from a seed commit of 2026-09-13 (`ed969ee`, "Give the price ceiling some numbers to enforce"), with the reasoning in the seed script's comments (per-photo rates, about 1.7 times per tier step). The pound caps inherit them, so a correction to a euro cap probably wants the same correction in pounds.
3. **No minimum anywhere** (0.00): nothing stops a free or 1p package. This is deliberate in the seed ("a floor is a separate policy decision"), but it is a decision still open.
4. **Weddings rookie is the lowest cap:** €4.00, proposed £3.50 per photo. This is by design (high volume per shoot). It is listed because it is the cap most likely to feel low to a UK wedding photographer.
5. **Family and Events & Nightlife are almost identical** (they differ only at pro and elite). That may be intended.
6. **The extra-photo price bounds** (`extra_image_pricing_policy`) are a separate table and are not covered here.

## Before launch

- [ ] **Review the pound caps with UK photographers** (the owner), then approve them or correct them in the admin (Settings > Price caps > GBP). Until then they stay PROVISIONAL here, in the bootstrap's output and in DEPLOY_CHECKLIST.

## Applying corrections

Edit `price-caps-GBP.csv` (or the EUR file). The API tests check, in `api/tests/test_price_caps_import.py`, that:
- both files cap the same niches and tiers;
- every niche rises with tier;
- master is uncapped;
- each pound cap is between 70% and 100% of its euro cap. This is a typo guard, so widen it in the test if a correction is meant to go outside it.

On dev: `docker exec api-api-1 python scripts/seed_price_caps.py` (`--currency GBP` for one currency; `--dry-run` first).
