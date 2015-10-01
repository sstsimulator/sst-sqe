# Automatically generated SST Python input
import sst

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "0 ns")

# Define the simulation components
comp_rtr_G0R0 = sst.Component("rtr:G0R0", "merlin.hr_router")
comp_rtr_G0R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """0""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G0R0H0 = sst.Component("nic:G0R0H0", "merlin.test_nic")
comp_nic_G0R0H0.addParams({
      "id" : """0""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G0R0H1 = sst.Component("nic:G0R0H1", "merlin.test_nic")
comp_nic_G0R0H1.addParams({
      "id" : """1""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G0R1 = sst.Component("rtr:G0R1", "merlin.hr_router")
comp_rtr_G0R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """1""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G0R1H0 = sst.Component("nic:G0R1H0", "merlin.test_nic")
comp_nic_G0R1H0.addParams({
      "id" : """2""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G0R1H1 = sst.Component("nic:G0R1H1", "merlin.test_nic")
comp_nic_G0R1H1.addParams({
      "id" : """3""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G0R2 = sst.Component("rtr:G0R2", "merlin.hr_router")
comp_rtr_G0R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """2""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G0R2H0 = sst.Component("nic:G0R2H0", "merlin.test_nic")
comp_nic_G0R2H0.addParams({
      "id" : """4""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G0R2H1 = sst.Component("nic:G0R2H1", "merlin.test_nic")
comp_nic_G0R2H1.addParams({
      "id" : """5""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G0R3 = sst.Component("rtr:G0R3", "merlin.hr_router")
comp_rtr_G0R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """3""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G0R3H0 = sst.Component("nic:G0R3H0", "merlin.test_nic")
comp_nic_G0R3H0.addParams({
      "id" : """6""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G0R3H1 = sst.Component("nic:G0R3H1", "merlin.test_nic")
comp_nic_G0R3H1.addParams({
      "id" : """7""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G1R0 = sst.Component("rtr:G1R0", "merlin.hr_router")
comp_rtr_G1R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """4""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R0H0 = sst.Component("nic:G1R0H0", "merlin.test_nic")
comp_nic_G1R0H0.addParams({
      "id" : """8""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G1R0H1 = sst.Component("nic:G1R0H1", "merlin.test_nic")
comp_nic_G1R0H1.addParams({
      "id" : """9""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G1R1 = sst.Component("rtr:G1R1", "merlin.hr_router")
comp_rtr_G1R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """5""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R1H0 = sst.Component("nic:G1R1H0", "merlin.test_nic")
comp_nic_G1R1H0.addParams({
      "id" : """10""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G1R1H1 = sst.Component("nic:G1R1H1", "merlin.test_nic")
comp_nic_G1R1H1.addParams({
      "id" : """11""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G1R2 = sst.Component("rtr:G1R2", "merlin.hr_router")
comp_rtr_G1R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """6""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R2H0 = sst.Component("nic:G1R2H0", "merlin.test_nic")
comp_nic_G1R2H0.addParams({
      "id" : """12""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G1R2H1 = sst.Component("nic:G1R2H1", "merlin.test_nic")
comp_nic_G1R2H1.addParams({
      "id" : """13""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G1R3 = sst.Component("rtr:G1R3", "merlin.hr_router")
comp_rtr_G1R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """7""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R3H0 = sst.Component("nic:G1R3H0", "merlin.test_nic")
comp_nic_G1R3H0.addParams({
      "id" : """14""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G1R3H1 = sst.Component("nic:G1R3H1", "merlin.test_nic")
comp_nic_G1R3H1.addParams({
      "id" : """15""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G2R0 = sst.Component("rtr:G2R0", "merlin.hr_router")
comp_rtr_G2R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """8""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R0H0 = sst.Component("nic:G2R0H0", "merlin.test_nic")
comp_nic_G2R0H0.addParams({
      "id" : """16""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G2R0H1 = sst.Component("nic:G2R0H1", "merlin.test_nic")
comp_nic_G2R0H1.addParams({
      "id" : """17""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G2R1 = sst.Component("rtr:G2R1", "merlin.hr_router")
comp_rtr_G2R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """9""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R1H0 = sst.Component("nic:G2R1H0", "merlin.test_nic")
comp_nic_G2R1H0.addParams({
      "id" : """18""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G2R1H1 = sst.Component("nic:G2R1H1", "merlin.test_nic")
comp_nic_G2R1H1.addParams({
      "id" : """19""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G2R2 = sst.Component("rtr:G2R2", "merlin.hr_router")
comp_rtr_G2R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """10""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R2H0 = sst.Component("nic:G2R2H0", "merlin.test_nic")
comp_nic_G2R2H0.addParams({
      "id" : """20""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G2R2H1 = sst.Component("nic:G2R2H1", "merlin.test_nic")
comp_nic_G2R2H1.addParams({
      "id" : """21""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G2R3 = sst.Component("rtr:G2R3", "merlin.hr_router")
comp_rtr_G2R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """11""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R3H0 = sst.Component("nic:G2R3H0", "merlin.test_nic")
comp_nic_G2R3H0.addParams({
      "id" : """22""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G2R3H1 = sst.Component("nic:G2R3H1", "merlin.test_nic")
comp_nic_G2R3H1.addParams({
      "id" : """23""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G3R0 = sst.Component("rtr:G3R0", "merlin.hr_router")
comp_rtr_G3R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """12""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G3R0H0 = sst.Component("nic:G3R0H0", "merlin.test_nic")
comp_nic_G3R0H0.addParams({
      "id" : """24""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G3R0H1 = sst.Component("nic:G3R0H1", "merlin.test_nic")
comp_nic_G3R0H1.addParams({
      "id" : """25""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G3R1 = sst.Component("rtr:G3R1", "merlin.hr_router")
comp_rtr_G3R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """13""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G3R1H0 = sst.Component("nic:G3R1H0", "merlin.test_nic")
comp_nic_G3R1H0.addParams({
      "id" : """26""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G3R1H1 = sst.Component("nic:G3R1H1", "merlin.test_nic")
comp_nic_G3R1H1.addParams({
      "id" : """27""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G3R2 = sst.Component("rtr:G3R2", "merlin.hr_router")
comp_rtr_G3R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """14""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G3R2H0 = sst.Component("nic:G3R2H0", "merlin.test_nic")
comp_nic_G3R2H0.addParams({
      "id" : """28""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G3R2H1 = sst.Component("nic:G3R2H1", "merlin.test_nic")
comp_nic_G3R2H1.addParams({
      "id" : """29""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G3R3 = sst.Component("rtr:G3R3", "merlin.hr_router")
comp_rtr_G3R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """15""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G3R3H0 = sst.Component("nic:G3R3H0", "merlin.test_nic")
comp_nic_G3R3H0.addParams({
      "id" : """30""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G3R3H1 = sst.Component("nic:G3R3H1", "merlin.test_nic")
comp_nic_G3R3H1.addParams({
      "id" : """31""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G4R0 = sst.Component("rtr:G4R0", "merlin.hr_router")
comp_rtr_G4R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """16""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G4R0H0 = sst.Component("nic:G4R0H0", "merlin.test_nic")
comp_nic_G4R0H0.addParams({
      "id" : """32""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G4R0H1 = sst.Component("nic:G4R0H1", "merlin.test_nic")
comp_nic_G4R0H1.addParams({
      "id" : """33""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G4R1 = sst.Component("rtr:G4R1", "merlin.hr_router")
comp_rtr_G4R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """17""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G4R1H0 = sst.Component("nic:G4R1H0", "merlin.test_nic")
comp_nic_G4R1H0.addParams({
      "id" : """34""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G4R1H1 = sst.Component("nic:G4R1H1", "merlin.test_nic")
comp_nic_G4R1H1.addParams({
      "id" : """35""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G4R2 = sst.Component("rtr:G4R2", "merlin.hr_router")
comp_rtr_G4R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """18""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G4R2H0 = sst.Component("nic:G4R2H0", "merlin.test_nic")
comp_nic_G4R2H0.addParams({
      "id" : """36""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G4R2H1 = sst.Component("nic:G4R2H1", "merlin.test_nic")
comp_nic_G4R2H1.addParams({
      "id" : """37""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G4R3 = sst.Component("rtr:G4R3", "merlin.hr_router")
comp_rtr_G4R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """19""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G4R3H0 = sst.Component("nic:G4R3H0", "merlin.test_nic")
comp_nic_G4R3H0.addParams({
      "id" : """38""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G4R3H1 = sst.Component("nic:G4R3H1", "merlin.test_nic")
comp_nic_G4R3H1.addParams({
      "id" : """39""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G5R0 = sst.Component("rtr:G5R0", "merlin.hr_router")
comp_rtr_G5R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """20""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G5R0H0 = sst.Component("nic:G5R0H0", "merlin.test_nic")
comp_nic_G5R0H0.addParams({
      "id" : """40""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G5R0H1 = sst.Component("nic:G5R0H1", "merlin.test_nic")
comp_nic_G5R0H1.addParams({
      "id" : """41""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G5R1 = sst.Component("rtr:G5R1", "merlin.hr_router")
comp_rtr_G5R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """21""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G5R1H0 = sst.Component("nic:G5R1H0", "merlin.test_nic")
comp_nic_G5R1H0.addParams({
      "id" : """42""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G5R1H1 = sst.Component("nic:G5R1H1", "merlin.test_nic")
comp_nic_G5R1H1.addParams({
      "id" : """43""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G5R2 = sst.Component("rtr:G5R2", "merlin.hr_router")
comp_rtr_G5R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """22""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G5R2H0 = sst.Component("nic:G5R2H0", "merlin.test_nic")
comp_nic_G5R2H0.addParams({
      "id" : """44""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G5R2H1 = sst.Component("nic:G5R2H1", "merlin.test_nic")
comp_nic_G5R2H1.addParams({
      "id" : """45""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G5R3 = sst.Component("rtr:G5R3", "merlin.hr_router")
comp_rtr_G5R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """23""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G5R3H0 = sst.Component("nic:G5R3H0", "merlin.test_nic")
comp_nic_G5R3H0.addParams({
      "id" : """46""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G5R3H1 = sst.Component("nic:G5R3H1", "merlin.test_nic")
comp_nic_G5R3H1.addParams({
      "id" : """47""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G6R0 = sst.Component("rtr:G6R0", "merlin.hr_router")
comp_rtr_G6R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """24""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G6R0H0 = sst.Component("nic:G6R0H0", "merlin.test_nic")
comp_nic_G6R0H0.addParams({
      "id" : """48""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G6R0H1 = sst.Component("nic:G6R0H1", "merlin.test_nic")
comp_nic_G6R0H1.addParams({
      "id" : """49""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G6R1 = sst.Component("rtr:G6R1", "merlin.hr_router")
comp_rtr_G6R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """25""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G6R1H0 = sst.Component("nic:G6R1H0", "merlin.test_nic")
comp_nic_G6R1H0.addParams({
      "id" : """50""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G6R1H1 = sst.Component("nic:G6R1H1", "merlin.test_nic")
comp_nic_G6R1H1.addParams({
      "id" : """51""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G6R2 = sst.Component("rtr:G6R2", "merlin.hr_router")
comp_rtr_G6R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """26""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G6R2H0 = sst.Component("nic:G6R2H0", "merlin.test_nic")
comp_nic_G6R2H0.addParams({
      "id" : """52""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G6R2H1 = sst.Component("nic:G6R2H1", "merlin.test_nic")
comp_nic_G6R2H1.addParams({
      "id" : """53""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G6R3 = sst.Component("rtr:G6R3", "merlin.hr_router")
comp_rtr_G6R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """27""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G6R3H0 = sst.Component("nic:G6R3H0", "merlin.test_nic")
comp_nic_G6R3H0.addParams({
      "id" : """54""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G6R3H1 = sst.Component("nic:G6R3H1", "merlin.test_nic")
comp_nic_G6R3H1.addParams({
      "id" : """55""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G7R0 = sst.Component("rtr:G7R0", "merlin.hr_router")
comp_rtr_G7R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """28""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G7R0H0 = sst.Component("nic:G7R0H0", "merlin.test_nic")
comp_nic_G7R0H0.addParams({
      "id" : """56""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G7R0H1 = sst.Component("nic:G7R0H1", "merlin.test_nic")
comp_nic_G7R0H1.addParams({
      "id" : """57""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G7R1 = sst.Component("rtr:G7R1", "merlin.hr_router")
comp_rtr_G7R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """29""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G7R1H0 = sst.Component("nic:G7R1H0", "merlin.test_nic")
comp_nic_G7R1H0.addParams({
      "id" : """58""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G7R1H1 = sst.Component("nic:G7R1H1", "merlin.test_nic")
comp_nic_G7R1H1.addParams({
      "id" : """59""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G7R2 = sst.Component("rtr:G7R2", "merlin.hr_router")
comp_rtr_G7R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """30""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G7R2H0 = sst.Component("nic:G7R2H0", "merlin.test_nic")
comp_nic_G7R2H0.addParams({
      "id" : """60""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G7R2H1 = sst.Component("nic:G7R2H1", "merlin.test_nic")
comp_nic_G7R2H1.addParams({
      "id" : """61""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G7R3 = sst.Component("rtr:G7R3", "merlin.hr_router")
comp_rtr_G7R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """31""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G7R3H0 = sst.Component("nic:G7R3H0", "merlin.test_nic")
comp_nic_G7R3H0.addParams({
      "id" : """62""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G7R3H1 = sst.Component("nic:G7R3H1", "merlin.test_nic")
comp_nic_G7R3H1.addParams({
      "id" : """63""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G8R0 = sst.Component("rtr:G8R0", "merlin.hr_router")
comp_rtr_G8R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """32""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G8R0H0 = sst.Component("nic:G8R0H0", "merlin.test_nic")
comp_nic_G8R0H0.addParams({
      "id" : """64""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G8R0H1 = sst.Component("nic:G8R0H1", "merlin.test_nic")
comp_nic_G8R0H1.addParams({
      "id" : """65""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G8R1 = sst.Component("rtr:G8R1", "merlin.hr_router")
comp_rtr_G8R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """33""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G8R1H0 = sst.Component("nic:G8R1H0", "merlin.test_nic")
comp_nic_G8R1H0.addParams({
      "id" : """66""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G8R1H1 = sst.Component("nic:G8R1H1", "merlin.test_nic")
comp_nic_G8R1H1.addParams({
      "id" : """67""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G8R2 = sst.Component("rtr:G8R2", "merlin.hr_router")
comp_rtr_G8R2.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """34""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G8R2H0 = sst.Component("nic:G8R2H0", "merlin.test_nic")
comp_nic_G8R2H0.addParams({
      "id" : """68""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G8R2H1 = sst.Component("nic:G8R2H1", "merlin.test_nic")
comp_nic_G8R2H1.addParams({
      "id" : """69""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_rtr_G8R3 = sst.Component("rtr:G8R3", "merlin.hr_router")
comp_rtr_G8R3.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """35""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """9""",
      "dragonfly:routers_per_group" : """4""",
      "input_buf_size" : """1KB""",
      "debug" : """0""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """7""",
      "dragonfly:intergroup_per_router" : """2""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G8R3H0 = sst.Component("nic:G8R3H0", "merlin.test_nic")
comp_nic_G8R3H0.addParams({
      "id" : """70""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})
comp_nic_G8R3H1 = sst.Component("nic:G8R3H1", "merlin.test_nic")
comp_nic_G8R3H1.addParams({
      "id" : """71""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """72"""
})


# Define the simulation links
link_g0r0h0 = sst.Link("link_g0r0h0")
link_g0r0h0.connect( (comp_rtr_G0R0, "port0", "10000ps"), (comp_nic_G0R0H0, "rtr", "10000ps") )
link_g0r0h1 = sst.Link("link_g0r0h1")
link_g0r0h1.connect( (comp_rtr_G0R0, "port1", "10000ps"), (comp_nic_G0R0H1, "rtr", "10000ps") )
link_g0r0r1 = sst.Link("link_g0r0r1")
link_g0r0r1.connect( (comp_rtr_G0R0, "port2", "10000ps"), (comp_rtr_G0R1, "port2", "10000ps") )
link_g0r0r2 = sst.Link("link_g0r0r2")
link_g0r0r2.connect( (comp_rtr_G0R0, "port3", "10000ps"), (comp_rtr_G0R2, "port2", "10000ps") )
link_g0r0r3 = sst.Link("link_g0r0r3")
link_g0r0r3.connect( (comp_rtr_G0R0, "port4", "10000ps"), (comp_rtr_G0R3, "port2", "10000ps") )
link_g0g1_0 = sst.Link("link_g0g1_0")
link_g0g1_0.connect( (comp_rtr_G0R0, "port5", "10000ps"), (comp_rtr_G1R0, "port5", "10000ps") )
link_g0g2_0 = sst.Link("link_g0g2_0")
link_g0g2_0.connect( (comp_rtr_G0R0, "port6", "10000ps"), (comp_rtr_G2R0, "port5", "10000ps") )
link_g0r1h0 = sst.Link("link_g0r1h0")
link_g0r1h0.connect( (comp_rtr_G0R1, "port0", "10000ps"), (comp_nic_G0R1H0, "rtr", "10000ps") )
link_g0r1h1 = sst.Link("link_g0r1h1")
link_g0r1h1.connect( (comp_rtr_G0R1, "port1", "10000ps"), (comp_nic_G0R1H1, "rtr", "10000ps") )
link_g0r1r2 = sst.Link("link_g0r1r2")
link_g0r1r2.connect( (comp_rtr_G0R1, "port3", "10000ps"), (comp_rtr_G0R2, "port3", "10000ps") )
link_g0r1r3 = sst.Link("link_g0r1r3")
link_g0r1r3.connect( (comp_rtr_G0R1, "port4", "10000ps"), (comp_rtr_G0R3, "port3", "10000ps") )
link_g0g3_0 = sst.Link("link_g0g3_0")
link_g0g3_0.connect( (comp_rtr_G0R1, "port5", "10000ps"), (comp_rtr_G3R0, "port5", "10000ps") )
link_g0g4_0 = sst.Link("link_g0g4_0")
link_g0g4_0.connect( (comp_rtr_G0R1, "port6", "10000ps"), (comp_rtr_G4R0, "port5", "10000ps") )
link_g0r2h0 = sst.Link("link_g0r2h0")
link_g0r2h0.connect( (comp_rtr_G0R2, "port0", "10000ps"), (comp_nic_G0R2H0, "rtr", "10000ps") )
link_g0r2h1 = sst.Link("link_g0r2h1")
link_g0r2h1.connect( (comp_rtr_G0R2, "port1", "10000ps"), (comp_nic_G0R2H1, "rtr", "10000ps") )
link_g0r2r3 = sst.Link("link_g0r2r3")
link_g0r2r3.connect( (comp_rtr_G0R2, "port4", "10000ps"), (comp_rtr_G0R3, "port4", "10000ps") )
link_g0g5_0 = sst.Link("link_g0g5_0")
link_g0g5_0.connect( (comp_rtr_G0R2, "port5", "10000ps"), (comp_rtr_G5R0, "port5", "10000ps") )
link_g0g6_0 = sst.Link("link_g0g6_0")
link_g0g6_0.connect( (comp_rtr_G0R2, "port6", "10000ps"), (comp_rtr_G6R0, "port5", "10000ps") )
link_g0r3h0 = sst.Link("link_g0r3h0")
link_g0r3h0.connect( (comp_rtr_G0R3, "port0", "10000ps"), (comp_nic_G0R3H0, "rtr", "10000ps") )
link_g0r3h1 = sst.Link("link_g0r3h1")
link_g0r3h1.connect( (comp_rtr_G0R3, "port1", "10000ps"), (comp_nic_G0R3H1, "rtr", "10000ps") )
link_g0g7_0 = sst.Link("link_g0g7_0")
link_g0g7_0.connect( (comp_rtr_G0R3, "port5", "10000ps"), (comp_rtr_G7R0, "port5", "10000ps") )
link_g0g8_0 = sst.Link("link_g0g8_0")
link_g0g8_0.connect( (comp_rtr_G0R3, "port6", "10000ps"), (comp_rtr_G8R0, "port5", "10000ps") )
link_g1r0h0 = sst.Link("link_g1r0h0")
link_g1r0h0.connect( (comp_rtr_G1R0, "port0", "10000ps"), (comp_nic_G1R0H0, "rtr", "10000ps") )
link_g1r0h1 = sst.Link("link_g1r0h1")
link_g1r0h1.connect( (comp_rtr_G1R0, "port1", "10000ps"), (comp_nic_G1R0H1, "rtr", "10000ps") )
link_g1r0r1 = sst.Link("link_g1r0r1")
link_g1r0r1.connect( (comp_rtr_G1R0, "port2", "10000ps"), (comp_rtr_G1R1, "port2", "10000ps") )
link_g1r0r2 = sst.Link("link_g1r0r2")
link_g1r0r2.connect( (comp_rtr_G1R0, "port3", "10000ps"), (comp_rtr_G1R2, "port2", "10000ps") )
link_g1r0r3 = sst.Link("link_g1r0r3")
link_g1r0r3.connect( (comp_rtr_G1R0, "port4", "10000ps"), (comp_rtr_G1R3, "port2", "10000ps") )
link_g1g2_0 = sst.Link("link_g1g2_0")
link_g1g2_0.connect( (comp_rtr_G1R0, "port6", "10000ps"), (comp_rtr_G2R0, "port6", "10000ps") )
link_g1r1h0 = sst.Link("link_g1r1h0")
link_g1r1h0.connect( (comp_rtr_G1R1, "port0", "10000ps"), (comp_nic_G1R1H0, "rtr", "10000ps") )
link_g1r1h1 = sst.Link("link_g1r1h1")
link_g1r1h1.connect( (comp_rtr_G1R1, "port1", "10000ps"), (comp_nic_G1R1H1, "rtr", "10000ps") )
link_g1r1r2 = sst.Link("link_g1r1r2")
link_g1r1r2.connect( (comp_rtr_G1R1, "port3", "10000ps"), (comp_rtr_G1R2, "port3", "10000ps") )
link_g1r1r3 = sst.Link("link_g1r1r3")
link_g1r1r3.connect( (comp_rtr_G1R1, "port4", "10000ps"), (comp_rtr_G1R3, "port3", "10000ps") )
link_g1g3_0 = sst.Link("link_g1g3_0")
link_g1g3_0.connect( (comp_rtr_G1R1, "port5", "10000ps"), (comp_rtr_G3R0, "port6", "10000ps") )
link_g1g4_0 = sst.Link("link_g1g4_0")
link_g1g4_0.connect( (comp_rtr_G1R1, "port6", "10000ps"), (comp_rtr_G4R0, "port6", "10000ps") )
link_g1r2h0 = sst.Link("link_g1r2h0")
link_g1r2h0.connect( (comp_rtr_G1R2, "port0", "10000ps"), (comp_nic_G1R2H0, "rtr", "10000ps") )
link_g1r2h1 = sst.Link("link_g1r2h1")
link_g1r2h1.connect( (comp_rtr_G1R2, "port1", "10000ps"), (comp_nic_G1R2H1, "rtr", "10000ps") )
link_g1r2r3 = sst.Link("link_g1r2r3")
link_g1r2r3.connect( (comp_rtr_G1R2, "port4", "10000ps"), (comp_rtr_G1R3, "port4", "10000ps") )
link_g1g5_0 = sst.Link("link_g1g5_0")
link_g1g5_0.connect( (comp_rtr_G1R2, "port5", "10000ps"), (comp_rtr_G5R0, "port6", "10000ps") )
link_g1g6_0 = sst.Link("link_g1g6_0")
link_g1g6_0.connect( (comp_rtr_G1R2, "port6", "10000ps"), (comp_rtr_G6R0, "port6", "10000ps") )
link_g1r3h0 = sst.Link("link_g1r3h0")
link_g1r3h0.connect( (comp_rtr_G1R3, "port0", "10000ps"), (comp_nic_G1R3H0, "rtr", "10000ps") )
link_g1r3h1 = sst.Link("link_g1r3h1")
link_g1r3h1.connect( (comp_rtr_G1R3, "port1", "10000ps"), (comp_nic_G1R3H1, "rtr", "10000ps") )
link_g1g7_0 = sst.Link("link_g1g7_0")
link_g1g7_0.connect( (comp_rtr_G1R3, "port5", "10000ps"), (comp_rtr_G7R0, "port6", "10000ps") )
link_g1g8_0 = sst.Link("link_g1g8_0")
link_g1g8_0.connect( (comp_rtr_G1R3, "port6", "10000ps"), (comp_rtr_G8R0, "port6", "10000ps") )
link_g2r0h0 = sst.Link("link_g2r0h0")
link_g2r0h0.connect( (comp_rtr_G2R0, "port0", "10000ps"), (comp_nic_G2R0H0, "rtr", "10000ps") )
link_g2r0h1 = sst.Link("link_g2r0h1")
link_g2r0h1.connect( (comp_rtr_G2R0, "port1", "10000ps"), (comp_nic_G2R0H1, "rtr", "10000ps") )
link_g2r0r1 = sst.Link("link_g2r0r1")
link_g2r0r1.connect( (comp_rtr_G2R0, "port2", "10000ps"), (comp_rtr_G2R1, "port2", "10000ps") )
link_g2r0r2 = sst.Link("link_g2r0r2")
link_g2r0r2.connect( (comp_rtr_G2R0, "port3", "10000ps"), (comp_rtr_G2R2, "port2", "10000ps") )
link_g2r0r3 = sst.Link("link_g2r0r3")
link_g2r0r3.connect( (comp_rtr_G2R0, "port4", "10000ps"), (comp_rtr_G2R3, "port2", "10000ps") )
link_g2r1h0 = sst.Link("link_g2r1h0")
link_g2r1h0.connect( (comp_rtr_G2R1, "port0", "10000ps"), (comp_nic_G2R1H0, "rtr", "10000ps") )
link_g2r1h1 = sst.Link("link_g2r1h1")
link_g2r1h1.connect( (comp_rtr_G2R1, "port1", "10000ps"), (comp_nic_G2R1H1, "rtr", "10000ps") )
link_g2r1r2 = sst.Link("link_g2r1r2")
link_g2r1r2.connect( (comp_rtr_G2R1, "port3", "10000ps"), (comp_rtr_G2R2, "port3", "10000ps") )
link_g2r1r3 = sst.Link("link_g2r1r3")
link_g2r1r3.connect( (comp_rtr_G2R1, "port4", "10000ps"), (comp_rtr_G2R3, "port3", "10000ps") )
link_g2g3_0 = sst.Link("link_g2g3_0")
link_g2g3_0.connect( (comp_rtr_G2R1, "port5", "10000ps"), (comp_rtr_G3R1, "port5", "10000ps") )
link_g2g4_0 = sst.Link("link_g2g4_0")
link_g2g4_0.connect( (comp_rtr_G2R1, "port6", "10000ps"), (comp_rtr_G4R1, "port5", "10000ps") )
link_g2r2h0 = sst.Link("link_g2r2h0")
link_g2r2h0.connect( (comp_rtr_G2R2, "port0", "10000ps"), (comp_nic_G2R2H0, "rtr", "10000ps") )
link_g2r2h1 = sst.Link("link_g2r2h1")
link_g2r2h1.connect( (comp_rtr_G2R2, "port1", "10000ps"), (comp_nic_G2R2H1, "rtr", "10000ps") )
link_g2r2r3 = sst.Link("link_g2r2r3")
link_g2r2r3.connect( (comp_rtr_G2R2, "port4", "10000ps"), (comp_rtr_G2R3, "port4", "10000ps") )
link_g2g5_0 = sst.Link("link_g2g5_0")
link_g2g5_0.connect( (comp_rtr_G2R2, "port5", "10000ps"), (comp_rtr_G5R1, "port5", "10000ps") )
link_g2g6_0 = sst.Link("link_g2g6_0")
link_g2g6_0.connect( (comp_rtr_G2R2, "port6", "10000ps"), (comp_rtr_G6R1, "port5", "10000ps") )
link_g2r3h0 = sst.Link("link_g2r3h0")
link_g2r3h0.connect( (comp_rtr_G2R3, "port0", "10000ps"), (comp_nic_G2R3H0, "rtr", "10000ps") )
link_g2r3h1 = sst.Link("link_g2r3h1")
link_g2r3h1.connect( (comp_rtr_G2R3, "port1", "10000ps"), (comp_nic_G2R3H1, "rtr", "10000ps") )
link_g2g7_0 = sst.Link("link_g2g7_0")
link_g2g7_0.connect( (comp_rtr_G2R3, "port5", "10000ps"), (comp_rtr_G7R1, "port5", "10000ps") )
link_g2g8_0 = sst.Link("link_g2g8_0")
link_g2g8_0.connect( (comp_rtr_G2R3, "port6", "10000ps"), (comp_rtr_G8R1, "port5", "10000ps") )
link_g3r0h0 = sst.Link("link_g3r0h0")
link_g3r0h0.connect( (comp_rtr_G3R0, "port0", "10000ps"), (comp_nic_G3R0H0, "rtr", "10000ps") )
link_g3r0h1 = sst.Link("link_g3r0h1")
link_g3r0h1.connect( (comp_rtr_G3R0, "port1", "10000ps"), (comp_nic_G3R0H1, "rtr", "10000ps") )
link_g3r0r1 = sst.Link("link_g3r0r1")
link_g3r0r1.connect( (comp_rtr_G3R0, "port2", "10000ps"), (comp_rtr_G3R1, "port2", "10000ps") )
link_g3r0r2 = sst.Link("link_g3r0r2")
link_g3r0r2.connect( (comp_rtr_G3R0, "port3", "10000ps"), (comp_rtr_G3R2, "port2", "10000ps") )
link_g3r0r3 = sst.Link("link_g3r0r3")
link_g3r0r3.connect( (comp_rtr_G3R0, "port4", "10000ps"), (comp_rtr_G3R3, "port2", "10000ps") )
link_g3r1h0 = sst.Link("link_g3r1h0")
link_g3r1h0.connect( (comp_rtr_G3R1, "port0", "10000ps"), (comp_nic_G3R1H0, "rtr", "10000ps") )
link_g3r1h1 = sst.Link("link_g3r1h1")
link_g3r1h1.connect( (comp_rtr_G3R1, "port1", "10000ps"), (comp_nic_G3R1H1, "rtr", "10000ps") )
link_g3r1r2 = sst.Link("link_g3r1r2")
link_g3r1r2.connect( (comp_rtr_G3R1, "port3", "10000ps"), (comp_rtr_G3R2, "port3", "10000ps") )
link_g3r1r3 = sst.Link("link_g3r1r3")
link_g3r1r3.connect( (comp_rtr_G3R1, "port4", "10000ps"), (comp_rtr_G3R3, "port3", "10000ps") )
link_g3g4_0 = sst.Link("link_g3g4_0")
link_g3g4_0.connect( (comp_rtr_G3R1, "port6", "10000ps"), (comp_rtr_G4R1, "port6", "10000ps") )
link_g3r2h0 = sst.Link("link_g3r2h0")
link_g3r2h0.connect( (comp_rtr_G3R2, "port0", "10000ps"), (comp_nic_G3R2H0, "rtr", "10000ps") )
link_g3r2h1 = sst.Link("link_g3r2h1")
link_g3r2h1.connect( (comp_rtr_G3R2, "port1", "10000ps"), (comp_nic_G3R2H1, "rtr", "10000ps") )
link_g3r2r3 = sst.Link("link_g3r2r3")
link_g3r2r3.connect( (comp_rtr_G3R2, "port4", "10000ps"), (comp_rtr_G3R3, "port4", "10000ps") )
link_g3g5_0 = sst.Link("link_g3g5_0")
link_g3g5_0.connect( (comp_rtr_G3R2, "port5", "10000ps"), (comp_rtr_G5R1, "port6", "10000ps") )
link_g3g6_0 = sst.Link("link_g3g6_0")
link_g3g6_0.connect( (comp_rtr_G3R2, "port6", "10000ps"), (comp_rtr_G6R1, "port6", "10000ps") )
link_g3r3h0 = sst.Link("link_g3r3h0")
link_g3r3h0.connect( (comp_rtr_G3R3, "port0", "10000ps"), (comp_nic_G3R3H0, "rtr", "10000ps") )
link_g3r3h1 = sst.Link("link_g3r3h1")
link_g3r3h1.connect( (comp_rtr_G3R3, "port1", "10000ps"), (comp_nic_G3R3H1, "rtr", "10000ps") )
link_g3g7_0 = sst.Link("link_g3g7_0")
link_g3g7_0.connect( (comp_rtr_G3R3, "port5", "10000ps"), (comp_rtr_G7R1, "port6", "10000ps") )
link_g3g8_0 = sst.Link("link_g3g8_0")
link_g3g8_0.connect( (comp_rtr_G3R3, "port6", "10000ps"), (comp_rtr_G8R1, "port6", "10000ps") )
link_g4r0h0 = sst.Link("link_g4r0h0")
link_g4r0h0.connect( (comp_rtr_G4R0, "port0", "10000ps"), (comp_nic_G4R0H0, "rtr", "10000ps") )
link_g4r0h1 = sst.Link("link_g4r0h1")
link_g4r0h1.connect( (comp_rtr_G4R0, "port1", "10000ps"), (comp_nic_G4R0H1, "rtr", "10000ps") )
link_g4r0r1 = sst.Link("link_g4r0r1")
link_g4r0r1.connect( (comp_rtr_G4R0, "port2", "10000ps"), (comp_rtr_G4R1, "port2", "10000ps") )
link_g4r0r2 = sst.Link("link_g4r0r2")
link_g4r0r2.connect( (comp_rtr_G4R0, "port3", "10000ps"), (comp_rtr_G4R2, "port2", "10000ps") )
link_g4r0r3 = sst.Link("link_g4r0r3")
link_g4r0r3.connect( (comp_rtr_G4R0, "port4", "10000ps"), (comp_rtr_G4R3, "port2", "10000ps") )
link_g4r1h0 = sst.Link("link_g4r1h0")
link_g4r1h0.connect( (comp_rtr_G4R1, "port0", "10000ps"), (comp_nic_G4R1H0, "rtr", "10000ps") )
link_g4r1h1 = sst.Link("link_g4r1h1")
link_g4r1h1.connect( (comp_rtr_G4R1, "port1", "10000ps"), (comp_nic_G4R1H1, "rtr", "10000ps") )
link_g4r1r2 = sst.Link("link_g4r1r2")
link_g4r1r2.connect( (comp_rtr_G4R1, "port3", "10000ps"), (comp_rtr_G4R2, "port3", "10000ps") )
link_g4r1r3 = sst.Link("link_g4r1r3")
link_g4r1r3.connect( (comp_rtr_G4R1, "port4", "10000ps"), (comp_rtr_G4R3, "port3", "10000ps") )
link_g4r2h0 = sst.Link("link_g4r2h0")
link_g4r2h0.connect( (comp_rtr_G4R2, "port0", "10000ps"), (comp_nic_G4R2H0, "rtr", "10000ps") )
link_g4r2h1 = sst.Link("link_g4r2h1")
link_g4r2h1.connect( (comp_rtr_G4R2, "port1", "10000ps"), (comp_nic_G4R2H1, "rtr", "10000ps") )
link_g4r2r3 = sst.Link("link_g4r2r3")
link_g4r2r3.connect( (comp_rtr_G4R2, "port4", "10000ps"), (comp_rtr_G4R3, "port4", "10000ps") )
link_g4g5_0 = sst.Link("link_g4g5_0")
link_g4g5_0.connect( (comp_rtr_G4R2, "port5", "10000ps"), (comp_rtr_G5R2, "port5", "10000ps") )
link_g4g6_0 = sst.Link("link_g4g6_0")
link_g4g6_0.connect( (comp_rtr_G4R2, "port6", "10000ps"), (comp_rtr_G6R2, "port5", "10000ps") )
link_g4r3h0 = sst.Link("link_g4r3h0")
link_g4r3h0.connect( (comp_rtr_G4R3, "port0", "10000ps"), (comp_nic_G4R3H0, "rtr", "10000ps") )
link_g4r3h1 = sst.Link("link_g4r3h1")
link_g4r3h1.connect( (comp_rtr_G4R3, "port1", "10000ps"), (comp_nic_G4R3H1, "rtr", "10000ps") )
link_g4g7_0 = sst.Link("link_g4g7_0")
link_g4g7_0.connect( (comp_rtr_G4R3, "port5", "10000ps"), (comp_rtr_G7R2, "port5", "10000ps") )
link_g4g8_0 = sst.Link("link_g4g8_0")
link_g4g8_0.connect( (comp_rtr_G4R3, "port6", "10000ps"), (comp_rtr_G8R2, "port5", "10000ps") )
link_g5r0h0 = sst.Link("link_g5r0h0")
link_g5r0h0.connect( (comp_rtr_G5R0, "port0", "10000ps"), (comp_nic_G5R0H0, "rtr", "10000ps") )
link_g5r0h1 = sst.Link("link_g5r0h1")
link_g5r0h1.connect( (comp_rtr_G5R0, "port1", "10000ps"), (comp_nic_G5R0H1, "rtr", "10000ps") )
link_g5r0r1 = sst.Link("link_g5r0r1")
link_g5r0r1.connect( (comp_rtr_G5R0, "port2", "10000ps"), (comp_rtr_G5R1, "port2", "10000ps") )
link_g5r0r2 = sst.Link("link_g5r0r2")
link_g5r0r2.connect( (comp_rtr_G5R0, "port3", "10000ps"), (comp_rtr_G5R2, "port2", "10000ps") )
link_g5r0r3 = sst.Link("link_g5r0r3")
link_g5r0r3.connect( (comp_rtr_G5R0, "port4", "10000ps"), (comp_rtr_G5R3, "port2", "10000ps") )
link_g5r1h0 = sst.Link("link_g5r1h0")
link_g5r1h0.connect( (comp_rtr_G5R1, "port0", "10000ps"), (comp_nic_G5R1H0, "rtr", "10000ps") )
link_g5r1h1 = sst.Link("link_g5r1h1")
link_g5r1h1.connect( (comp_rtr_G5R1, "port1", "10000ps"), (comp_nic_G5R1H1, "rtr", "10000ps") )
link_g5r1r2 = sst.Link("link_g5r1r2")
link_g5r1r2.connect( (comp_rtr_G5R1, "port3", "10000ps"), (comp_rtr_G5R2, "port3", "10000ps") )
link_g5r1r3 = sst.Link("link_g5r1r3")
link_g5r1r3.connect( (comp_rtr_G5R1, "port4", "10000ps"), (comp_rtr_G5R3, "port3", "10000ps") )
link_g5r2h0 = sst.Link("link_g5r2h0")
link_g5r2h0.connect( (comp_rtr_G5R2, "port0", "10000ps"), (comp_nic_G5R2H0, "rtr", "10000ps") )
link_g5r2h1 = sst.Link("link_g5r2h1")
link_g5r2h1.connect( (comp_rtr_G5R2, "port1", "10000ps"), (comp_nic_G5R2H1, "rtr", "10000ps") )
link_g5r2r3 = sst.Link("link_g5r2r3")
link_g5r2r3.connect( (comp_rtr_G5R2, "port4", "10000ps"), (comp_rtr_G5R3, "port4", "10000ps") )
link_g5g6_0 = sst.Link("link_g5g6_0")
link_g5g6_0.connect( (comp_rtr_G5R2, "port6", "10000ps"), (comp_rtr_G6R2, "port6", "10000ps") )
link_g5r3h0 = sst.Link("link_g5r3h0")
link_g5r3h0.connect( (comp_rtr_G5R3, "port0", "10000ps"), (comp_nic_G5R3H0, "rtr", "10000ps") )
link_g5r3h1 = sst.Link("link_g5r3h1")
link_g5r3h1.connect( (comp_rtr_G5R3, "port1", "10000ps"), (comp_nic_G5R3H1, "rtr", "10000ps") )
link_g5g7_0 = sst.Link("link_g5g7_0")
link_g5g7_0.connect( (comp_rtr_G5R3, "port5", "10000ps"), (comp_rtr_G7R2, "port6", "10000ps") )
link_g5g8_0 = sst.Link("link_g5g8_0")
link_g5g8_0.connect( (comp_rtr_G5R3, "port6", "10000ps"), (comp_rtr_G8R2, "port6", "10000ps") )
link_g6r0h0 = sst.Link("link_g6r0h0")
link_g6r0h0.connect( (comp_rtr_G6R0, "port0", "10000ps"), (comp_nic_G6R0H0, "rtr", "10000ps") )
link_g6r0h1 = sst.Link("link_g6r0h1")
link_g6r0h1.connect( (comp_rtr_G6R0, "port1", "10000ps"), (comp_nic_G6R0H1, "rtr", "10000ps") )
link_g6r0r1 = sst.Link("link_g6r0r1")
link_g6r0r1.connect( (comp_rtr_G6R0, "port2", "10000ps"), (comp_rtr_G6R1, "port2", "10000ps") )
link_g6r0r2 = sst.Link("link_g6r0r2")
link_g6r0r2.connect( (comp_rtr_G6R0, "port3", "10000ps"), (comp_rtr_G6R2, "port2", "10000ps") )
link_g6r0r3 = sst.Link("link_g6r0r3")
link_g6r0r3.connect( (comp_rtr_G6R0, "port4", "10000ps"), (comp_rtr_G6R3, "port2", "10000ps") )
link_g6r1h0 = sst.Link("link_g6r1h0")
link_g6r1h0.connect( (comp_rtr_G6R1, "port0", "10000ps"), (comp_nic_G6R1H0, "rtr", "10000ps") )
link_g6r1h1 = sst.Link("link_g6r1h1")
link_g6r1h1.connect( (comp_rtr_G6R1, "port1", "10000ps"), (comp_nic_G6R1H1, "rtr", "10000ps") )
link_g6r1r2 = sst.Link("link_g6r1r2")
link_g6r1r2.connect( (comp_rtr_G6R1, "port3", "10000ps"), (comp_rtr_G6R2, "port3", "10000ps") )
link_g6r1r3 = sst.Link("link_g6r1r3")
link_g6r1r3.connect( (comp_rtr_G6R1, "port4", "10000ps"), (comp_rtr_G6R3, "port3", "10000ps") )
link_g6r2h0 = sst.Link("link_g6r2h0")
link_g6r2h0.connect( (comp_rtr_G6R2, "port0", "10000ps"), (comp_nic_G6R2H0, "rtr", "10000ps") )
link_g6r2h1 = sst.Link("link_g6r2h1")
link_g6r2h1.connect( (comp_rtr_G6R2, "port1", "10000ps"), (comp_nic_G6R2H1, "rtr", "10000ps") )
link_g6r2r3 = sst.Link("link_g6r2r3")
link_g6r2r3.connect( (comp_rtr_G6R2, "port4", "10000ps"), (comp_rtr_G6R3, "port4", "10000ps") )
link_g6r3h0 = sst.Link("link_g6r3h0")
link_g6r3h0.connect( (comp_rtr_G6R3, "port0", "10000ps"), (comp_nic_G6R3H0, "rtr", "10000ps") )
link_g6r3h1 = sst.Link("link_g6r3h1")
link_g6r3h1.connect( (comp_rtr_G6R3, "port1", "10000ps"), (comp_nic_G6R3H1, "rtr", "10000ps") )
link_g6g7_0 = sst.Link("link_g6g7_0")
link_g6g7_0.connect( (comp_rtr_G6R3, "port5", "10000ps"), (comp_rtr_G7R3, "port5", "10000ps") )
link_g6g8_0 = sst.Link("link_g6g8_0")
link_g6g8_0.connect( (comp_rtr_G6R3, "port6", "10000ps"), (comp_rtr_G8R3, "port5", "10000ps") )
link_g7r0h0 = sst.Link("link_g7r0h0")
link_g7r0h0.connect( (comp_rtr_G7R0, "port0", "10000ps"), (comp_nic_G7R0H0, "rtr", "10000ps") )
link_g7r0h1 = sst.Link("link_g7r0h1")
link_g7r0h1.connect( (comp_rtr_G7R0, "port1", "10000ps"), (comp_nic_G7R0H1, "rtr", "10000ps") )
link_g7r0r1 = sst.Link("link_g7r0r1")
link_g7r0r1.connect( (comp_rtr_G7R0, "port2", "10000ps"), (comp_rtr_G7R1, "port2", "10000ps") )
link_g7r0r2 = sst.Link("link_g7r0r2")
link_g7r0r2.connect( (comp_rtr_G7R0, "port3", "10000ps"), (comp_rtr_G7R2, "port2", "10000ps") )
link_g7r0r3 = sst.Link("link_g7r0r3")
link_g7r0r3.connect( (comp_rtr_G7R0, "port4", "10000ps"), (comp_rtr_G7R3, "port2", "10000ps") )
link_g7r1h0 = sst.Link("link_g7r1h0")
link_g7r1h0.connect( (comp_rtr_G7R1, "port0", "10000ps"), (comp_nic_G7R1H0, "rtr", "10000ps") )
link_g7r1h1 = sst.Link("link_g7r1h1")
link_g7r1h1.connect( (comp_rtr_G7R1, "port1", "10000ps"), (comp_nic_G7R1H1, "rtr", "10000ps") )
link_g7r1r2 = sst.Link("link_g7r1r2")
link_g7r1r2.connect( (comp_rtr_G7R1, "port3", "10000ps"), (comp_rtr_G7R2, "port3", "10000ps") )
link_g7r1r3 = sst.Link("link_g7r1r3")
link_g7r1r3.connect( (comp_rtr_G7R1, "port4", "10000ps"), (comp_rtr_G7R3, "port3", "10000ps") )
link_g7r2h0 = sst.Link("link_g7r2h0")
link_g7r2h0.connect( (comp_rtr_G7R2, "port0", "10000ps"), (comp_nic_G7R2H0, "rtr", "10000ps") )
link_g7r2h1 = sst.Link("link_g7r2h1")
link_g7r2h1.connect( (comp_rtr_G7R2, "port1", "10000ps"), (comp_nic_G7R2H1, "rtr", "10000ps") )
link_g7r2r3 = sst.Link("link_g7r2r3")
link_g7r2r3.connect( (comp_rtr_G7R2, "port4", "10000ps"), (comp_rtr_G7R3, "port4", "10000ps") )
link_g7r3h0 = sst.Link("link_g7r3h0")
link_g7r3h0.connect( (comp_rtr_G7R3, "port0", "10000ps"), (comp_nic_G7R3H0, "rtr", "10000ps") )
link_g7r3h1 = sst.Link("link_g7r3h1")
link_g7r3h1.connect( (comp_rtr_G7R3, "port1", "10000ps"), (comp_nic_G7R3H1, "rtr", "10000ps") )
link_g7g8_0 = sst.Link("link_g7g8_0")
link_g7g8_0.connect( (comp_rtr_G7R3, "port6", "10000ps"), (comp_rtr_G8R3, "port6", "10000ps") )
link_g8r0h0 = sst.Link("link_g8r0h0")
link_g8r0h0.connect( (comp_rtr_G8R0, "port0", "10000ps"), (comp_nic_G8R0H0, "rtr", "10000ps") )
link_g8r0h1 = sst.Link("link_g8r0h1")
link_g8r0h1.connect( (comp_rtr_G8R0, "port1", "10000ps"), (comp_nic_G8R0H1, "rtr", "10000ps") )
link_g8r0r1 = sst.Link("link_g8r0r1")
link_g8r0r1.connect( (comp_rtr_G8R0, "port2", "10000ps"), (comp_rtr_G8R1, "port2", "10000ps") )
link_g8r0r2 = sst.Link("link_g8r0r2")
link_g8r0r2.connect( (comp_rtr_G8R0, "port3", "10000ps"), (comp_rtr_G8R2, "port2", "10000ps") )
link_g8r0r3 = sst.Link("link_g8r0r3")
link_g8r0r3.connect( (comp_rtr_G8R0, "port4", "10000ps"), (comp_rtr_G8R3, "port2", "10000ps") )
link_g8r1h0 = sst.Link("link_g8r1h0")
link_g8r1h0.connect( (comp_rtr_G8R1, "port0", "10000ps"), (comp_nic_G8R1H0, "rtr", "10000ps") )
link_g8r1h1 = sst.Link("link_g8r1h1")
link_g8r1h1.connect( (comp_rtr_G8R1, "port1", "10000ps"), (comp_nic_G8R1H1, "rtr", "10000ps") )
link_g8r1r2 = sst.Link("link_g8r1r2")
link_g8r1r2.connect( (comp_rtr_G8R1, "port3", "10000ps"), (comp_rtr_G8R2, "port3", "10000ps") )
link_g8r1r3 = sst.Link("link_g8r1r3")
link_g8r1r3.connect( (comp_rtr_G8R1, "port4", "10000ps"), (comp_rtr_G8R3, "port3", "10000ps") )
link_g8r2h0 = sst.Link("link_g8r2h0")
link_g8r2h0.connect( (comp_rtr_G8R2, "port0", "10000ps"), (comp_nic_G8R2H0, "rtr", "10000ps") )
link_g8r2h1 = sst.Link("link_g8r2h1")
link_g8r2h1.connect( (comp_rtr_G8R2, "port1", "10000ps"), (comp_nic_G8R2H1, "rtr", "10000ps") )
link_g8r2r3 = sst.Link("link_g8r2r3")
link_g8r2r3.connect( (comp_rtr_G8R2, "port4", "10000ps"), (comp_rtr_G8R3, "port4", "10000ps") )
link_g8r3h0 = sst.Link("link_g8r3h0")
link_g8r3h0.connect( (comp_rtr_G8R3, "port0", "10000ps"), (comp_nic_G8R3H0, "rtr", "10000ps") )
link_g8r3h1 = sst.Link("link_g8r3h1")
link_g8r3h1.connect( (comp_rtr_G8R3, "port1", "10000ps"), (comp_nic_G8R3H1, "rtr", "10000ps") )
# End of generated output.
