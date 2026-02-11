"""
UCR Campus Power Grid Simulation and Analysis
=============================================
This module simulates the University of California, Riverside (UCR) campus
electrical distribution network using PandaPower. It models a multi-feeder
distribution system with 69kV utility input, 12kV main campus bus, and
various building loads across four feeders.

Key Features:
- Campus main transformer and distribution feeders
- Building-level loads with power factor specifications
- Scenario-based power flow analysis (normal, heatwave, outage)
- Voltage profile and convergence monitoring
"""

import pandapower as pp
import pandas as pd
import warnings
import math

# Suppress non-critical warnings for cleaner output
warnings.filterwarnings("ignore")


def get_ucr_building_data():
    """
    Define UCR campus buildings and their electrical characteristics.
    
    Returns:
        dict: A dictionary mapping feeder names to lists of building tuples.
              Each tuple contains: (building_name, power_mw, power_factor)
              - power_mw: Active power demand in megawatts
              - power_factor: Lagging power factor (0-1)
    """
    return {
        # Feeder A: Engineering and Research Facilities
        "Feeder_A": [
            ("Bourns Hall", 0.45, 0.90),
            ("Winston Chung Hall", 0.40, 0.90),
            ("Physics 2000", 0.35, 0.92),
            ("Materials Sci & Eng", 0.30, 0.90),
            ("Multidisciplinary Research Bldg", 0.50, 0.88)
        ],
        # Feeder B: Life Sciences and Medical Facilities
        "Feeder_B": [
            ("Spieth Hall", 0.30, 0.90),
            ("Batchelor Hall", 0.35, 0.90),
            ("Life Sciences", 0.25, 0.95),
            ("School of Medicine Ed", 0.40, 0.90),
            ("Genomics Building", 0.38, 0.89),
            ("Greenhouse Operations", 0.15, 0.95)
        ],
        # Feeder C: Library and Administrative Buildings
        "Feeder_C": [
            ("Hinderaker Hall", 0.15, 0.95),
            ("Rivera Library", 0.25, 0.92),
            ("Orbach Science Library", 0.30, 0.92),
            ("Highlander Union (HUB)", 0.35, 0.95),
            ("Student Services Bldg", 0.15, 0.95),
            ("Humanities & Social Sci", 0.20, 0.95),
            ("Arts Building", 0.12, 0.95)
        ],
        # Feeder D: Residential Housing Facilities
        "Feeder_D": [
            ("Aberdeen-Inverness", 0.25, 0.98),
            ("Lothian Hall", 0.25, 0.98),
            ("Pentland Hills", 0.20, 0.98),
            ("Dundee Hall", 0.22, 0.98),
            ("Glen Mor", 0.30, 0.98),
            ("North District", 0.40, 0.98)
        ]
    }


