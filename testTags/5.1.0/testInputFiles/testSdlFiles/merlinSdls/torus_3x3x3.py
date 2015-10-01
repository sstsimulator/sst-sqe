# Automatically generated SST Python input
import sst

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "0 ns")

# Define the simulation components
comp_rtr_0x0x0 = sst.Component("rtr.0x0x0", "merlin.hr_router")
comp_rtr_0x0x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """0""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x0x0_0 = sst.Component("nic.0x0x0-0", "merlin.test_nic")
comp_nic_0x0x0_0.addParams({
      "id" : """0""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x0_1 = sst.Component("nic.0x0x0-1", "merlin.test_nic")
comp_nic_0x0x0_1.addParams({
      "id" : """1""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x0_2 = sst.Component("nic.0x0x0-2", "merlin.test_nic")
comp_nic_0x0x0_2.addParams({
      "id" : """2""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x0_3 = sst.Component("nic.0x0x0-3", "merlin.test_nic")
comp_nic_0x0x0_3.addParams({
      "id" : """3""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x0x0 = sst.Component("rtr.1x0x0", "merlin.hr_router")
comp_rtr_1x0x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """1""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x0x0_0 = sst.Component("nic.1x0x0-0", "merlin.test_nic")
comp_nic_1x0x0_0.addParams({
      "id" : """4""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x0_1 = sst.Component("nic.1x0x0-1", "merlin.test_nic")
comp_nic_1x0x0_1.addParams({
      "id" : """5""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x0_2 = sst.Component("nic.1x0x0-2", "merlin.test_nic")
comp_nic_1x0x0_2.addParams({
      "id" : """6""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x0_3 = sst.Component("nic.1x0x0-3", "merlin.test_nic")
comp_nic_1x0x0_3.addParams({
      "id" : """7""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x0x0 = sst.Component("rtr.2x0x0", "merlin.hr_router")
comp_rtr_2x0x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """2""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x0x0_0 = sst.Component("nic.2x0x0-0", "merlin.test_nic")
comp_nic_2x0x0_0.addParams({
      "id" : """8""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x0_1 = sst.Component("nic.2x0x0-1", "merlin.test_nic")
comp_nic_2x0x0_1.addParams({
      "id" : """9""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x0_2 = sst.Component("nic.2x0x0-2", "merlin.test_nic")
comp_nic_2x0x0_2.addParams({
      "id" : """10""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x0_3 = sst.Component("nic.2x0x0-3", "merlin.test_nic")
comp_nic_2x0x0_3.addParams({
      "id" : """11""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x1x0 = sst.Component("rtr.0x1x0", "merlin.hr_router")
comp_rtr_0x1x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """3""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x1x0_0 = sst.Component("nic.0x1x0-0", "merlin.test_nic")
comp_nic_0x1x0_0.addParams({
      "id" : """12""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x0_1 = sst.Component("nic.0x1x0-1", "merlin.test_nic")
comp_nic_0x1x0_1.addParams({
      "id" : """13""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x0_2 = sst.Component("nic.0x1x0-2", "merlin.test_nic")
comp_nic_0x1x0_2.addParams({
      "id" : """14""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x0_3 = sst.Component("nic.0x1x0-3", "merlin.test_nic")
comp_nic_0x1x0_3.addParams({
      "id" : """15""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x1x0 = sst.Component("rtr.1x1x0", "merlin.hr_router")
comp_rtr_1x1x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """4""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x1x0_0 = sst.Component("nic.1x1x0-0", "merlin.test_nic")
comp_nic_1x1x0_0.addParams({
      "id" : """16""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x0_1 = sst.Component("nic.1x1x0-1", "merlin.test_nic")
comp_nic_1x1x0_1.addParams({
      "id" : """17""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x0_2 = sst.Component("nic.1x1x0-2", "merlin.test_nic")
comp_nic_1x1x0_2.addParams({
      "id" : """18""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x0_3 = sst.Component("nic.1x1x0-3", "merlin.test_nic")
comp_nic_1x1x0_3.addParams({
      "id" : """19""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x1x0 = sst.Component("rtr.2x1x0", "merlin.hr_router")
comp_rtr_2x1x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """5""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x1x0_0 = sst.Component("nic.2x1x0-0", "merlin.test_nic")
comp_nic_2x1x0_0.addParams({
      "id" : """20""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x0_1 = sst.Component("nic.2x1x0-1", "merlin.test_nic")
comp_nic_2x1x0_1.addParams({
      "id" : """21""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x0_2 = sst.Component("nic.2x1x0-2", "merlin.test_nic")
comp_nic_2x1x0_2.addParams({
      "id" : """22""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x0_3 = sst.Component("nic.2x1x0-3", "merlin.test_nic")
comp_nic_2x1x0_3.addParams({
      "id" : """23""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x2x0 = sst.Component("rtr.0x2x0", "merlin.hr_router")
comp_rtr_0x2x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """6""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x2x0_0 = sst.Component("nic.0x2x0-0", "merlin.test_nic")
comp_nic_0x2x0_0.addParams({
      "id" : """24""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x0_1 = sst.Component("nic.0x2x0-1", "merlin.test_nic")
comp_nic_0x2x0_1.addParams({
      "id" : """25""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x0_2 = sst.Component("nic.0x2x0-2", "merlin.test_nic")
comp_nic_0x2x0_2.addParams({
      "id" : """26""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x0_3 = sst.Component("nic.0x2x0-3", "merlin.test_nic")
comp_nic_0x2x0_3.addParams({
      "id" : """27""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x2x0 = sst.Component("rtr.1x2x0", "merlin.hr_router")
comp_rtr_1x2x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """7""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x2x0_0 = sst.Component("nic.1x2x0-0", "merlin.test_nic")
comp_nic_1x2x0_0.addParams({
      "id" : """28""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x0_1 = sst.Component("nic.1x2x0-1", "merlin.test_nic")
comp_nic_1x2x0_1.addParams({
      "id" : """29""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x0_2 = sst.Component("nic.1x2x0-2", "merlin.test_nic")
comp_nic_1x2x0_2.addParams({
      "id" : """30""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x0_3 = sst.Component("nic.1x2x0-3", "merlin.test_nic")
comp_nic_1x2x0_3.addParams({
      "id" : """31""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x2x0 = sst.Component("rtr.2x2x0", "merlin.hr_router")
comp_rtr_2x2x0.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """8""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x2x0_0 = sst.Component("nic.2x2x0-0", "merlin.test_nic")
comp_nic_2x2x0_0.addParams({
      "id" : """32""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x0_1 = sst.Component("nic.2x2x0-1", "merlin.test_nic")
comp_nic_2x2x0_1.addParams({
      "id" : """33""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x0_2 = sst.Component("nic.2x2x0-2", "merlin.test_nic")
comp_nic_2x2x0_2.addParams({
      "id" : """34""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x0_3 = sst.Component("nic.2x2x0-3", "merlin.test_nic")
comp_nic_2x2x0_3.addParams({
      "id" : """35""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x0x1 = sst.Component("rtr.0x0x1", "merlin.hr_router")
comp_rtr_0x0x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """9""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x0x1_0 = sst.Component("nic.0x0x1-0", "merlin.test_nic")
comp_nic_0x0x1_0.addParams({
      "id" : """36""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x1_1 = sst.Component("nic.0x0x1-1", "merlin.test_nic")
comp_nic_0x0x1_1.addParams({
      "id" : """37""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x1_2 = sst.Component("nic.0x0x1-2", "merlin.test_nic")
comp_nic_0x0x1_2.addParams({
      "id" : """38""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x1_3 = sst.Component("nic.0x0x1-3", "merlin.test_nic")
comp_nic_0x0x1_3.addParams({
      "id" : """39""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x0x1 = sst.Component("rtr.1x0x1", "merlin.hr_router")
comp_rtr_1x0x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """10""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x0x1_0 = sst.Component("nic.1x0x1-0", "merlin.test_nic")
comp_nic_1x0x1_0.addParams({
      "id" : """40""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x1_1 = sst.Component("nic.1x0x1-1", "merlin.test_nic")
comp_nic_1x0x1_1.addParams({
      "id" : """41""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x1_2 = sst.Component("nic.1x0x1-2", "merlin.test_nic")
comp_nic_1x0x1_2.addParams({
      "id" : """42""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x1_3 = sst.Component("nic.1x0x1-3", "merlin.test_nic")
comp_nic_1x0x1_3.addParams({
      "id" : """43""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x0x1 = sst.Component("rtr.2x0x1", "merlin.hr_router")
comp_rtr_2x0x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """11""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x0x1_0 = sst.Component("nic.2x0x1-0", "merlin.test_nic")
comp_nic_2x0x1_0.addParams({
      "id" : """44""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x1_1 = sst.Component("nic.2x0x1-1", "merlin.test_nic")
comp_nic_2x0x1_1.addParams({
      "id" : """45""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x1_2 = sst.Component("nic.2x0x1-2", "merlin.test_nic")
comp_nic_2x0x1_2.addParams({
      "id" : """46""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x1_3 = sst.Component("nic.2x0x1-3", "merlin.test_nic")
comp_nic_2x0x1_3.addParams({
      "id" : """47""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x1x1 = sst.Component("rtr.0x1x1", "merlin.hr_router")
comp_rtr_0x1x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """12""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x1x1_0 = sst.Component("nic.0x1x1-0", "merlin.test_nic")
comp_nic_0x1x1_0.addParams({
      "id" : """48""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x1_1 = sst.Component("nic.0x1x1-1", "merlin.test_nic")
comp_nic_0x1x1_1.addParams({
      "id" : """49""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x1_2 = sst.Component("nic.0x1x1-2", "merlin.test_nic")
comp_nic_0x1x1_2.addParams({
      "id" : """50""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x1_3 = sst.Component("nic.0x1x1-3", "merlin.test_nic")
comp_nic_0x1x1_3.addParams({
      "id" : """51""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x1x1 = sst.Component("rtr.1x1x1", "merlin.hr_router")
comp_rtr_1x1x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """13""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x1x1_0 = sst.Component("nic.1x1x1-0", "merlin.test_nic")
comp_nic_1x1x1_0.addParams({
      "id" : """52""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x1_1 = sst.Component("nic.1x1x1-1", "merlin.test_nic")
comp_nic_1x1x1_1.addParams({
      "id" : """53""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x1_2 = sst.Component("nic.1x1x1-2", "merlin.test_nic")
comp_nic_1x1x1_2.addParams({
      "id" : """54""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x1_3 = sst.Component("nic.1x1x1-3", "merlin.test_nic")
comp_nic_1x1x1_3.addParams({
      "id" : """55""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x1x1 = sst.Component("rtr.2x1x1", "merlin.hr_router")
comp_rtr_2x1x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """14""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x1x1_0 = sst.Component("nic.2x1x1-0", "merlin.test_nic")
comp_nic_2x1x1_0.addParams({
      "id" : """56""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x1_1 = sst.Component("nic.2x1x1-1", "merlin.test_nic")
comp_nic_2x1x1_1.addParams({
      "id" : """57""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x1_2 = sst.Component("nic.2x1x1-2", "merlin.test_nic")
comp_nic_2x1x1_2.addParams({
      "id" : """58""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x1_3 = sst.Component("nic.2x1x1-3", "merlin.test_nic")
comp_nic_2x1x1_3.addParams({
      "id" : """59""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x2x1 = sst.Component("rtr.0x2x1", "merlin.hr_router")
comp_rtr_0x2x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """15""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x2x1_0 = sst.Component("nic.0x2x1-0", "merlin.test_nic")
comp_nic_0x2x1_0.addParams({
      "id" : """60""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x1_1 = sst.Component("nic.0x2x1-1", "merlin.test_nic")
comp_nic_0x2x1_1.addParams({
      "id" : """61""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x1_2 = sst.Component("nic.0x2x1-2", "merlin.test_nic")
comp_nic_0x2x1_2.addParams({
      "id" : """62""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x1_3 = sst.Component("nic.0x2x1-3", "merlin.test_nic")
comp_nic_0x2x1_3.addParams({
      "id" : """63""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x2x1 = sst.Component("rtr.1x2x1", "merlin.hr_router")
comp_rtr_1x2x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """16""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x2x1_0 = sst.Component("nic.1x2x1-0", "merlin.test_nic")
comp_nic_1x2x1_0.addParams({
      "id" : """64""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x1_1 = sst.Component("nic.1x2x1-1", "merlin.test_nic")
comp_nic_1x2x1_1.addParams({
      "id" : """65""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x1_2 = sst.Component("nic.1x2x1-2", "merlin.test_nic")
comp_nic_1x2x1_2.addParams({
      "id" : """66""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x1_3 = sst.Component("nic.1x2x1-3", "merlin.test_nic")
comp_nic_1x2x1_3.addParams({
      "id" : """67""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x2x1 = sst.Component("rtr.2x2x1", "merlin.hr_router")
comp_rtr_2x2x1.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """17""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x2x1_0 = sst.Component("nic.2x2x1-0", "merlin.test_nic")
comp_nic_2x2x1_0.addParams({
      "id" : """68""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x1_1 = sst.Component("nic.2x2x1-1", "merlin.test_nic")
comp_nic_2x2x1_1.addParams({
      "id" : """69""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x1_2 = sst.Component("nic.2x2x1-2", "merlin.test_nic")
comp_nic_2x2x1_2.addParams({
      "id" : """70""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x1_3 = sst.Component("nic.2x2x1-3", "merlin.test_nic")
comp_nic_2x2x1_3.addParams({
      "id" : """71""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x0x2 = sst.Component("rtr.0x0x2", "merlin.hr_router")
comp_rtr_0x0x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """18""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x0x2_0 = sst.Component("nic.0x0x2-0", "merlin.test_nic")
comp_nic_0x0x2_0.addParams({
      "id" : """72""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x2_1 = sst.Component("nic.0x0x2-1", "merlin.test_nic")
comp_nic_0x0x2_1.addParams({
      "id" : """73""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x2_2 = sst.Component("nic.0x0x2-2", "merlin.test_nic")
comp_nic_0x0x2_2.addParams({
      "id" : """74""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x0x2_3 = sst.Component("nic.0x0x2-3", "merlin.test_nic")
comp_nic_0x0x2_3.addParams({
      "id" : """75""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x0x2 = sst.Component("rtr.1x0x2", "merlin.hr_router")
comp_rtr_1x0x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """19""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x0x2_0 = sst.Component("nic.1x0x2-0", "merlin.test_nic")
comp_nic_1x0x2_0.addParams({
      "id" : """76""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x2_1 = sst.Component("nic.1x0x2-1", "merlin.test_nic")
comp_nic_1x0x2_1.addParams({
      "id" : """77""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x2_2 = sst.Component("nic.1x0x2-2", "merlin.test_nic")
comp_nic_1x0x2_2.addParams({
      "id" : """78""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x0x2_3 = sst.Component("nic.1x0x2-3", "merlin.test_nic")
comp_nic_1x0x2_3.addParams({
      "id" : """79""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x0x2 = sst.Component("rtr.2x0x2", "merlin.hr_router")
comp_rtr_2x0x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """20""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x0x2_0 = sst.Component("nic.2x0x2-0", "merlin.test_nic")
comp_nic_2x0x2_0.addParams({
      "id" : """80""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x2_1 = sst.Component("nic.2x0x2-1", "merlin.test_nic")
comp_nic_2x0x2_1.addParams({
      "id" : """81""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x2_2 = sst.Component("nic.2x0x2-2", "merlin.test_nic")
comp_nic_2x0x2_2.addParams({
      "id" : """82""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x0x2_3 = sst.Component("nic.2x0x2-3", "merlin.test_nic")
comp_nic_2x0x2_3.addParams({
      "id" : """83""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x1x2 = sst.Component("rtr.0x1x2", "merlin.hr_router")
comp_rtr_0x1x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """21""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x1x2_0 = sst.Component("nic.0x1x2-0", "merlin.test_nic")
comp_nic_0x1x2_0.addParams({
      "id" : """84""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x2_1 = sst.Component("nic.0x1x2-1", "merlin.test_nic")
comp_nic_0x1x2_1.addParams({
      "id" : """85""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x2_2 = sst.Component("nic.0x1x2-2", "merlin.test_nic")
comp_nic_0x1x2_2.addParams({
      "id" : """86""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x1x2_3 = sst.Component("nic.0x1x2-3", "merlin.test_nic")
comp_nic_0x1x2_3.addParams({
      "id" : """87""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x1x2 = sst.Component("rtr.1x1x2", "merlin.hr_router")
comp_rtr_1x1x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """22""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x1x2_0 = sst.Component("nic.1x1x2-0", "merlin.test_nic")
comp_nic_1x1x2_0.addParams({
      "id" : """88""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x2_1 = sst.Component("nic.1x1x2-1", "merlin.test_nic")
comp_nic_1x1x2_1.addParams({
      "id" : """89""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x2_2 = sst.Component("nic.1x1x2-2", "merlin.test_nic")
comp_nic_1x1x2_2.addParams({
      "id" : """90""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x1x2_3 = sst.Component("nic.1x1x2-3", "merlin.test_nic")
comp_nic_1x1x2_3.addParams({
      "id" : """91""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x1x2 = sst.Component("rtr.2x1x2", "merlin.hr_router")
comp_rtr_2x1x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """23""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x1x2_0 = sst.Component("nic.2x1x2-0", "merlin.test_nic")
comp_nic_2x1x2_0.addParams({
      "id" : """92""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x2_1 = sst.Component("nic.2x1x2-1", "merlin.test_nic")
comp_nic_2x1x2_1.addParams({
      "id" : """93""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x2_2 = sst.Component("nic.2x1x2-2", "merlin.test_nic")
comp_nic_2x1x2_2.addParams({
      "id" : """94""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x1x2_3 = sst.Component("nic.2x1x2-3", "merlin.test_nic")
comp_nic_2x1x2_3.addParams({
      "id" : """95""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_0x2x2 = sst.Component("rtr.0x2x2", "merlin.hr_router")
comp_rtr_0x2x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """24""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_0x2x2_0 = sst.Component("nic.0x2x2-0", "merlin.test_nic")
comp_nic_0x2x2_0.addParams({
      "id" : """96""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x2_1 = sst.Component("nic.0x2x2-1", "merlin.test_nic")
comp_nic_0x2x2_1.addParams({
      "id" : """97""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x2_2 = sst.Component("nic.0x2x2-2", "merlin.test_nic")
comp_nic_0x2x2_2.addParams({
      "id" : """98""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_0x2x2_3 = sst.Component("nic.0x2x2-3", "merlin.test_nic")
comp_nic_0x2x2_3.addParams({
      "id" : """99""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_1x2x2 = sst.Component("rtr.1x2x2", "merlin.hr_router")
comp_rtr_1x2x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """25""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_1x2x2_0 = sst.Component("nic.1x2x2-0", "merlin.test_nic")
comp_nic_1x2x2_0.addParams({
      "id" : """100""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x2_1 = sst.Component("nic.1x2x2-1", "merlin.test_nic")
comp_nic_1x2x2_1.addParams({
      "id" : """101""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x2_2 = sst.Component("nic.1x2x2-2", "merlin.test_nic")
comp_nic_1x2x2_2.addParams({
      "id" : """102""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_1x2x2_3 = sst.Component("nic.1x2x2-3", "merlin.test_nic")
comp_nic_1x2x2_3.addParams({
      "id" : """103""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_rtr_2x2x2 = sst.Component("rtr.2x2x2", "merlin.hr_router")
comp_rtr_2x2x2.addParams({
      "torus:shape" : """3x3x3""",
      "xbar_bw" : """1GB/s""",
      "id" : """26""",
      "input_buf_size" : """1KB""",
      "num_ports" : """22""",
      "debug" : """0""",
      "torus:local_ports" : """4""",
      "flit_size" : """16B""",
      "output_buf_size" : """1KB""",
      "link_bw" : """1GB/s""",
      "torus:width" : """3x3x3""",
      "topology" : """merlin.torus"""
})
comp_nic_2x2x2_0 = sst.Component("nic.2x2x2-0", "merlin.test_nic")
comp_nic_2x2x2_0.addParams({
      "id" : """104""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x2_1 = sst.Component("nic.2x2x2-1", "merlin.test_nic")
comp_nic_2x2x2_1.addParams({
      "id" : """105""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x2_2 = sst.Component("nic.2x2x2-2", "merlin.test_nic")
comp_nic_2x2x2_2.addParams({
      "id" : """106""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})
comp_nic_2x2x2_3 = sst.Component("nic.2x2x2-3", "merlin.test_nic")
comp_nic_2x2x2_3.addParams({
      "id" : """107""",
      "link_bw" : """1GB/s""",
      "num_vns" : """2""",
      "num_peers" : """108"""
})


# Define the simulation links
link_0x0x0_1x0x0_0 = sst.Link("link_0x0x0_1x0x0_0")
link_0x0x0_1x0x0_0.connect( (comp_rtr_0x0x0, "port0", "10000ps"), (comp_rtr_1x0x0, "port3", "10000ps") )
link_0x0x0_1x0x0_1 = sst.Link("link_0x0x0_1x0x0_1")
link_0x0x0_1x0x0_1.connect( (comp_rtr_0x0x0, "port1", "10000ps"), (comp_rtr_1x0x0, "port4", "10000ps") )
link_0x0x0_1x0x0_2 = sst.Link("link_0x0x0_1x0x0_2")
link_0x0x0_1x0x0_2.connect( (comp_rtr_0x0x0, "port2", "10000ps"), (comp_rtr_1x0x0, "port5", "10000ps") )
link_2x0x0_0x0x0_0 = sst.Link("link_2x0x0_0x0x0_0")
link_2x0x0_0x0x0_0.connect( (comp_rtr_0x0x0, "port3", "10000ps"), (comp_rtr_2x0x0, "port0", "10000ps") )
link_2x0x0_0x0x0_1 = sst.Link("link_2x0x0_0x0x0_1")
link_2x0x0_0x0x0_1.connect( (comp_rtr_0x0x0, "port4", "10000ps"), (comp_rtr_2x0x0, "port1", "10000ps") )
link_2x0x0_0x0x0_2 = sst.Link("link_2x0x0_0x0x0_2")
link_2x0x0_0x0x0_2.connect( (comp_rtr_0x0x0, "port5", "10000ps"), (comp_rtr_2x0x0, "port2", "10000ps") )
link_0x0x0_0x1x0_0 = sst.Link("link_0x0x0_0x1x0_0")
link_0x0x0_0x1x0_0.connect( (comp_rtr_0x0x0, "port6", "10000ps"), (comp_rtr_0x1x0, "port9", "10000ps") )
link_0x0x0_0x1x0_1 = sst.Link("link_0x0x0_0x1x0_1")
link_0x0x0_0x1x0_1.connect( (comp_rtr_0x0x0, "port7", "10000ps"), (comp_rtr_0x1x0, "port10", "10000ps") )
link_0x0x0_0x1x0_2 = sst.Link("link_0x0x0_0x1x0_2")
link_0x0x0_0x1x0_2.connect( (comp_rtr_0x0x0, "port8", "10000ps"), (comp_rtr_0x1x0, "port11", "10000ps") )
link_0x2x0_0x0x0_0 = sst.Link("link_0x2x0_0x0x0_0")
link_0x2x0_0x0x0_0.connect( (comp_rtr_0x0x0, "port9", "10000ps"), (comp_rtr_0x2x0, "port6", "10000ps") )
link_0x2x0_0x0x0_1 = sst.Link("link_0x2x0_0x0x0_1")
link_0x2x0_0x0x0_1.connect( (comp_rtr_0x0x0, "port10", "10000ps"), (comp_rtr_0x2x0, "port7", "10000ps") )
link_0x2x0_0x0x0_2 = sst.Link("link_0x2x0_0x0x0_2")
link_0x2x0_0x0x0_2.connect( (comp_rtr_0x0x0, "port11", "10000ps"), (comp_rtr_0x2x0, "port8", "10000ps") )
link_0x0x0_0x0x1_0 = sst.Link("link_0x0x0_0x0x1_0")
link_0x0x0_0x0x1_0.connect( (comp_rtr_0x0x0, "port12", "10000ps"), (comp_rtr_0x0x1, "port15", "10000ps") )
link_0x0x0_0x0x1_1 = sst.Link("link_0x0x0_0x0x1_1")
link_0x0x0_0x0x1_1.connect( (comp_rtr_0x0x0, "port13", "10000ps"), (comp_rtr_0x0x1, "port16", "10000ps") )
link_0x0x0_0x0x1_2 = sst.Link("link_0x0x0_0x0x1_2")
link_0x0x0_0x0x1_2.connect( (comp_rtr_0x0x0, "port14", "10000ps"), (comp_rtr_0x0x1, "port17", "10000ps") )
link_0x0x2_0x0x0_0 = sst.Link("link_0x0x2_0x0x0_0")
link_0x0x2_0x0x0_0.connect( (comp_rtr_0x0x0, "port15", "10000ps"), (comp_rtr_0x0x2, "port12", "10000ps") )
link_0x0x2_0x0x0_1 = sst.Link("link_0x0x2_0x0x0_1")
link_0x0x2_0x0x0_1.connect( (comp_rtr_0x0x0, "port16", "10000ps"), (comp_rtr_0x0x2, "port13", "10000ps") )
link_0x0x2_0x0x0_2 = sst.Link("link_0x0x2_0x0x0_2")
link_0x0x2_0x0x0_2.connect( (comp_rtr_0x0x0, "port17", "10000ps"), (comp_rtr_0x0x2, "port14", "10000ps") )
link_nic_0_0 = sst.Link("link_nic_0_0")
link_nic_0_0.connect( (comp_rtr_0x0x0, "port18", "10000ps"), (comp_nic_0x0x0_0, "rtr", "10000ps") )
link_nic_0_1 = sst.Link("link_nic_0_1")
link_nic_0_1.connect( (comp_rtr_0x0x0, "port19", "10000ps"), (comp_nic_0x0x0_1, "rtr", "10000ps") )
link_nic_0_2 = sst.Link("link_nic_0_2")
link_nic_0_2.connect( (comp_rtr_0x0x0, "port20", "10000ps"), (comp_nic_0x0x0_2, "rtr", "10000ps") )
link_nic_0_3 = sst.Link("link_nic_0_3")
link_nic_0_3.connect( (comp_rtr_0x0x0, "port21", "10000ps"), (comp_nic_0x0x0_3, "rtr", "10000ps") )
link_1x0x0_2x0x0_0 = sst.Link("link_1x0x0_2x0x0_0")
link_1x0x0_2x0x0_0.connect( (comp_rtr_1x0x0, "port0", "10000ps"), (comp_rtr_2x0x0, "port3", "10000ps") )
link_1x0x0_2x0x0_1 = sst.Link("link_1x0x0_2x0x0_1")
link_1x0x0_2x0x0_1.connect( (comp_rtr_1x0x0, "port1", "10000ps"), (comp_rtr_2x0x0, "port4", "10000ps") )
link_1x0x0_2x0x0_2 = sst.Link("link_1x0x0_2x0x0_2")
link_1x0x0_2x0x0_2.connect( (comp_rtr_1x0x0, "port2", "10000ps"), (comp_rtr_2x0x0, "port5", "10000ps") )
link_1x0x0_1x1x0_0 = sst.Link("link_1x0x0_1x1x0_0")
link_1x0x0_1x1x0_0.connect( (comp_rtr_1x0x0, "port6", "10000ps"), (comp_rtr_1x1x0, "port9", "10000ps") )
link_1x0x0_1x1x0_1 = sst.Link("link_1x0x0_1x1x0_1")
link_1x0x0_1x1x0_1.connect( (comp_rtr_1x0x0, "port7", "10000ps"), (comp_rtr_1x1x0, "port10", "10000ps") )
link_1x0x0_1x1x0_2 = sst.Link("link_1x0x0_1x1x0_2")
link_1x0x0_1x1x0_2.connect( (comp_rtr_1x0x0, "port8", "10000ps"), (comp_rtr_1x1x0, "port11", "10000ps") )
link_1x2x0_1x0x0_0 = sst.Link("link_1x2x0_1x0x0_0")
link_1x2x0_1x0x0_0.connect( (comp_rtr_1x0x0, "port9", "10000ps"), (comp_rtr_1x2x0, "port6", "10000ps") )
link_1x2x0_1x0x0_1 = sst.Link("link_1x2x0_1x0x0_1")
link_1x2x0_1x0x0_1.connect( (comp_rtr_1x0x0, "port10", "10000ps"), (comp_rtr_1x2x0, "port7", "10000ps") )
link_1x2x0_1x0x0_2 = sst.Link("link_1x2x0_1x0x0_2")
link_1x2x0_1x0x0_2.connect( (comp_rtr_1x0x0, "port11", "10000ps"), (comp_rtr_1x2x0, "port8", "10000ps") )
link_1x0x0_1x0x1_0 = sst.Link("link_1x0x0_1x0x1_0")
link_1x0x0_1x0x1_0.connect( (comp_rtr_1x0x0, "port12", "10000ps"), (comp_rtr_1x0x1, "port15", "10000ps") )
link_1x0x0_1x0x1_1 = sst.Link("link_1x0x0_1x0x1_1")
link_1x0x0_1x0x1_1.connect( (comp_rtr_1x0x0, "port13", "10000ps"), (comp_rtr_1x0x1, "port16", "10000ps") )
link_1x0x0_1x0x1_2 = sst.Link("link_1x0x0_1x0x1_2")
link_1x0x0_1x0x1_2.connect( (comp_rtr_1x0x0, "port14", "10000ps"), (comp_rtr_1x0x1, "port17", "10000ps") )
link_1x0x2_1x0x0_0 = sst.Link("link_1x0x2_1x0x0_0")
link_1x0x2_1x0x0_0.connect( (comp_rtr_1x0x0, "port15", "10000ps"), (comp_rtr_1x0x2, "port12", "10000ps") )
link_1x0x2_1x0x0_1 = sst.Link("link_1x0x2_1x0x0_1")
link_1x0x2_1x0x0_1.connect( (comp_rtr_1x0x0, "port16", "10000ps"), (comp_rtr_1x0x2, "port13", "10000ps") )
link_1x0x2_1x0x0_2 = sst.Link("link_1x0x2_1x0x0_2")
link_1x0x2_1x0x0_2.connect( (comp_rtr_1x0x0, "port17", "10000ps"), (comp_rtr_1x0x2, "port14", "10000ps") )
link_nic_1_0 = sst.Link("link_nic_1_0")
link_nic_1_0.connect( (comp_rtr_1x0x0, "port18", "10000ps"), (comp_nic_1x0x0_0, "rtr", "10000ps") )
link_nic_1_1 = sst.Link("link_nic_1_1")
link_nic_1_1.connect( (comp_rtr_1x0x0, "port19", "10000ps"), (comp_nic_1x0x0_1, "rtr", "10000ps") )
link_nic_1_2 = sst.Link("link_nic_1_2")
link_nic_1_2.connect( (comp_rtr_1x0x0, "port20", "10000ps"), (comp_nic_1x0x0_2, "rtr", "10000ps") )
link_nic_1_3 = sst.Link("link_nic_1_3")
link_nic_1_3.connect( (comp_rtr_1x0x0, "port21", "10000ps"), (comp_nic_1x0x0_3, "rtr", "10000ps") )
link_2x0x0_2x1x0_0 = sst.Link("link_2x0x0_2x1x0_0")
link_2x0x0_2x1x0_0.connect( (comp_rtr_2x0x0, "port6", "10000ps"), (comp_rtr_2x1x0, "port9", "10000ps") )
link_2x0x0_2x1x0_1 = sst.Link("link_2x0x0_2x1x0_1")
link_2x0x0_2x1x0_1.connect( (comp_rtr_2x0x0, "port7", "10000ps"), (comp_rtr_2x1x0, "port10", "10000ps") )
link_2x0x0_2x1x0_2 = sst.Link("link_2x0x0_2x1x0_2")
link_2x0x0_2x1x0_2.connect( (comp_rtr_2x0x0, "port8", "10000ps"), (comp_rtr_2x1x0, "port11", "10000ps") )
link_2x2x0_2x0x0_0 = sst.Link("link_2x2x0_2x0x0_0")
link_2x2x0_2x0x0_0.connect( (comp_rtr_2x0x0, "port9", "10000ps"), (comp_rtr_2x2x0, "port6", "10000ps") )
link_2x2x0_2x0x0_1 = sst.Link("link_2x2x0_2x0x0_1")
link_2x2x0_2x0x0_1.connect( (comp_rtr_2x0x0, "port10", "10000ps"), (comp_rtr_2x2x0, "port7", "10000ps") )
link_2x2x0_2x0x0_2 = sst.Link("link_2x2x0_2x0x0_2")
link_2x2x0_2x0x0_2.connect( (comp_rtr_2x0x0, "port11", "10000ps"), (comp_rtr_2x2x0, "port8", "10000ps") )
link_2x0x0_2x0x1_0 = sst.Link("link_2x0x0_2x0x1_0")
link_2x0x0_2x0x1_0.connect( (comp_rtr_2x0x0, "port12", "10000ps"), (comp_rtr_2x0x1, "port15", "10000ps") )
link_2x0x0_2x0x1_1 = sst.Link("link_2x0x0_2x0x1_1")
link_2x0x0_2x0x1_1.connect( (comp_rtr_2x0x0, "port13", "10000ps"), (comp_rtr_2x0x1, "port16", "10000ps") )
link_2x0x0_2x0x1_2 = sst.Link("link_2x0x0_2x0x1_2")
link_2x0x0_2x0x1_2.connect( (comp_rtr_2x0x0, "port14", "10000ps"), (comp_rtr_2x0x1, "port17", "10000ps") )
link_2x0x2_2x0x0_0 = sst.Link("link_2x0x2_2x0x0_0")
link_2x0x2_2x0x0_0.connect( (comp_rtr_2x0x0, "port15", "10000ps"), (comp_rtr_2x0x2, "port12", "10000ps") )
link_2x0x2_2x0x0_1 = sst.Link("link_2x0x2_2x0x0_1")
link_2x0x2_2x0x0_1.connect( (comp_rtr_2x0x0, "port16", "10000ps"), (comp_rtr_2x0x2, "port13", "10000ps") )
link_2x0x2_2x0x0_2 = sst.Link("link_2x0x2_2x0x0_2")
link_2x0x2_2x0x0_2.connect( (comp_rtr_2x0x0, "port17", "10000ps"), (comp_rtr_2x0x2, "port14", "10000ps") )
link_nic_2_0 = sst.Link("link_nic_2_0")
link_nic_2_0.connect( (comp_rtr_2x0x0, "port18", "10000ps"), (comp_nic_2x0x0_0, "rtr", "10000ps") )
link_nic_2_1 = sst.Link("link_nic_2_1")
link_nic_2_1.connect( (comp_rtr_2x0x0, "port19", "10000ps"), (comp_nic_2x0x0_1, "rtr", "10000ps") )
link_nic_2_2 = sst.Link("link_nic_2_2")
link_nic_2_2.connect( (comp_rtr_2x0x0, "port20", "10000ps"), (comp_nic_2x0x0_2, "rtr", "10000ps") )
link_nic_2_3 = sst.Link("link_nic_2_3")
link_nic_2_3.connect( (comp_rtr_2x0x0, "port21", "10000ps"), (comp_nic_2x0x0_3, "rtr", "10000ps") )
link_0x1x0_1x1x0_0 = sst.Link("link_0x1x0_1x1x0_0")
link_0x1x0_1x1x0_0.connect( (comp_rtr_0x1x0, "port0", "10000ps"), (comp_rtr_1x1x0, "port3", "10000ps") )
link_0x1x0_1x1x0_1 = sst.Link("link_0x1x0_1x1x0_1")
link_0x1x0_1x1x0_1.connect( (comp_rtr_0x1x0, "port1", "10000ps"), (comp_rtr_1x1x0, "port4", "10000ps") )
link_0x1x0_1x1x0_2 = sst.Link("link_0x1x0_1x1x0_2")
link_0x1x0_1x1x0_2.connect( (comp_rtr_0x1x0, "port2", "10000ps"), (comp_rtr_1x1x0, "port5", "10000ps") )
link_2x1x0_0x1x0_0 = sst.Link("link_2x1x0_0x1x0_0")
link_2x1x0_0x1x0_0.connect( (comp_rtr_0x1x0, "port3", "10000ps"), (comp_rtr_2x1x0, "port0", "10000ps") )
link_2x1x0_0x1x0_1 = sst.Link("link_2x1x0_0x1x0_1")
link_2x1x0_0x1x0_1.connect( (comp_rtr_0x1x0, "port4", "10000ps"), (comp_rtr_2x1x0, "port1", "10000ps") )
link_2x1x0_0x1x0_2 = sst.Link("link_2x1x0_0x1x0_2")
link_2x1x0_0x1x0_2.connect( (comp_rtr_0x1x0, "port5", "10000ps"), (comp_rtr_2x1x0, "port2", "10000ps") )
link_0x1x0_0x2x0_0 = sst.Link("link_0x1x0_0x2x0_0")
link_0x1x0_0x2x0_0.connect( (comp_rtr_0x1x0, "port6", "10000ps"), (comp_rtr_0x2x0, "port9", "10000ps") )
link_0x1x0_0x2x0_1 = sst.Link("link_0x1x0_0x2x0_1")
link_0x1x0_0x2x0_1.connect( (comp_rtr_0x1x0, "port7", "10000ps"), (comp_rtr_0x2x0, "port10", "10000ps") )
link_0x1x0_0x2x0_2 = sst.Link("link_0x1x0_0x2x0_2")
link_0x1x0_0x2x0_2.connect( (comp_rtr_0x1x0, "port8", "10000ps"), (comp_rtr_0x2x0, "port11", "10000ps") )
link_0x1x0_0x1x1_0 = sst.Link("link_0x1x0_0x1x1_0")
link_0x1x0_0x1x1_0.connect( (comp_rtr_0x1x0, "port12", "10000ps"), (comp_rtr_0x1x1, "port15", "10000ps") )
link_0x1x0_0x1x1_1 = sst.Link("link_0x1x0_0x1x1_1")
link_0x1x0_0x1x1_1.connect( (comp_rtr_0x1x0, "port13", "10000ps"), (comp_rtr_0x1x1, "port16", "10000ps") )
link_0x1x0_0x1x1_2 = sst.Link("link_0x1x0_0x1x1_2")
link_0x1x0_0x1x1_2.connect( (comp_rtr_0x1x0, "port14", "10000ps"), (comp_rtr_0x1x1, "port17", "10000ps") )
link_0x1x2_0x1x0_0 = sst.Link("link_0x1x2_0x1x0_0")
link_0x1x2_0x1x0_0.connect( (comp_rtr_0x1x0, "port15", "10000ps"), (comp_rtr_0x1x2, "port12", "10000ps") )
link_0x1x2_0x1x0_1 = sst.Link("link_0x1x2_0x1x0_1")
link_0x1x2_0x1x0_1.connect( (comp_rtr_0x1x0, "port16", "10000ps"), (comp_rtr_0x1x2, "port13", "10000ps") )
link_0x1x2_0x1x0_2 = sst.Link("link_0x1x2_0x1x0_2")
link_0x1x2_0x1x0_2.connect( (comp_rtr_0x1x0, "port17", "10000ps"), (comp_rtr_0x1x2, "port14", "10000ps") )
link_nic_3_0 = sst.Link("link_nic_3_0")
link_nic_3_0.connect( (comp_rtr_0x1x0, "port18", "10000ps"), (comp_nic_0x1x0_0, "rtr", "10000ps") )
link_nic_3_1 = sst.Link("link_nic_3_1")
link_nic_3_1.connect( (comp_rtr_0x1x0, "port19", "10000ps"), (comp_nic_0x1x0_1, "rtr", "10000ps") )
link_nic_3_2 = sst.Link("link_nic_3_2")
link_nic_3_2.connect( (comp_rtr_0x1x0, "port20", "10000ps"), (comp_nic_0x1x0_2, "rtr", "10000ps") )
link_nic_3_3 = sst.Link("link_nic_3_3")
link_nic_3_3.connect( (comp_rtr_0x1x0, "port21", "10000ps"), (comp_nic_0x1x0_3, "rtr", "10000ps") )
link_1x1x0_2x1x0_0 = sst.Link("link_1x1x0_2x1x0_0")
link_1x1x0_2x1x0_0.connect( (comp_rtr_1x1x0, "port0", "10000ps"), (comp_rtr_2x1x0, "port3", "10000ps") )
link_1x1x0_2x1x0_1 = sst.Link("link_1x1x0_2x1x0_1")
link_1x1x0_2x1x0_1.connect( (comp_rtr_1x1x0, "port1", "10000ps"), (comp_rtr_2x1x0, "port4", "10000ps") )
link_1x1x0_2x1x0_2 = sst.Link("link_1x1x0_2x1x0_2")
link_1x1x0_2x1x0_2.connect( (comp_rtr_1x1x0, "port2", "10000ps"), (comp_rtr_2x1x0, "port5", "10000ps") )
link_1x1x0_1x2x0_0 = sst.Link("link_1x1x0_1x2x0_0")
link_1x1x0_1x2x0_0.connect( (comp_rtr_1x1x0, "port6", "10000ps"), (comp_rtr_1x2x0, "port9", "10000ps") )
link_1x1x0_1x2x0_1 = sst.Link("link_1x1x0_1x2x0_1")
link_1x1x0_1x2x0_1.connect( (comp_rtr_1x1x0, "port7", "10000ps"), (comp_rtr_1x2x0, "port10", "10000ps") )
link_1x1x0_1x2x0_2 = sst.Link("link_1x1x0_1x2x0_2")
link_1x1x0_1x2x0_2.connect( (comp_rtr_1x1x0, "port8", "10000ps"), (comp_rtr_1x2x0, "port11", "10000ps") )
link_1x1x0_1x1x1_0 = sst.Link("link_1x1x0_1x1x1_0")
link_1x1x0_1x1x1_0.connect( (comp_rtr_1x1x0, "port12", "10000ps"), (comp_rtr_1x1x1, "port15", "10000ps") )
link_1x1x0_1x1x1_1 = sst.Link("link_1x1x0_1x1x1_1")
link_1x1x0_1x1x1_1.connect( (comp_rtr_1x1x0, "port13", "10000ps"), (comp_rtr_1x1x1, "port16", "10000ps") )
link_1x1x0_1x1x1_2 = sst.Link("link_1x1x0_1x1x1_2")
link_1x1x0_1x1x1_2.connect( (comp_rtr_1x1x0, "port14", "10000ps"), (comp_rtr_1x1x1, "port17", "10000ps") )
link_1x1x2_1x1x0_0 = sst.Link("link_1x1x2_1x1x0_0")
link_1x1x2_1x1x0_0.connect( (comp_rtr_1x1x0, "port15", "10000ps"), (comp_rtr_1x1x2, "port12", "10000ps") )
link_1x1x2_1x1x0_1 = sst.Link("link_1x1x2_1x1x0_1")
link_1x1x2_1x1x0_1.connect( (comp_rtr_1x1x0, "port16", "10000ps"), (comp_rtr_1x1x2, "port13", "10000ps") )
link_1x1x2_1x1x0_2 = sst.Link("link_1x1x2_1x1x0_2")
link_1x1x2_1x1x0_2.connect( (comp_rtr_1x1x0, "port17", "10000ps"), (comp_rtr_1x1x2, "port14", "10000ps") )
link_nic_4_0 = sst.Link("link_nic_4_0")
link_nic_4_0.connect( (comp_rtr_1x1x0, "port18", "10000ps"), (comp_nic_1x1x0_0, "rtr", "10000ps") )
link_nic_4_1 = sst.Link("link_nic_4_1")
link_nic_4_1.connect( (comp_rtr_1x1x0, "port19", "10000ps"), (comp_nic_1x1x0_1, "rtr", "10000ps") )
link_nic_4_2 = sst.Link("link_nic_4_2")
link_nic_4_2.connect( (comp_rtr_1x1x0, "port20", "10000ps"), (comp_nic_1x1x0_2, "rtr", "10000ps") )
link_nic_4_3 = sst.Link("link_nic_4_3")
link_nic_4_3.connect( (comp_rtr_1x1x0, "port21", "10000ps"), (comp_nic_1x1x0_3, "rtr", "10000ps") )
link_2x1x0_2x2x0_0 = sst.Link("link_2x1x0_2x2x0_0")
link_2x1x0_2x2x0_0.connect( (comp_rtr_2x1x0, "port6", "10000ps"), (comp_rtr_2x2x0, "port9", "10000ps") )
link_2x1x0_2x2x0_1 = sst.Link("link_2x1x0_2x2x0_1")
link_2x1x0_2x2x0_1.connect( (comp_rtr_2x1x0, "port7", "10000ps"), (comp_rtr_2x2x0, "port10", "10000ps") )
link_2x1x0_2x2x0_2 = sst.Link("link_2x1x0_2x2x0_2")
link_2x1x0_2x2x0_2.connect( (comp_rtr_2x1x0, "port8", "10000ps"), (comp_rtr_2x2x0, "port11", "10000ps") )
link_2x1x0_2x1x1_0 = sst.Link("link_2x1x0_2x1x1_0")
link_2x1x0_2x1x1_0.connect( (comp_rtr_2x1x0, "port12", "10000ps"), (comp_rtr_2x1x1, "port15", "10000ps") )
link_2x1x0_2x1x1_1 = sst.Link("link_2x1x0_2x1x1_1")
link_2x1x0_2x1x1_1.connect( (comp_rtr_2x1x0, "port13", "10000ps"), (comp_rtr_2x1x1, "port16", "10000ps") )
link_2x1x0_2x1x1_2 = sst.Link("link_2x1x0_2x1x1_2")
link_2x1x0_2x1x1_2.connect( (comp_rtr_2x1x0, "port14", "10000ps"), (comp_rtr_2x1x1, "port17", "10000ps") )
link_2x1x2_2x1x0_0 = sst.Link("link_2x1x2_2x1x0_0")
link_2x1x2_2x1x0_0.connect( (comp_rtr_2x1x0, "port15", "10000ps"), (comp_rtr_2x1x2, "port12", "10000ps") )
link_2x1x2_2x1x0_1 = sst.Link("link_2x1x2_2x1x0_1")
link_2x1x2_2x1x0_1.connect( (comp_rtr_2x1x0, "port16", "10000ps"), (comp_rtr_2x1x2, "port13", "10000ps") )
link_2x1x2_2x1x0_2 = sst.Link("link_2x1x2_2x1x0_2")
link_2x1x2_2x1x0_2.connect( (comp_rtr_2x1x0, "port17", "10000ps"), (comp_rtr_2x1x2, "port14", "10000ps") )
link_nic_5_0 = sst.Link("link_nic_5_0")
link_nic_5_0.connect( (comp_rtr_2x1x0, "port18", "10000ps"), (comp_nic_2x1x0_0, "rtr", "10000ps") )
link_nic_5_1 = sst.Link("link_nic_5_1")
link_nic_5_1.connect( (comp_rtr_2x1x0, "port19", "10000ps"), (comp_nic_2x1x0_1, "rtr", "10000ps") )
link_nic_5_2 = sst.Link("link_nic_5_2")
link_nic_5_2.connect( (comp_rtr_2x1x0, "port20", "10000ps"), (comp_nic_2x1x0_2, "rtr", "10000ps") )
link_nic_5_3 = sst.Link("link_nic_5_3")
link_nic_5_3.connect( (comp_rtr_2x1x0, "port21", "10000ps"), (comp_nic_2x1x0_3, "rtr", "10000ps") )
link_0x2x0_1x2x0_0 = sst.Link("link_0x2x0_1x2x0_0")
link_0x2x0_1x2x0_0.connect( (comp_rtr_0x2x0, "port0", "10000ps"), (comp_rtr_1x2x0, "port3", "10000ps") )
link_0x2x0_1x2x0_1 = sst.Link("link_0x2x0_1x2x0_1")
link_0x2x0_1x2x0_1.connect( (comp_rtr_0x2x0, "port1", "10000ps"), (comp_rtr_1x2x0, "port4", "10000ps") )
link_0x2x0_1x2x0_2 = sst.Link("link_0x2x0_1x2x0_2")
link_0x2x0_1x2x0_2.connect( (comp_rtr_0x2x0, "port2", "10000ps"), (comp_rtr_1x2x0, "port5", "10000ps") )
link_2x2x0_0x2x0_0 = sst.Link("link_2x2x0_0x2x0_0")
link_2x2x0_0x2x0_0.connect( (comp_rtr_0x2x0, "port3", "10000ps"), (comp_rtr_2x2x0, "port0", "10000ps") )
link_2x2x0_0x2x0_1 = sst.Link("link_2x2x0_0x2x0_1")
link_2x2x0_0x2x0_1.connect( (comp_rtr_0x2x0, "port4", "10000ps"), (comp_rtr_2x2x0, "port1", "10000ps") )
link_2x2x0_0x2x0_2 = sst.Link("link_2x2x0_0x2x0_2")
link_2x2x0_0x2x0_2.connect( (comp_rtr_0x2x0, "port5", "10000ps"), (comp_rtr_2x2x0, "port2", "10000ps") )
link_0x2x0_0x2x1_0 = sst.Link("link_0x2x0_0x2x1_0")
link_0x2x0_0x2x1_0.connect( (comp_rtr_0x2x0, "port12", "10000ps"), (comp_rtr_0x2x1, "port15", "10000ps") )
link_0x2x0_0x2x1_1 = sst.Link("link_0x2x0_0x2x1_1")
link_0x2x0_0x2x1_1.connect( (comp_rtr_0x2x0, "port13", "10000ps"), (comp_rtr_0x2x1, "port16", "10000ps") )
link_0x2x0_0x2x1_2 = sst.Link("link_0x2x0_0x2x1_2")
link_0x2x0_0x2x1_2.connect( (comp_rtr_0x2x0, "port14", "10000ps"), (comp_rtr_0x2x1, "port17", "10000ps") )
link_0x2x2_0x2x0_0 = sst.Link("link_0x2x2_0x2x0_0")
link_0x2x2_0x2x0_0.connect( (comp_rtr_0x2x0, "port15", "10000ps"), (comp_rtr_0x2x2, "port12", "10000ps") )
link_0x2x2_0x2x0_1 = sst.Link("link_0x2x2_0x2x0_1")
link_0x2x2_0x2x0_1.connect( (comp_rtr_0x2x0, "port16", "10000ps"), (comp_rtr_0x2x2, "port13", "10000ps") )
link_0x2x2_0x2x0_2 = sst.Link("link_0x2x2_0x2x0_2")
link_0x2x2_0x2x0_2.connect( (comp_rtr_0x2x0, "port17", "10000ps"), (comp_rtr_0x2x2, "port14", "10000ps") )
link_nic_6_0 = sst.Link("link_nic_6_0")
link_nic_6_0.connect( (comp_rtr_0x2x0, "port18", "10000ps"), (comp_nic_0x2x0_0, "rtr", "10000ps") )
link_nic_6_1 = sst.Link("link_nic_6_1")
link_nic_6_1.connect( (comp_rtr_0x2x0, "port19", "10000ps"), (comp_nic_0x2x0_1, "rtr", "10000ps") )
link_nic_6_2 = sst.Link("link_nic_6_2")
link_nic_6_2.connect( (comp_rtr_0x2x0, "port20", "10000ps"), (comp_nic_0x2x0_2, "rtr", "10000ps") )
link_nic_6_3 = sst.Link("link_nic_6_3")
link_nic_6_3.connect( (comp_rtr_0x2x0, "port21", "10000ps"), (comp_nic_0x2x0_3, "rtr", "10000ps") )
link_1x2x0_2x2x0_0 = sst.Link("link_1x2x0_2x2x0_0")
link_1x2x0_2x2x0_0.connect( (comp_rtr_1x2x0, "port0", "10000ps"), (comp_rtr_2x2x0, "port3", "10000ps") )
link_1x2x0_2x2x0_1 = sst.Link("link_1x2x0_2x2x0_1")
link_1x2x0_2x2x0_1.connect( (comp_rtr_1x2x0, "port1", "10000ps"), (comp_rtr_2x2x0, "port4", "10000ps") )
link_1x2x0_2x2x0_2 = sst.Link("link_1x2x0_2x2x0_2")
link_1x2x0_2x2x0_2.connect( (comp_rtr_1x2x0, "port2", "10000ps"), (comp_rtr_2x2x0, "port5", "10000ps") )
link_1x2x0_1x2x1_0 = sst.Link("link_1x2x0_1x2x1_0")
link_1x2x0_1x2x1_0.connect( (comp_rtr_1x2x0, "port12", "10000ps"), (comp_rtr_1x2x1, "port15", "10000ps") )
link_1x2x0_1x2x1_1 = sst.Link("link_1x2x0_1x2x1_1")
link_1x2x0_1x2x1_1.connect( (comp_rtr_1x2x0, "port13", "10000ps"), (comp_rtr_1x2x1, "port16", "10000ps") )
link_1x2x0_1x2x1_2 = sst.Link("link_1x2x0_1x2x1_2")
link_1x2x0_1x2x1_2.connect( (comp_rtr_1x2x0, "port14", "10000ps"), (comp_rtr_1x2x1, "port17", "10000ps") )
link_1x2x2_1x2x0_0 = sst.Link("link_1x2x2_1x2x0_0")
link_1x2x2_1x2x0_0.connect( (comp_rtr_1x2x0, "port15", "10000ps"), (comp_rtr_1x2x2, "port12", "10000ps") )
link_1x2x2_1x2x0_1 = sst.Link("link_1x2x2_1x2x0_1")
link_1x2x2_1x2x0_1.connect( (comp_rtr_1x2x0, "port16", "10000ps"), (comp_rtr_1x2x2, "port13", "10000ps") )
link_1x2x2_1x2x0_2 = sst.Link("link_1x2x2_1x2x0_2")
link_1x2x2_1x2x0_2.connect( (comp_rtr_1x2x0, "port17", "10000ps"), (comp_rtr_1x2x2, "port14", "10000ps") )
link_nic_7_0 = sst.Link("link_nic_7_0")
link_nic_7_0.connect( (comp_rtr_1x2x0, "port18", "10000ps"), (comp_nic_1x2x0_0, "rtr", "10000ps") )
link_nic_7_1 = sst.Link("link_nic_7_1")
link_nic_7_1.connect( (comp_rtr_1x2x0, "port19", "10000ps"), (comp_nic_1x2x0_1, "rtr", "10000ps") )
link_nic_7_2 = sst.Link("link_nic_7_2")
link_nic_7_2.connect( (comp_rtr_1x2x0, "port20", "10000ps"), (comp_nic_1x2x0_2, "rtr", "10000ps") )
link_nic_7_3 = sst.Link("link_nic_7_3")
link_nic_7_3.connect( (comp_rtr_1x2x0, "port21", "10000ps"), (comp_nic_1x2x0_3, "rtr", "10000ps") )
link_2x2x0_2x2x1_0 = sst.Link("link_2x2x0_2x2x1_0")
link_2x2x0_2x2x1_0.connect( (comp_rtr_2x2x0, "port12", "10000ps"), (comp_rtr_2x2x1, "port15", "10000ps") )
link_2x2x0_2x2x1_1 = sst.Link("link_2x2x0_2x2x1_1")
link_2x2x0_2x2x1_1.connect( (comp_rtr_2x2x0, "port13", "10000ps"), (comp_rtr_2x2x1, "port16", "10000ps") )
link_2x2x0_2x2x1_2 = sst.Link("link_2x2x0_2x2x1_2")
link_2x2x0_2x2x1_2.connect( (comp_rtr_2x2x0, "port14", "10000ps"), (comp_rtr_2x2x1, "port17", "10000ps") )
link_2x2x2_2x2x0_0 = sst.Link("link_2x2x2_2x2x0_0")
link_2x2x2_2x2x0_0.connect( (comp_rtr_2x2x0, "port15", "10000ps"), (comp_rtr_2x2x2, "port12", "10000ps") )
link_2x2x2_2x2x0_1 = sst.Link("link_2x2x2_2x2x0_1")
link_2x2x2_2x2x0_1.connect( (comp_rtr_2x2x0, "port16", "10000ps"), (comp_rtr_2x2x2, "port13", "10000ps") )
link_2x2x2_2x2x0_2 = sst.Link("link_2x2x2_2x2x0_2")
link_2x2x2_2x2x0_2.connect( (comp_rtr_2x2x0, "port17", "10000ps"), (comp_rtr_2x2x2, "port14", "10000ps") )
link_nic_8_0 = sst.Link("link_nic_8_0")
link_nic_8_0.connect( (comp_rtr_2x2x0, "port18", "10000ps"), (comp_nic_2x2x0_0, "rtr", "10000ps") )
link_nic_8_1 = sst.Link("link_nic_8_1")
link_nic_8_1.connect( (comp_rtr_2x2x0, "port19", "10000ps"), (comp_nic_2x2x0_1, "rtr", "10000ps") )
link_nic_8_2 = sst.Link("link_nic_8_2")
link_nic_8_2.connect( (comp_rtr_2x2x0, "port20", "10000ps"), (comp_nic_2x2x0_2, "rtr", "10000ps") )
link_nic_8_3 = sst.Link("link_nic_8_3")
link_nic_8_3.connect( (comp_rtr_2x2x0, "port21", "10000ps"), (comp_nic_2x2x0_3, "rtr", "10000ps") )
link_0x0x1_1x0x1_0 = sst.Link("link_0x0x1_1x0x1_0")
link_0x0x1_1x0x1_0.connect( (comp_rtr_0x0x1, "port0", "10000ps"), (comp_rtr_1x0x1, "port3", "10000ps") )
link_0x0x1_1x0x1_1 = sst.Link("link_0x0x1_1x0x1_1")
link_0x0x1_1x0x1_1.connect( (comp_rtr_0x0x1, "port1", "10000ps"), (comp_rtr_1x0x1, "port4", "10000ps") )
link_0x0x1_1x0x1_2 = sst.Link("link_0x0x1_1x0x1_2")
link_0x0x1_1x0x1_2.connect( (comp_rtr_0x0x1, "port2", "10000ps"), (comp_rtr_1x0x1, "port5", "10000ps") )
link_2x0x1_0x0x1_0 = sst.Link("link_2x0x1_0x0x1_0")
link_2x0x1_0x0x1_0.connect( (comp_rtr_0x0x1, "port3", "10000ps"), (comp_rtr_2x0x1, "port0", "10000ps") )
link_2x0x1_0x0x1_1 = sst.Link("link_2x0x1_0x0x1_1")
link_2x0x1_0x0x1_1.connect( (comp_rtr_0x0x1, "port4", "10000ps"), (comp_rtr_2x0x1, "port1", "10000ps") )
link_2x0x1_0x0x1_2 = sst.Link("link_2x0x1_0x0x1_2")
link_2x0x1_0x0x1_2.connect( (comp_rtr_0x0x1, "port5", "10000ps"), (comp_rtr_2x0x1, "port2", "10000ps") )
link_0x0x1_0x1x1_0 = sst.Link("link_0x0x1_0x1x1_0")
link_0x0x1_0x1x1_0.connect( (comp_rtr_0x0x1, "port6", "10000ps"), (comp_rtr_0x1x1, "port9", "10000ps") )
link_0x0x1_0x1x1_1 = sst.Link("link_0x0x1_0x1x1_1")
link_0x0x1_0x1x1_1.connect( (comp_rtr_0x0x1, "port7", "10000ps"), (comp_rtr_0x1x1, "port10", "10000ps") )
link_0x0x1_0x1x1_2 = sst.Link("link_0x0x1_0x1x1_2")
link_0x0x1_0x1x1_2.connect( (comp_rtr_0x0x1, "port8", "10000ps"), (comp_rtr_0x1x1, "port11", "10000ps") )
link_0x2x1_0x0x1_0 = sst.Link("link_0x2x1_0x0x1_0")
link_0x2x1_0x0x1_0.connect( (comp_rtr_0x0x1, "port9", "10000ps"), (comp_rtr_0x2x1, "port6", "10000ps") )
link_0x2x1_0x0x1_1 = sst.Link("link_0x2x1_0x0x1_1")
link_0x2x1_0x0x1_1.connect( (comp_rtr_0x0x1, "port10", "10000ps"), (comp_rtr_0x2x1, "port7", "10000ps") )
link_0x2x1_0x0x1_2 = sst.Link("link_0x2x1_0x0x1_2")
link_0x2x1_0x0x1_2.connect( (comp_rtr_0x0x1, "port11", "10000ps"), (comp_rtr_0x2x1, "port8", "10000ps") )
link_0x0x1_0x0x2_0 = sst.Link("link_0x0x1_0x0x2_0")
link_0x0x1_0x0x2_0.connect( (comp_rtr_0x0x1, "port12", "10000ps"), (comp_rtr_0x0x2, "port15", "10000ps") )
link_0x0x1_0x0x2_1 = sst.Link("link_0x0x1_0x0x2_1")
link_0x0x1_0x0x2_1.connect( (comp_rtr_0x0x1, "port13", "10000ps"), (comp_rtr_0x0x2, "port16", "10000ps") )
link_0x0x1_0x0x2_2 = sst.Link("link_0x0x1_0x0x2_2")
link_0x0x1_0x0x2_2.connect( (comp_rtr_0x0x1, "port14", "10000ps"), (comp_rtr_0x0x2, "port17", "10000ps") )
link_nic_9_0 = sst.Link("link_nic_9_0")
link_nic_9_0.connect( (comp_rtr_0x0x1, "port18", "10000ps"), (comp_nic_0x0x1_0, "rtr", "10000ps") )
link_nic_9_1 = sst.Link("link_nic_9_1")
link_nic_9_1.connect( (comp_rtr_0x0x1, "port19", "10000ps"), (comp_nic_0x0x1_1, "rtr", "10000ps") )
link_nic_9_2 = sst.Link("link_nic_9_2")
link_nic_9_2.connect( (comp_rtr_0x0x1, "port20", "10000ps"), (comp_nic_0x0x1_2, "rtr", "10000ps") )
link_nic_9_3 = sst.Link("link_nic_9_3")
link_nic_9_3.connect( (comp_rtr_0x0x1, "port21", "10000ps"), (comp_nic_0x0x1_3, "rtr", "10000ps") )
link_1x0x1_2x0x1_0 = sst.Link("link_1x0x1_2x0x1_0")
link_1x0x1_2x0x1_0.connect( (comp_rtr_1x0x1, "port0", "10000ps"), (comp_rtr_2x0x1, "port3", "10000ps") )
link_1x0x1_2x0x1_1 = sst.Link("link_1x0x1_2x0x1_1")
link_1x0x1_2x0x1_1.connect( (comp_rtr_1x0x1, "port1", "10000ps"), (comp_rtr_2x0x1, "port4", "10000ps") )
link_1x0x1_2x0x1_2 = sst.Link("link_1x0x1_2x0x1_2")
link_1x0x1_2x0x1_2.connect( (comp_rtr_1x0x1, "port2", "10000ps"), (comp_rtr_2x0x1, "port5", "10000ps") )
link_1x0x1_1x1x1_0 = sst.Link("link_1x0x1_1x1x1_0")
link_1x0x1_1x1x1_0.connect( (comp_rtr_1x0x1, "port6", "10000ps"), (comp_rtr_1x1x1, "port9", "10000ps") )
link_1x0x1_1x1x1_1 = sst.Link("link_1x0x1_1x1x1_1")
link_1x0x1_1x1x1_1.connect( (comp_rtr_1x0x1, "port7", "10000ps"), (comp_rtr_1x1x1, "port10", "10000ps") )
link_1x0x1_1x1x1_2 = sst.Link("link_1x0x1_1x1x1_2")
link_1x0x1_1x1x1_2.connect( (comp_rtr_1x0x1, "port8", "10000ps"), (comp_rtr_1x1x1, "port11", "10000ps") )
link_1x2x1_1x0x1_0 = sst.Link("link_1x2x1_1x0x1_0")
link_1x2x1_1x0x1_0.connect( (comp_rtr_1x0x1, "port9", "10000ps"), (comp_rtr_1x2x1, "port6", "10000ps") )
link_1x2x1_1x0x1_1 = sst.Link("link_1x2x1_1x0x1_1")
link_1x2x1_1x0x1_1.connect( (comp_rtr_1x0x1, "port10", "10000ps"), (comp_rtr_1x2x1, "port7", "10000ps") )
link_1x2x1_1x0x1_2 = sst.Link("link_1x2x1_1x0x1_2")
link_1x2x1_1x0x1_2.connect( (comp_rtr_1x0x1, "port11", "10000ps"), (comp_rtr_1x2x1, "port8", "10000ps") )
link_1x0x1_1x0x2_0 = sst.Link("link_1x0x1_1x0x2_0")
link_1x0x1_1x0x2_0.connect( (comp_rtr_1x0x1, "port12", "10000ps"), (comp_rtr_1x0x2, "port15", "10000ps") )
link_1x0x1_1x0x2_1 = sst.Link("link_1x0x1_1x0x2_1")
link_1x0x1_1x0x2_1.connect( (comp_rtr_1x0x1, "port13", "10000ps"), (comp_rtr_1x0x2, "port16", "10000ps") )
link_1x0x1_1x0x2_2 = sst.Link("link_1x0x1_1x0x2_2")
link_1x0x1_1x0x2_2.connect( (comp_rtr_1x0x1, "port14", "10000ps"), (comp_rtr_1x0x2, "port17", "10000ps") )
link_nic_10_0 = sst.Link("link_nic_10_0")
link_nic_10_0.connect( (comp_rtr_1x0x1, "port18", "10000ps"), (comp_nic_1x0x1_0, "rtr", "10000ps") )
link_nic_10_1 = sst.Link("link_nic_10_1")
link_nic_10_1.connect( (comp_rtr_1x0x1, "port19", "10000ps"), (comp_nic_1x0x1_1, "rtr", "10000ps") )
link_nic_10_2 = sst.Link("link_nic_10_2")
link_nic_10_2.connect( (comp_rtr_1x0x1, "port20", "10000ps"), (comp_nic_1x0x1_2, "rtr", "10000ps") )
link_nic_10_3 = sst.Link("link_nic_10_3")
link_nic_10_3.connect( (comp_rtr_1x0x1, "port21", "10000ps"), (comp_nic_1x0x1_3, "rtr", "10000ps") )
link_2x0x1_2x1x1_0 = sst.Link("link_2x0x1_2x1x1_0")
link_2x0x1_2x1x1_0.connect( (comp_rtr_2x0x1, "port6", "10000ps"), (comp_rtr_2x1x1, "port9", "10000ps") )
link_2x0x1_2x1x1_1 = sst.Link("link_2x0x1_2x1x1_1")
link_2x0x1_2x1x1_1.connect( (comp_rtr_2x0x1, "port7", "10000ps"), (comp_rtr_2x1x1, "port10", "10000ps") )
link_2x0x1_2x1x1_2 = sst.Link("link_2x0x1_2x1x1_2")
link_2x0x1_2x1x1_2.connect( (comp_rtr_2x0x1, "port8", "10000ps"), (comp_rtr_2x1x1, "port11", "10000ps") )
link_2x2x1_2x0x1_0 = sst.Link("link_2x2x1_2x0x1_0")
link_2x2x1_2x0x1_0.connect( (comp_rtr_2x0x1, "port9", "10000ps"), (comp_rtr_2x2x1, "port6", "10000ps") )
link_2x2x1_2x0x1_1 = sst.Link("link_2x2x1_2x0x1_1")
link_2x2x1_2x0x1_1.connect( (comp_rtr_2x0x1, "port10", "10000ps"), (comp_rtr_2x2x1, "port7", "10000ps") )
link_2x2x1_2x0x1_2 = sst.Link("link_2x2x1_2x0x1_2")
link_2x2x1_2x0x1_2.connect( (comp_rtr_2x0x1, "port11", "10000ps"), (comp_rtr_2x2x1, "port8", "10000ps") )
link_2x0x1_2x0x2_0 = sst.Link("link_2x0x1_2x0x2_0")
link_2x0x1_2x0x2_0.connect( (comp_rtr_2x0x1, "port12", "10000ps"), (comp_rtr_2x0x2, "port15", "10000ps") )
link_2x0x1_2x0x2_1 = sst.Link("link_2x0x1_2x0x2_1")
link_2x0x1_2x0x2_1.connect( (comp_rtr_2x0x1, "port13", "10000ps"), (comp_rtr_2x0x2, "port16", "10000ps") )
link_2x0x1_2x0x2_2 = sst.Link("link_2x0x1_2x0x2_2")
link_2x0x1_2x0x2_2.connect( (comp_rtr_2x0x1, "port14", "10000ps"), (comp_rtr_2x0x2, "port17", "10000ps") )
link_nic_11_0 = sst.Link("link_nic_11_0")
link_nic_11_0.connect( (comp_rtr_2x0x1, "port18", "10000ps"), (comp_nic_2x0x1_0, "rtr", "10000ps") )
link_nic_11_1 = sst.Link("link_nic_11_1")
link_nic_11_1.connect( (comp_rtr_2x0x1, "port19", "10000ps"), (comp_nic_2x0x1_1, "rtr", "10000ps") )
link_nic_11_2 = sst.Link("link_nic_11_2")
link_nic_11_2.connect( (comp_rtr_2x0x1, "port20", "10000ps"), (comp_nic_2x0x1_2, "rtr", "10000ps") )
link_nic_11_3 = sst.Link("link_nic_11_3")
link_nic_11_3.connect( (comp_rtr_2x0x1, "port21", "10000ps"), (comp_nic_2x0x1_3, "rtr", "10000ps") )
link_0x1x1_1x1x1_0 = sst.Link("link_0x1x1_1x1x1_0")
link_0x1x1_1x1x1_0.connect( (comp_rtr_0x1x1, "port0", "10000ps"), (comp_rtr_1x1x1, "port3", "10000ps") )
link_0x1x1_1x1x1_1 = sst.Link("link_0x1x1_1x1x1_1")
link_0x1x1_1x1x1_1.connect( (comp_rtr_0x1x1, "port1", "10000ps"), (comp_rtr_1x1x1, "port4", "10000ps") )
link_0x1x1_1x1x1_2 = sst.Link("link_0x1x1_1x1x1_2")
link_0x1x1_1x1x1_2.connect( (comp_rtr_0x1x1, "port2", "10000ps"), (comp_rtr_1x1x1, "port5", "10000ps") )
link_2x1x1_0x1x1_0 = sst.Link("link_2x1x1_0x1x1_0")
link_2x1x1_0x1x1_0.connect( (comp_rtr_0x1x1, "port3", "10000ps"), (comp_rtr_2x1x1, "port0", "10000ps") )
link_2x1x1_0x1x1_1 = sst.Link("link_2x1x1_0x1x1_1")
link_2x1x1_0x1x1_1.connect( (comp_rtr_0x1x1, "port4", "10000ps"), (comp_rtr_2x1x1, "port1", "10000ps") )
link_2x1x1_0x1x1_2 = sst.Link("link_2x1x1_0x1x1_2")
link_2x1x1_0x1x1_2.connect( (comp_rtr_0x1x1, "port5", "10000ps"), (comp_rtr_2x1x1, "port2", "10000ps") )
link_0x1x1_0x2x1_0 = sst.Link("link_0x1x1_0x2x1_0")
link_0x1x1_0x2x1_0.connect( (comp_rtr_0x1x1, "port6", "10000ps"), (comp_rtr_0x2x1, "port9", "10000ps") )
link_0x1x1_0x2x1_1 = sst.Link("link_0x1x1_0x2x1_1")
link_0x1x1_0x2x1_1.connect( (comp_rtr_0x1x1, "port7", "10000ps"), (comp_rtr_0x2x1, "port10", "10000ps") )
link_0x1x1_0x2x1_2 = sst.Link("link_0x1x1_0x2x1_2")
link_0x1x1_0x2x1_2.connect( (comp_rtr_0x1x1, "port8", "10000ps"), (comp_rtr_0x2x1, "port11", "10000ps") )
link_0x1x1_0x1x2_0 = sst.Link("link_0x1x1_0x1x2_0")
link_0x1x1_0x1x2_0.connect( (comp_rtr_0x1x1, "port12", "10000ps"), (comp_rtr_0x1x2, "port15", "10000ps") )
link_0x1x1_0x1x2_1 = sst.Link("link_0x1x1_0x1x2_1")
link_0x1x1_0x1x2_1.connect( (comp_rtr_0x1x1, "port13", "10000ps"), (comp_rtr_0x1x2, "port16", "10000ps") )
link_0x1x1_0x1x2_2 = sst.Link("link_0x1x1_0x1x2_2")
link_0x1x1_0x1x2_2.connect( (comp_rtr_0x1x1, "port14", "10000ps"), (comp_rtr_0x1x2, "port17", "10000ps") )
link_nic_12_0 = sst.Link("link_nic_12_0")
link_nic_12_0.connect( (comp_rtr_0x1x1, "port18", "10000ps"), (comp_nic_0x1x1_0, "rtr", "10000ps") )
link_nic_12_1 = sst.Link("link_nic_12_1")
link_nic_12_1.connect( (comp_rtr_0x1x1, "port19", "10000ps"), (comp_nic_0x1x1_1, "rtr", "10000ps") )
link_nic_12_2 = sst.Link("link_nic_12_2")
link_nic_12_2.connect( (comp_rtr_0x1x1, "port20", "10000ps"), (comp_nic_0x1x1_2, "rtr", "10000ps") )
link_nic_12_3 = sst.Link("link_nic_12_3")
link_nic_12_3.connect( (comp_rtr_0x1x1, "port21", "10000ps"), (comp_nic_0x1x1_3, "rtr", "10000ps") )
link_1x1x1_2x1x1_0 = sst.Link("link_1x1x1_2x1x1_0")
link_1x1x1_2x1x1_0.connect( (comp_rtr_1x1x1, "port0", "10000ps"), (comp_rtr_2x1x1, "port3", "10000ps") )
link_1x1x1_2x1x1_1 = sst.Link("link_1x1x1_2x1x1_1")
link_1x1x1_2x1x1_1.connect( (comp_rtr_1x1x1, "port1", "10000ps"), (comp_rtr_2x1x1, "port4", "10000ps") )
link_1x1x1_2x1x1_2 = sst.Link("link_1x1x1_2x1x1_2")
link_1x1x1_2x1x1_2.connect( (comp_rtr_1x1x1, "port2", "10000ps"), (comp_rtr_2x1x1, "port5", "10000ps") )
link_1x1x1_1x2x1_0 = sst.Link("link_1x1x1_1x2x1_0")
link_1x1x1_1x2x1_0.connect( (comp_rtr_1x1x1, "port6", "10000ps"), (comp_rtr_1x2x1, "port9", "10000ps") )
link_1x1x1_1x2x1_1 = sst.Link("link_1x1x1_1x2x1_1")
link_1x1x1_1x2x1_1.connect( (comp_rtr_1x1x1, "port7", "10000ps"), (comp_rtr_1x2x1, "port10", "10000ps") )
link_1x1x1_1x2x1_2 = sst.Link("link_1x1x1_1x2x1_2")
link_1x1x1_1x2x1_2.connect( (comp_rtr_1x1x1, "port8", "10000ps"), (comp_rtr_1x2x1, "port11", "10000ps") )
link_1x1x1_1x1x2_0 = sst.Link("link_1x1x1_1x1x2_0")
link_1x1x1_1x1x2_0.connect( (comp_rtr_1x1x1, "port12", "10000ps"), (comp_rtr_1x1x2, "port15", "10000ps") )
link_1x1x1_1x1x2_1 = sst.Link("link_1x1x1_1x1x2_1")
link_1x1x1_1x1x2_1.connect( (comp_rtr_1x1x1, "port13", "10000ps"), (comp_rtr_1x1x2, "port16", "10000ps") )
link_1x1x1_1x1x2_2 = sst.Link("link_1x1x1_1x1x2_2")
link_1x1x1_1x1x2_2.connect( (comp_rtr_1x1x1, "port14", "10000ps"), (comp_rtr_1x1x2, "port17", "10000ps") )
link_nic_13_0 = sst.Link("link_nic_13_0")
link_nic_13_0.connect( (comp_rtr_1x1x1, "port18", "10000ps"), (comp_nic_1x1x1_0, "rtr", "10000ps") )
link_nic_13_1 = sst.Link("link_nic_13_1")
link_nic_13_1.connect( (comp_rtr_1x1x1, "port19", "10000ps"), (comp_nic_1x1x1_1, "rtr", "10000ps") )
link_nic_13_2 = sst.Link("link_nic_13_2")
link_nic_13_2.connect( (comp_rtr_1x1x1, "port20", "10000ps"), (comp_nic_1x1x1_2, "rtr", "10000ps") )
link_nic_13_3 = sst.Link("link_nic_13_3")
link_nic_13_3.connect( (comp_rtr_1x1x1, "port21", "10000ps"), (comp_nic_1x1x1_3, "rtr", "10000ps") )
link_2x1x1_2x2x1_0 = sst.Link("link_2x1x1_2x2x1_0")
link_2x1x1_2x2x1_0.connect( (comp_rtr_2x1x1, "port6", "10000ps"), (comp_rtr_2x2x1, "port9", "10000ps") )
link_2x1x1_2x2x1_1 = sst.Link("link_2x1x1_2x2x1_1")
link_2x1x1_2x2x1_1.connect( (comp_rtr_2x1x1, "port7", "10000ps"), (comp_rtr_2x2x1, "port10", "10000ps") )
link_2x1x1_2x2x1_2 = sst.Link("link_2x1x1_2x2x1_2")
link_2x1x1_2x2x1_2.connect( (comp_rtr_2x1x1, "port8", "10000ps"), (comp_rtr_2x2x1, "port11", "10000ps") )
link_2x1x1_2x1x2_0 = sst.Link("link_2x1x1_2x1x2_0")
link_2x1x1_2x1x2_0.connect( (comp_rtr_2x1x1, "port12", "10000ps"), (comp_rtr_2x1x2, "port15", "10000ps") )
link_2x1x1_2x1x2_1 = sst.Link("link_2x1x1_2x1x2_1")
link_2x1x1_2x1x2_1.connect( (comp_rtr_2x1x1, "port13", "10000ps"), (comp_rtr_2x1x2, "port16", "10000ps") )
link_2x1x1_2x1x2_2 = sst.Link("link_2x1x1_2x1x2_2")
link_2x1x1_2x1x2_2.connect( (comp_rtr_2x1x1, "port14", "10000ps"), (comp_rtr_2x1x2, "port17", "10000ps") )
link_nic_14_0 = sst.Link("link_nic_14_0")
link_nic_14_0.connect( (comp_rtr_2x1x1, "port18", "10000ps"), (comp_nic_2x1x1_0, "rtr", "10000ps") )
link_nic_14_1 = sst.Link("link_nic_14_1")
link_nic_14_1.connect( (comp_rtr_2x1x1, "port19", "10000ps"), (comp_nic_2x1x1_1, "rtr", "10000ps") )
link_nic_14_2 = sst.Link("link_nic_14_2")
link_nic_14_2.connect( (comp_rtr_2x1x1, "port20", "10000ps"), (comp_nic_2x1x1_2, "rtr", "10000ps") )
link_nic_14_3 = sst.Link("link_nic_14_3")
link_nic_14_3.connect( (comp_rtr_2x1x1, "port21", "10000ps"), (comp_nic_2x1x1_3, "rtr", "10000ps") )
link_0x2x1_1x2x1_0 = sst.Link("link_0x2x1_1x2x1_0")
link_0x2x1_1x2x1_0.connect( (comp_rtr_0x2x1, "port0", "10000ps"), (comp_rtr_1x2x1, "port3", "10000ps") )
link_0x2x1_1x2x1_1 = sst.Link("link_0x2x1_1x2x1_1")
link_0x2x1_1x2x1_1.connect( (comp_rtr_0x2x1, "port1", "10000ps"), (comp_rtr_1x2x1, "port4", "10000ps") )
link_0x2x1_1x2x1_2 = sst.Link("link_0x2x1_1x2x1_2")
link_0x2x1_1x2x1_2.connect( (comp_rtr_0x2x1, "port2", "10000ps"), (comp_rtr_1x2x1, "port5", "10000ps") )
link_2x2x1_0x2x1_0 = sst.Link("link_2x2x1_0x2x1_0")
link_2x2x1_0x2x1_0.connect( (comp_rtr_0x2x1, "port3", "10000ps"), (comp_rtr_2x2x1, "port0", "10000ps") )
link_2x2x1_0x2x1_1 = sst.Link("link_2x2x1_0x2x1_1")
link_2x2x1_0x2x1_1.connect( (comp_rtr_0x2x1, "port4", "10000ps"), (comp_rtr_2x2x1, "port1", "10000ps") )
link_2x2x1_0x2x1_2 = sst.Link("link_2x2x1_0x2x1_2")
link_2x2x1_0x2x1_2.connect( (comp_rtr_0x2x1, "port5", "10000ps"), (comp_rtr_2x2x1, "port2", "10000ps") )
link_0x2x1_0x2x2_0 = sst.Link("link_0x2x1_0x2x2_0")
link_0x2x1_0x2x2_0.connect( (comp_rtr_0x2x1, "port12", "10000ps"), (comp_rtr_0x2x2, "port15", "10000ps") )
link_0x2x1_0x2x2_1 = sst.Link("link_0x2x1_0x2x2_1")
link_0x2x1_0x2x2_1.connect( (comp_rtr_0x2x1, "port13", "10000ps"), (comp_rtr_0x2x2, "port16", "10000ps") )
link_0x2x1_0x2x2_2 = sst.Link("link_0x2x1_0x2x2_2")
link_0x2x1_0x2x2_2.connect( (comp_rtr_0x2x1, "port14", "10000ps"), (comp_rtr_0x2x2, "port17", "10000ps") )
link_nic_15_0 = sst.Link("link_nic_15_0")
link_nic_15_0.connect( (comp_rtr_0x2x1, "port18", "10000ps"), (comp_nic_0x2x1_0, "rtr", "10000ps") )
link_nic_15_1 = sst.Link("link_nic_15_1")
link_nic_15_1.connect( (comp_rtr_0x2x1, "port19", "10000ps"), (comp_nic_0x2x1_1, "rtr", "10000ps") )
link_nic_15_2 = sst.Link("link_nic_15_2")
link_nic_15_2.connect( (comp_rtr_0x2x1, "port20", "10000ps"), (comp_nic_0x2x1_2, "rtr", "10000ps") )
link_nic_15_3 = sst.Link("link_nic_15_3")
link_nic_15_3.connect( (comp_rtr_0x2x1, "port21", "10000ps"), (comp_nic_0x2x1_3, "rtr", "10000ps") )
link_1x2x1_2x2x1_0 = sst.Link("link_1x2x1_2x2x1_0")
link_1x2x1_2x2x1_0.connect( (comp_rtr_1x2x1, "port0", "10000ps"), (comp_rtr_2x2x1, "port3", "10000ps") )
link_1x2x1_2x2x1_1 = sst.Link("link_1x2x1_2x2x1_1")
link_1x2x1_2x2x1_1.connect( (comp_rtr_1x2x1, "port1", "10000ps"), (comp_rtr_2x2x1, "port4", "10000ps") )
link_1x2x1_2x2x1_2 = sst.Link("link_1x2x1_2x2x1_2")
link_1x2x1_2x2x1_2.connect( (comp_rtr_1x2x1, "port2", "10000ps"), (comp_rtr_2x2x1, "port5", "10000ps") )
link_1x2x1_1x2x2_0 = sst.Link("link_1x2x1_1x2x2_0")
link_1x2x1_1x2x2_0.connect( (comp_rtr_1x2x1, "port12", "10000ps"), (comp_rtr_1x2x2, "port15", "10000ps") )
link_1x2x1_1x2x2_1 = sst.Link("link_1x2x1_1x2x2_1")
link_1x2x1_1x2x2_1.connect( (comp_rtr_1x2x1, "port13", "10000ps"), (comp_rtr_1x2x2, "port16", "10000ps") )
link_1x2x1_1x2x2_2 = sst.Link("link_1x2x1_1x2x2_2")
link_1x2x1_1x2x2_2.connect( (comp_rtr_1x2x1, "port14", "10000ps"), (comp_rtr_1x2x2, "port17", "10000ps") )
link_nic_16_0 = sst.Link("link_nic_16_0")
link_nic_16_0.connect( (comp_rtr_1x2x1, "port18", "10000ps"), (comp_nic_1x2x1_0, "rtr", "10000ps") )
link_nic_16_1 = sst.Link("link_nic_16_1")
link_nic_16_1.connect( (comp_rtr_1x2x1, "port19", "10000ps"), (comp_nic_1x2x1_1, "rtr", "10000ps") )
link_nic_16_2 = sst.Link("link_nic_16_2")
link_nic_16_2.connect( (comp_rtr_1x2x1, "port20", "10000ps"), (comp_nic_1x2x1_2, "rtr", "10000ps") )
link_nic_16_3 = sst.Link("link_nic_16_3")
link_nic_16_3.connect( (comp_rtr_1x2x1, "port21", "10000ps"), (comp_nic_1x2x1_3, "rtr", "10000ps") )
link_2x2x1_2x2x2_0 = sst.Link("link_2x2x1_2x2x2_0")
link_2x2x1_2x2x2_0.connect( (comp_rtr_2x2x1, "port12", "10000ps"), (comp_rtr_2x2x2, "port15", "10000ps") )
link_2x2x1_2x2x2_1 = sst.Link("link_2x2x1_2x2x2_1")
link_2x2x1_2x2x2_1.connect( (comp_rtr_2x2x1, "port13", "10000ps"), (comp_rtr_2x2x2, "port16", "10000ps") )
link_2x2x1_2x2x2_2 = sst.Link("link_2x2x1_2x2x2_2")
link_2x2x1_2x2x2_2.connect( (comp_rtr_2x2x1, "port14", "10000ps"), (comp_rtr_2x2x2, "port17", "10000ps") )
link_nic_17_0 = sst.Link("link_nic_17_0")
link_nic_17_0.connect( (comp_rtr_2x2x1, "port18", "10000ps"), (comp_nic_2x2x1_0, "rtr", "10000ps") )
link_nic_17_1 = sst.Link("link_nic_17_1")
link_nic_17_1.connect( (comp_rtr_2x2x1, "port19", "10000ps"), (comp_nic_2x2x1_1, "rtr", "10000ps") )
link_nic_17_2 = sst.Link("link_nic_17_2")
link_nic_17_2.connect( (comp_rtr_2x2x1, "port20", "10000ps"), (comp_nic_2x2x1_2, "rtr", "10000ps") )
link_nic_17_3 = sst.Link("link_nic_17_3")
link_nic_17_3.connect( (comp_rtr_2x2x1, "port21", "10000ps"), (comp_nic_2x2x1_3, "rtr", "10000ps") )
link_0x0x2_1x0x2_0 = sst.Link("link_0x0x2_1x0x2_0")
link_0x0x2_1x0x2_0.connect( (comp_rtr_0x0x2, "port0", "10000ps"), (comp_rtr_1x0x2, "port3", "10000ps") )
link_0x0x2_1x0x2_1 = sst.Link("link_0x0x2_1x0x2_1")
link_0x0x2_1x0x2_1.connect( (comp_rtr_0x0x2, "port1", "10000ps"), (comp_rtr_1x0x2, "port4", "10000ps") )
link_0x0x2_1x0x2_2 = sst.Link("link_0x0x2_1x0x2_2")
link_0x0x2_1x0x2_2.connect( (comp_rtr_0x0x2, "port2", "10000ps"), (comp_rtr_1x0x2, "port5", "10000ps") )
link_2x0x2_0x0x2_0 = sst.Link("link_2x0x2_0x0x2_0")
link_2x0x2_0x0x2_0.connect( (comp_rtr_0x0x2, "port3", "10000ps"), (comp_rtr_2x0x2, "port0", "10000ps") )
link_2x0x2_0x0x2_1 = sst.Link("link_2x0x2_0x0x2_1")
link_2x0x2_0x0x2_1.connect( (comp_rtr_0x0x2, "port4", "10000ps"), (comp_rtr_2x0x2, "port1", "10000ps") )
link_2x0x2_0x0x2_2 = sst.Link("link_2x0x2_0x0x2_2")
link_2x0x2_0x0x2_2.connect( (comp_rtr_0x0x2, "port5", "10000ps"), (comp_rtr_2x0x2, "port2", "10000ps") )
link_0x0x2_0x1x2_0 = sst.Link("link_0x0x2_0x1x2_0")
link_0x0x2_0x1x2_0.connect( (comp_rtr_0x0x2, "port6", "10000ps"), (comp_rtr_0x1x2, "port9", "10000ps") )
link_0x0x2_0x1x2_1 = sst.Link("link_0x0x2_0x1x2_1")
link_0x0x2_0x1x2_1.connect( (comp_rtr_0x0x2, "port7", "10000ps"), (comp_rtr_0x1x2, "port10", "10000ps") )
link_0x0x2_0x1x2_2 = sst.Link("link_0x0x2_0x1x2_2")
link_0x0x2_0x1x2_2.connect( (comp_rtr_0x0x2, "port8", "10000ps"), (comp_rtr_0x1x2, "port11", "10000ps") )
link_0x2x2_0x0x2_0 = sst.Link("link_0x2x2_0x0x2_0")
link_0x2x2_0x0x2_0.connect( (comp_rtr_0x0x2, "port9", "10000ps"), (comp_rtr_0x2x2, "port6", "10000ps") )
link_0x2x2_0x0x2_1 = sst.Link("link_0x2x2_0x0x2_1")
link_0x2x2_0x0x2_1.connect( (comp_rtr_0x0x2, "port10", "10000ps"), (comp_rtr_0x2x2, "port7", "10000ps") )
link_0x2x2_0x0x2_2 = sst.Link("link_0x2x2_0x0x2_2")
link_0x2x2_0x0x2_2.connect( (comp_rtr_0x0x2, "port11", "10000ps"), (comp_rtr_0x2x2, "port8", "10000ps") )
link_nic_18_0 = sst.Link("link_nic_18_0")
link_nic_18_0.connect( (comp_rtr_0x0x2, "port18", "10000ps"), (comp_nic_0x0x2_0, "rtr", "10000ps") )
link_nic_18_1 = sst.Link("link_nic_18_1")
link_nic_18_1.connect( (comp_rtr_0x0x2, "port19", "10000ps"), (comp_nic_0x0x2_1, "rtr", "10000ps") )
link_nic_18_2 = sst.Link("link_nic_18_2")
link_nic_18_2.connect( (comp_rtr_0x0x2, "port20", "10000ps"), (comp_nic_0x0x2_2, "rtr", "10000ps") )
link_nic_18_3 = sst.Link("link_nic_18_3")
link_nic_18_3.connect( (comp_rtr_0x0x2, "port21", "10000ps"), (comp_nic_0x0x2_3, "rtr", "10000ps") )
link_1x0x2_2x0x2_0 = sst.Link("link_1x0x2_2x0x2_0")
link_1x0x2_2x0x2_0.connect( (comp_rtr_1x0x2, "port0", "10000ps"), (comp_rtr_2x0x2, "port3", "10000ps") )
link_1x0x2_2x0x2_1 = sst.Link("link_1x0x2_2x0x2_1")
link_1x0x2_2x0x2_1.connect( (comp_rtr_1x0x2, "port1", "10000ps"), (comp_rtr_2x0x2, "port4", "10000ps") )
link_1x0x2_2x0x2_2 = sst.Link("link_1x0x2_2x0x2_2")
link_1x0x2_2x0x2_2.connect( (comp_rtr_1x0x2, "port2", "10000ps"), (comp_rtr_2x0x2, "port5", "10000ps") )
link_1x0x2_1x1x2_0 = sst.Link("link_1x0x2_1x1x2_0")
link_1x0x2_1x1x2_0.connect( (comp_rtr_1x0x2, "port6", "10000ps"), (comp_rtr_1x1x2, "port9", "10000ps") )
link_1x0x2_1x1x2_1 = sst.Link("link_1x0x2_1x1x2_1")
link_1x0x2_1x1x2_1.connect( (comp_rtr_1x0x2, "port7", "10000ps"), (comp_rtr_1x1x2, "port10", "10000ps") )
link_1x0x2_1x1x2_2 = sst.Link("link_1x0x2_1x1x2_2")
link_1x0x2_1x1x2_2.connect( (comp_rtr_1x0x2, "port8", "10000ps"), (comp_rtr_1x1x2, "port11", "10000ps") )
link_1x2x2_1x0x2_0 = sst.Link("link_1x2x2_1x0x2_0")
link_1x2x2_1x0x2_0.connect( (comp_rtr_1x0x2, "port9", "10000ps"), (comp_rtr_1x2x2, "port6", "10000ps") )
link_1x2x2_1x0x2_1 = sst.Link("link_1x2x2_1x0x2_1")
link_1x2x2_1x0x2_1.connect( (comp_rtr_1x0x2, "port10", "10000ps"), (comp_rtr_1x2x2, "port7", "10000ps") )
link_1x2x2_1x0x2_2 = sst.Link("link_1x2x2_1x0x2_2")
link_1x2x2_1x0x2_2.connect( (comp_rtr_1x0x2, "port11", "10000ps"), (comp_rtr_1x2x2, "port8", "10000ps") )
link_nic_19_0 = sst.Link("link_nic_19_0")
link_nic_19_0.connect( (comp_rtr_1x0x2, "port18", "10000ps"), (comp_nic_1x0x2_0, "rtr", "10000ps") )
link_nic_19_1 = sst.Link("link_nic_19_1")
link_nic_19_1.connect( (comp_rtr_1x0x2, "port19", "10000ps"), (comp_nic_1x0x2_1, "rtr", "10000ps") )
link_nic_19_2 = sst.Link("link_nic_19_2")
link_nic_19_2.connect( (comp_rtr_1x0x2, "port20", "10000ps"), (comp_nic_1x0x2_2, "rtr", "10000ps") )
link_nic_19_3 = sst.Link("link_nic_19_3")
link_nic_19_3.connect( (comp_rtr_1x0x2, "port21", "10000ps"), (comp_nic_1x0x2_3, "rtr", "10000ps") )
link_2x0x2_2x1x2_0 = sst.Link("link_2x0x2_2x1x2_0")
link_2x0x2_2x1x2_0.connect( (comp_rtr_2x0x2, "port6", "10000ps"), (comp_rtr_2x1x2, "port9", "10000ps") )
link_2x0x2_2x1x2_1 = sst.Link("link_2x0x2_2x1x2_1")
link_2x0x2_2x1x2_1.connect( (comp_rtr_2x0x2, "port7", "10000ps"), (comp_rtr_2x1x2, "port10", "10000ps") )
link_2x0x2_2x1x2_2 = sst.Link("link_2x0x2_2x1x2_2")
link_2x0x2_2x1x2_2.connect( (comp_rtr_2x0x2, "port8", "10000ps"), (comp_rtr_2x1x2, "port11", "10000ps") )
link_2x2x2_2x0x2_0 = sst.Link("link_2x2x2_2x0x2_0")
link_2x2x2_2x0x2_0.connect( (comp_rtr_2x0x2, "port9", "10000ps"), (comp_rtr_2x2x2, "port6", "10000ps") )
link_2x2x2_2x0x2_1 = sst.Link("link_2x2x2_2x0x2_1")
link_2x2x2_2x0x2_1.connect( (comp_rtr_2x0x2, "port10", "10000ps"), (comp_rtr_2x2x2, "port7", "10000ps") )
link_2x2x2_2x0x2_2 = sst.Link("link_2x2x2_2x0x2_2")
link_2x2x2_2x0x2_2.connect( (comp_rtr_2x0x2, "port11", "10000ps"), (comp_rtr_2x2x2, "port8", "10000ps") )
link_nic_20_0 = sst.Link("link_nic_20_0")
link_nic_20_0.connect( (comp_rtr_2x0x2, "port18", "10000ps"), (comp_nic_2x0x2_0, "rtr", "10000ps") )
link_nic_20_1 = sst.Link("link_nic_20_1")
link_nic_20_1.connect( (comp_rtr_2x0x2, "port19", "10000ps"), (comp_nic_2x0x2_1, "rtr", "10000ps") )
link_nic_20_2 = sst.Link("link_nic_20_2")
link_nic_20_2.connect( (comp_rtr_2x0x2, "port20", "10000ps"), (comp_nic_2x0x2_2, "rtr", "10000ps") )
link_nic_20_3 = sst.Link("link_nic_20_3")
link_nic_20_3.connect( (comp_rtr_2x0x2, "port21", "10000ps"), (comp_nic_2x0x2_3, "rtr", "10000ps") )
link_0x1x2_1x1x2_0 = sst.Link("link_0x1x2_1x1x2_0")
link_0x1x2_1x1x2_0.connect( (comp_rtr_0x1x2, "port0", "10000ps"), (comp_rtr_1x1x2, "port3", "10000ps") )
link_0x1x2_1x1x2_1 = sst.Link("link_0x1x2_1x1x2_1")
link_0x1x2_1x1x2_1.connect( (comp_rtr_0x1x2, "port1", "10000ps"), (comp_rtr_1x1x2, "port4", "10000ps") )
link_0x1x2_1x1x2_2 = sst.Link("link_0x1x2_1x1x2_2")
link_0x1x2_1x1x2_2.connect( (comp_rtr_0x1x2, "port2", "10000ps"), (comp_rtr_1x1x2, "port5", "10000ps") )
link_2x1x2_0x1x2_0 = sst.Link("link_2x1x2_0x1x2_0")
link_2x1x2_0x1x2_0.connect( (comp_rtr_0x1x2, "port3", "10000ps"), (comp_rtr_2x1x2, "port0", "10000ps") )
link_2x1x2_0x1x2_1 = sst.Link("link_2x1x2_0x1x2_1")
link_2x1x2_0x1x2_1.connect( (comp_rtr_0x1x2, "port4", "10000ps"), (comp_rtr_2x1x2, "port1", "10000ps") )
link_2x1x2_0x1x2_2 = sst.Link("link_2x1x2_0x1x2_2")
link_2x1x2_0x1x2_2.connect( (comp_rtr_0x1x2, "port5", "10000ps"), (comp_rtr_2x1x2, "port2", "10000ps") )
link_0x1x2_0x2x2_0 = sst.Link("link_0x1x2_0x2x2_0")
link_0x1x2_0x2x2_0.connect( (comp_rtr_0x1x2, "port6", "10000ps"), (comp_rtr_0x2x2, "port9", "10000ps") )
link_0x1x2_0x2x2_1 = sst.Link("link_0x1x2_0x2x2_1")
link_0x1x2_0x2x2_1.connect( (comp_rtr_0x1x2, "port7", "10000ps"), (comp_rtr_0x2x2, "port10", "10000ps") )
link_0x1x2_0x2x2_2 = sst.Link("link_0x1x2_0x2x2_2")
link_0x1x2_0x2x2_2.connect( (comp_rtr_0x1x2, "port8", "10000ps"), (comp_rtr_0x2x2, "port11", "10000ps") )
link_nic_21_0 = sst.Link("link_nic_21_0")
link_nic_21_0.connect( (comp_rtr_0x1x2, "port18", "10000ps"), (comp_nic_0x1x2_0, "rtr", "10000ps") )
link_nic_21_1 = sst.Link("link_nic_21_1")
link_nic_21_1.connect( (comp_rtr_0x1x2, "port19", "10000ps"), (comp_nic_0x1x2_1, "rtr", "10000ps") )
link_nic_21_2 = sst.Link("link_nic_21_2")
link_nic_21_2.connect( (comp_rtr_0x1x2, "port20", "10000ps"), (comp_nic_0x1x2_2, "rtr", "10000ps") )
link_nic_21_3 = sst.Link("link_nic_21_3")
link_nic_21_3.connect( (comp_rtr_0x1x2, "port21", "10000ps"), (comp_nic_0x1x2_3, "rtr", "10000ps") )
link_1x1x2_2x1x2_0 = sst.Link("link_1x1x2_2x1x2_0")
link_1x1x2_2x1x2_0.connect( (comp_rtr_1x1x2, "port0", "10000ps"), (comp_rtr_2x1x2, "port3", "10000ps") )
link_1x1x2_2x1x2_1 = sst.Link("link_1x1x2_2x1x2_1")
link_1x1x2_2x1x2_1.connect( (comp_rtr_1x1x2, "port1", "10000ps"), (comp_rtr_2x1x2, "port4", "10000ps") )
link_1x1x2_2x1x2_2 = sst.Link("link_1x1x2_2x1x2_2")
link_1x1x2_2x1x2_2.connect( (comp_rtr_1x1x2, "port2", "10000ps"), (comp_rtr_2x1x2, "port5", "10000ps") )
link_1x1x2_1x2x2_0 = sst.Link("link_1x1x2_1x2x2_0")
link_1x1x2_1x2x2_0.connect( (comp_rtr_1x1x2, "port6", "10000ps"), (comp_rtr_1x2x2, "port9", "10000ps") )
link_1x1x2_1x2x2_1 = sst.Link("link_1x1x2_1x2x2_1")
link_1x1x2_1x2x2_1.connect( (comp_rtr_1x1x2, "port7", "10000ps"), (comp_rtr_1x2x2, "port10", "10000ps") )
link_1x1x2_1x2x2_2 = sst.Link("link_1x1x2_1x2x2_2")
link_1x1x2_1x2x2_2.connect( (comp_rtr_1x1x2, "port8", "10000ps"), (comp_rtr_1x2x2, "port11", "10000ps") )
link_nic_22_0 = sst.Link("link_nic_22_0")
link_nic_22_0.connect( (comp_rtr_1x1x2, "port18", "10000ps"), (comp_nic_1x1x2_0, "rtr", "10000ps") )
link_nic_22_1 = sst.Link("link_nic_22_1")
link_nic_22_1.connect( (comp_rtr_1x1x2, "port19", "10000ps"), (comp_nic_1x1x2_1, "rtr", "10000ps") )
link_nic_22_2 = sst.Link("link_nic_22_2")
link_nic_22_2.connect( (comp_rtr_1x1x2, "port20", "10000ps"), (comp_nic_1x1x2_2, "rtr", "10000ps") )
link_nic_22_3 = sst.Link("link_nic_22_3")
link_nic_22_3.connect( (comp_rtr_1x1x2, "port21", "10000ps"), (comp_nic_1x1x2_3, "rtr", "10000ps") )
link_2x1x2_2x2x2_0 = sst.Link("link_2x1x2_2x2x2_0")
link_2x1x2_2x2x2_0.connect( (comp_rtr_2x1x2, "port6", "10000ps"), (comp_rtr_2x2x2, "port9", "10000ps") )
link_2x1x2_2x2x2_1 = sst.Link("link_2x1x2_2x2x2_1")
link_2x1x2_2x2x2_1.connect( (comp_rtr_2x1x2, "port7", "10000ps"), (comp_rtr_2x2x2, "port10", "10000ps") )
link_2x1x2_2x2x2_2 = sst.Link("link_2x1x2_2x2x2_2")
link_2x1x2_2x2x2_2.connect( (comp_rtr_2x1x2, "port8", "10000ps"), (comp_rtr_2x2x2, "port11", "10000ps") )
link_nic_23_0 = sst.Link("link_nic_23_0")
link_nic_23_0.connect( (comp_rtr_2x1x2, "port18", "10000ps"), (comp_nic_2x1x2_0, "rtr", "10000ps") )
link_nic_23_1 = sst.Link("link_nic_23_1")
link_nic_23_1.connect( (comp_rtr_2x1x2, "port19", "10000ps"), (comp_nic_2x1x2_1, "rtr", "10000ps") )
link_nic_23_2 = sst.Link("link_nic_23_2")
link_nic_23_2.connect( (comp_rtr_2x1x2, "port20", "10000ps"), (comp_nic_2x1x2_2, "rtr", "10000ps") )
link_nic_23_3 = sst.Link("link_nic_23_3")
link_nic_23_3.connect( (comp_rtr_2x1x2, "port21", "10000ps"), (comp_nic_2x1x2_3, "rtr", "10000ps") )
link_0x2x2_1x2x2_0 = sst.Link("link_0x2x2_1x2x2_0")
link_0x2x2_1x2x2_0.connect( (comp_rtr_0x2x2, "port0", "10000ps"), (comp_rtr_1x2x2, "port3", "10000ps") )
link_0x2x2_1x2x2_1 = sst.Link("link_0x2x2_1x2x2_1")
link_0x2x2_1x2x2_1.connect( (comp_rtr_0x2x2, "port1", "10000ps"), (comp_rtr_1x2x2, "port4", "10000ps") )
link_0x2x2_1x2x2_2 = sst.Link("link_0x2x2_1x2x2_2")
link_0x2x2_1x2x2_2.connect( (comp_rtr_0x2x2, "port2", "10000ps"), (comp_rtr_1x2x2, "port5", "10000ps") )
link_2x2x2_0x2x2_0 = sst.Link("link_2x2x2_0x2x2_0")
link_2x2x2_0x2x2_0.connect( (comp_rtr_0x2x2, "port3", "10000ps"), (comp_rtr_2x2x2, "port0", "10000ps") )
link_2x2x2_0x2x2_1 = sst.Link("link_2x2x2_0x2x2_1")
link_2x2x2_0x2x2_1.connect( (comp_rtr_0x2x2, "port4", "10000ps"), (comp_rtr_2x2x2, "port1", "10000ps") )
link_2x2x2_0x2x2_2 = sst.Link("link_2x2x2_0x2x2_2")
link_2x2x2_0x2x2_2.connect( (comp_rtr_0x2x2, "port5", "10000ps"), (comp_rtr_2x2x2, "port2", "10000ps") )
link_nic_24_0 = sst.Link("link_nic_24_0")
link_nic_24_0.connect( (comp_rtr_0x2x2, "port18", "10000ps"), (comp_nic_0x2x2_0, "rtr", "10000ps") )
link_nic_24_1 = sst.Link("link_nic_24_1")
link_nic_24_1.connect( (comp_rtr_0x2x2, "port19", "10000ps"), (comp_nic_0x2x2_1, "rtr", "10000ps") )
link_nic_24_2 = sst.Link("link_nic_24_2")
link_nic_24_2.connect( (comp_rtr_0x2x2, "port20", "10000ps"), (comp_nic_0x2x2_2, "rtr", "10000ps") )
link_nic_24_3 = sst.Link("link_nic_24_3")
link_nic_24_3.connect( (comp_rtr_0x2x2, "port21", "10000ps"), (comp_nic_0x2x2_3, "rtr", "10000ps") )
link_1x2x2_2x2x2_0 = sst.Link("link_1x2x2_2x2x2_0")
link_1x2x2_2x2x2_0.connect( (comp_rtr_1x2x2, "port0", "10000ps"), (comp_rtr_2x2x2, "port3", "10000ps") )
link_1x2x2_2x2x2_1 = sst.Link("link_1x2x2_2x2x2_1")
link_1x2x2_2x2x2_1.connect( (comp_rtr_1x2x2, "port1", "10000ps"), (comp_rtr_2x2x2, "port4", "10000ps") )
link_1x2x2_2x2x2_2 = sst.Link("link_1x2x2_2x2x2_2")
link_1x2x2_2x2x2_2.connect( (comp_rtr_1x2x2, "port2", "10000ps"), (comp_rtr_2x2x2, "port5", "10000ps") )
link_nic_25_0 = sst.Link("link_nic_25_0")
link_nic_25_0.connect( (comp_rtr_1x2x2, "port18", "10000ps"), (comp_nic_1x2x2_0, "rtr", "10000ps") )
link_nic_25_1 = sst.Link("link_nic_25_1")
link_nic_25_1.connect( (comp_rtr_1x2x2, "port19", "10000ps"), (comp_nic_1x2x2_1, "rtr", "10000ps") )
link_nic_25_2 = sst.Link("link_nic_25_2")
link_nic_25_2.connect( (comp_rtr_1x2x2, "port20", "10000ps"), (comp_nic_1x2x2_2, "rtr", "10000ps") )
link_nic_25_3 = sst.Link("link_nic_25_3")
link_nic_25_3.connect( (comp_rtr_1x2x2, "port21", "10000ps"), (comp_nic_1x2x2_3, "rtr", "10000ps") )
link_nic_26_0 = sst.Link("link_nic_26_0")
link_nic_26_0.connect( (comp_rtr_2x2x2, "port18", "10000ps"), (comp_nic_2x2x2_0, "rtr", "10000ps") )
link_nic_26_1 = sst.Link("link_nic_26_1")
link_nic_26_1.connect( (comp_rtr_2x2x2, "port19", "10000ps"), (comp_nic_2x2x2_1, "rtr", "10000ps") )
link_nic_26_2 = sst.Link("link_nic_26_2")
link_nic_26_2.connect( (comp_rtr_2x2x2, "port20", "10000ps"), (comp_nic_2x2x2_2, "rtr", "10000ps") )
link_nic_26_3 = sst.Link("link_nic_26_3")
link_nic_26_3.connect( (comp_rtr_2x2x2, "port21", "10000ps"), (comp_nic_2x2x2_3, "rtr", "10000ps") )
# End of generated output.
