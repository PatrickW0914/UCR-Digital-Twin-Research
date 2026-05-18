within ThreeAModel;

model Circuit_3A_S3
  "Feeder 3A scenario S3: S1 (Phase-1 HP) + distributed rooftop PV + HUB BESS"
  extends Circuit_3A_S1;

  // ============================================================
  // S3 scenario parameters
  // ------------------------------------------------------------
  // Layered on top of S1. Distributed PV on the three metered
  // buildings (HUB, Campus Surge, Physics). Single 1 MWh BESS
  // sited at HUB-B 480 V LV bus, controlled on T3 substation
  // transformer % loading.
  //
  // Sizing rationale:
  //   HUB: 1.5 MW PV (HUB-A + HUB-B rooftops, 2250 kVA combined xfmr)
  //   Surge: 0.5 MW PV (Skye Hall rooftop, 750 kVA xfmr)
  //   Physics: 0.75 MW PV (lab building, 1500 kVA xfmr)
  //   BESS: 1000 kWh / 500 kW at HUB-B 480 V bus
  //
  // All PV in non-export mode (behind-the-meter, no backflow to MV).
  // ============================================================
  parameter Real P_PV_HUB    = 1500e3 "HUB rooftop PV nameplate (W)";
  parameter Real P_PV_Surge  =  500e3 "Surge rooftop PV nameplate (W)";
  parameter Real P_PV_Phys   =  750e3 "Physics rooftop PV nameplate (W)";

  parameter Real E_BESS_kWh = 1000 "BESS energy capacity (kWh)";
  parameter Real P_BESS_kW  =  500 "BESS power rating (kW)";
  parameter Real BESS_dischargeAbove_pct = 85
    "T3 % loading threshold to discharge BESS";
  parameter Real BESS_chargeBelow_pct = 50
    "T3 % loading threshold to charge BESS";

  // ============================================================
  // Local building load signals (W, positive) for non-export PV cap.
  // Each metered load exposes .P which is negative for consumption,
  // so we use RealExpression with the negated value.
  // ============================================================
  Modelica.Blocks.Sources.RealExpression loadHUB_W(y = -l_HUBA.P - l_HUBB.P)
    "HUB-A + HUB-B load (W, positive)" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{220, 220}, {240, 240}})));
  Modelica.Blocks.Sources.RealExpression loadSurge_W(y = -l_Surge.P)
    "Surge load (W, positive)" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{220, 192}, {240, 212}})));
  Modelica.Blocks.Sources.RealExpression loadPhys_W(y = -l_Phys.P)
    "Physics load (W, positive)" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{220, 162}, {240, 182}})));

  // ============================================================
  // T3 loading signal for BESS controller.
  // Computed directly from base-model variables to avoid the name
  // collision that would occur if we tried to connect through the
  // inherited Loading_T3_pct output connector. This also breaks the
  // potential algebraic loop (BESS reacting to its own contribution)
  // because P_total_kW reflects all loads INCLUDING the BESS, but
  // RealExpression delays evaluation so the solver handles it.
  // ============================================================
  Modelica.Blocks.Sources.RealExpression t3LoadingSignal(
    y = 100 * sqrt(P_total_kW^2 + Q_total_kvar^2) / 18000)
    "T3 loading % for BESS controller" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{220, 130}, {240, 150}})));

  // ============================================================
  // Solar PV blocks (signal-level generators, non-export)
  // ============================================================
  ThreeAModel.SolarPV pv_HUB(
    P_rated = P_PV_HUB,
    nonExportMode = true) "HUB rooftop PV" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{260, 220}, {280, 240}})));
  ThreeAModel.SolarPV pv_Surge(
    P_rated = P_PV_Surge,
    nonExportMode = true) "Campus Surge rooftop PV" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{260, 190}, {280, 210}})));
  ThreeAModel.SolarPV pv_Phys(
    P_rated = P_PV_Phys,
    nonExportMode = true) "Physics rooftop PV" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{260, 160}, {280, 180}})));

  // ============================================================
  // BESS controller block
  // ============================================================
  ThreeAModel.BESS_PeakShaver bess_HUB(
    capacity_kWh = E_BESS_kWh,
    P_max_kW = P_BESS_kW,
    dischargeAbove_pct = BESS_dischargeAbove_pct,
    chargeBelow_pct = BESS_chargeBelow_pct) "HUB-sited campus BESS" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{260, 130}, {280, 150}})));

  // ============================================================
  // Sign-flip gains: PV/BESS generation (positive W out) is fed
  // through Gain(k=-1) so it appears as NEGATIVE load on the bus,
  // matching the rest of the model where load.P < 0 = power INTO bus.
  // ============================================================
  Modelica.Blocks.Math.Gain negPV_HUB(k = -1)
    "Flip sign: PV generation -> negative load" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{295, 220}, {311, 236}})));
  Modelica.Blocks.Math.Gain negPV_Surge(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{295, 190}, {311, 206}})));
  Modelica.Blocks.Math.Gain negPV_Phys(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{295, 160}, {311, 176}})));
  Modelica.Blocks.Math.Gain negBESS(k = -1)
    "Flip sign: BESS discharge (+W) -> negative load on bus" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{295, 130}, {311, 146}})));

  // ============================================================
  // PV and BESS as electrical injectors on their respective LV buses.
  // VariableZ_P_input mode lets us drive P_nominal from a signal.
  // pf=1.0 because grid-tied PV/battery inverters operate near unity.
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_HUB_load(
    pf = 1.0,
    mode = Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal = V_208) "HUB PV electrical injection" annotation(
    Placement(transformation(origin = {54, 32}, extent = {{237, 67}, {253, 83}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Surge_load(
    pf = 1.0,
    mode = Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal = V_480) "Surge PV electrical injection" annotation(
    Placement(transformation(origin = {62, 94}, extent = {{132, 52}, {148, 68}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive pv_Phys_load(
    pf = 1.0,
    mode = Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal = V_480) "Physics PV electrical injection" annotation(
    Placement(transformation(origin = {16, -76}, extent = {{2, -308}, {18, -292}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive bess_load(
    pf = 1.0,
    mode = Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal = V_480) "BESS electrical port at HUB-B 480 V bus" annotation(
    Placement(transformation(origin = {56, 0}, extent = {{237, 37}, {253, 53}})));

  // ============================================================
  // PV summation (3-input adder, no MultiSum to keep tool-portable)
  // ============================================================
  Modelica.Blocks.Math.Add3 sumPV_W
    "Sum of all PV generation (W)" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{300, 200}, {320, 220}})));

  Modelica.Blocks.Continuous.Integrator E_PV_J(k = 1)
    "PV cumulative energy in joules" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{330, 200}, {346, 216}})));

  // ============================================================
  // S3 reported outputs.
  // RealExpression source blocks feed each output connector via
  // connect() so we never assign a connector with an = equation.
  // ============================================================
  Modelica.Blocks.Sources.RealExpression expr_P_PV_total_kW(
    y = sumPV_W.y / 1000) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -288}, {260, -272}})));
  Modelica.Blocks.Sources.RealExpression expr_E_PV_kWh(
    y = E_PV_J.y / 3.6e6) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -313}, {260, -297}})));
  Modelica.Blocks.Sources.RealExpression expr_P_BESS_kW(
    y = bess_HUB.P_bess / 1000) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -338}, {260, -322}})));
  Modelica.Blocks.Sources.RealExpression expr_SoC(
    y = bess_HUB.soc) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -363}, {260, -347}})));
  Modelica.Blocks.Sources.RealExpression expr_Loading_T3_S3(
    y = 100 * sqrt(P_total_kW^2 + Q_total_kvar^2) / 18000) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -388}, {260, -372}})));
  Modelica.Blocks.Sources.RealExpression expr_P_grid_3A_kW(
    y = P_total_kW) annotation(
    Placement(transformation(origin = {2, -98}, extent = {{220, -413}, {260, -397}})));

  Modelica.Blocks.Interfaces.RealOutput P_PV_total_kW
    "Total instantaneous PV generation (kW)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -288}, {288, -272}}),
              iconTransformation(extent = {{272, -288}, {288, -272}})));
  Modelica.Blocks.Interfaces.RealOutput E_PV_kWh
    "Cumulative PV energy generated (kWh)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -313}, {288, -297}}),
              iconTransformation(extent = {{272, -313}, {288, -297}})));
  Modelica.Blocks.Interfaces.RealOutput P_BESS_kW_out
    "BESS instantaneous power (kW, +discharge / -charge)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -338}, {288, -322}}),
              iconTransformation(extent = {{272, -338}, {288, -322}})));
  Modelica.Blocks.Interfaces.RealOutput SoC_BESS
    "BESS state of charge (0-1)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -363}, {288, -347}}),
              iconTransformation(extent = {{272, -363}, {288, -347}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_T3_S3_pct
    "T3 % loading WITH all S3 assets active (HP + PV + BESS)" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -388}, {288, -372}}),
              iconTransformation(extent = {{272, -388}, {288, -372}})));
  Modelica.Blocks.Interfaces.RealOutput P_grid_3A_kW
    "Net grid import on 3A (load + HP - PV - BESS_discharge), kW" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -413}, {288, -397}}),
              iconTransformation(extent = {{272, -413}, {288, -397}})));

