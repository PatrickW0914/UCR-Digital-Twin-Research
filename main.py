import pandapower as pp
import pandas as pd
import warnings
import math

warnings.filterwarnings("ignore")


def get_ucr_building_data():
    return {
        "Feeder_A": [
            ("Bourns Hall", 0.45, 0.90),
            ("Winston Chung Hall", 0.40, 0.90),
            ("Physics 2000", 0.35, 0.92),
            ("Materials Sci & Eng", 0.30, 0.90),
            ("Multidisciplinary Research Bldg", 0.50, 0.88)
        ],
        "Feeder_B": [
            ("Spieth Hall", 0.30, 0.90),
            ("Batchelor Hall", 0.35, 0.90),
            ("Life Sciences", 0.25, 0.95),
            ("School of Medicine Ed", 0.40, 0.90),
            ("Genomics Building", 0.38, 0.89),
            ("Greenhouse Operations", 0.15, 0.95)
        ],
        "Feeder_C": [
            ("Hinderaker Hall", 0.15, 0.95),
            ("Rivera Library", 0.25, 0.92),
            ("Orbach Science Library", 0.30, 0.92),
            ("Highlander Union (HUB)", 0.35, 0.95),
            ("Student Services Bldg", 0.15, 0.95),
            ("Humanities & Social Sci", 0.20, 0.95),
            ("Arts Building", 0.12, 0.95)
        ],
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
    net = pp.create_empty_network()

    # -------------------------
    # 1. Utility Grid (69kV)
    # -------------------------
    utility_bus = pp.create_bus(net, vn_kv=69, name="RPU Grid")
    pp.create_ext_grid(net, utility_bus, vm_pu=1.02)

    # -------------------------
    # 2. Campus Main Bus (12kV)
    # -------------------------
    campus_bus = pp.create_bus(net, vn_kv=12, name="Campus Main Bus")

    # Main transformer
    pp.create_transformer_from_parameters(
        net,
        hv_bus=utility_bus,
        lv_bus=campus_bus,
        sn_mva=40,
        vn_hv_kv=69,
        vn_lv_kv=12,
        vkr_percent=0.3,
        vk_percent=12,
        pfe_kw=30,
        i0_percent=0.1,
        name="Main Substation Transformer"
    )

    building_data = get_ucr_building_data()

    # -------------------------
    # 3. Create Feeders
    # -------------------------
    for feeder_name, buildings in building_data.items():

        feeder_head = pp.create_bus(net, vn_kv=12, name=f"{feeder_name} Head")

        # Create line from campus bus to feeder head
        feeder_line = pp.create_line_from_parameters(
            net,
            from_bus=campus_bus,
            to_bus=feeder_head,
            length_km=0.01,
            r_ohm_per_km=0.01,
            x_ohm_per_km=0.01,
            c_nf_per_km=0,
            max_i_ka=1.0,
            name=f"{feeder_name} Feeder Line"
        )

        # Breaker on feeder line
        pp.create_switch(
            net,
            bus=campus_bus,
            element=feeder_line,
            et="l",
            type="CB",
            closed=True,
            name=f"CB {feeder_name}"
        )

        previous_bus = feeder_head

        # -------------------------
        # 4. Add Buildings
        # -------------------------
        for b_name, p_mw, pf in buildings:

            q_mvar = p_mw * math.tan(math.acos(pf))

            # MV node
            mv_node = pp.create_bus(net, vn_kv=12, name=f"MV - {b_name}")

            # Line to building
            pp.create_line_from_parameters(
                net,
                from_bus=previous_bus,
                to_bus=mv_node,
                length_km=0.3,
                r_ohm_per_km=0.16,
                x_ohm_per_km=0.12,
                c_nf_per_km=250,
                max_i_ka=0.4,
                name=f"Line to {b_name}"
            )

            # LV bus
            lv_node = pp.create_bus(net, vn_kv=0.48, name=f"LV - {b_name}")

            # Building transformer
            trafo_idx = pp.create_transformer_from_parameters(
                net,
                hv_bus=mv_node,
                lv_bus=lv_node,
                sn_mva=1.5,
                vn_hv_kv=12,
                vn_lv_kv=0.48,
                vkr_percent=1.0,
                vk_percent=5.0,
                pfe_kw=2.0,
                i0_percent=0.4,
                name=f"Trafo {b_name}"
            )

            # Fuse on transformer
            pp.create_switch(
                net,
                bus=mv_node,
                element=trafo_idx,
                et="t",
                type="LBS",
                closed=True,
                name=f"Fuse {b_name}"
            )

            # Load
            pp.create_load(
                net,
                bus=lv_node,
                p_mw=p_mw,
                q_mvar=q_mvar,
                name=b_name
            )

            previous_bus = mv_node

    return net


def run_simulation(net, scenario_name="Base Case"):
    print(f"\n--- {scenario_name} ---")

    try:
        pp.runpp(net, algorithm="nr", numba=False)
    except Exception as e:
        print("Simulation Failed:", e)
        return

    if net.converged:
        print("Power Flow Converged")
        print(f"Total Load: {net.res_load.p_mw.sum():.2f} MW")
        print(f"Voltage Range: "
              f"{net.res_bus.vm_pu.min():.3f} - "
              f"{net.res_bus.vm_pu.max():.3f} p.u.")
    else:
        print("Did not converge")


if __name__ == "__main__":

    ucr_net = create_ucr_network()

    # Base Case
    run_simulation(ucr_net, "Base Case")

    # Heatwave (30% increase)
    ucr_net.load["scaling"] = 1.3
    run_simulation(ucr_net, "Heatwave Scenario")

    # Reset scaling
    ucr_net.load["scaling"] = 1.0

    # Feeder A Outage
    idx = ucr_net.switch.index[ucr_net.switch.name == "CB Feeder_A"]
    if len(idx) > 0:
        ucr_net.switch.at[idx[0], "closed"] = False
        run_simulation(ucr_net, "Feeder A Outage")
