# TIF_PLMB — Project Context for Claude

## What This Project Is

An econometric study evaluating the fiscal feasibility of **Tax Increment Financing (TIF)** for extending the **Primera Línea del Metro de Bogotá (PLMB)**. The core question: does the metro announcement/contracting (2019) generate a causally significant increase in cadastral property values (*avalúos*) within the metro's area of influence, and are those increases sufficient to finance the infrastructure through TIF?

**Author:** Maria Corina Hernandez (Universidad de los Andes)
**Period:** February–March 2026
**Software:** Stata 17 + ArcGIS Pro
**Language of deliverables:** Spanish (Colombian government consulting report)

---

## Identification Strategy

Difference-in-Differences (DiD) with lot and year fixed effects on a balanced 12-year panel (2014–2025) of Bogotá cadastral parcels (~2.3 million properties, ~27.6 million obs).

- **Treatment group:** Properties within the metro's area of influence AND year ≥ 2019
- **Control group:** All other private properties in Bogotá (outside AI)
- **Outcome:** `ln_avaluo_real_2014` = log of cadastral assessment in 2014 constant COP
- **Clustered SE:** at *barrio* (neighborhood) level
- **Estimator:** `reghdfe` (Correia 2017)
- **Treatment cutoff year:** 2019 (announcement/contracting of PLMB)

---

## Data Sources

| Source | Content | File(s) |
|--------|---------|---------|
| UAECD | Annual cadastral assessments 2014–2025 | `PREDIO_FINAL_20YY.csv` |
| ArcGIS | Treatment assignment (buffer 400/800/1200m + Nueva AI) | `Lotes_catastrales.dbf`, `Lotes_catastrales_treat_robust.dbf` |
| UAECD/Gov | Nueva Área de Influencia (street-bounded, legally validated) | `Nueva Área de Influencia/*.csv` |
| DANE | Monthly December CPI 2014–2025 for deflation | `inflacion.xlsx` |
| Catastro | Block-level distances to CBD, TM stations, road network | `base_bogota_270221.dta` |
| EM2021 | Employment by block (2021) | `EM2021_800m_PLMB/` |

---

## Key Variables

- `codigo_lote` — unique lot ID (barrio+manzana+predio concatenated, zero-padded)
- `treat` — DiD treatment indicator (in AI AND year ≥ 2019)
- `ln_avaluo_real_2014` — log real cadastral assessment (2014 COP)
- `ln_avaluo_com_2014` — log real commercial assessment
- `descripcion_destino` — economic destination (fixed to 2018 to avoid endogeneity)
- `codigo_estrato` — socioeconomic stratum 1–6 (fixed to 2018)
- `tramo_800` — PLMB segment (1, 2, or 3)
- `I_AccB` — composite urban accessibility index (PCA-based, from Stage 7)
- `economic_access` — log(1+employment) × transport accessibility index

---

## Analysis Pipeline (9 Stata do-files)

| File | Purpose | Key Output |
|------|---------|------------|
| `1_append_merge.do` | Append 12 years of CSVs, build balanced panel, merge treatment shapefiles | `predios.dta` |
| `2_analysis_did.do` | Deflate to 2014 COP, main DiD + event study (1200m buffer) | `predios_proc.dta`, `DID_simple.docx`, PDFs |
| `3_analysis_did_atributes.do` | DiD on built area/floors at block level | `manzanas_proc.dta`, `DID_atributes.docx` |
| `3_analysis_did_heter.do` | Heterogeneity by destination, stratum, tramo | `DID_heter_*.docx` |
| `4_analysis_cem.do` | Coarsened Exact Matching (CEM) robustness | `treat_weights.dta`, `DID_CEM.docx` |
| `5_robustez.do` | Robustness: 400m and 1200m buffers | `predios_robust.dta` |
| `6_nueva_ai.do` | **Default spec from here on:** Nueva AI (street-bounded treatment) | `predios_proc_ai2.dta` |
| `7_centralidades.do` | Build accessibility indices at block level (PCA → I_AccB) | `manzanas_access.dta` |
| `8_robustez_control.do` | Robustness: restricted control group (1200m ring around AI) | Tables appended |
| `9_heter_access.do` | Triple heterogeneity: destination/stratum × accessibility | `DID_heter_*_access.docx` |

**Execution order:** 1 → 2 → {3a, 3b, 4, 5} → 6 → 7 → {8, 9}

---

## Treatment Definitions

| Name | Variable | Use |
|------|----------|-----|
| Buffer 400m | `treatment_400` | Narrow robustness check |
| Buffer 800m | `treatment_800` | Original base spec (Stages 1–5) |
| Buffer 1200m | `treatment_1200` | Wide robustness check |
| Nueva AI (AI Vías) | `treatment` (Stage 6+) | **Default spec for Stages 6–9** — street-bounded, legally validated |

---

## Sample Exclusions

Always excluded: `VIAS`, `ESPACIO PÚBLICO`, `LOTE DEL ESTADO`, `DOTACIONAL PÚBLICO`, `RECREACIONAL PÚBLICO` (public/non-taxable categories).
Also excluded: rural UPZs (cod_upz ∈ {1,3,4,5}), Sumapaz.
CEM only: also excludes `AGRÍCOLA`, `AGROPECUARIO`, `PECUARIO`, `FORESTAL`, rural unbuilt parcels.

---

## Parallel Trends

Verified via dynamic DiD (event study): year-by-year interactions with 2018 as reference year. Pre-treatment coefficients (2014–2017) should be close to zero.
Treatment is simultaneous (all treated units treated in 2019), so calendar-year and event-time coefficients are identical — no staggered adoption issues.

---

## Accessibility Index (Stage 7)

`I_AccB` = PCA-based composite from 17 distance/accessibility variables (SITP, Alimentadores, TM, arterial/local/troncal/rural roads, 6 specific corridors). 7 factors retained (eigenvalue > 1), varimax rotation, aggregated into 4 interpretable dimensions:
- D1: Structural accessibility (main road network)
- D2: Peripherality-rurality
- D3: Urban capillarity (local network)
- D4: Specific corridors

Weighted by relative eigenvalue: `I_AccB = Σ D_k × (eigenvalue_k / Σeigenvalues)`

---

## Output Files

All output goes to `Datos/outcomes/`. Key tables in `.docx` via `outreg2`, event-study plots in `.pdf` via `coefplot`.

---

## Important Notes for Future Conversations

- The **Nota Metodológica** (Word docx) is the main methodology write-up and was authored by Claude. A new version is being written as a continuous-prose government consulting document.
- Results have not yet been analyzed/discussed — the do-files are still being run.
- The project is a deliverable for the **Bogotá Mayor's office** and the national government.
- The analysis uses `reghdfe` with `a(codigo_lote year)` — not `i.year` — for computational efficiency on the large panel.
- CEM matching is done on the 2018 cross-section and weights are then merged back to the full panel.
