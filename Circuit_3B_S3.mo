within ThreeAModel;

model Circuit_3B_S3 "Feeder 3B scenario S3: distributed rooftop PV + HSS_3B BESS"
  extends Circuit_3B;
  // ============================================================
  // S3 scenario parameters for 3B
  // ------------------------------------------------------------
  // No S1 layer: Phase-1 heat pump is electrically on Feeder 3A.
  // 3B's S3 is therefore (S0 baseline) + DER stack.
  //
  // Sizing matches the 3A pattern: PV nameplate roughly equal to or
  // a bit below the host transformer kVA, all behind-the-meter
  // (non-export). BESS at the largest LV load center.
  //   HSS_3B:    1.0 MW PV (1500 kVA xfmr)
  //   Bookstore: 0.2 MW PV (300 kVA xfmr)
  //   Arts(3B):  0.5 MW PV (750 kVA xfmr)
  //   Materials: 1.0 MW PV (1500 kVA xfmr)
  //   Humanities: 0.3 MW PV (500 kVA xfmr)
  //   BESS: 1 MWh / 500 kW at HSS_3B 480 V bus
  // ============================================================
  parameter Real P_PV_HSS_3B = 1000e3 "HSS_3B rooftop PV nameplate (W)";
  parameter Real P_PV_Bookstore = 200e3 "University Bookstore PV nameplate (W)";
  parameter Real P_PV_Arts_3B = 500e3 "Arts Building (3B) PV nameplate (W)";
  parameter Real P_PV_Materials = 1000e3 "Materials Building PV nameplate (W)";
  parameter Real P_PV_Hum_3B = 300e3 "Humanities (3B) PV nameplate (W)";
  parameter Real E_BESS_kWh = 1000 "BESS energy capacity (kWh)";
  parameter Real P_BESS_kW = 500 "BESS power rating (kW)";
  parameter Real BESS_dischargeAbove_pct = 85 "T4 % loading threshold to discharge BESS";
  parameter Real BESS_chargeBelow_pct = 50 "T4 % loading threshold to charge BESS";
  // ============================================================
  // Local building load signals (W, positive) for non-export caps
  // ============================================================
  Modelica.Blocks.Sources.RealExpression loadHSS_W(y = -l_HSS_3B.P) "HSS_3B load (W, positive)" annotation(
    Placement(transformation(extent = {{200, 110}, {220, 130}})));
  Modelica.Blocks.Sources.RealExpression loadBookstore_W(y = -l_UniversityBookStore.P) "Bookstore load (W, positive)" annotation(
    Placement(transformation(extent = {{200, 80}, {220, 100}})));
  Modelica.Blocks.Sources.RealExpression loadArts_W(y = -l_ArtsBuilding_3B.P) "Arts(3B) load (W, positive)" annotation(
    Placement(transformation(extent = {{200, 50}, {220, 70}})));
  Modelica.Blocks.Sources.RealExpression loadMaterials_W(y = -l_MaterialsBuilding.P) "Materials load (W, positive)" annotation(
    Placement(transformation(extent = {{200, 20}, {220, 40}})));
  Modelica.Blocks.Sources.RealExpression loadHum_W(y = -l_Humanities_3B.P) "Humanities(3B) load (W, positive)" annotation(
    Placement(transformation(extent = {{200, -10}, {220, 10}})));
  // ============================================================
  // T4 loading signal for BESS controller
  // ============================================================
  Modelica.Blocks.Sources.RealExpression t4LoadingSignal(y = 100*sqrt(P_total_S3_kW^2 + Q_total_S3_kvar^2)/(T4_VABase/1000)) "T4 loading % from corrected S3 totals" annotation(
    Placement(transformation(extent = {{200, -40}, {220, -20}})));
  // ============================================================
  // PV blocks (signal-level, non-export)
  // ============================================================
  ThreeAModel.SolarPV pv_HSS_3B(P_rated = P_PV_HSS_3B, nonExportMode = true) "HSS_3B rooftop PV" annotation(
    Placement(transformation(extent = {{240, 110}, {260, 130}})));
  ThreeAModel.SolarPV pv_Bookstore(P_rated = P_PV_Bookstore, nonExportMode = true) "Bookstore rooftop PV" annotation(
    Placement(transformation(extent = {{240, 80}, {260, 100}})));
  ThreeAModel.SolarPV pv_Arts_3B(P_rated = P_PV_Arts_3B, nonExportMode = true) "Arts(3B) rooftop PV" annotation(
    Placement(transformation(extent = {{240, 50}, {260, 70}})));
  ThreeAModel.SolarPV pv_Materials(P_rated = P_PV_Materials, nonExportMode = true) "Materials rooftop PV" annotation(
    Placement(transformation(extent = {{240, 20}, {260, 40}})));
  ThreeAModel.SolarPV pv_Hum_3B(P_rated = P_PV_Hum_3B, nonExportMode = true) "Humanities(3B) rooftop PV" annotation(
    Placement(transformation(extent = {{240, -10}, {260, 10}})));
  // ============================================================
  // BESS controller block
  // ============================================================
  ThreeAModel.BESS_PeakShaver bess_HSS_3B(capacity_kWh = E_BESS_kWh, P_max_kW = P_BESS_kW, dischargeAbove_pct = BESS_dischargeAbove_pct, chargeBelow_pct = BESS_chargeBelow_pct) "HSS_3B-sited BESS" annotation(
    Placement(transformation(extent = {{240, -40}, {260, -20}})));
  // ============================================================
  // Sign-flip gains: PV/BESS generation -> negative load
  // ============================================================
  Modelica.Blocks.Math.Gain negPV_HSS(k = -1) annotation(
    Placement(transformation(extent = {{280, 110}, {296, 126}})));
  Modelica.Blocks.Math.Gain negPV_Book(k = -1) annotation(
    Placement(transformation(extent = {{280, 80}, {296, 96}})));
  Modelica.Blocks.Math.Gain negPV_Arts(k = -1) annotation(
    Placement(transformation(extent = {{280, 50}, {296, 66}})));
  Modelica.Blocks.Math.Gain negPV_Mat(k = -1) annotation(
    Placement(transformation(extent = {{280, 20}, {296, 36}})));
  Modelica.Blocks.Math.Gain negPV_Hum(k = -1) annotation(
    Placement(transformation(extent = {{280, -10}, {296, 6}})));
  Modelica.Blocks.Math.Gain negBESS(k = -1) annotation(
    Placement(transformation(extent = {{280, -40}, {296, -24}})));
  // ============================================================
  // PV and BESS as electrical injectors on host LV buses
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_HSS_3B_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "HSS_3B PV electrical injection" annotation(
    Placement(transformation(extent = {{310, 92}, {326, 108}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Bookstore_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_208) "Bookstore PV electrical injection" annotation(
    Placement(transformation(extent = {{310, 32}, {326, 48}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Arts_3B_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_208) "Arts(3B) PV electrical injection" annotation(
    Placement(transformation(extent = {{310, 12}, {326, 28}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Materials_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "Materials PV electrical injection" annotation(
    Placement(transformation(extent = {{310, -28}, {326, -12}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Hum_3B_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_208) "Humanities(3B) PV electrical injection" annotation(
    Placement(transformation(extent = {{310, -118}, {326, -102}})));
  // BESS sits on the HSS_3B 480 V bus (largest LV load center on 3B)
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive bess_load(pf = 1.0, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "BESS electrical port at HSS_3B 480 V bus" annotation(
    Placement(transformation(extent = {{310, 70}, {326, 86}})));
  // ============================================================
  // PV summation and energy integrator
  // ============================================================
  Modelica.Blocks.Math.Add3 sumPV_a "Sum of PVs 1-3 (W)" annotation(
    Placement(transformation(extent = {{330, 100}, {350, 120}})));
  Modelica.Blocks.Math.Add sumPV_b "Add Materials PV" annotation(
    Placement(transformation(extent = {{360, 80}, {376, 96}})));
  Modelica.Blocks.Math.Add sumPV_total "Add Humanities PV" annotation(
    Placement(transformation(extent = {{390, 60}, {406, 76}})));
  Modelica.Blocks.Continuous.Integrator E_PV_J(k = 1) "PV cum energy (J)" annotation(
    Placement(transformation(extent = {{420, 60}, {436, 76}})));
  // ============================================================
  // S3 reported outputs (RealExpression -> connector pattern)
  // ============================================================
  Modelica.Blocks.Sources.RealExpression expr_P_PV_total_kW(y = sumPV_total.y/1000) annotation(
    Placement(transformation(extent = {{220, -150}, {260, -130}})));
  Modelica.Blocks.Sources.RealExpression expr_E_PV_kWh(y = E_PV_J.y/3.6e6) annotation(
    Placement(transformation(extent = {{220, -175}, {260, -155}})));
  Modelica.Blocks.Sources.RealExpression expr_P_BESS_kW(y = bess_HSS_3B.P_bess/1000) annotation(
    Placement(transformation(extent = {{220, -200}, {260, -180}})));
  Modelica.Blocks.Sources.RealExpression expr_SoC(y = bess_HSS_3B.soc) annotation(
    Placement(transformation(extent = {{220, -225}, {260, -205}})));
  Modelica.Blocks.Sources.RealExpression expr_Loading_T4_S3(y = 100*sqrt(P_total_S3_kW^2 + Q_total_S3_kvar^2)/(T4_VABase/1000)) annotation(
    Placement(transformation(extent = {{220, -250}, {260, -230}})));
  Modelica.Blocks.Sources.RealExpression expr_P_grid_3B_kW(y = P_total_S3_kW) annotation(
    Placement(transformation(extent = {{220, -275}, {260, -255}})));
  Modelica.Blocks.Interfaces.RealOutput P_PV_total_kW "Total instantaneous PV generation (kW)" annotation(
    Placement(transformation(extent = {{272, -148}, {288, -132}}), iconTransformation(extent = {{272, -148}, {288, -132}})));
  Modelica.Blocks.Interfaces.RealOutput E_PV_kWh "Cumulative PV energy generated (kWh)" annotation(
    Placement(transformation(extent = {{272, -173}, {288, -157}}), iconTransformation(extent = {{272, -173}, {288, -157}})));
  Modelica.Blocks.Interfaces.RealOutput P_BESS_kW_out "BESS instantaneous power (kW, +discharge / -charge)" annotation(
    Placement(transformation(extent = {{272, -198}, {288, -182}}), iconTransformation(extent = {{272, -198}, {288, -182}})));
  Modelica.Blocks.Interfaces.RealOutput SoC_BESS "BESS state of charge (0-1)" annotation(
    Placement(transformation(extent = {{272, -223}, {288, -207}}), iconTransformation(extent = {{272, -223}, {288, -207}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_T4_S3_pct "T4 % loading WITH all S3 assets active (PV + BESS)" annotation(
    Placement(transformation(extent = {{272, -248}, {288, -232}}), iconTransformation(extent = {{272, -248}, {288, -232}})));
  Modelica.Blocks.Interfaces.RealOutput P_grid_3B_kW "Net grid import on 3B (load - PV - BESS_discharge), kW" annotation(
    Placement(transformation(extent = {{272, -273}, {288, -257}}), iconTransformation(extent = {{272, -273}, {288, -257}})));
  // Internal S3 aggregates that include the 5 PV injectors and BESS.
  // Computed from first principles in the equation section.
  Real P_total_S3_kW "S3 net real power including PV + BESS (kW)";
  Real Q_total_S3_kvar "S3 net reactive power (kvar)";
equation
// ---- Local load signals -> PV non-export caps ----
  connect(loadHSS_W.y, pv_HSS_3B.P_load_local);
  connect(loadBookstore_W.y, pv_Bookstore.P_load_local);
  connect(loadArts_W.y, pv_Arts_3B.P_load_local);
  connect(loadMaterials_W.y, pv_Materials.P_load_local);
  connect(loadHum_W.y, pv_Hum_3B.P_load_local);
// ---- T4 loading signal -> BESS controller ----
  connect(t4LoadingSignal.y, bess_HSS_3B.Loading_T3_pct);
// ---- PV signals -> sign flip -> electrical injection ----
  connect(pv_HSS_3B.P_solar, negPV_HSS.u);
  connect(pv_Bookstore.P_solar, negPV_Book.u);
  connect(pv_Arts_3B.P_solar, negPV_Arts.u);
  connect(pv_Materials.P_solar, negPV_Mat.u);
  connect(pv_Hum_3B.P_solar, negPV_Hum.u);
  connect(negPV_HSS.y, pv_HSS_3B_load.Pow);
  connect(negPV_Book.y, pv_Bookstore_load.Pow);
  connect(negPV_Arts.y, pv_Arts_3B_load.Pow);
  connect(negPV_Mat.y, pv_Materials_load.Pow);
  connect(negPV_Hum.y, pv_Hum_3B_load.Pow);
// ---- BESS signal -> sign flip -> electrical injection ----
  connect(bess_HSS_3B.P_bess, negBESS.u);
  connect(negBESS.y, bess_load.Pow);
// ---- Electrical attachments to host LV buses ----
  connect(x_HSS_3B.terminal_p, pv_HSS_3B_load.terminal) annotation(
    Line(points = {{-92, 100}, {310, 100}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_UniversityBookStore.terminal_p, pv_Bookstore_load.terminal) annotation(
    Line(points = {{-92, 40}, {310, 40}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_ArtsBuilding_3B.terminal_p, pv_Arts_3B_load.terminal) annotation(
    Line(points = {{-92, 20}, {310, 20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_MaterialsBuilding.terminal_p, pv_Materials_load.terminal) annotation(
    Line(points = {{-92, -20}, {310, -20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Humanities_3B.terminal_p, pv_Hum_3B_load.terminal) annotation(
    Line(points = {{-92, -110}, {310, -110}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_HSS_3B.terminal_p, bess_load.terminal) annotation(
    Line(points = {{-92, 100}, {310, 78}}, color = {0, 120, 0}, thickness = 0.5));
// ---- PV aggregation: ((HSS + Book + Arts) + Materials) + Hum ----
  connect(pv_HSS_3B.P_solar, sumPV_a.u1);
  connect(pv_Bookstore.P_solar, sumPV_a.u2);
  connect(pv_Arts_3B.P_solar, sumPV_a.u3);
  connect(sumPV_a.y, sumPV_b.u1);
  connect(pv_Materials.P_solar, sumPV_b.u2);
  connect(sumPV_b.y, sumPV_total.u1);
  connect(pv_Hum_3B.P_solar, sumPV_total.u2);
  connect(sumPV_total.y, E_PV_J.u);
// ---- Output connectors driven by RealExpression sources ----
  connect(expr_P_PV_total_kW.y, P_PV_total_kW);
  connect(expr_E_PV_kWh.y, E_PV_kWh);
  connect(expr_P_BESS_kW.y, P_BESS_kW_out);
  connect(expr_SoC.y, SoC_BESS);
  connect(expr_Loading_T4_S3.y, Loading_T4_S3_pct);
  connect(expr_P_grid_3B_kW.y, P_grid_3B_kW);
// ============================================================
// Corrected S3 net feeder demand
// ------------------------------------------------------------
// Sum all 5 base loads + 5 PV injectors + 1 BESS injector.
// Each load.P is negative when consuming, negative for PV/BESS
// when generating, so adding them subtracts from demand. /1000 -> kW.
//
// Q: PV and BESS at unity PF contribute zero reactive power.
// ============================================================
  P_total_S3_kW = -(l_HSS_3B.P + l_UniversityBookStore.P + l_ArtsBuilding_3B.P + l_MaterialsBuilding.P + l_Humanities_3B.P + pv_HSS_3B_load.P + pv_Bookstore_load.P + pv_Arts_3B_load.P + pv_Materials_load.P + pv_Hum_3B_load.P + bess_load.P)/1000;
  Q_total_S3_kvar = (-(l_HSS_3B.P + l_UniversityBookStore.P + l_ArtsBuilding_3B.P + l_MaterialsBuilding.P + l_Humanities_3B.P)/1000)*QoverP;
  annotation(
    experiment(StopTime = 31536000, Tolerance = 1e-6),
    Documentation(info = "<html>
<h3>UCR Feeder 3B - Scenario S3: Distributed PV + BESS</h3>

<p><b>Scope</b>: extends <code>Circuit_3B</code> baseline by adding rooftop
PV at all five buildings on 3B and a single BESS at the largest LV load
center (HSS_3B 480 V bus). No S1 layer because Phase-1 heat pump is
electrically loaded onto Feeder 3A only.</p>

<ul>
  <li>HSS_3B: 1.0 MW PV (480 V bus)</li>
  <li>University Bookstore: 0.2 MW PV (208 V bus)</li>
  <li>Arts Building (3B): 0.5 MW PV (208 V bus)</li>
  <li>Materials Building: 1.0 MW PV (480 V bus)</li>
  <li>Humanities (3B): 0.3 MW PV (208 V bus)</li>
  <li>Total PV nameplate: 3.0 MW</li>
  <li>BESS: 1 MWh / 500 kW at HSS_3B 480 V bus</li>
</ul>

<p>Same SolarPV and BESS_PeakShaver blocks as Circuit_3A_S3. PV in
non-export mode (output capped at local load). BESS controller watches
T4 transformer percent loading; discharges above 85%, charges below 50%.</p>

<p><b>Comparison metrics</b> (parallel to 3A_S3):</p>
<ul>
  <li><code>P_PV_total_kW</code>, <code>E_PV_kWh</code></li>
  <li><code>P_BESS_kW_out</code>, <code>SoC_BESS</code></li>
  <li><code>Loading_T4_S3_pct</code> - net T4 loading with S3 assets</li>
  <li><code>P_grid_3B_kW</code> - net grid import on 3B breaker</li>
</ul>
</html>"),
    Diagram(coordinateSystem(extent = {{-260, 140}, {440, -280}})),
    version = "",
    uses);
end Circuit_3B_S3;
