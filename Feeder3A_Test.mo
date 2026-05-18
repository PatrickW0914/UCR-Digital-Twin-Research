within ;
model Feeder3A_Test

  Modelica.Blocks.Sources.CombiTimeTable feeder(
    tableOnFile = true,
    fileName = Modelica.Utilities.Files.loadResource("modelica://ThreeAModel/Feeder_3A_Modelica.csv"),
    columns = {2,3},   // P(W), Q(VAR), time in seconds
    smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint);

end Feeder3A_Test;
