# UCR-Digital-Twin-Research
# UCR Campus Electrical Distribution Digital Twin (Prototype)

## Overview

This project models and simulates a simplified electrical distribution system for the University of California, Riverside (UCR) campus using **Pandapower** in Python.

The system includes:

- A 69 kV utility grid connection
- A 12 kV campus substation
- Four main distribution feeders (Feeder A, B, C, D)
- Building-level transformers (12 kV → 0.48 kV)
- Circuit breakers and fuse switches
- Realistic load modeling with power factor
- Contingency and stress scenario simulations

This project serves as a **physics-based foundation for a campus electrical digital twin prototype**.

---

## Features

- Full power flow simulation using Newton-Raphson
- Modular feeder architecture
- Building-level load representation
- Transformer and line parameter customization
- Breaker-based feeder isolation simulation
- Scenario analysis:
  - Base Case
  - Heatwave (Load Scaling)
  - Feeder Outage (N-1 contingency)

---

## System Architecture

### Voltage Levels

| Level | Description |
|--------|-------------|
| 69 kV  | Utility Grid Connection |
| 12 kV  | Campus Medium Voltage Distribution |
| 0.48 kV | Building-Level Low Voltage |

### Feeders

- **Feeder A** – Engineering & Research Buildings
- **Feeder B** – Life Sciences & Medicine
- **Feeder C** – Academic & Student Services
- **Feeder D** – Residential Housing

Each feeder includes:
- A dedicated breaker (CB)
- Underground MV cable segments
- Step-down transformer per building
- Transformer-level fuse protection

---

## Project Structure

```
.
├── ucr_digital_twin.py
├── README.md
```

Main components:

- `get_ucr_building_data()` – Defines building loads
- `create_ucr_network()` – Builds full electrical topology
- `run_simulation()` – Executes power flow and prints system results

---

## Installation

### Requirements

- Python 3.9+
- pandapower
- pandas

### Install Dependencies

```bash
pip install pandapower pandas
```

---

## Running the Simulation

```bash
python ucr_digital_twin.py
```

The program will automatically run:

1. Base Case
2. Heatwave Scenario (30% load increase)
3. Feeder A Outage

---

## Example Output

- Total campus MW load
- Voltage range (min/max per unit)
- Convergence confirmation

---

## Customization

You can modify:

### 1. Building Loads
Inside:

```python
get_ucr_building_data()
```

Change:
- Real power (MW)
- Power factor
- Add/remove buildings

---

### 2. Transformer Ratings

Edit parameters in:

```python
create_transformer_from_parameters()
```

---

### 3. Line Impedance

Modify:

```python
create_line_from_parameters()
```

---

### 4. Load Scaling for Scenarios

```python
net.load["scaling"] = 1.3
```

---

## Digital Twin Roadmap

This project is currently a **steady-state power flow model**.

To evolve into a full digital twin:

- Integrate real-time SCADA data
- Add state estimation
- Implement continuous simulation loop
- Add event detection (overvoltage, overload)
- Add renewable energy sources (solar, storage)
- Add EV charging station modeling
- Create live dashboard (Streamlit or Dash)
- Connect to database (InfluxDB / PostgreSQL)

---

## Engineering Applications

- Campus grid contingency analysis
- Voltage stability study
- Load growth forecasting
- Infrastructure planning
- Renewable integration simulation
- Academic research project
- Senior design project
- Graduate-level digital twin research

---

## Future Improvements

- Ring distribution topology
- Fault current modeling
- Protection coordination study
- Distributed generation modeling
- Monte Carlo stress simulation
- Real-time data ingestion

---

## Disclaimer

This is a simplified academic model of UCR’s distribution system for simulation and research purposes only. It does not represent the actual operational electrical infrastructure of the University of California, Riverside.

---

## License

MIT License

---

## Author

Patrick W  
Computer Engineering  
University of California, Riverside

