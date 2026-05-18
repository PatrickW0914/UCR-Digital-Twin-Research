within ;
package ThreeAModel
  annotation(
    version = "1.0",
    Documentation(info = "<html>
<p>Feeder 3A model for the UCR campus electrical digital twin.</p>
<p>Uses 15-minute interval substation data from Oct 2025 - Feb 2026.
The Dec 16-17 maintenance outage is preserved in the source data;
elevated Dec 18-21 loads reflect real load rerouted from other
feeders during their respective maintenance windows.</p>
</html>"));
end ThreeAModel;
