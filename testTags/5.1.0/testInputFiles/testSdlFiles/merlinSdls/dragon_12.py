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
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
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
      "num_peers" : """12"""
})
comp_nic_G0R0H1 = sst.Component("nic:G0R0H1", "merlin.test_nic")
comp_nic_G0R0H1.addParams({
      "id" : """1""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_rtr_G0R1 = sst.Component("rtr:G0R1", "merlin.hr_router")
comp_rtr_G0R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """1""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
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
      "num_peers" : """12"""
})
comp_nic_G0R1H1 = sst.Component("nic:G0R1H1", "merlin.test_nic")
comp_nic_G0R1H1.addParams({
      "id" : """3""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_rtr_G1R0 = sst.Component("rtr:G1R0", "merlin.hr_router")
comp_rtr_G1R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """2""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R0H0 = sst.Component("nic:G1R0H0", "merlin.test_nic")
comp_nic_G1R0H0.addParams({
      "id" : """4""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_nic_G1R0H1 = sst.Component("nic:G1R0H1", "merlin.test_nic")
comp_nic_G1R0H1.addParams({
      "id" : """5""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_rtr_G1R1 = sst.Component("rtr:G1R1", "merlin.hr_router")
comp_rtr_G1R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """3""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G1R1H0 = sst.Component("nic:G1R1H0", "merlin.test_nic")
comp_nic_G1R1H0.addParams({
      "id" : """6""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_nic_G1R1H1 = sst.Component("nic:G1R1H1", "merlin.test_nic")
comp_nic_G1R1H1.addParams({
      "id" : """7""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_rtr_G2R0 = sst.Component("rtr:G2R0", "merlin.hr_router")
comp_rtr_G2R0.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """4""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R0H0 = sst.Component("nic:G2R0H0", "merlin.test_nic")
comp_nic_G2R0H0.addParams({
      "id" : """8""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_nic_G2R0H1 = sst.Component("nic:G2R0H1", "merlin.test_nic")
comp_nic_G2R0H1.addParams({
      "id" : """9""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_rtr_G2R1 = sst.Component("rtr:G2R1", "merlin.hr_router")
comp_rtr_G2R1.addParams({
      "dragonfly:hosts_per_router" : """2""",
      "id" : """5""",
      "xbar_bw" : """1GB/s""",
      "dragonfly:num_groups" : """3""",
      "dragonfly:routers_per_group" : """2""",
      "input_buf_size" : """1KB""",
      "debug" : """1""",
      "dragonfly:algorithm" : """valiant""",
      "num_ports" : """4""",
      "dragonfly:intergroup_per_router" : """1""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly"""
})
comp_nic_G2R1H0 = sst.Component("nic:G2R1H0", "merlin.test_nic")
comp_nic_G2R1H0.addParams({
      "id" : """10""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})
comp_nic_G2R1H1 = sst.Component("nic:G2R1H1", "merlin.test_nic")
comp_nic_G2R1H1.addParams({
      "id" : """11""",
      "link_bw" : """1GB/s""",
      "topology" : """merlin.dragonfly""",
      "num_vns" : """3""",
      "num_peers" : """12"""
})


# Define the simulation links
link_g0r0h0 = sst.Link("link_g0r0h0")
link_g0r0h0.connect( (comp_rtr_G0R0, "port0", "10000ps"), (comp_nic_G0R0H0, "rtr", "10000ps") )
link_g0r0h1 = sst.Link("link_g0r0h1")
link_g0r0h1.connect( (comp_rtr_G0R0, "port1", "10000ps"), (comp_nic_G0R0H1, "rtr", "10000ps") )
link_g0r0r1 = sst.Link("link_g0r0r1")
link_g0r0r1.connect( (comp_rtr_G0R0, "port2", "10000ps"), (comp_rtr_G0R1, "port2", "10000ps") )
link_g0g1_0 = sst.Link("link_g0g1_0")
link_g0g1_0.connect( (comp_rtr_G0R0, "port3", "10000ps"), (comp_rtr_G1R0, "port3", "10000ps") )
link_g0r1h0 = sst.Link("link_g0r1h0")
link_g0r1h0.connect( (comp_rtr_G0R1, "port0", "10000ps"), (comp_nic_G0R1H0, "rtr", "10000ps") )
link_g0r1h1 = sst.Link("link_g0r1h1")
link_g0r1h1.connect( (comp_rtr_G0R1, "port1", "10000ps"), (comp_nic_G0R1H1, "rtr", "10000ps") )
link_g0g2_0 = sst.Link("link_g0g2_0")
link_g0g2_0.connect( (comp_rtr_G0R1, "port3", "10000ps"), (comp_rtr_G2R0, "port3", "10000ps") )
link_g1r0h0 = sst.Link("link_g1r0h0")
link_g1r0h0.connect( (comp_rtr_G1R0, "port0", "10000ps"), (comp_nic_G1R0H0, "rtr", "10000ps") )
link_g1r0h1 = sst.Link("link_g1r0h1")
link_g1r0h1.connect( (comp_rtr_G1R0, "port1", "10000ps"), (comp_nic_G1R0H1, "rtr", "10000ps") )
link_g1r0r1 = sst.Link("link_g1r0r1")
link_g1r0r1.connect( (comp_rtr_G1R0, "port2", "10000ps"), (comp_rtr_G1R1, "port2", "10000ps") )
link_g1r1h0 = sst.Link("link_g1r1h0")
link_g1r1h0.connect( (comp_rtr_G1R1, "port0", "10000ps"), (comp_nic_G1R1H0, "rtr", "10000ps") )
link_g1r1h1 = sst.Link("link_g1r1h1")
link_g1r1h1.connect( (comp_rtr_G1R1, "port1", "10000ps"), (comp_nic_G1R1H1, "rtr", "10000ps") )
link_g1g2_0 = sst.Link("link_g1g2_0")
link_g1g2_0.connect( (comp_rtr_G1R1, "port3", "10000ps"), (comp_rtr_G2R1, "port3", "10000ps") )
link_g2r0h0 = sst.Link("link_g2r0h0")
link_g2r0h0.connect( (comp_rtr_G2R0, "port0", "10000ps"), (comp_nic_G2R0H0, "rtr", "10000ps") )
link_g2r0h1 = sst.Link("link_g2r0h1")
link_g2r0h1.connect( (comp_rtr_G2R0, "port1", "10000ps"), (comp_nic_G2R0H1, "rtr", "10000ps") )
link_g2r0r1 = sst.Link("link_g2r0r1")
link_g2r0r1.connect( (comp_rtr_G2R0, "port2", "10000ps"), (comp_rtr_G2R1, "port2", "10000ps") )
link_g2r1h0 = sst.Link("link_g2r1h0")
link_g2r1h0.connect( (comp_rtr_G2R1, "port0", "10000ps"), (comp_nic_G2R1H0, "rtr", "10000ps") )
link_g2r1h1 = sst.Link("link_g2r1h1")
link_g2r1h1.connect( (comp_rtr_G2R1, "port1", "10000ps"), (comp_nic_G2R1H1, "rtr", "10000ps") )
# End of generated output.
