# UCR Campus Electrical Digital Twin

A Modelica simulation model of UC Riverside's medium-voltage electrical
distribution system, built to evaluate the campus decarbonization
roadmap before capital is committed.

This repository contains parallel models of **Feeder 3A** and
**Feeder 3B** — two of UCR's main 12 kV distribution feeders — with
scenarios for Phase-1 central-plant electrification (heat recovery
chiller) and distributed energy resources (rooftop PV + battery
storage). Models are calibrated against fifteen-minute interval
substation data from October 2025 – February 2026.

---

## Why this exists

UCR's decarbonization plan calls for replacing the gas-fired central
energy plant with heat pumps over four phases, scaling from a 1 MW
Phase-1 heat recovery chiller to roughly 4 MW at full electrification.
The question this project answers: **can the existing 12 kV
distribution absorb that load, and if not, where and when do upgrades
become necessary?**

A digital twin lets us answer that in software, against measured
operational data, before committing real capital.

---

## What's in this repo

### Modelica package: `ThreeAModel/`

| File | Purpose |
|---|---|
| `package.mo` / `package.order` | Modelica package machinery |
| `Circuit_3A.mo` | Feeder 3A baseline (S0) — 14 buildings, T3 18 MVA substation |
| `Circuit_3A_S1.mo` | S1 — adds 1 MW Phase-1 heat recovery chiller |
| `Circuit_3A_S3.mo` | S3 — adds distributed PV (2.75 MW) + 1 MWh BESS |
| `Circuit_3B.mo` | Feeder 3B baseline (S0) — 5 buildings, T4 18/26.88 MVA substation |
| `Circuit_3B_S3.mo` | S3 — adds distributed PV (3.0 MW) + 1 MWh BESS |
| `Feeder3A_RealLoad.mo` | Single-bus lumped model for total-load validation |
| `Feeder3A_Test.mo` | Time-series loader (CSV inspection) |
| `SolarPV.mo` | Reusable diurnal PV generation block |
| `BESS_PeakShaver.mo` | Reusable BESS block with transformer-loading-based controller |

### Data files

| File | Purpose |
|---|---|
| `Feeder_3A_Modelica.csv` | 15-minute total feeder P/Q, Oct 2025 – Feb 2026 |
| `Loads_3A_2025_kW.txt` | Monthly per-building load profile (HUB, MSE, Surge, Bookstore, Physics) |
| `Substation_electricl_data_for_3B.xlsx` | 15-minute T4 substation measurements |

---

## How to run

### Requirements

- **OpenModelica** 1.24.0 or newer
- **LBNL Buildings library** 12.1.0 (or 11.x — earlier versions are
  more forgiving with OpenModelica's icon parser; see Known Issues)

### Loading the package

1. Clone or download this repo
2. Open OMEdit
3. **File → Open Model/Library File**
4. Navigate to the `ThreeAModel/` directory and select **`package.mo`**
   (not the individual model files)
5. The package tree should appear in the Libraries Browser

> **Important:** open `package.mo`, not the child `.mo` files
> directly — otherwise OpenModelica cannot resolve the
> `within ThreeAModel;` namespace declarations and you'll get
> grammar errors.

### Running a simulation

Each model has `experiment(StopTime = 31536000)` set — that's one
full year in seconds. Simulation horizon and tolerance can be
overridden in the simulation setup dialog.

Suggested run order for reproducing the headline findings:

1. `Circuit_3A` — baseline T3 loading and per-building validation
2. `Circuit_3A_S1` — Phase-1 heat pump impact
3. `Circuit_3A_S3` — PV + BESS overlay
4. `Circuit_3B` — parallel baseline on 3B
5. `Circuit_3B_S3` — same DER overlay on 3B

### Local-path setup

`Circuit_3A.mo` has a hard-coded path on line 19 to the monthly
load profile:

```modelica
parameter String csvPath = "C:/Users/<your-user>/.../Loads_3A_2025_kW.txt";
```

Change this to the actual path on your machine, or replace with the
portable form:

```modelica
parameter String csvPath = Modelica.Utilities.Files.loadResource(
  "modelica://ThreeAModel/Loads_3A_2025_kW.txt");
```

---

## Findings so far

### Validation

Per-building cumulative annual kWh on Feeder 3A validates against
measured reference totals for HUB, Campus Surge, and Physics within
the noise floor of monthly-resolution input data. The `err_*_pct`
output variables expose the validation error directly so any
re-calibration is auditable.

Feeder 3B per-building validation is pending real meter data; the
model currently uses loading factor assumptions for all five
buildings and references the 3A HUB annual total as a placeholder
for HSS_3B.

### Scenario results

| Metric | Feeder 3A | Feeder 3B |
|---|---|---|
| Substation rating | 18 MVA (T3) | 18 MVA OA (T4) |
| S0 baseline T3/T4 peak | ~22% | ~12% |
| S1 (+Phase-1 HP) | ~28% | N/A |
| S3 (+PV +BESS) | 27–31% (osc.) | 12-14% |
| Total PV deployed in S3 | 2.75 MW across 3 buildings | 3.0 MW across 5 buildings |
| BESS in S3 | 1 MWh / 500 kW at HUB-B | 1 MWh / 500 kW at HSS_3B |

### Three headline findings

1. **The modeling approach works.** Annual energy validated within
   acceptable error on both feeders. Reusable components extend to
   additional feeders without rewriting.

2. **Phase-1 electrification is feasible today.** No substation
   upgrade required on either feeder. T3 loading rises by ~5.5
   percentage points under the Phase-1 heat pump — well within
   existing headroom.

3. **DER value scales with electrification depth.** PV provides
   modest daytime relief at current load levels. Battery storage
   sized for Phase-1 doesn't dispatch (T3/T4 never approach the 85%
   threshold). Both become essential as central-plant electrification
   scales toward Phase 4.