equation
  // ---- Local load signals -> PV non-export caps ----
  connect(loadHUB_W.y,   pv_HUB.P_load_local);
  connect(loadSurge_W.y, pv_Surge.P_load_local);
  connect(loadPhys_W.y,  pv_Phys.P_load_local);

  // ---- T3 loading signal -> BESS controller ----
  connect(t3LoadingSignal.y, bess_HUB.Loading_T3_pct);

  // ---- PV signals -> sign flip -> electrical injection ----
  connect(pv_HUB.P_solar,   negPV_HUB.u);
  connect(pv_Surge.P_solar, negPV_Surge.u);
  connect(pv_Phys.P_solar,  negPV_Phys.u);
  connect(negPV_HUB.y,   pv_HUB_load.Pow);
  connect(negPV_Surge.y, pv_Surge_load.Pow);
  connect(negPV_Phys.y,  pv_Phys_load.Pow);

  // ---- BESS signal -> sign flip -> electrical injection ----
  connect(bess_HUB.P_bess, negBESS.u);
  connect(negBESS.y, bess_load.Pow);

  // ---- Electrical attachments to host LV buses ----
  connect(x_HUBA.terminal_p, pv_HUB_load.terminal) annotation(
    Line(points = {{207, 107}, {291, 107}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Surge.terminal_p, pv_Surge_load.terminal) annotation(
    Line(points = {{124, 154}, {194, 154}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Phys.terminal_p, pv_Phys_load.terminal) annotation(
    Line(points = {{-86, -376}, {18, -376}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_HUBB.terminal_p, bess_load.terminal) annotation(
    Line(points = {{209, 45}, {293, 45}}, color = {0, 120, 0}, thickness = 0.5));

  // ---- PV aggregation and energy integration ----
  connect(pv_HUB.P_solar,   sumPV_W.u1);
  connect(pv_Surge.P_solar, sumPV_W.u2);
  connect(pv_Phys.P_solar,  sumPV_W.u3);
  connect(sumPV_W.y, E_PV_J.u);

  // ---- Output connectors driven by RealExpression sources ----
  connect(expr_P_PV_total_kW.y,   P_PV_total_kW);
  connect(expr_E_PV_kWh.y,        E_PV_kWh);
  connect(expr_P_BESS_kW.y,       P_BESS_kW_out);
  connect(expr_SoC.y,             SoC_BESS);
  connect(expr_Loading_T3_S3.y,   Loading_T3_S3_pct);
  connect(expr_P_grid_3A_kW.y,    P_grid_3A_kW);

  annotation(
    experiment(StopTime = 31536000, Tolerance = 1e-6),
    Documentation(info = "<html>
<h3>UCR Feeder 3A - Scenario S3: Heat Pump + Distributed PV + BESS</h3>

<p><b>Scope</b>: Stacks on top of S1 (Phase-1 heat pump). Adds:</p>
<ul>
  <li>1.5 MW rooftop PV at HUB (208 V LV bus)</li>
  <li>0.5 MW rooftop PV at Campus Surge (480 V LV bus)</li>
  <li>0.75 MW rooftop PV at Physics (480 V LV bus)</li>
  <li>1 MWh / 500 kW BESS at HUB-B 480 V bus</li>
</ul>

<p><b>PV model</b>: ported from the Feeder 3B work. Diurnal bell-curve
irradiance peaking at 12:30 PST, 20% panel efficiency, 80% performance
ratio. All three PVs in <b>non-export mode</b> -- output is capped at
local building load to avoid backflow onto the MV feeder.</p>

<p><b>BESS controller</b>: peak-shaving on T3 transformer % loading.
Discharges when T3 &gt; 85%, charges when T3 &lt; 50%, idles otherwise.
SoC clamped to [0.10, 0.90]. Round-trip efficiency 92%.</p>

<p><b>Comparison metrics</b>:</p>
<ul>
  <li><code>P_PV_total_kW</code> - instantaneous PV generation</li>
  <li><code>E_PV_kWh</code> - cumulative PV energy (annual)</li>
  <li><code>P_BESS_kW_out</code> - instantaneous BESS power</li>
  <li><code>SoC_BESS</code> - BESS state of charge over time</li>
  <li><code>Loading_T3_S3_pct</code> - net T3 loading after all S3 assets</li>
  <li><code>P_grid_3A_kW</code> - net grid import on 3A breaker</li>
</ul>
</html>"));
end Circuit_3A_S3;
