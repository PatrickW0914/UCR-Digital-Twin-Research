within ThreeAModel ;

model Circuit_3A "UCR Feeder 3A - corrected topology: V4D sibling of V4A, Dance split from Athletics"
  extends Modelica.Icons.Example;
  // ============================================================
  // Parameters
  // ============================================================
  parameter Modelica.Units.SI.Frequency f = 60 "System frequency";
  parameter Modelica.Units.SI.Voltage V_MV = 12470 "Feeder line-to-line voltage";
  parameter Modelica.Units.SI.Voltage V_480 = 480 "LV system 480/277 V";
  parameter Modelica.Units.SI.Voltage V_208 = 208 "LV system 208/120 V";
  parameter Modelica.Units.SI.Voltage V_4160 = 4160 "Intermediate 4.16 kV branch voltage";
  parameter Real PF = 0.90 "Assumed displacement power factor for all loads";
  parameter Real QoverP = sqrt(1/PF^2 - 1) "Reactive-to-real power ratio for inductive PF";
  parameter Real LF_unmet = 0.40 "Diversified loading factor for un-metered branches";
  parameter Real LF_MRB1 = 0.20 "Placeholder loading factor for MRB1 until metered profile is connected";
  parameter Real LF_4160Branch = 0.10 "Placeholder loading factor for Olmstead/Steam Plant 4.16 kV branch";
  parameter Real Zpu_T3 = 0.067 "T3 transformer impedance, 6.7%";
  parameter String csvPath = "C:/Users/mar1o/UCR-Digital-Twin/ThreeAModel/Loads_3A_2025_kW.txt" "Path to monthly load profile (Modelica CombiTimeTable .txt format)";
  parameter Real f_HUBA = 750/(750 + 1500) "HUB-A share of HUB meter";
  parameter Real f_HUBB = 1500/(750 + 1500) "HUB-B share of HUB meter";
  parameter Real E_HUB_ref_kWh = 1967459.95;
  parameter Real E_Surge_ref_kWh = 1010099.0;
  parameter Real E_Phys_ref_kWh = 1762397.0;
  // ============================================================
  // Source: T3 secondary 12.47 kV bus
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid grid(f = f, V = V_MV, phiSou = 0) "T3 12.47 kV bus" annotation(
    Placement(transformation(extent = {{-248, -8}, {-232, 8}})));
  // ============================================================
  // Explicit 3A primary feeder nodes (Switchboard B / breaker 3A and switching subs)
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_3A "Switchboard B / breaker 3A node" annotation(
    Placement(transformation(extent = {{-218, -8}, {-202, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V3A "V3A node (HSS)" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-148, 122}, {-132, 138}}), iconTransformation(extent = {{-148, 122}, {-132, 138}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4 "V4 node (parent of V4A and V4D)" annotation(
    Placement(transformation(extent = {{-148, -8}, {-132, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4A "V4A node" annotation(
    Placement(transformation(extent = {{-108, -8}, {-92, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4B "V4B node" annotation(
    Placement(transformation(extent = {{-68, -8}, {-52, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4C "V4C node (parent of Arts, Fine Arts, V4F)" annotation(
    Placement(transformation(extent = {{-28, -8}, {-12, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4D "V4D node, sibling of V4A: feeds CHASS / Athletics / Dance / SAS" annotation(
    Placement(transformation(origin = {20, -106}, extent = {{-108, -33}, {-92, -17}}), iconTransformation(extent = {{-108, -33}, {-92, -17}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4F "V4F node (child of V4C)" annotation(
    Placement(transformation(origin = {48, 0}, extent = {{52, -8}, {68, 8}}), iconTransformation(extent = {{52, -8}, {68, 8}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_HV4 "HV4 node feeding HUB A and HUB B" annotation(
    Placement(transformation(origin = {48, 18}, extent = {{102, 42}, {118, 58}}), iconTransformation(extent = {{102, 42}, {118, 58}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4G "V4G node" annotation(
    Placement(transformation(origin = {76, 40}, extent = {{102, -48}, {118, -32}}), iconTransformation(extent = {{102, -48}, {118, -32}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V4N "V4N node" annotation(
    Placement(transformation(origin = {76, 40}, extent = {{142, -48}, {158, -32}}), iconTransformation(extent = {{142, -48}, {158, -32}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V30 "V30 node with side tap to MRB1" annotation(
    Placement(transformation(origin = {76, 40}, extent = {{182, -48}, {198, -32}}), iconTransformation(extent = {{182, -48}, {198, -32}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V31 "V31 downstream node" annotation(
    Placement(transformation(origin = {76, 40}, extent = {{222, -28}, {238, -12}}), iconTransformation(extent = {{222, -28}, {238, -12}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V32 "V32 downstream node" annotation(
    Placement(transformation(origin = {76, 40}, extent = {{222, -58}, {238, -42}}), iconTransformation(extent = {{222, -58}, {238, -42}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V5 "V5 node (Humanities Building)" annotation(
    Placement(transformation(origin = {-28, -48}, extent = {{-148, -208}, {-132, -192}}), iconTransformation(extent = {{-148, -208}, {-132, -192}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_V1 "V1 disconnect feeding 12.47/4.16 kV branch" annotation(
    Placement(transformation(origin = {-6, -76}, extent = {{-148, -258}, {-132, -242}}), iconTransformation(extent = {{-148, -258}, {-132, -242}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n n_3A4k7 "3A4k7 branch node for Physics" annotation(
    Placement(transformation(origin = {-6, -76}, extent = {{-148, -308}, {-132, -292}}), iconTransformation(extent = {{-148, -308}, {-132, -292}})));
  // ============================================================
  // Time-series loader
  // ============================================================
  Modelica.Blocks.Sources.CombiTimeTable loadTable(tableOnFile = true, tableName = "tab1", fileName = csvPath, columns = {2, 4, 6}, smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments, extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint) "Monthly average kW for HUB, Campus Surge, and Physics" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-248, 182}, {-232, 198}})));
  Modelica.Blocks.Math.Gain gHUBA(k = f_HUBA) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-218, 212}, {-202, 228}})));
  Modelica.Blocks.Math.Gain gHUBB(k = f_HUBB) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-218, 192}, {-202, 208}})));
  Modelica.Blocks.Math.Gain negHUBA(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-183, 212}, {-167, 228}})));
  Modelica.Blocks.Math.Gain negHUBB(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-183, 192}, {-167, 208}})));
  Modelica.Blocks.Math.Gain negSurge(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-183, 172}, {-167, 188}})));
  Modelica.Blocks.Math.Gain negPhys(k = -1) annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{-183, 152}, {-167, 168}})));
  // ============================================================
  // Branch transformers (12.47 kV -> LV)
  // ============================================================
  // V3A
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_HSS(VHigh = V_MV, VLow = V_480, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "HSS 1500 kVA, 480/277 V dry, 200E" annotation(
    Placement(transformation(origin = {12, 72}, extent = {{-108, 122}, {-92, 138}})));
  // V4D family (CHASS, Athletics, Dance, SAS) -- placed BELOW backbone to keep V4D wiring visually separate from V4C
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_CHASS(VHigh = V_MV, VLow = V_208, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "CHASS Inter S 1500 kVA, 208/120 V, 200E" annotation(
    Placement(transformation(origin = {2, -100}, extent = {{22, -128}, {38, -112}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_Athletics(VHigh = V_MV, VLow = V_208, VABase = 225e3, XoverR = 6, Zperc = 0.0575) "Athletics 225 kVA, 208/120 V, 30E" annotation(
    Placement(transformation(origin = {-4, -54}, extent = {{22, -68}, {38, -52}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_Dance(VHigh = V_MV, VLow = V_208, VABase = 330e3, XoverR = 6, Zperc = 0.0575) "Dance 330 kVA, 208/120 V, 45E" annotation(
    Placement(transformation(origin = {2, -80}, extent = {{22, -98}, {38, -82}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_SAS(VHigh = V_MV, VLow = V_480, VABase = 750e3, XoverR = 8, Zperc = 0.0575) "SAS 750 kVA, 480/277 V (TODO field-check nameplate and fuse)" annotation(
    Placement(transformation(origin = {-2, -38}, extent = {{22, -38}, {38, -22}})));
  // V4C family (Arts, Fine Arts)
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_ArtsBuilding(VHigh = V_MV, VLow = V_208, VABase = 750e3, XoverR = 6, Zperc = 0.0575) "Arts Building 750 kVA, 208/120 V dry, 100E" annotation(
    Placement(transformation(origin = {8, 6}, extent = {{-28, 32}, {-12, 48}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_FineArts(VHigh = V_MV, VLow = V_208, VABase = 750e3, XoverR = 6, Zperc = 0.0575) "Fine Arts 750 kVA, 208/120 V dry, 100E" annotation(
    Placement(transformation(origin = {8, -16}, extent = {{-28, -28}, {-12, -12}})));
  // V4F family (Campus Surge, then HV4 sub for HUB, then V4G chain to MRB1)
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_Surge(VHigh = V_MV, VLow = V_480, VABase = 750e3, XoverR = 8, Zperc = 0.0575) "Campus Surge 750 kVA, 480/277 V pad-mount oil, 100E (cluster fusing TBD)" annotation(
    Placement(transformation(origin = {56, 94}, extent = {{52, 52}, {68, 68}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_HUBA(VHigh = V_MV, VLow = V_208, VABase = 750e3, XoverR = 8, Zperc = 0.0575) "HUB-A 750 kVA, 208/120 V oil, 100E" annotation(
    Placement(transformation(origin = {54, 32}, extent = {{137, 67}, {153, 83}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_HUBB(VHigh = V_MV, VLow = V_480, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "HUB-B 1500 kVA, 480/277 V oil, 200E" annotation(
    Placement(transformation(origin = {56, 0}, extent = {{137, 37}, {153, 53}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_MRB1(VHigh = V_MV, VLow = V_480, VABase = 2670e3, XoverR = 8, Zperc = 0.065) "MRB1 side tap from V30: 2670 kVA, 12.47/480 V, Z=6.5%, ~190-200 A fuse" annotation(
    Placement(transformation(origin = {84, 20}, extent = {{182, -78}, {198, -62}})));
  // V5
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_HumanitiesBldg(VHigh = V_MV, VLow = V_208, VABase = 500e3, XoverR = 6, Zperc = 0.0575) "Humanities Building 500 kVA, 208/120 V dry, dual 600A fused oil switch, 70E" annotation(
    Placement(transformation(origin = {-4, -48}, extent = {{-108, -208}, {-92, -192}})));
  // V1 disconnect 12.47/4.16 kV branch (Olmstead lights + Steam Plant)
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_V1_4160(VHigh = V_MV, VLow = V_4160, VABase = 3500e3, XoverR = 8, Zperc = 0.065) "V1 disconnect branch 3500 kVA, 12.47/4.16 kV (downstream Olmstead/Steam protection TBD)" annotation(
    Placement(transformation(origin = {16, -76}, extent = {{-108, -258}, {-92, -242}})));
  // 3A4k7
  Buildings.Electrical.AC.ThreePhasesBalanced.Conversion.ACACTransformer x_Phys(VHigh = V_MV, VLow = V_480, VABase = 1500e3, XoverR = 8, Zperc = 0.0575) "Physics PLACEHOLDER nameplate - field-check on 3A4k7" annotation(
    Placement(transformation(origin = {6, -76}, extent = {{-108, -308}, {-92, -292}})));
  // ============================================================
  // Loads
  // ============================================================
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HSS(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -1500e3*LF_unmet*PF, V_nominal = V_480) "HSS" annotation(
    Placement(transformation(origin = {16, 72}, extent = {{-38, 122}, {-22, 138}})));
  // V4D loads
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_CHASS(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -1500e3*LF_unmet*PF, V_nominal = V_208) "CHASS Inter S" annotation(
    Placement(transformation(origin = {40, -100}, extent = {{62, -128}, {78, -112}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_Athletics(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -225e3*LF_unmet*PF, V_nominal = V_208) "Athletics" annotation(
    Placement(transformation(origin = {38, -54}, extent = {{62, -68}, {78, -52}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_Dance(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -330e3*LF_unmet*PF, V_nominal = V_208) "Dance" annotation(
    Placement(transformation(origin = {40, -80}, extent = {{62, -98}, {78, -82}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_SAS(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -750e3*LF_unmet*PF, V_nominal = V_480) "SAS" annotation(
    Placement(transformation(origin = {38, -38}, extent = {{62, -38}, {78, -22}})));
  // V4C loads
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_ArtsBuilding(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -750e3*LF_unmet*PF, V_nominal = V_208) "Arts Building" annotation(
    Placement(transformation(origin = {22, 6}, extent = {{22, 32}, {38, 48}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_FineArts(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -750e3*LF_unmet*PF, V_nominal = V_208) "Fine Arts" annotation(
    Placement(transformation(origin = {16, -16}, extent = {{22, -28}, {38, -12}})));
  // V4F / HV4 / V30 metered loads
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_Surge(pf = PF, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "Campus Surge (metered)" annotation(
    Placement(transformation(origin = {62, 94}, extent = {{102, 52}, {118, 68}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HUBA(pf = PF, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_208) "HUB-A (metered share)" annotation(
    Placement(transformation(origin = {54, 32}, extent = {{207, 67}, {223, 83}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HUBB(pf = PF, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "HUB-B (metered share)" annotation(
    Placement(transformation(origin = {56, 0}, extent = {{207, 37}, {223, 53}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_MRB1(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -2670e3*LF_MRB1*PF, V_nominal = V_480) "MRB1 placeholder load" annotation(
    Placement(transformation(origin = {82, 20}, extent = {{252, -78}, {268, -62}})));
  // V5, V1, 3A4k7 loads
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_HumanitiesBldg(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -500e3*LF_unmet*PF, V_nominal = V_208) "Humanities Building" annotation(
    Placement(transformation(origin = {16, -48}, extent = {{-38, -208}, {-22, -192}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_OlmsteadSteam(pf = PF, mode = Buildings.Electrical.Types.Load.FixedZ_steady_state, P_nominal = -3500e3*LF_4160Branch*PF, V_nominal = V_4160) "Olmstead lights + Steam Plant placeholder" annotation(
    Placement(transformation(origin = {18, -76}, extent = {{-38, -258}, {-22, -242}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive l_Phys(pf = PF, mode = Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal = V_480) "Physics (metered)" annotation(
    Placement(transformation(origin = {16, -76}, extent = {{-38, -308}, {-22, -292}})));
  // ============================================================
  // Validation: cumulative kWh per metered building & feeder total
  // ============================================================
  Modelica.Blocks.Math.Add addHUB annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{172, 202}, {188, 218}})));
  Modelica.Blocks.Continuous.Integrator E_HUB(k = 1/3.6e6) "HUB cum kWh" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{222, 202}, {238, 218}})));
  Modelica.Blocks.Continuous.Integrator E_Surge(k = 1/3.6e6) "Surge cum kWh" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{222, 172}, {238, 188}})));
  Modelica.Blocks.Continuous.Integrator E_Phys(k = 1/3.6e6) "Physics cum kWh" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{222, 142}, {238, 158}})));
  Modelica.Blocks.Continuous.Integrator E_3A(k = 1/3.6e6) "Feeder 3A cum kWh" annotation(
    Placement(transformation(origin = {-6, 72}, extent = {{222, 112}, {238, 128}})));
  // ============================================================
  // Reported outputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealOutput P_total_kW "kW supplied by 3A from T3" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -13}, {288, 3}}), iconTransformation(extent = {{272, -13}, {288, 3}})));
  Modelica.Blocks.Interfaces.RealOutput Q_total_kvar "kvar on 3A" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -38}, {288, -22}}), iconTransformation(extent = {{272, -38}, {288, -22}})));
  Modelica.Blocks.Interfaces.RealOutput S_total_kVA "kVA on 3A" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -63}, {288, -47}}), iconTransformation(extent = {{272, -63}, {288, -47}})));
  Modelica.Blocks.Interfaces.RealOutput Loading_T3_pct "% of T3 18 MVA" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -88}, {288, -72}}), iconTransformation(extent = {{272, -88}, {288, -72}})));
  Modelica.Blocks.Interfaces.RealOutput err_HUB_pct "(simulated - meter)/meter * 100" annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -113}, {288, -97}}), iconTransformation(extent = {{272, -113}, {288, -97}})));
  Modelica.Blocks.Interfaces.RealOutput err_Surge_pct annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -138}, {288, -122}}), iconTransformation(extent = {{272, -138}, {288, -122}})));
  Modelica.Blocks.Interfaces.RealOutput err_Phys_pct annotation(
    Placement(transformation(origin = {2, -98}, extent = {{272, -163}, {288, -147}}), iconTransformation(extent = {{272, -163}, {288, -147}})));
equation
// ---- Time-table fan-out ----
  connect(loadTable.y[1], gHUBA.u);
  connect(loadTable.y[1], gHUBB.u);
  connect(gHUBA.y, negHUBA.u);
  connect(gHUBB.y, negHUBB.u);
  connect(loadTable.y[2], negSurge.u);
  connect(loadTable.y[3], negPhys.u);
  connect(negHUBA.y, l_HUBA.Pow);
  connect(negHUBB.y, l_HUBB.Pow);
  connect(negSurge.y, l_Surge.Pow);
  connect(negPhys.y, l_Phys.Pow);
// ============================================================
// 3A primary topology - all five children of the 3A breaker
// ============================================================
  connect(grid.terminal, n_3A) annotation(
    Line(points = {{-230, 0}, {-210, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A, n_V3A) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, 202}, {-146, 202}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A, n_V4) annotation(
    Line(points = {{-210, 0}, {-140, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A, n_V5) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, -248}, {-168, -248}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A, n_V1) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, -326}, {-146, -326}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A, n_3A4k7) annotation(
    Line(points = {{-210, 0}, {-180, 0}, {-180, -376}, {-146, -376}}, color = {0, 120, 0}, thickness = 0.5));
// ============================================================
// V4 family backbone: V4 -> V4A -> V4B -> V4C -> V4F (V4D branches separately off V4)
// ============================================================
  connect(n_V4, n_V4A) annotation(
    Line(points = {{-140, 0}, {-100, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4A, n_V4B) annotation(
    Line(points = {{-100, 0}, {-60, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4B, n_V4C) annotation(
    Line(points = {{-60, 0}, {-20, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4C, n_V4F) annotation(
    Line(points = {{-20, 0}, {108, 0}}, color = {0, 120, 0}, thickness = 0.5));
// V4D as direct sibling of V4A (NOT downstream of V4C)
  connect(n_V4, n_V4D) annotation(
    Line(points = {{-140, 0}, {-140, -131}, {-80, -131}}, color = {0, 120, 0}, thickness = 0.5));
// V4F children: Campus Surge tap, HV4 sub for HUB, V4G chain
  connect(n_V4F, n_HV4) annotation(
    Line(points = {{108, 0}, {124, 0}, {124, 68}, {158, 68}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4F, n_V4G) annotation(
    Line(points = {{108, 0}, {186, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4G, n_V4N) annotation(
    Line(points = {{186, 0}, {226, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4N, n_V30) annotation(
    Line(points = {{226, 0}, {266, 0}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V30, n_V31) annotation(
    Line(points = {{266, 0}, {306, 20}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V30, n_V32) annotation(
    Line(points = {{266, 0}, {306, -10}}, color = {0, 120, 0}, thickness = 0.5));
// ============================================================
// Transformer primary attachments
// ============================================================
// V3A -> HSS
  connect(n_V3A, x_HSS.terminal_n) annotation(
    Line(points = {{-146, 202}, {-96, 202}}, color = {0, 120, 0}, thickness = 0.5));
// V4D -> CHASS, Athletics, Dance, SAS (all routed downward from V4D bus)
  connect(n_V4D, x_SAS.terminal_n) annotation(
    Line(points = {{-80, -131}, {-80, -68}, {20, -68}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4D, x_Athletics.terminal_n) annotation(
    Line(points = {{-80, -131}, {-80, -114}, {18, -114}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4D, x_Dance.terminal_n) annotation(
    Line(points = {{-80, -131}, {-80, -170}, {24, -170}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4D, x_CHASS.terminal_n) annotation(
    Line(points = {{-80, -131}, {-80, -220}, {24, -220}}, color = {0, 120, 0}, thickness = 0.5));
// V4C -> Arts, Fine Arts
  connect(n_V4C, x_ArtsBuilding.terminal_n) annotation(
    Line(points = {{-20, 0}, {-20, 46}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V4C, x_FineArts.terminal_n) annotation(
    Line(points = {{-20, 0}, {-20, -36}}, color = {0, 120, 0}, thickness = 0.5));
// V4F -> Surge ; HV4 -> HUB A/B ; V30 -> MRB1
  connect(n_V4F, x_Surge.terminal_n) annotation(
    Line(points = {{108, 0}, {108, 154}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_HV4, x_HUBA.terminal_n) annotation(
    Line(points = {{158, 68}, {169, 68}, {169, 107}, {191, 107}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_HV4, x_HUBB.terminal_n) annotation(
    Line(points = {{158, 68}, {169, 68}, {169, 45}, {193, 45}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V30, x_MRB1.terminal_n) annotation(
    Line(points = {{266, 0}, {266, -50}}, color = {0, 120, 0}, thickness = 0.5));
// V5 -> Humanities ; V1 -> 12.47/4.16 ; 3A4k7 -> Physics
  connect(n_V5, x_HumanitiesBldg.terminal_n) annotation(
    Line(points = {{-168, -248}, {-112, -248}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_V1, x_V1_4160.terminal_n) annotation(
    Line(points = {{-146, -326}, {-92, -326}}, color = {0, 120, 0}, thickness = 0.5));
  connect(n_3A4k7, x_Phys.terminal_n) annotation(
    Line(points = {{-146, -376}, {-102, -376}}, color = {0, 120, 0}, thickness = 0.5));
// ============================================================
// Transformer secondaries -> loads
// ============================================================
  connect(x_HSS.terminal_p, l_HSS.terminal) annotation(
    Line(points = {{-80, 202}, {-22, 202}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_CHASS.terminal_p, l_CHASS.terminal) annotation(
    Line(points = {{40, -220}, {102, -220}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Athletics.terminal_p, l_Athletics.terminal) annotation(
    Line(points = {{34, -114}, {100, -114}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Dance.terminal_p, l_Dance.terminal) annotation(
    Line(points = {{40, -170}, {102, -170}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_SAS.terminal_p, l_SAS.terminal) annotation(
    Line(points = {{36, -68}, {100, -68}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_ArtsBuilding.terminal_p, l_ArtsBuilding.terminal) annotation(
    Line(points = {{-4, 46}, {-4, 47}, {44, 47}, {44, 46}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_FineArts.terminal_p, l_FineArts.terminal) annotation(
    Line(points = {{-4, -36}, {38, -36}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Surge.terminal_p, l_Surge.terminal) annotation(
    Line(points = {{124, 154}, {164, 154}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_HUBA.terminal_p, l_HUBA.terminal) annotation(
    Line(points = {{207, 107}, {261, 107}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_HUBB.terminal_p, l_HUBB.terminal) annotation(
    Line(points = {{209, 45}, {263, 45}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_MRB1.terminal_p, l_MRB1.terminal) annotation(
    Line(points = {{282, -50}, {334, -50}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_HumanitiesBldg.terminal_p, l_HumanitiesBldg.terminal) annotation(
    Line(points = {{-96, -248}, {-22, -248}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_V1_4160.terminal_p, l_OlmsteadSteam.terminal) annotation(
    Line(points = {{-76, -326}, {-20, -326}}, color = {0, 120, 0}, thickness = 0.5));
  connect(x_Phys.terminal_p, l_Phys.terminal) annotation(
    Line(points = {{-86, -376}, {-22, -376}}, color = {0, 120, 0}, thickness = 0.5));
// ---- Aggregate diagnostics (positive = supplied) ----
  P_total_kW = -(l_HSS.P + l_CHASS.P + l_Athletics.P + l_Dance.P + l_SAS.P + l_ArtsBuilding.P + l_FineArts.P + l_Surge.P + l_HUBA.P + l_HUBB.P + l_MRB1.P + l_HumanitiesBldg.P + l_OlmsteadSteam.P + l_Phys.P)/1000;
  Q_total_kvar = P_total_kW*QoverP;
  S_total_kVA = sqrt(P_total_kW^2 + Q_total_kvar^2);
  Loading_T3_pct = 100*S_total_kVA/18000;
// ---- Energy integrators ----
  addHUB.u1 = -l_HUBA.P;
  addHUB.u2 = -l_HUBB.P;
  connect(addHUB.y, E_HUB.u);
  E_Surge.u = -l_Surge.P;
  E_Phys.u = -l_Phys.P;
  E_3A.u = P_total_kW*1000;
  err_HUB_pct = 100*(E_HUB.y - E_HUB_ref_kWh)/E_HUB_ref_kWh;
  err_Surge_pct = 100*(E_Surge.y - E_Surge_ref_kWh)/E_Surge_ref_kWh;
  err_Phys_pct = 100*(E_Phys.y - E_Phys_ref_kWh)/E_Phys_ref_kWh;
  annotation(
    Diagram(coordinateSystem(extent = {{-280, -340}, {300, 300}}), graphics = {Text(extent = {{-260, 280}, {260, 295}}, textString = "3A feeder"), Rectangle(fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-228, -7}, {-192, 7}}), Text(origin = {8, 0},extent = {{-227, -6}, {-193, 6}}, textString = "3A"), Rectangle(origin = {-6, 72}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-158, 123}, {-122, 137}}), Text(origin = {-6, 72}, extent = {{-157, 124}, {-123, 136}}, textString = "V3A"), Rectangle(fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-158, -7}, {-122, 7}}), Text(extent = {{-157, -6}, {-123, 6}}, textString = "V4"), Rectangle(fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-118, -7}, {-82, 7}}), Text(extent = {{-117, -6}, {-83, 6}}, textString = "V4A"), Rectangle(fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-78, -7}, {-42, 7}}), Text(extent = {{-77, -6}, {-43, 6}}, textString = "V4B"), Rectangle(fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-38, -7}, {-2, 7}}), Text(extent = {{-37, -6}, {-3, 6}}, textString = "V4C"), Rectangle(origin = {62, -73}, fillColor = {255, 235, 205}, fillPattern = FillPattern.Solid, extent = {{-204, -66}, {-142, -37}}), Text(origin = {-16, -72}, extent = {{-117, -31}, {-83, -19}}, textString = "V4D"), Rectangle(origin = {51, 7}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{35, -14}, {65, 14}}), Text(origin = {36, 16}, extent = {{43, -6}, {77, 6}}, textString = "V4F"), Rectangle(origin = {37, 0}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{87, 61}, {121, 81}}), Text(origin = {28, 28}, extent = {{93, 44}, {127, 56}}, textString = "HV4"), Rectangle(origin = {76, 40}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{92, -47}, {128, -33}}), Text(origin = {76, 40}, extent = {{93, -46}, {127, -34}}, textString = "V4G"), Rectangle(origin = {76, 40}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{132, -47}, {168, -33}}), Text(origin = {76, 40}, extent = {{133, -46}, {167, -34}}, textString = "V4N"), Rectangle(origin = {76, 40}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{172, -47}, {208, -33}}), Text(origin = {76, 40}, extent = {{173, -46}, {207, -34}}, textString = "V30"), Rectangle(origin = {76, 40}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{212, -27}, {248, -13}}), Text(origin = {76, 40}, extent = {{213, -26}, {247, -14}}, textString = "V31"), Rectangle(origin = {76, 40}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{212, -57}, {248, -43}}), Text(origin = {76, 40}, extent = {{213, -56}, {247, -44}}, textString = "V32"), Rectangle(origin = {-18, -48}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-158, -207}, {-122, -193}}), Text(origin = {-18, -48}, extent = {{-157, -206}, {-123, -194}}, textString = "V5"), Rectangle(origin = {-8, 289}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-158, -624}, {-122, -590}}), Text(origin = {-6, -58}, extent = {{-157, -256}, {-123, -244}}, textString = "V1"), Rectangle(origin = {-13, 259}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-149, -658}, {-115, -628}}), Text(origin = {-4, -92}, extent = {{-157, -306}, {-123, -294}}, textString = "3A4k7"), Rectangle(origin = {7, -102}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-125, 296}, {-87, 326}}), Text(origin = {0, 74}, extent = {{-117, 139}, {-83, 151}}, textString = "x_HSS"), Rectangle(origin = {2, -100}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{12, -128}, {48, -112}}), Text(origin = {2, -100}, extent = {{13, -127}, {47, -113}}, textString = "x_CHASS"), Rectangle(origin = {-1, -7}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{11, -121}, {45, -93}}), Text(origin = {-2, -40}, extent = {{13, -67}, {47, -53}}, textString = "x_Ath"), Rectangle(origin = {2, -80}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{12, -98}, {48, -82}}), Text(origin = {2, -80}, extent = {{13, -97}, {47, -83}}, textString = "x_Dance"), Rectangle(origin = {-2, -38}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{12, -38}, {48, -22}}), Text(origin = {-2, -38}, extent = {{13, -37}, {47, -23}}, textString = "x_SAS"), Rectangle(origin = {0, -10}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-34, 48}, {-2, 72}}), Text(origin = {4, 20}, extent = {{-37, 33}, {-3, 47}}, textString = "x_Arts"), Rectangle(origin = {2, 2}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-38, -44}, {-2, -19}}), Text(origin = {4, -6}, extent = {{-37, -27}, {-3, -13}}, textString = "x_FineArts"), Rectangle(origin = {59, 52}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{35, 94}, {65, 123}}), Text(origin = {50, 112}, extent = {{43, 53}, {77, 67}}, textString = "x_Surge"), Rectangle(origin = {35, -18}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{134, 117}, {172, 145}}), Text(origin = {44, 48}, extent = {{128, 68}, {162, 82}}, textString = "x_HUBA"), Rectangle(origin = {21, -19}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{148, 56}, {190, 80}}), Text(origin = {48, 12}, extent = {{128, 38}, {162, 52}}, textString = "x_HUBB"), Rectangle(origin = {78, 43}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{172, -105}, {208, -83}}), Text(origin = {80, 12}, extent = {{173, -77}, {207, -63}}, textString = "x_MRB1"), Rectangle(origin = {9, 226}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-131, -494}, {-91, -456}}), Text(origin = {-2, -32}, extent = {{-117, -207}, {-83, -193}}, textString = "x_Hum"), Rectangle(origin = {33, 198}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-157, -532}, {-109, -499}}), Text(origin = {2, -60}, extent = {{-117, -257}, {-83, -243}}, textString = "x_12.47/4.16"), Rectangle(origin = {-15, 198}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-105, -597}, {-73, -566}}), Text(origin = {-4, -94}, extent = {{-117, -307}, {-83, -293}}, textString = "x_Phys"), Rectangle(origin = {-6, -122}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-56, 316}, {-2, 348}}), Text(origin = {-6, 74}, extent = {{-57, 139}, {-3, 151}}, textString = "HSS"), Rectangle(origin = {10, 64}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{62, -304}, {105, -266}}), Text(origin = {24, -88}, extent = {{53, -127}, {87, -113}}, textString = "CHASS"), Rectangle(origin = {11, 13}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{61, -147}, {103, -113}}), Text(origin = {20, -42}, extent = {{53, -67}, {87, -53}}, textString = "Athletics"), Rectangle(origin = {8, 10}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{64, -201}, {108, -168}}), Text(origin = {20, -72}, extent = {{53, -97}, {87, -83}}, textString = "Dance"), Rectangle(origin = {11, -5}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{61, -81}, {103, -47}}), Text(origin = {18, -28}, extent = {{53, -37}, {87, -23}}, textString = "SAS"), Rectangle(origin = {0, -2}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{14, 40}, {56, 60}}), Text(origin = {-1, 6}, extent = {{14, 33}, {50, 47}}, textString = "Arts"), Rectangle(origin = {4, 6}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{12, -47}, {48, -20}}), Text(origin = {4, 0}, extent = {{13, -27}, {47, -13}}, textString = "Fine Arts"), Rectangle(origin = {45, 47}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{97, 99}, {135, 130}}), Text(origin = {52, 112}, extent = {{93, 53}, {127, 67}}, textString = "Campus Surge"), Rectangle(origin = {55, -18}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{186, 117}, {220, 145}}), Text(origin = {44, 48}, extent = {{198, 68}, {232, 82}}, textString = "HUB A"), Rectangle(origin = {44, -25}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{197, 62}, {233, 89}}), Text(origin = {44, 14}, extent = {{198, 38}, {232, 52}}, textString = "HUB B"), Rectangle(origin = {-7, 64}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{309, -122}, {355, -97}}), Text(origin = {66, 32}, extent = {{243, -77}, {277, -63}}, textString = "MRB1"), Rectangle(origin = {-6, 226}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-56, -494}, {-2, -456}}), Text(origin = {-4, -34}, extent = {{-57, -207}, {-3, -193}}, textString = "Humanities"), Rectangle(origin = {-2, 231}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-62, -565}, {-2, -530}}), Text(origin = {-6, 87}, extent = {{-55, -404}, {-3, -382}}, textString = "Olmstead/Steam"), Rectangle(origin = {-6, -76}, fillColor = {245, 245, 245}, fillPattern = FillPattern.Solid, extent = {{-58, -308}, {-2, -292}}), Text(origin = {-12, -68}, extent = {{-57, -307}, {-3, -293}}, textString = "Physics")}),
    Icon(coordinateSystem(extent = {{-280, -340}, {300, 300}})),
    experiment(StopTime = 31536000, Tolerance = 1e-6),
    Documentation(info = "<html>
<p><b>UCR Feeder 3A</b>, corrected topology to match the V3A / V4 / V4A / V4B / V4C / V4D / V4F / HV4 / V4G / V4N / V30 / V31 / V32 / V5 / V1 / 3A4k7 single-line.</p>

<p><b>Topology changes from prior revision</b>:</p>
<ul>
<li>V4D is now a direct child of V4 (sibling of V4A), not in series with V4C.</li>
<li>V4F is a direct child of V4C, not downstream of V4D.</li>
<li>V4D family (CHASS, Athletics, Dance, SAS) placed below the backbone for visual clarity.</li>
<li>Athletics and Dance split into separate transformers (225 kVA / 30E and 330 kVA / 45E).</li>
</ul>

<p><b>Profile-driven (metered) loads</b>: HUB (split HUB-A / HUB-B by kVA), Campus Surge (Skye Hall), Physics. Driven by Loads_3A_2025_kW.txt with columns {2,4,6} extracting HUB, Surge, Physics.</p>

<p><b>Constant-LF un-metered loads</b>: HSS, CHASS, Athletics, Dance, SAS, Arts, Fine Arts, Humanities Building, MRB1, V1 12.47/4.16 kV branch (Olmstead lights / Steam Plant).</p>

<p><b>Field-check TODO</b>: SAS nameplate and fuse, Campus Surge fuse pairing in V4F/V4G cluster, Physics 3A4k7 nameplate, downstream Olmstead/Steam protection on the 12.47/4.16 kV branch.</p>

<p><b>MV cables</b> idealized (Buildings.Electrical Line CableMode.automatic does not support 12.47 kV).</p>
</html>"));
end Circuit_3A;
