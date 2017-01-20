# Automatically generated SST Python input
import sst
from sst.merlin import *
import os
import sys,getopt

L1cachesz = "8 KB"
L2cachesz = "32 KB"
L3cachesz = "32 KB"
L1assoc = 2
L2assoc = 2
L3assoc = 2
L1Replacp = "lru"
L2Replacp = "lru"
L3Replacp = "lru"
L2MSHR = 32
L3MSHR = 32
MSIMESI = "MSI"
Pref1 = "cassini.NextBlockPrefetcher"
Pref2 = "cassini.NextBlockPrefetcher"
Executable = os.getenv('OMP_EXE', "ompbarrier/ompbarrier.x")

def main():
    global L1cachesz
    global L2cachesz
    global L3cachesz
    global L1assoc
    global L2assoc
    global L3assoc
    global L1Replacp
    global L2Replacp
    global L3Replacp
    global L2MSHR
    global L3MSHR
    global MSIMESI
    global Pref1
    global Pref2
    global Executable

    try:
        opts, args = getopt.getopt(sys.argv[1:], "", ["L1cachesz=","L2cachesz=","L3cachesz=","L1assoc=","L2assoc=","L3assoc=","L1Replacp=","L2Replacp=","L3Replacp=","L2MSHR=","L3MSHR=","MSIMESI=","Pref1=","Pref2=","Executable="])
    except getopt.GetopError as err:
        print str(err)
        sys.exit(2)
    for o, a in opts:
        if o in ("--L1cachesz"):
            L1cachesz = a
            print 'found L1c'
        elif o in ("--L2cachesz"):
            L2cachesz = a
        elif o in ("--L3cachesz"):
            L3cachesz = a
        elif o in ("--L1assoc"):
            L1assoc = a
        elif o in ("--L2assoc"):
            L2assoc = a
        elif o in ("--L3assoc"):
            L3assoc = a
        elif o in ("--L1Replacp"):
            L1Replacp = a
        elif o in ("--L2Replacp"):
            L2Replacp = a
        elif o in ("--L3Replacp"):
            L3Replacp = a
        elif o in ("--L2MSHR"):
            L2MSHR = a
        elif o in ("--L3MSHR"):
            L3MSHR = a
        elif o in ("--MSIMESI"):
            MSIMESI = a
        elif o in ("--Pref1"):
            if a == "yes":
                Pref1 = "cassini.NextBlockPrefetcher"
        elif o in ("--Pref2"):
            if a == "yes":
                Pref2 = "cassini.NextBlockPrefetcher"
        elif o in ("--Executable"):
            Executable = a
        else:
            print o
            assert False, "Unknown Options"
    print L1cachesz, L2cachesz, L3cachesz, L1assoc, L2assoc, L3assoc, L1Replacp, L2Replacp, L3Replacp, L2MSHR,L2MSHR,  MSIMESI, Pref1, Pref2, Executable

main()
# Define needed environment params
os.environ['OMP_NUM_THREADS']="8"

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "100ms")

# Define the simulation components
ariel_cpus = sst.Component("cpus", "ariel.ariel")
ariel_cpus.addParams({
    "verbose"           : 0,
    "clock"             : "2 Ghz",
    "maxcorequeue"      : 256,
    "maxissuepercycle"  : 4,
    "pipetimeout"       : 0,
    "corecount"         : 8,
    "arielmode"         : 1,
    "memmgr.memorylevels"      : 1,
    "memmgr.pagecount0"        : 262144,
    "memmgr.defaultlevel"      : 0,
    "executable"        : Executable
})

