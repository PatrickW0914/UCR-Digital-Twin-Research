within ThreeAModel;

model Circuit_3B "UCR Feeder 3B - parallel feeder to 3A, served by T4 substation"
  extends Modelica.Icons.Example;
  // Parameters
  parameter Modelica.Units.SI.Frequency f = 60 "System frequency";
  parameter Modelica.Units.SI.Voltage V_MV = 12500 "Feeder line-to-line voltage (T4 secondary 12.5 kV)";
  parameter Modelica.Units.SI.Voltage V_480 = 480 "LV system 480/277 V";
  parameter Modelica.Units.SI.Voltage V_208 = 208 "LV system 208/120 V";
  parameter Real PF = 0.92 "Assumed displacement power factor (3B substation data avg ~0.92-0.94)";
  parameter Real QoverP = sqrt(1/PF^2 - 1) "Reactive-to-real power ratio for inductive PF";
  parameter Real LF_HSS_3B = 0.40 "Loading factor for HSS_3B (un-metered placeholder; replace with metered profile)";
  parameter Real LF_Bookstore = 0.40 "Loading factor for University Bookstore";
  parameter Real LF_Arts_3B = 0.60 "Loading factor for Arts Building (3B)";
  parameter Real LF_Materials = 0.50 "Loading factor for Materials Building";
  parameter Real LF_Humanities_3B = 0.40 "Loading factor for Humanities (3B side)";
  parameter Real Zpu_T4 = 0.067 "T4 transformer impedance, 6.7%";
  parameter Real T4_VABase = 18e6 "T4 nameplate VA at standard rating (18/26.88 MVA OA/FA, OA used)";
  parameter Real E_HSS_3B_ref_kWh = 1967459.95 "Validation reference for HSS_3B annual kWh (placeholder = HUB 3A value, replace when 3B meter data available)";
  
  // Source: T4 secondary 12.5 kV bus
  // T4 is the Riverside Utility Co substation transformer for 3B,
  // 18/26.88 MVA OA/FA, 66kV -> 12.5kV, Z=6.7%. Modeled as an ideal
  // grid source at the secondary bus (same approach as 3A's T3).
  
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid grid(f = f, V = V_MV, phiSou = 0) "T4 12.5 kV bus" annotation(
    Placement(transformation(extent = {{-248, -8}, {-232, 8}})));
  
  // Primary feeder nodes
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_3B "Switchboard / breaker 3B node" annotation(
    Placement(transformation(extent = {{-218, -8}, {-202, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V3_3B "V3_3B node (HSS_3B)" annotation(
    Placement(transformation(extent = {{-148, 92}, {-132, 108}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4_3B "V4_3B node (parent of Bookstore, Arts, Materials)" annotation(
    Placement(transformation(extent = {{-148, -8}, {-132, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V5_3B "V5_3B node (Humanities_3B 4.16 kV branch... 208/120 in spec; treating as direct 12.5/208)" annotation(
    Placement(transformation(extent = {{-148, -118}, {-132, -102}})));

  // Branch transformers (12.5 kV -> LV)
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_HSS_3B(VHigh = V_MV, VLow = V_480, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "HSS_3B 1500 kVA, 12.5kV -> 480V" annotation(
    Placement(transformation(extent = {{-108, 92}, {-92, 108}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_UniversityBookStore(VHigh = V_MV, VLow = V_208, VABase = 300e3, XoverR = 6, Zperc = 0.0575) "University Bookstore 300 kVA, 12.5kV -> 208/120V" annotation(
    Placement(transformation(extent = {{-108, 32}, {-92, 48}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_ArtsBuilding_3B(VHigh = V_MV, VLow = V_208, VABase = 750e3, XoverR = 6, Zperc = 0.0575) "Arts Building (3B) 750 kVA, 12.5kV -> 208/120V" annotation(
    Placement(transformation(extent = {{-108, 12}, {-92, 28}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_MaterialsBuilding(VHigh = V_MV, VLow = V_480, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "Materials Building 1500 kVA, 12.5kV -> 480V" annotation(
    Placement(transformation(extent = {{-108, -28}, {-92, -12}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_Humanities_3B(VHigh = V_MV, VLow = V_208, VABase = 500e3, XoverR = 6, Zperc = 0.0575) "Humanities (3B) 500 kVA, 12.5kV -> 208/120V dry" annotation(
    Placement(transformation(extent = {{-108, -118}, {-92, -102}})));
  
  // Loads 
  // all un-metered for 3B baseline (no per-building meter
  // data was supplied; HSS_3B is treated as un-metered with a
  // placeholder LF until metered data is available, even though
  // the validation reference is exposed as if it were metered).
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HSS_3B(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -1500e3*LF_HSS_3B*PF, V_nominal = V_480) "HSS_3B" annotation(
    Placement(transformation(extent = {{-38, 92}, {-22, 108}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_UniversityBookStore(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -300e3*LF_Bookstore*PF, V_nominal = V_208) "University Bookstore" annotation(
    Placement(transformation(extent = {{-38, 32}, {-22, 48}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_ArtsBuilding_3B(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -750e3*LF_Arts_3B*PF, V_nominal = V_208) "Arts Building 3B" annotation(
    Placement(transformation(extent = {{-38, 12}, {-22, 28}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_MaterialsBuilding(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -1500e3*LF_Materials*PF, V_nominal = V_480) "Materials Building" annotation(
    Placement(transformation(extent = {{-38, -28}, {-22, -12}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_Humanities_3B(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -500e3*LF_Humanities_3B*PF, V_nominal = V_208) "Humanities Building (3B)" annotation(
    Placement(transformation(extent = {{-38, -118}, {-22, -102}})));
  
  // Validation: cumulative kWh
  Modelica.Blocks.Continuous.Integrator E_HSS_3B(k = 1/3.6e6) "HSS_3B cum kWh" annotation(
    Placement(transformation(extent = {{220, 80}, {236, 96}})));
  Modelica.Blocks.Continuous.Integrator E_3B(k = 1/3.6e6) "Feeder 3B cum kWh" annotation(
    Placement(transformation(extent = {{220, 50}, {236, 66}})));
  
  // Reported outputs (same naming to 3A)
  Modelica.Blocks.Interfaces.RealOutput P_total_kW "kW supplied by 3B from T4" annotation(
    Placement(transformation(extent = {{272, -10}, {288, 6}}), iconTransformation(extent = {{272, -10}, {288, 6}})));
  Modelica.Blocks.Interfaces.RealOutput Q_total_kvar "kvar on 3B" annotation(
    Placement(transformation(extent = {{272, -38}, {288, -22}}), iconTransformation(extent = {{272, -38}, {288, -22}})));
  Modelica.Blocks.Interfaces.RealOutput S_total_kVA "kVA on 3B" annotation(
    Placement(transformation(extent = {{272, -63}, {288, -47}}), iconTransformation(extent = {{272, -63}, {288, -47}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_T4_pct "% of T4 18 MVA OA rating" annotation(
    Placement(transformation(extent = {{272, -88}, {288, -72}}), iconTransformation(extent = {{272, -88}, {288, -72}})));
  Modelica.Blocks.Interfaces.RealOutput err_HSS_3B_pct "(simulated - reference)/reference * 100 for HSS_3B" annotation(
    Placement(transformation(extent = {{272, -113}, {288, -97}}), iconTransformation(extent = {{272, -113}, {288, -97}})));
equation
  
// 3B breaker feeds three children
//   V3_3B -> HSS_3B
//   V4_3B -> Bookstore, Arts(3B), Materials
//   V5_3B -> Humanities(3B)
// ============================================================
  connect(grid.terminal, n_3B) annotation(
    Line(points = {{-230, 0}, {-210, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3B, n_V3_3B) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, 100}, {-146, 100}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3B, n_V4_3B) annotation(
    Line(points = {{-210, 0}, {-140, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3B, n_V5_3B) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, -110}, {-146, -110}}, color = {0, 120, 0}, thickness = 0.5));
  
// Transformer primary attachments
  connect(n_V3_3B, x_HSS_3B.terminal_n) annotation(
    Line(points = {{-146, 100}, {-96, 100}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4_3B, x_UniversityBookStore.terminal_n) annotation(
    Line(points = {{-140, 0}, {-140, 40}, {-96, 40}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4_3B, x_ArtsBuilding_3B.terminal_n) annotation(
    Line(points = {{-140, 0}, {-140, 20}, {-96, 20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4_3B, x_MaterialsBuilding.terminal_n) annotation(
    Line(points = {{-140, 0}, {-140, -20}, {-96, -20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V5_3B, x_Humanities_3B.terminal_n) annotation(
    Line(points = {{-146, -110}, {-96, -110}}, color = {0, 120, 0}, thickness = 0.5));
  
// Transformer secondary -> load attachments
  connect(x_HSS_3B.terminal_p, l_HSS_3B.terminal) annotation(
    Line(points = {{-92, 100}, {-38, 100}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_UniversityBookStore.terminal_p, l_UniversityBookStore.terminal) annotation(
    Line(points = {{-92, 40}, {-38, 40}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_ArtsBuilding_3B.terminal_p, l_ArtsBuilding_3B.terminal) annotation(
    Line(points = {{-92, 20}, {-38, 20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_MaterialsBuilding.terminal_p, l_MaterialsBuilding.terminal) annotation(
    Line(points = {{-92, -20}, {-38, -20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Humanities_3B.terminal_p, l_Humanities_3B.terminal) annotation(
    Line(points = {{-92, -110}, {-38, -110}}, color = {0, 120, 0}, thickness = 0.5));
  
// Aggregate diagnostics (positive = supplied)
  P_total_kW = -(l_HSS_3B.P + l_UniversityBookStore.P + l_ArtsBuilding_3B.P + l_MaterialsBuilding.P + l_Humanities_3B.P)/1000;
  Q_total_kvar = P_total_kW*QoverP;
  S_total_kVA = sqrt(P_total_kW^2 + Q_total_kvar^2);
  Loading_T4_pct = 100*S_total_kVA/(T4_VABase/1000);
//  Energy integrators 
  E_HSS_3B.u = -l_HSS_3B.P;
  E_3B.u = P_total_kW*1000;
  err_HSS_3B_pct = 100*(E_HSS_3B.y - E_HSS_3B_ref_kWh)/E_HSS_3B_ref_kWh;
  annotation(
    experiment(StopTime = 31536000, Tolerance = 1e-6),
    Documentation(info = "<html>
<h3>UCR Feeder 3B - Baseline (S0)</h3>

<p>Parallel feeder to 3A, served by the T4 substation transformer
(Riverside Utility Co, 18/26.88 MVA OA/FA, 66 kV -> 12.5 kV, Z = 6.7%).
Built to mirror the structure of <code>Circuit_3A</code> for like-for-like
scenario comparisons.</p>

<p><b>Topology</b>: three primary children of the 3B breaker:</p>
<ul>
  <li><code>V3_3B</code> (12.5 kV) feeds the HSS_3B 1500 kVA transformer
      to a 480/277 V LV bus</li>
  <li><code>V4_3B</code> (12.5 kV) feeds three branch transformers in
      parallel: University Bookstore (300 kVA, 208/120 V), Arts Building
      (750 kVA, 208/120 V), and Materials Building (1500 kVA, 480 V)</li>
  <li><code>V5_3B</code> (12.5 kV) feeds the Humanities 500 kVA transformer
      to 208/120 V dry-type secondary</li>
</ul>

<p><b>Loads</b>: all un-metered in this baseline. HSS_3B uses
<code>LF_HSS_3B = 0.40</code> as a placeholder; the validation output
<code>err_HSS_3B_pct</code> compares against a placeholder reference
(annual kWh borrowed from HUB on 3A, since per-building 3B meter data
was not available at modeling time). When real HSS_3B meter data becomes
available, swap to a CombiTimeTable-driven load and replace
<code>E_HSS_3B_ref_kWh</code> with the measured annual total.</p>

<p><b>Heat pump siting</b>: the campus Phase-1 heat recovery chiller is
electrically loaded onto Feeder 3A (V1 4.16 kV branch, attached to the
CUP/Steam Plant). Both feeders share the central thermal plant, but the
electrical load is on 3A only. Therefore <b>3B has no S1 scenario</b> --
the Phase-1 electrification is invisible to T4. Skip directly from S0 to
S3 (PV + BESS) on this feeder.</p>

<p><b>Out of scope</b>: protection devices (fuses, breakers, switches),
MV cable impedances (idealized), real-time meter ingest. Same scope
boundary as <code>Circuit_3A</code>.</p>
</html>"),
    Diagram(coordinateSystem(extent = {{-260, 120}, {300, -120}})),
    version = "",
    uses);
end Circuit_3B;
