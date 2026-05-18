within ThreeAModel;

model Circuit_3A_S1
  "Feeder 3A scenario S1: Phase-1 heat pump chiller added at CUP/Steam Plant (V1 4.16 kV branch)"
  extends Circuit_3A;

  // ============================================================
  // S1 scenario parameters: Phase-1 heat pump chiller at CUP/Steam Plant
  // ------------------------------------------------------------
  // Per UCR decarb plan: phased electrification of central plant.
  // Phase-1 = first heat recovery chiller (HRC), sized at 25% of full
  // central plant heat-pump conversion. Full conversion peak electrical
  // demand assumed 4 MW (mid-range estimate for a campus this size with
  // ~30-60 MMBtu/hr peak heating demand at HRC COP ~3).
  //
  //   P_new(t) = P_base(t) + dP_HP_Phase1(t)
  //   dP_HP_Phase1 = frac_Phase1 * P_HP_full
  //
  // Modeled as constant electrical demand for the first run (medium Phase-1
  // assumption). Replace with CombiTimeTable later for hourly HRC dispatch.
  // ============================================================
  parameter Modelica.Units.SI.Power P_HP_full = 4000e3
    "Full central-plant heat-pump electrical capacity at peak (W)";
  parameter Real frac_Phase1 = 0.25
    "Phase-1 fraction of full plant heat-pump conversion";
  parameter Modelica.Units.SI.Power P_HP_Phase1 = frac_Phase1 * P_HP_full
    "Phase-1 incremental electrical demand at CUP (W)";

  // ============================================================
  // New load: Phase-1 HRC, parallel to l_OlmsteadSteam on the
  // 4.16 kV secondary of x_V1_4160. Same branch transformer (3500 kVA)
  // serves both, so no new MV protection / no topology change required.
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HP_Phase1(
    pf = PF,
    mode = Buildings.Electrical.Types.Load.FixedZ_steady_state,
    P_nominal = -P_HP_Phase1*PF,
    V_nominal = V_4160) "Phase-1 heat pump chiller (CUP)" annotation(
    Placement(transformation(origin = {18, -76}, extent = {{-38, -278}, {-22, -262}})));

  // ============================================================
  // S1-specific outputs
  // ============================================================
  Modelica.Blocks.Continuous.Integrator E_HP(k = 1/3.6e6)
    "Phase-1 heat pump cumulative kWh" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{222, 82}, {238, 98}})));
  Modelica.Blocks.Interfaces.RealOutput P_HP_kW
    "Phase-1 HRC instantaneous kW (positive = supplied)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -188}, {288, -172}}),
              iconTransformation(extent = {{272, -188}, {288, -172}})));
  Modelica.Blocks.Interfaces.RealOutput E_HP_kWh
    "Phase-1 HRC cumulative kWh" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -213}, {288, -197}}),
              iconTransformation(extent = {{272, -213}, {288, -197}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_T3_S1_pct
    "T3 % loading including Phase-1 HRC" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -238}, {288, -222}}),
              iconTransformation(extent = {{272, -238}, {288, -222}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_V1branch_pct
    "V1 4.16 kV branch transformer % of 3500 kVA" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -263}, {288, -247}}),
              iconTransformation(extent = {{272, -263}, {288, -247}})));

equation
  // ---- Connect Phase-1 HRC to the 4.16 kV branch (alongside Olmstead/Steam) ----
  connect(x_V1_4160.terminal_p, l_HP_Phase1.terminal) annotation(
    Line(points = {{-76, -326}, {-20, -346}}, color = {0, 120, 0}, thickness = 0.5));

  // ---- HRC diagnostics ----
  P_HP_kW = -l_HP_Phase1.P/1000;
  E_HP.u  = -l_HP_Phase1.P;
  E_HP_kWh = E_HP.y;

  // ---- S1 aggregate metrics (override scope of base model loading metric) ----
  Loading_T3_S1_pct = 100 * sqrt((P_total_kW)^2 + (Q_total_kvar)^2) / 18000;
  Loading_V1branch_pct = 100 * sqrt((-l_OlmsteadSteam.P - l_HP_Phase1.P)^2 *
                          (1 + QoverP^2)) / (3500e3);

  annotation(
    experiment(StopTime = 31536000, Tolerance = 1e-6),
    Documentation(info = "<html>
<h3>UCR Feeder 3A - Scenario S1: Phase-1 Heat Pump Chiller</h3>

<p><b>Scope</b>: extends the baseline Circuit_3A (S0) by adding the first
heat recovery chiller (HRC) at the CUP/Steam Plant as an incremental
electrical load. No feeder topology change, no new protection, no line
impedance changes - matches the UCR decarb plan's phased electrification
of the central energy system.</p>

<p><b>Phase-1 sizing</b>:
<ul>
  <li>Full central-plant heat-pump capacity (peak): 4 MW (mid-range
      estimate for a campus this size with ~30-60 MMBtu/hr peak heating
      demand and HRC COP ~3)</li>
  <li>Phase-1 fraction: 25%</li>
  <li>Phase-1 HRC electrical demand: 1.0 MW (constant for first run;
      replace with CombiTimeTable for hourly dispatch later)</li>
</ul>
</p>

<p><b>Connection</b>: load attached to the 4.16 kV secondary of
<code>x_V1_4160</code>, parallel to <code>l_OlmsteadSteam</code>.
Branch transformer rated 3500 kVA - Phase-1 fits with margin.</p>

<p><b>Comparison metrics</b>:
<ul>
  <li><code>P_HP_kW</code> - HRC instantaneous demand</li>
  <li><code>E_HP_kWh</code> - HRC cumulative annual energy</li>
  <li><code>Loading_T3_S1_pct</code> - T3 % loading with HRC online</li>
  <li><code>Loading_V1branch_pct</code> - 3500 kVA branch transformer
      % loading (HRC + Olmstead/Steam)</li>
</ul>
</p>

<p><b>How to run S0 vs S1</b>:
<ol>
  <li>Simulate Circuit_3A.mo (baseline S0)</li>
  <li>Simulate Circuit_3A_S1.mo (Phase-1 HRC)</li>
  <li>Compare <code>P_total_kW</code>, <code>E_3A.y</code>,
      <code>Loading_T3_pct</code> between runs</li>
</ol>
</p>

<p><b>Out of scope for Phase-1</b> (deferred to later scenarios):
full boiler retirement, heat pump + solar combination, TOU optimization,
feeder impedance studies, full 3A/3B reconfiguration.</p>
</html>"));
end Circuit_3A_S1;
