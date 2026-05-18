within ThreeAModel;

block SolarPV
  "Rooftop solar PV with diurnal generation profile (UCR ~33.97N latitude)"
  // ------------------------------------------------------------
  // Same model as Feeder 3B work: bell-curve irradiance peaking
  // at solar noon (12:30 PST), efficiency * performance ratio
  // applied to nameplate. Outputs P_solar in W (positive).
  // ------------------------------------------------------------
  parameter Real P_rated = 500e3
    "Rated PV nameplate capacity (W)";
  parameter Real panel_efficiency = 0.20
    "Panel module efficiency";
  parameter Real performance_ratio = 0.80
    "Real-world derating (soiling, inverter, temperature, mismatch)";
  parameter Boolean nonExportMode = false
    "true = cap output at local building load (no backflow)";

  Modelica.Blocks.Interfaces.RealInput P_load_local
    "Local building load in W (used only when nonExportMode = true)" annotation(
    Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  Modelica.Blocks.Interfaces.RealOutput P_solar
    "PV electrical output in W (always >= 0)" annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Real solarHour "Time of day in hours [0,24)";
  Real irradiance_pu "Normalized irradiance (0-1)";
  Real P_uncapped "Solar output before non-export cap (W)";

equation
  solarHour = mod(time, 86400) / 3600;
  irradiance_pu = max(0, Modelica.Math.exp(-0.5 * ((solarHour - 12.5)/3.5)^2));
  P_uncapped = P_rated * panel_efficiency * performance_ratio * irradiance_pu;
  P_solar = if nonExportMode then min(P_uncapped, P_load_local) else P_uncapped;

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-100, 100}, {100, -100}},
        lineColor = {59, 109, 17}, fillColor = {234, 243, 222},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-90, 80}, {90, 40}}, textColor = {59, 109, 17},
        textString = "Solar PV"),
      Text(extent = {{-90, 20}, {90, -20}}, textColor = {59, 109, 17},
        textString = DynamicSelect("0.0 MW",
          String(P_solar/1e6, format = ".2f") + " MW")),
      Text(extent = {{-90, -40}, {90, -80}}, textColor = {59, 109, 17},
        textString = DynamicSelect("rated",
          String(P_rated/1e6, format = ".2f") + " MW rated"))
    }),
    Documentation(info = "<html>
<p>Diurnal PV generation block. Bell-curve irradiance approximation
peaking at 12:30 PST. Output P_solar is always &gt;= 0.</p>
<p>Set <code>nonExportMode = true</code> to clip generation at local load
(typical for behind-the-meter installations without export agreement).
Leave <code>false</code> for net-export configurations.</p>
</html>"));
end SolarPV;