def create_ucr_network():
    """
    Create the UCR campus electrical network topology.
    
    Network Architecture:
    - 69kV: Utility Grid Input
    - 12kV: Campus Main Bus (stepped down from 69kV via main transformer)
    - 4 Medium Voltage Feeders: Each serving multiple buildings
    - 0.48kV: Building Level (stepped down from 12kV via individual transformers)
    
    Returns:
        pandapower.Network: Fully configured network model ready for simulation
    """
    # Initialize empty network object
    net = pp.create_empty_network()

    # =========================================================================
    # 1. Utility Grid (69kV)
    # =========================================================================
    # Create the utility grid bus at 69kV (step 1 in voltage reduction)
    utility_bus = pp.create_bus(net, vn_kv=69, name="RPU Grid")
    # Define external grid source with voltage set point slightly above nominal (1.02 pu)
    pp.create_ext_grid(net, utility_bus, vm_pu=1.02)

    # =========================================================================
    # 2. Campus Main Bus (12kV)
    # =========================================================================
    # Create main distribution bus at 12kV (secondary voltage level)
    campus_bus = pp.create_bus(net, vn_kv=12, name="Campus Main Bus")

    # Main substation transformer: Step down from 69kV utility to 12kV campus distribution
    # Rated capacity: 40 MVA (typical for mid-sized university campus)
    # Includes transformer losses: core losses (pfe) and impedance losses (vk)
    pp.create_transformer_from_parameters(
        net,
        hv_bus=utility_bus,
        lv_bus=campus_bus,
        sn_mva=40,
        vn_hv_kv=69,
        vn_lv_kv=12,
        vkr_percent=0.3,  # Resistance component of impedance
        vk_percent=12,    # Total impedance (voltage drop under full load)
        pfe_kw=30,        # Core losses (no-load losses)
        i0_percent=0.1,   # No-load current percentage
        name="Main Substation Transformer"
    )

    # Retrieve building data organized by feeder
    building_data = get_ucr_building_data()

    # =========================================================================
    # 3. Create Distribution Feeders
    # =========================================================================
    # Create four separate medium voltage feeders, each supplying multiple buildings
    # This provides redundancy and load balancing across the campus
    for feeder_name, buildings in building_data.items():
        # Create feeder head bus (originating point of each feeder)
        feeder_head = pp.create_bus(net, vn_kv=12, name=f"{feeder_name} Head")

        # Create distribution line from main campus bus to feeder head
        # Line parameters are representative of typical campus underground circuits
        feeder_line = pp.create_line_from_parameters(
            net,
            from_bus=campus_bus,
            to_bus=feeder_head,
            length_km=0.01,     # Short connection from main bus to feeder start
            r_ohm_per_km=0.01,  # Resistance per km (typical for underground cable)
            x_ohm_per_km=0.01,  # Reactance per km
            c_nf_per_km=0,      # Capacitance (shunt)
            max_i_ka=1.0,       # Maximum current rating (1000 A)
            name=f"{feeder_name} Feeder Line"
        )

        # Circuit breaker at the originating end of the feeder
        # Allows isolation of entire feeder for maintenance or fault clearing
        pp.create_switch(
            net,
            bus=campus_bus,
            element=feeder_line,
            et="l",             # Line element
            type="CB",          # Circuit breaker type
            closed=True,        # Default state: breaker is closed
            name=f"CB {feeder_name}"
        )

        # Track the previous bus as we build the feeder (for series connection of buildings)
        previous_bus = feeder_head

        # =========================================================================
        # 4. Add Building Loads to Feeder
        # =========================================================================
        for b_name, p_mw, pf in buildings:
            # Calculate reactive power from active power and power factor
            # Q = P * tan(arccos(PF)) - converts power factor to reactive power demand
            q_mvar = p_mw * math.tan(math.acos(pf))

            # Create medium voltage (12kV) bus for this building connection point
            mv_node = pp.create_bus(net, vn_kv=12, name=f"MV - {b_name}")

            # Distribution line from previous junction to this building's MV node
            # Typical parameters for 12kV distribution feeder (3-phase underground circuit)
            pp.create_line_from_parameters(
                net,
                from_bus=previous_bus,
                to_bus=mv_node,
                length_km=0.3,       # 300 m typical distance between buildings
                r_ohm_per_km=0.16,   # Resistance per km (12kV cable)
                x_ohm_per_km=0.12,   # Reactance per km
                c_nf_per_km=250,     # Shunt capacitance per km
                max_i_ka=0.4,        # Current limit: 400 A
                name=f"Line to {b_name}"
            )

            # Create low voltage (480V) bus internal to the building
            lv_node = pp.create_bus(net, vn_kv=0.48, name=f"LV - {b_name}")

            # Building transformer: Step down from 12kV to 480V for internal distribution
            # 1.5 MVA capacity typical for academic buildings in this power range
            trafo_idx = pp.create_transformer_from_parameters(
                net,
                hv_bus=mv_node,
                lv_bus=lv_node,
                sn_mva=1.5,          # Rated power
                vn_hv_kv=12,         # High voltage side
                vn_lv_kv=0.48,       # Low voltage side (480V)
                vkr_percent=1.0,     # Resistance component of impedance
                vk_percent=5.0,      # Total impedance
                pfe_kw=2.0,          # Core/iron losses
                i0_percent=0.4,      # No-load current percentage
                name=f"Trafo {b_name}"
            )

            # Fuse at transformer primary: Protects transformer from overcurrent conditions
            # LBS = Load Break Switch type (can interrupt load current safely)
            pp.create_switch(
                net,
                bus=mv_node,
                element=trafo_idx,
                et="t",              # Transformer element
                type="LBS",          # Load break switch (can safely open under load)
                closed=True,         # Default: switch is closed
                name=f"Fuse {b_name}"
            )

            # Building electrical load (demand)
            # Includes both active power (P, in MW) and reactive power (Q, in MVAR)
            # Reactive power is needed by inductive equipment (motors, transformers)
            pp.create_load(
                net,
                bus=lv_node,
                p_mw=p_mw,           # Active power demand
                q_mvar=q_mvar,       # Reactive power demand (calculated from power factor)
                name=b_name
            )

            # Update tracking variable for series feeder construction
            previous_bus = mv_node

    # Return fully constructed network model
    return net