---

## Architecture notes

### Topology approach

Each `Circuit_3X.mo` model captures the actual single-line diagram
as a network of named buses (`n_V3A`, `n_V4`, etc.), branch
transformers (`x_HUB-A`, `x_HUB-B`, etc.), and building loads
(`l_HUB-A`, `l_HUB-B`, etc.). The Modelica `connect()` statements
mirror the as-built electrical topology one-to-one. MV cables are
idealized (zero impedance) because the Buildings library's automatic
line-mode does not support 12 kV class.

### Scenario inheritance

Scenarios stack via Modelica `extends`:

```
Circuit_3A          ← baseline
   └── Circuit_3A_S1      ← extends Circuit_3A, adds heat pump
          └── Circuit_3A_S3   ← extends S1, adds PV + BESS

Circuit_3B          ← baseline
   └── Circuit_3B_S3      ← extends Circuit_3B, adds PV + BESS
                          (no S1: heat pump is on 3A only)
```

This makes every scenario directly comparable — the underlying
topology is bit-identical across scenarios on the same feeder.

### Aggregate metric correction

The baseline `P_total_kW` in `Circuit_3A` hard-codes a sum of the
original 14 loads, so it is blind to anything added in scenarios.
S1 and S3 compute their own aggregate variables
(`P_total_S1_kW`, `P_total_S3_kW`) from first principles to include
the heat pump and DER injectors. This was a debugging fix during
development — see commit history for the diagnostic plot that
revealed it.

### PV and BESS modeling

`SolarPV.mo` implements a diurnal generation profile with a Gaussian
irradiance approximation peaking at 12:30 PST (UCR latitude ~33.97°N).
Default panel efficiency 20%, performance ratio 80%. Non-export mode
caps output at local building load to prevent backflow onto the MV
feeder — the standard configuration for behind-the-meter campus solar.

`BESS_PeakShaver.mo` implements a two-threshold peak-shaving controller
on transformer percent loading (not raw kW). Discharges above
`dischargeAbove_pct` (default 85%), charges below `chargeBelow_pct`
(default 50%), idles in the deadband. SoC clamped to [0.10, 0.90] for
cycle-life modeling. Round-trip efficiency 92%.

Both blocks are parameterized — drop them onto any feeder model with
new nameplate values.

---

## Known issues

### Buildings library / OpenModelica icon resolution

OpenModelica may emit `Scripting Error` messages referencing
`RefAngleConversion.mo` inside the Buildings library:

```
Error: Variable ground_1 not found in scope RefAngleConversion.
Error: Variable ground_2 not found in scope RefAngleConversion.
```

These come from an icon-only annotation class and are **cosmetic** —
they affect icon rendering in the Diagram view but do not prevent
compilation or simulation. Models run correctly despite the errors.

If you want to eliminate them, install Buildings 11.0.0 alongside or
instead of 12.1.0. Buildings 11.x has a longer track record of clean
loading in OpenModelica.

### Line ending sensitivity

OpenModelica on Windows can fail to load `.mo` files if line endings
are mixed (LF vs. CRLF) across the package. All files in this repo
are checked in with **CRLF line endings** to match what OpenModelica
expects on Windows. Don't reformat them with a tool that strips CRLF
unless you also strip CRLF from `package.mo` to match.

### Hard-coded path in Circuit_3A.mo

Line 19 contains an absolute path to `Loads_3A_2025_kW.txt` from the
original developer's machine. Update this before running, or replace
with the `loadResource(...)` portable form shown above.

---

## Roadmap

Near-term (next quarter):

- Replace constant-load Phase-1 heat pump with variable-load
  `Buildings.Fluid.Chillers.ElectricEIR` driven by a cooling-demand
  profile
- Add chilled-water thermal energy storage
  (`Buildings.Fluid.Storage.Stratified`) for thermal-side load shifting
- Sweep `frac_Phase1` parameter from 0.25 → 1.0 to find the substation
  upgrade trigger point as electrification deepens
- Per-building metering on Feeder 3B to enable proper validation

Mid-term:

- Time-of-use rate structure for economic BESS dispatch
- Weather-driven irradiance (replace analytic bell curve with
  measured/forecast solar data)
- Extend modeling to additional UCR feeders

Long-term:

- Full campus-wide twin with shared central plant model
- Real-time meter ingest to keep the model calibrated against
  operational drift
- Co-optimization of PV sizing, BESS dispatch, and chiller staging
  across phases of electrification

---

## Out of scope

The following are deliberately not modeled. Listed here so
expectations are calibrated:

- **Protection coordination** — no fuses, breakers, or switches.
  This is a power-flow model, not a relay-settings study.
- **MV cable impedances** — idealized as zero. The Buildings library's
  automatic cable mode doesn't support 12 kV class. Voltage drop and
  losses on the MV side are therefore not captured.
- **Economic / financial analysis** — no capital costs, no tariffs, no
  ROI. The model answers feasibility questions, not investment-decision
  questions.
- **Sub-monthly load shape** — input data is monthly resolution per
  building. Daily and hourly load shape inside a month is not captured.

---

## License & attribution

This work was developed at UC Riverside as part of the campus
electrical distribution digital-twin project.

LBNL Buildings Library is © Lawrence Berkeley National Laboratory and
distributed under the Modified BSD License. See
https://simulationresearch.lbl.gov/modelica/ for details.

OpenModelica is © OSMC and distributed under the OSMC-PL.

---

## Contact

Questions, suggestions, or interest in extending this work to other
campus feeders: please open an issue.
