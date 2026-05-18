within ThreeAModel;

block BESS_PeakShaver
  "Battery storage with peak-shaving control on T3 transformer % loading"

  // Adapted from the Feeder 3B BESS block: same SoC integrator and
  // efficiency model, but the controller watches T3 transformer
  // loading % instead of raw load. Discharges when T3 nears its
  // rating, charges when there's headroom.
  // Sign convention: P_bess > 0 = discharging (supplying load)
  //                  P_bess < 0 = charging (drawing load)

parameter Real capacity_kWh = 1000
    "Storage energy capacity (kWh)";
  parameter Real P_max_kW = 250
    "Max charge / discharge rate (kW)";
  parameter Real efficiency = 0.92
    "Round-trip efficiency (applied on discharge)";

  parameter Real dischargeAbove_pct = 85
    "Discharge when T3 loading exceeds this % of rating";
  parameter Real chargeBelow_pct = 50
    "Charge when T3 loading is below this % of rating";

  parameter Real soc_min = 0.10 "Minimum allowed state of charge";
  parameter Real soc_max = 0.90 "Maximum allowed state of charge";
  parameter Real soc_initial = 0.50 "Initial state of charge (0-1)";

  Real soc(start = soc_initial, fixed = true) "State of charge (0-1)";

  Modelica.Blocks.Interfaces.RealInput Loading_T3_pct
    "T3 transformer loading (% of 18 MVA rating)" annotation(
    Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  Modelica.Blocks.Interfaces.RealOutput P_bess
    "Battery output in W (+discharging / -charging)" annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}})));

equation
  // Controller: discharge above threshold (if SoC allows), charge below
  // threshold (if SoC allows), idle in the deadband.
  P_bess = if Loading_T3_pct > dischargeAbove_pct and soc > soc_min then
             P_max_kW * 1000
           elseif Loading_T3_pct < chargeBelow_pct and soc < soc_max then
             -P_max_kW * 1000
           else
             0;

  // Discharging (P_bess>0) drains the battery and charging fills it.
  // Efficiency penalty applied symmetrically.
  // capacity_kWh * 3.6e6 converts kWh -> J so der(soc) is 1/s.
  der(soc) = -P_bess * efficiency / (capacity_kWh * 3.6e6);

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-100, 100}, {100, -100}},
        lineColor = {186, 117, 23}, fillColor = {250, 238, 218},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-90, 80}, {90, 40}}, textColor = {101, 56, 6},
        textString = "BESS"),
      Text(extent = {{-90, 20}, {90, -20}}, textColor = {101, 56, 6},
        textString = DynamicSelect("SoC: 50%",
          "SoC: " + String(soc * 100, format = ".0f") + "%")),
      Text(extent = {{-90, -40}, {90, -80}}, textColor = {101, 56, 6},
        textString = DynamicSelect("0 kW",
          String(P_bess/1000, format = ".0f") + " kW"))
    }),
    Documentation(info = "<html>
<p>Battery energy storage block with simple two-threshold peak-shaving
controller. Same SoC integration model as the Feeder 3B work; the
controller input is changed from raw campus load to T3 transformer
percent loading so the BESS responds to substation stress rather than
raw kW magnitude.</p>

<p><b>Control logic</b>:</p>
<ul>
  <li>If T3 loading &gt; <code>dischargeAbove_pct</code> AND SoC &gt;
      <code>soc_min</code> &rarr; discharge at <code>P_max_kW</code></li>
  <li>If T3 loading &lt; <code>chargeBelow_pct</code> AND SoC &lt;
      <code>soc_max</code> &rarr; charge at <code>P_max_kW</code></li>
  <li>Otherwise idle (zero power)</li>
</ul>
</html>"));
end BESS_PeakShaver;