def run_simulation(net, scenario_name="Base Case"):
    """
    Execute power flow analysis and report results.
    
    Performs Newton-Raphson power flow calculation to determine:
    - Bus voltage magnitudes and angles
    - Line flows and losses
    - Transformer loadings
    - Convergence status
    
    Args:
        net: PandaPower network object to simulate
        scenario_name: Descriptive name for the scenario being analyzed
    """
    print(f"\n--- {scenario_name} ---")

    try:
        # Run power flow using Newton-Raphson algorithm (standard for AC power flow)
        # numba=False: Disable numba JIT compilation for clarity and debugging
        pp.runpp(net, algorithm="nr", numba=False)
    except Exception as e:
        print("Simulation Failed:", e)
        return

    # Check convergence and display results
    if net.converged:
        print("Power Flow Converged")
        # Total load across all buildings in the network
        print(f"Total Load: {net.res_load.p_mw.sum():.2f} MW")
        # Voltage levels across all buses (should be between 0.95-1.05 p.u. for normal operation)
        print(f"Voltage Range: "
              f"{net.res_bus.vm_pu.min():.3f} - "
              f"{net.res_bus.vm_pu.max():.3f} p.u.")
    else:
        print("Did not converge")


if __name__ == "__main__":
    # =========================================================================
    # Main Execution: Run Multiple Network Scenarios
    # =========================================================================
    
    # Create the complete UCR campus network model
    ucr_net = create_ucr_network()

    # Scenario 1: Base Case - Normal operating conditions
    # Represents typical daytime load profile
    run_simulation(ucr_net, "Base Case")

    # Scenario 2: Heatwave Scenario - Increased Air Conditioning Load
    # Simulates 30% increase in total campus load due to extreme heat conditions
    # Tests network's ability to supply peak demand periods
    ucr_net.load["scaling"] = 1.3
    run_simulation(ucr_net, "Heatwave Scenario")

    # Reset load scaling back to normal (1.0 = 100% of base load)
    ucr_net.load["scaling"] = 1.0

    # Scenario 3: Contingency Analysis - Feeder A Outage
    # Simulates loss of one feeder to test network support for affected buildings
    # Buildings on Feeder A would need to be supported by other feeders if available
    idx = ucr_net.switch.index[ucr_net.switch.name == "CB Feeder_A"]
    if len(idx) > 0:
        # Open the circuit breaker for Feeder A
        ucr_net.switch.at[idx[0], "closed"] = False
        run_simulation(ucr_net, "Feeder A Outage")