comp_c0_l1Dcache = sst.Component("c0.l1Dcache", "memHierarchy.Cache")
comp_c0_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """1""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c1_l1Dcache = sst.Component("c1.l1Dcache", "memHierarchy.Cache")
comp_c1_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """10""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c2_l1Dcache = sst.Component("c2.l1Dcache", "memHierarchy.Cache")
comp_c2_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """1""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c3_l1Dcache = sst.Component("c3.l1Dcache", "memHierarchy.Cache")
comp_c3_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """10""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c4_l1Dcache = sst.Component("c4.l1Dcache", "memHierarchy.Cache")
comp_c4_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """1""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c5_l1Dcache = sst.Component("c5.l1Dcache", "memHierarchy.Cache")
comp_c5_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """10""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c6_l1Dcache = sst.Component("c6.l1Dcache", "memHierarchy.Cache")
comp_c6_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """1""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_c7_l1Dcache = sst.Component("c7.l1Dcache", "memHierarchy.Cache")
comp_c7_l1Dcache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """10""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : L1Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """1""",
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1
})
comp_n0_bus = sst.Component("n0.bus", "memHierarchy.Bus")
comp_n0_bus.addParams({
      "bus_frequency" : """2 Ghz"""
})
comp_n0_l2cache = sst.Component("n0.l2cache", "memHierarchy.Cache")
comp_n0_l2cache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """15""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : L2Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """0""",
      "cache_size" : L2cachesz,
      "network_address" : """2""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L2MSHR,
      "prefetcher" : Pref2,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB"
})
comp_n1_bus = sst.Component("n1.bus", "memHierarchy.Bus")
comp_n1_bus.addParams({
      "bus_frequency" : """2 Ghz"""
})
comp_n1_l2cache = sst.Component("n1.l2cache", "memHierarchy.Cache")
comp_n1_l2cache.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """5""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : L2Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """0""",
      "cache_size" : L2cachesz,
      "network_address" : """3""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L2MSHR,
      "prefetcher" : Pref2,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB"
})
comp_l3cache0 = sst.Component("l3cache0", "memHierarchy.Cache")
comp_l3cache0.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """8""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : L3Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L3assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "L1" : """0""",
      "cache_size" : L3cachesz,
      "network_address" : """4""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L3MSHR,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "num_cache_slices" : """2""",
      "slice_id" : """0""",
      "slice_allocation_policy" : """rr"""
})
comp_l3cache1 = sst.Component("l3cache1", "memHierarchy.Cache")
comp_l3cache1.addParams({
      "debug" : """0""",
      "access_latency_cycles" : """8""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : L3Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L3assoc,
      "cache_line_size" : """64""",
      "debug_level" : """6""",
      "cache_size" : L3cachesz,
      "network_address" : """5""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L3MSHR,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "num_cache_slices" : """2""",
      "slice_id" : """1""",
      "slice_allocation_policy" : """rr"""
})
comp_chipRtr = sst.Component("chipRtr", "merlin.hr_router")
comp_chipRtr.addParams({
      "input_buf_size" : """2KB""",
      "num_ports" : """6""",
      "id" : """0""",
      "output_buf_size" : """2KB""",
      "flit_size" : """64B""",
      "xbar_bw" : """51.2 GB/s""",
      "link_bw" : """25.6 GB/s""",
      "topology" : """merlin.singlerouter"""
})
comp_dirctrl0 = sst.Component("dirctrl0", "memHierarchy.DirectoryController")
comp_dirctrl0.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "network_address" : """0""",
      "entry_cache_size" : """32768""",
      "network_bw" : """25GB/s""",
      "addr_range_start" : """0x0""",
      "backing_store_size" : """0""",
      "addr_range_end" : """0x000FFFFF""",
      "mshr_num_entries" : "2",
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
})
comp_memory0 = sst.Component("memory0", "memHierarchy.MemController")
comp_memory0.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "backend.mem_size" : """512MiB""",
      "clock" : """1.6GHz""",
      "access_time" : """5 ns""",
      "rangeStart" : """0"""
})
comp_dirctrl1 = sst.Component("dirctrl1", "memHierarchy.DirectoryController")
comp_dirctrl1.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "network_address" : """1""",
      "entry_cache_size" : """32768""",
      "network_bw" : """25GB/s""",
      "addr_range_start" : """0x00100000""",
      "backing_store_size" : """0""",
      "addr_range_end" : """0x3FFFFFFF""",
      "mshr_num_entries" : "2",
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
})
comp_memory1 = sst.Component("memory1", "memHierarchy.MemController")
comp_memory1.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "backend.mem_size" : """512MiB""",
      "clock" : """1.6GHz""",
      "access_time" : """5 ns""",
      "rangeStart" : """0"""
})


