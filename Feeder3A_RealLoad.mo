within ;
model Feeder3A_RealLoad

  // Nominal bus voltage
  parameter Real Vnom = 12000;

  // Feeder data (time in seconds, P in Watts, Q in VAR)
  // Includes Dec 16-17 maintenance outage as zero-power interval
  Modelica.Blocks.Sources.CombiTimeTable feeder(
    tableOnFile = true,
    fileName = Modelica.Utilities.Files.loadResource("modelica://ThreeAModel/Feeder_3A_Modelica.csv"),
    columns = {2,3},
    smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments);

  // Convert P to current: I = P/V
  Modelica.Blocks.Math.Gain powerToCurrent(k = 1/Vnom);

  // Electrical components
  Modelica.Electrical.Analog.Sources.ConstantVoltage grid(V = Vnom);
  Modelica.Electrical.Analog.Basic.Ground ground;
  Modelica.Electrical.Analog.Sources.SignalCurrent loadCurrent;
  Modelica.Units.SI.Power P_load "Real power [W]";
  Modelica.Units.SI.ReactivePower Q_load "Reactive power [VAR]";
equation
  // Convert feeder real power to current
  connect(feeder.y[1], powerToCurrent.u);
  connect(powerToCurrent.y, loadCurrent.i);


  // Electrical circuit
  connect(grid.p, loadCurrent.p);
  connect(loadCurrent.n, grid.n);
  connect(grid.n, ground.p);
  P_load = feeder.y[1];
  Q_load = feeder.y[2];

end Feeder3A_RealLoad;