# Define the simulation links
link_core0_dcache = sst.Link("link_core0_dcache")
link_core0_dcache.connect( (ariel_cpus, "cache_link_0", "500ps"), (comp_c0_l1Dcache, "high_network_0", "500ps") )
link_core1_dcache = sst.Link("link_core1_dcache")
link_core1_dcache.connect( (ariel_cpus, "cache_link_1", "500ps"), (comp_c1_l1Dcache, "high_network_0", "500ps") )
link_core2_dcache = sst.Link("link_core2_dcache")
link_core2_dcache.connect( (ariel_cpus, "cache_link_2", "500ps"), (comp_c2_l1Dcache, "high_network_0", "500ps") )
link_core3_dcache = sst.Link("link_core3_dcache")
link_core3_dcache.connect( (ariel_cpus, "cache_link_3", "500ps"), (comp_c3_l1Dcache, "high_network_0", "500ps") )
link_core4_dcache = sst.Link("link_core4_dcache")
link_core4_dcache.connect( (ariel_cpus, "cache_link_4", "500ps"), (comp_c4_l1Dcache, "high_network_0", "500ps") )
link_core5_dcache = sst.Link("link_core5_dcache")
link_core5_dcache.connect( (ariel_cpus, "cache_link_5", "500ps"), (comp_c5_l1Dcache, "high_network_0", "500ps") )
link_core6_dcache = sst.Link("link_core6_dcache")
link_core6_dcache.connect( (ariel_cpus, "cache_link_6", "500ps"), (comp_c6_l1Dcache, "high_network_0", "500ps") )
link_core7_dcache = sst.Link("link_core7_dcache")
link_core7_dcache.connect( (ariel_cpus, "cache_link_7", "500ps"), (comp_c7_l1Dcache, "high_network_0", "500ps") )
link_c0dcache_bus_link = sst.Link("link_c0dcache_bus_link")
link_c0dcache_bus_link.connect( (comp_c0_l1Dcache, "low_network_0", "100ps"), (comp_n0_bus, "high_network_0", "100ps") )
link_c1dcache_bus_link = sst.Link("link_c1dcache_bus_link")
link_c1dcache_bus_link.connect( (comp_c1_l1Dcache, "low_network_0", "100ps"), (comp_n0_bus, "high_network_1", "100ps") )
link_c2dcache_bus_link = sst.Link("link_c2dcache_bus_link")
link_c2dcache_bus_link.connect( (comp_c2_l1Dcache, "low_network_0", "100ps"), (comp_n0_bus, "high_network_2", "100ps") )
link_c3dcache_bus_link = sst.Link("link_c3dcache_bus_link")
link_c3dcache_bus_link.connect( (comp_c3_l1Dcache, "low_network_0", "100ps"), (comp_n0_bus, "high_network_3", "100ps") )
link_c4dcache_bus_link = sst.Link("link_c4dcache_bus_link")
link_c4dcache_bus_link.connect( (comp_c4_l1Dcache, "low_network_0", "100ps"), (comp_n1_bus, "high_network_0", "100ps") )
link_c5dcache_bus_link = sst.Link("link_c5dcache_bus_link")
link_c5dcache_bus_link.connect( (comp_c5_l1Dcache, "low_network_0", "100ps"), (comp_n1_bus, "high_network_1", "100ps") )
link_c6dcache_bus_link = sst.Link("link_c6dcache_bus_link")
link_c6dcache_bus_link.connect( (comp_c6_l1Dcache, "low_network_0", "100ps"), (comp_n1_bus, "high_network_2", "100ps") )
link_c7dcache_bus_link = sst.Link("link_c7dcache_bus_link")
link_c7dcache_bus_link.connect( (comp_c7_l1Dcache, "low_network_0", "100ps"), (comp_n1_bus, "high_network_3", "100ps") )
link_n0bus_n0l2cache = sst.Link("link_n0bus_n0l2cache")
link_n0bus_n0l2cache.connect( (comp_n0_bus, "low_network_0", "100ps"), (comp_n0_l2cache, "high_network_0", "100ps") )
link_n0bus_router = sst.Link("link_n0bus_router")
link_n0bus_router.connect( (comp_n0_l2cache, "cache", "100ps"), (comp_chipRtr, "port2", "1000ps") )
link_n1bus_n1l2cache = sst.Link("link_n1bus_n1l2cache")
link_n1bus_n1l2cache.connect( (comp_n1_bus, "low_network_0", "100ps"), (comp_n1_l2cache, "high_network_0", "100ps") )
link_n1bus_router = sst.Link("link_n1bus_router")
link_n1bus_router.connect( (comp_n1_l2cache, "cache", "100ps"), (comp_chipRtr, "port3", "1000ps") )
link_l3cache0_router = sst.Link("link_l3cache0_router")
link_l3cache0_router.connect( (comp_chipRtr, "port4", "1000ps"), (comp_l3cache0, "directory", "100ps") );
link_l3cache1_router = sst.Link("link_l3cache1_router")
link_l3cache1_router.connect( (comp_chipRtr, "port5", "1000ps"), (comp_l3cache1, "directory", "100ps") );
link_dirctrl0_router = sst.Link("link_dirctrl0_router")
link_dirctrl0_router.connect( (comp_chipRtr, "port0", "1000ps"), (comp_dirctrl0, "network", "100ps") )
link_dirctrl1_router = sst.Link("link_dirctrl1_router")
link_dirctrl1_router.connect( (comp_chipRtr, "port1", "1000ps"), (comp_dirctrl1, "network", "100ps") )
link_dirctrl0_mem = sst.Link("link_dirctrl0_mem")
link_dirctrl0_mem.connect( (comp_dirctrl0, "memory", "100ps"), (comp_memory0, "direct_link", "100ps") )
link_dirctrl1_mem = sst.Link("link_dirctrl1_mem")
link_dirctrl1_mem.connect( (comp_dirctrl1, "memory", "100ps"), (comp_memory1, "direct_link", "100ps") )
# End of generated output.
