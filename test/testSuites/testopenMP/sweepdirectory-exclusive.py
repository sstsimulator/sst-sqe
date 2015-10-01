# Automatically generated SST Python input
import sst
from sst.merlin import *

import sys,getopt

L1cachesz = "8 KB"
L2cachesz = "32 KB"
L1assoc = 2
L2assoc = 8
Replacp = "mru"
L2MSHR = 8
MSIMESI = "MSI"
#Pref1 = "cassini.NextBlockPrefetcher"
#Pref2 = "cassini.NextBlockPrefetcher"
Pref1 = ""
Pref2 = ""
L1idebug = 0
L1ddebug = 0
L1debugLevel = 9
L2debug = 0
L2debug_lev = 9
Dirdebug = 0
Dirdebug_lev = 10
stat = 1
addr = -1
#addr = 91712

def main():
    global L1cachesz
    global L2cachesz
    global L1assoc
    global L2assoc
    global Replacp
    global L2MSHR
    global MSIMESI
    global Pref1
    global Pref2

    try:
        opts, args = getopt.getopt(sys.argv[1:], "", ["L1cachesz=","L2cachesz=","L1assoc=","L2assoc=","Replacp=","L2MSHR=","MSIMESI=","Pref1=","Pref2="])
    except getopt.GetopError as err:
        print str(err)
        sys.exit(2)
    for o, a in opts:
        if o in ("--L1cachesz"):
            L1cachesz = a
        elif o in ("--L2cachesz"):
            L2cachesz = a
        elif o in ("--L1assoc"):
            L1assoc = a
        elif o in ("--L2assoc"):
            L2assoc = a
        elif o in ("--Replacp"):
            Replacp = a
        elif o in ("--L2MSHR"):
            L2MSHR = a
        elif o in ("--MSIMESI"):
            MSIMESI = a
        elif o in ("--Pref1"):
            if a == "yes":
                Pref1 = "cassini.NextBlockPrefetcher"
        elif o in ("--Pref2"):
            if a == "yes":
                Pref2 = "cassini.NextBlockPrefetcher"
        else:
            print o
            assert False, "Unknown Options"
    print L1cachesz, L2cachesz, L1assoc, L2assoc, Replacp, L2MSHR, MSIMESI, Pref1, Pref2

main()


# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "100ms")

# Define the simulation components
comp_system = sst.Component("system", "m5C.M5")
comp_system.addParams({
      "info" : """yes""",
      "mem_initializer_port" : """core0-dcache""",
      "configFile" : """directory-8cores-2nodesM5.xml""",
      "frequency" : """2 Ghz""",
      "statFile" : """out.txt""",
      "debug" : """0""",
      "memory_trace" : """0""",
      #"M5debug" : """Exec""",
      # Other options: 03ExecAll, Syscall
      "registerExit" : """yes"""
})
comp_c0_l1Dcache = sst.Component("c0.l1Dcache", "memHierarchy.Cache")
comp_c0_l1Dcache.addParams({
     #"debug" : 1,
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "prefetcher" : Pref1,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "statistics" : stat
})
comp_c0_l1Icache = sst.Component("c0.l1Icache", "memHierarchy.Cache")
comp_c0_l1Icache.addParams({
    #"debug" : 1,  
    "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c0_bus = sst.Component("c0.bus", "memHierarchy.Bus")
comp_c0_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c0_l2cache = sst.Component("c0.l2cache", "memHierarchy.Cache")
comp_c0_l2cache.addParams({
    #"debug" : 1,  
     "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c1_l1Dcache = sst.Component("c1.l1Dcache", "memHierarchy.Cache")
comp_c1_l1Dcache.addParams({
      "debug" : L1ddebug,
      #"debug" : 1,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c1_l1Icache = sst.Component("c1.l1Icache", "memHierarchy.Cache")
comp_c1_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c1_bus = sst.Component("c1.bus", "memHierarchy.Bus")
comp_c1_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c1_l2cache = sst.Component("c1.l2cache", "memHierarchy.Cache")
comp_c1_l2cache.addParams({
    #"debug" : 1, 
     "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c2_l1Dcache = sst.Component("c2.l1Dcache", "memHierarchy.Cache")
comp_c2_l1Dcache.addParams({
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c2_l1Icache = sst.Component("c2.l1Icache", "memHierarchy.Cache")
comp_c2_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c2_bus = sst.Component("c2.bus", "memHierarchy.Bus")
comp_c2_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c2_l2cache = sst.Component("c2.l2cache", "memHierarchy.Cache")
comp_c2_l2cache.addParams({
    #"debug" : 1, 
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c3_l1Dcache = sst.Component("c3.l1Dcache", "memHierarchy.Cache")
comp_c3_l1Dcache.addParams({
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c3_l1Icache = sst.Component("c3.l1Icache", "memHierarchy.Cache")
comp_c3_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c3_bus = sst.Component("c3.bus", "memHierarchy.Bus")
comp_c3_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c3_l2cache = sst.Component("c3.l2cache", "memHierarchy.Cache")
comp_c3_l2cache.addParams({
    #"debug" : 1, 
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c4_l1Dcache = sst.Component("c4.l1Dcache", "memHierarchy.Cache")
comp_c4_l1Dcache.addParams({
    #"debug" : 1,  
    "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "access_latency_cycles" : """2""",
      "statistics" : stat,
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c4_l1Icache = sst.Component("c4.l1Icache", "memHierarchy.Cache")
comp_c4_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c4_bus = sst.Component("c4.bus", "memHierarchy.Bus")
comp_c4_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c4_l2cache = sst.Component("c4.l2cache", "memHierarchy.Cache")
comp_c4_l2cache.addParams({
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c5_l1Dcache = sst.Component("c5.l1Dcache", "memHierarchy.Cache")
comp_c5_l1Dcache.addParams({
      #"debug" : 1, 
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c5_l1Icache = sst.Component("c5.l1Icache", "memHierarchy.Cache")
comp_c5_l1Icache.addParams({
    #"debug" : 1,
    "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c5_bus = sst.Component("c5.bus", "memHierarchy.Bus")
comp_c5_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c5_l2cache = sst.Component("c5.l2cache", "memHierarchy.Cache")
comp_c5_l2cache.addParams({
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c6_l1Dcache = sst.Component("c6.l1Dcache", "memHierarchy.Cache")
comp_c6_l1Dcache.addParams({
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c6_l1Icache = sst.Component("c6.l1Icache", "memHierarchy.Cache")
comp_c6_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c6_bus = sst.Component("c6.bus", "memHierarchy.Bus")
comp_c6_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c6_l2cache = sst.Component("c6.l2cache", "memHierarchy.Cache")
comp_c6_l2cache.addParams({
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_c7_l1Dcache = sst.Component("c7.l1Dcache", "memHierarchy.Cache")
comp_c7_l1Dcache.addParams({
      "debug" : L1ddebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c7_l1Icache = sst.Component("c7.l1Icache", "memHierarchy.Cache")
comp_c7_l1Icache.addParams({
      "debug" : L1idebug,
      "debug_level" : L1debugLevel,
      "statistics" : stat,
      "access_latency_cycles" : """2""",
      "cache_frequency" : """2 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L1assoc,
      "cache_line_size" : """64""",
      "L1" : 1,
      "cache_size" : L1cachesz,
      "debug_addr" : addr,
      "lower_is_noninclusive" : 1,
      "prefetcher" : Pref1
})
comp_c7_bus = sst.Component("c7.bus", "memHierarchy.Bus")
comp_c7_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_c7_l2cache = sst.Component("c7.l2cache", "memHierarchy.Cache")
comp_c7_l2cache.addParams({
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 2048,
      "noninclusive_directory_associativity" : 8,
      "lower_is_noninclusive" : 1,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "mshr_num_entries" : L2MSHR,
      "debug_addr" : addr
})
comp_n0_bus = sst.Component("n0.bus", "memHierarchy.Bus")
comp_n0_bus.addParams({
    "bus_frequency" : """2 Ghz"""
})
comp_n0_l3cache = sst.Component("n0.l3cache", "memHierarchy.Cache")
comp_n0_l3cache.addParams({
    #"debug" : 1,  
      "debug" : L2debug,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "network_address" : """2""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L2MSHR,
      "prefetcher" : Pref2,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "debug_addr" : addr,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 4096,
      "noninclusive_directory_associativity" : 32,
      "directory_at_next_level" : """1"""
})
comp_n1_bus = sst.Component("n1.bus", "memHierarchy.Bus")
comp_n1_bus.addParams({
      "bus_frequency" : """2 Ghz"""
})
comp_n1_l3cache = sst.Component("n1.l3cache", "memHierarchy.Cache")
comp_n1_l3cache.addParams({
      "debug" : L2debug,
      #"debug" : 1,
      "statistics" : stat,
      "access_latency_cycles" : """6""",
      "cache_frequency" : """2.0 Ghz""",
      "replacement_policy" : Replacp,
      "coherence_protocol" : MSIMESI,
      "associativity" : L2assoc,
      "cache_line_size" : """64""",
      "debug_level" : L2debug_lev,
      "cache_size" : L2cachesz,
      "network_address" : """3""",
      "network_bw" : """25GB/s""",
      "mshr_num_entries" : L2MSHR,
      "prefetcher" : Pref2,
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "debug_addr" : addr,
      "cache_type" : "noninclusive_with_directory",
      "noninclusive_directory_entries" : 4096,
      "noninclusive_directory_associativity" : 32,
      "directory_at_next_level" : """1"""
})
comp_chipRtr = sst.Component("chipRtr", "merlin.hr_router")
comp_chipRtr.addParams({
      "input_buf_size" : """2KB""",
      "num_ports" : """4""",
      "id" : """0""",
      "output_buf_size" : """2KB""",
      "flit_size" : """64B""",
      "xbar_bw" : """51.2 GB/s""",
      "link_bw" : """25.6 GB/s""",
      "topology" : """merlin.singlerouter"""
})
comp_dirctrl0 = sst.Component("dirctrl0", "memHierarchy.DirectoryController")
comp_dirctrl0.addParams({
    #"debug" : 1, 
    "debug" : Dirdebug,
      "statistics" : stat,
      "debug_level" : Dirdebug_lev,
      "coherence_protocol" : MSIMESI,
      "network_address" : """0""",
      "entry_cache_size" : """32768""",
      "network_bw" : """25GB/s""",
      "addr_range_start" : """0x0""",
      "backing_store_size" : """0""",
      "printStats" : """""",
      "interleave_step" : """0""",
      "addr_range_end" : """0x000FFFFF""",
      "mshr_num_entries" : "2",
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "debug_addr" : addr,
      "interleave_size" : """0"""
})
comp_memory0 = sst.Component("memory0", "memHierarchy.MemController")
comp_memory0.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "backend.mem_size" : """512""",
      "clock" : """1.6GHz""",
      "access_time" : """25 ns""",
      "rangeStart" : """0"""
})
comp_dirctrl1 = sst.Component("dirctrl1", "memHierarchy.DirectoryController")
comp_dirctrl1.addParams({
      "debug" : Dirdebug,
      "statistics" : stat,
      "debug_level" : Dirdebug_lev,
      "coherence_protocol" : MSIMESI,
      "network_address" : """1""",
      "entry_cache_size" : """32768""",
      "network_bw" : """25GB/s""",
      "addr_range_start" : """0x00100000""",
      "backing_store_size" : """0""",
      "printStats" : """""",
      "interleave_step" : """0""",
      "addr_range_end" : """0x3FFFFFFF""",
      "mshr_num_entries" : "2",
      "network_input_buffer_size" : "2KB",
      "network_output_buffer_size" : "2KB",
      "debug_addr" : addr,
      "interleave_size" : """0"""
})
comp_memory1 = sst.Component("memory1", "memHierarchy.MemController")
comp_memory1.addParams({
      "debug" : """0""",
      "coherence_protocol" : MSIMESI,
      "backend.mem_size" : """512""",
      "clock" : """1.6GHz""",
      "access_time" : """25 ns""",
      "rangeStart" : """0"""
})


# Define the simulation links
# Core to L1 I & D
link_core0_dcache = sst.Link("link_core0_dcache")
link_core0_dcache.connect( (comp_system, "core0-dcache", "1000ps"), (comp_c0_l1Dcache, "high_network_0", "1000ps") )
link_core0_icache = sst.Link("link_core0_icache")
link_core0_icache.connect( (comp_system, "core0-icache", "1000ps"), (comp_c0_l1Icache, "high_network_0", "1000ps") )
link_core1_dcache = sst.Link("link_core1_dcache")
link_core1_dcache.connect( (comp_system, "core1-dcache", "1000ps"), (comp_c1_l1Dcache, "high_network_0", "1000ps") )
link_core1_icache = sst.Link("link_core1_icache")
link_core1_icache.connect( (comp_system, "core1-icache", "1000ps"), (comp_c1_l1Icache, "high_network_0", "1000ps") )
link_core2_dcache = sst.Link("link_core2_dcache")
link_core2_dcache.connect( (comp_system, "core2-dcache", "1000ps"), (comp_c2_l1Dcache, "high_network_0", "1000ps") )
link_core2_icache = sst.Link("link_core2_icache")
link_core2_icache.connect( (comp_system, "core2-icache", "1000ps"), (comp_c2_l1Icache, "high_network_0", "1000ps") )
link_core3_dcache = sst.Link("link_core3_dcache")
link_core3_dcache.connect( (comp_system, "core3-dcache", "1000ps"), (comp_c3_l1Dcache, "high_network_0", "1000ps") )
link_core3_icache = sst.Link("link_core3_icache")
link_core3_icache.connect( (comp_system, "core3-icache", "1000ps"), (comp_c3_l1Icache, "high_network_0", "1000ps") )
link_core4_dcache = sst.Link("link_core4_dcache")
link_core4_dcache.connect( (comp_system, "core4-dcache", "1000ps"), (comp_c4_l1Dcache, "high_network_0", "1000ps") )
link_core4_icache = sst.Link("link_core4_icache")
link_core4_icache.connect( (comp_system, "core4-icache", "1000ps"), (comp_c4_l1Icache, "high_network_0", "1000ps") )
link_core5_dcache = sst.Link("link_core5_dcache")
link_core5_dcache.connect( (comp_system, "core5-dcache", "1000ps"), (comp_c5_l1Dcache, "high_network_0", "1000ps") )
link_core5_icache = sst.Link("link_core5_icache")
link_core5_icache.connect( (comp_system, "core5-icache", "1000ps"), (comp_c5_l1Icache, "high_network_0", "1000ps") )
link_core6_dcache = sst.Link("link_core6_dcache")
link_core6_dcache.connect( (comp_system, "core6-dcache", "1000ps"), (comp_c6_l1Dcache, "high_network_0", "1000ps") )
link_core6_icache = sst.Link("link_core6_icache")
link_core6_icache.connect( (comp_system, "core6-icache", "1000ps"), (comp_c6_l1Icache, "high_network_0", "1000ps") )
link_core7_dcache = sst.Link("link_core7_dcache")
link_core7_dcache.connect( (comp_system, "core7-dcache", "1000ps"), (comp_c7_l1Dcache, "high_network_0", "1000ps") )
link_core7_icache = sst.Link("link_core7_icache")
link_core7_icache.connect( (comp_system, "core7-icache", "1000ps"), (comp_c7_l1Icache, "high_network_0", "1000ps") )
# L1 I & D to L2 bus
link_c0dcache_c0bus = sst.Link("link_c0dcache_c0bus")
link_c0dcache_c0bus.connect( (comp_c0_l1Dcache, "low_network_0", "50ps"), (comp_c0_bus, "high_network_0", "50ps") )
link_c0icache_c0bus = sst.Link("link_c0icache_c0bus")
link_c0icache_c0bus.connect( (comp_c0_l1Icache, "low_network_0", "50ps"), (comp_c0_bus, "high_network_1", "50ps") )
link_c1dcache_c1bus = sst.Link("link_c1dcache_c1bus")
link_c1dcache_c1bus.connect( (comp_c1_l1Dcache, "low_network_0", "50ps"), (comp_c1_bus, "high_network_0", "50ps") )
link_c1icache_c1bus = sst.Link("link_c1icache_c1bus")
link_c1icache_c1bus.connect( (comp_c1_l1Icache, "low_network_0", "50ps"), (comp_c1_bus, "high_network_1", "50ps") )
link_c2dcache_c2bus = sst.Link("link_c2dcache_c2bus")
link_c2dcache_c2bus.connect( (comp_c2_l1Dcache, "low_network_0", "50ps"), (comp_c2_bus, "high_network_0", "50ps") )
link_c2icache_c2bus = sst.Link("link_c2icache_c2bus")
link_c2icache_c2bus.connect( (comp_c2_l1Icache, "low_network_0", "50ps"), (comp_c2_bus, "high_network_1", "50ps") )
link_c3dcache_c3bus = sst.Link("link_c3dcache_c3bus")
link_c3dcache_c3bus.connect( (comp_c3_l1Dcache, "low_network_0", "50ps"), (comp_c3_bus, "high_network_0", "50ps") )
link_c3icache_c3bus = sst.Link("link_c3icache_c3bus")
link_c3icache_c3bus.connect( (comp_c3_l1Icache, "low_network_0", "50ps"), (comp_c3_bus, "high_network_1", "50ps") )
link_c4dcache_c4bus = sst.Link("link_c4dcache_c4bus")
link_c4dcache_c4bus.connect( (comp_c4_l1Dcache, "low_network_0", "50ps"), (comp_c4_bus, "high_network_0", "50ps") )
link_c4icache_c4bus = sst.Link("link_c4icache_c4bus")
link_c4icache_c4bus.connect( (comp_c4_l1Icache, "low_network_0", "50ps"), (comp_c4_bus, "high_network_1", "50ps") )
link_c5dcache_c5bus = sst.Link("link_c5dcache_c5bus")
link_c5dcache_c5bus.connect( (comp_c5_l1Dcache, "low_network_0", "50ps"), (comp_c5_bus, "high_network_0", "50ps") )
link_c5icache_c5bus = sst.Link("link_c5icache_c5bus")
link_c5icache_c5bus.connect( (comp_c5_l1Icache, "low_network_0", "50ps"), (comp_c5_bus, "high_network_1", "50ps") )
link_c6dcache_c6bus = sst.Link("link_c6dcache_c6bus")
link_c6dcache_c6bus.connect( (comp_c6_l1Dcache, "low_network_0", "50ps"), (comp_c6_bus, "high_network_0", "50ps") )
link_c6icache_c6bus = sst.Link("link_c6icache_c6bus")
link_c6icache_c6bus.connect( (comp_c6_l1Icache, "low_network_0", "50ps"), (comp_c6_bus, "high_network_1", "50ps") )
link_c7dcache_c7bus = sst.Link("link_c7dcache_c7bus")
link_c7dcache_c7bus.connect( (comp_c7_l1Dcache, "low_network_0", "50ps"), (comp_c7_bus, "high_network_0", "50ps") )
link_c7icache_c7bus = sst.Link("link_c7icache_c7bus")
link_c7icache_c7bus.connect( (comp_c7_l1Icache, "low_network_0", "50ps"), (comp_c7_bus, "high_network_1", "50ps") )
# link c* buses to L2s
link_c0bus_c0l2 = sst.Link("link_c0bus_c0l2")
link_c0bus_c0l2.connect( (comp_c0_bus, "low_network_0", "50ps"), (comp_c0_l2cache, "high_network_0", "50ps") )
link_c1bus_c1l2 = sst.Link("link_c1bus_c1l2")
link_c1bus_c1l2.connect( (comp_c1_bus, "low_network_0", "50ps"), (comp_c1_l2cache, "high_network_0", "50ps") )
link_c2bus_c2l2 = sst.Link("link_c2bus_c2l2")
link_c2bus_c2l2.connect( (comp_c2_bus, "low_network_0", "50ps"), (comp_c2_l2cache, "high_network_0", "50ps") )
link_c3bus_c3l2 = sst.Link("link_c3bus_c3l2")
link_c3bus_c3l2.connect( (comp_c3_bus, "low_network_0", "50ps"), (comp_c3_l2cache, "high_network_0", "50ps") )
link_c4bus_c4l2 = sst.Link("link_c4bus_c4l2")
link_c4bus_c4l2.connect( (comp_c4_bus, "low_network_0", "50ps"), (comp_c4_l2cache, "high_network_0", "50ps") )
link_c5bus_c5l2 = sst.Link("link_c5bus_c5l2")
link_c5bus_c5l2.connect( (comp_c5_bus, "low_network_0", "50ps"), (comp_c5_l2cache, "high_network_0", "50ps") )
link_c6bus_c6l2 = sst.Link("link_c6bus_c6l2")
link_c6bus_c6l2.connect( (comp_c6_bus, "low_network_0", "50ps"), (comp_c6_l2cache, "high_network_0", "50ps") )
link_c7bus_c7l2 = sst.Link("link_c7bus_c7l2")
link_c7bus_c7l2.connect( (comp_c7_bus, "low_network_0", "50ps"), (comp_c7_l2cache, "high_network_0", "50ps") )
# link L2s to node buses
link_c0l2cache_bus = sst.Link("link_c0l2cache_bus")
link_c0l2cache_bus.connect( (comp_c0_l2cache, "low_network_0", "50ps"), (comp_n0_bus, "high_network_0", "50ps") )
link_c1l2cache_bus = sst.Link("link_c1l2cache_bus")
link_c1l2cache_bus.connect( (comp_c1_l2cache, "low_network_0", "50ps"), (comp_n0_bus, "high_network_1", "50ps") )
link_c2l2cache_bus = sst.Link("link_c2l2cache_bus")
link_c2l2cache_bus.connect( (comp_c2_l2cache, "low_network_0", "50ps"), (comp_n0_bus, "high_network_2", "50ps") )
link_c3l2cache_bus = sst.Link("link_c3l2cache_bus")
link_c3l2cache_bus.connect( (comp_c3_l2cache, "low_network_0", "50ps"), (comp_n0_bus, "high_network_3", "50ps") )
link_c4l2cache_bus = sst.Link("link_c4l2cache_bus")
link_c4l2cache_bus.connect( (comp_c4_l2cache, "low_network_0", "50ps"), (comp_n1_bus, "high_network_0", "50ps") )
link_c5l2cache_bus = sst.Link("link_c5l2cache_bus")
link_c5l2cache_bus.connect( (comp_c5_l2cache, "low_network_0", "50ps"), (comp_n1_bus, "high_network_1", "50ps") )
link_c6l2cache_bus = sst.Link("link_c6l2cache_bus")
link_c6l2cache_bus.connect( (comp_c6_l2cache, "low_network_0", "50ps"), (comp_n1_bus, "high_network_2", "50ps") )
link_c7l2cache_bus = sst.Link("link_c7l2cache_bus")
link_c7l2cache_bus.connect( (comp_c7_l2cache, "low_network_0", "50ps"), (comp_n1_bus, "high_network_3", "50ps") )
# link node buses to L3s and so on
link_n0bus_n0l3cache = sst.Link("link_n0bus_n0l3cache")
link_n0bus_n0l3cache.connect( (comp_n0_bus, "low_network_0", "50ps"), (comp_n0_l3cache, "high_network_0", "50ps") )
link_n0bus_memory = sst.Link("link_n0bus_memory")
link_n0bus_memory.connect( (comp_n0_l3cache, "directory", "50ps"), (comp_chipRtr, "port2", "10000ps") )
link_n1bus_n1l3cache = sst.Link("link_n1bus_n1l3cache")
link_n1bus_n1l3cache.connect( (comp_n1_bus, "low_network_0", "50ps"), (comp_n1_l3cache, "high_network_0", "50ps") )
link_n1bus_memory = sst.Link("link_n1bus_memory")
link_n1bus_memory.connect( (comp_n1_l3cache, "directory", "50ps"), (comp_chipRtr, "port3", "10000ps") )
link_dirctrl0_bus = sst.Link("link_dirctrl0_bus")
link_dirctrl0_bus.connect( (comp_chipRtr, "port0", "10000ps"), (comp_dirctrl0, "network", "50ps") )
link_dirctrl1_bus = sst.Link("link_dirctrl1_bus")
link_dirctrl1_bus.connect( (comp_chipRtr, "port1", "10000ps"), (comp_dirctrl1, "network", "50ps") )
link_dirctrl0_mem = sst.Link("link_dirctrl0_mem")
link_dirctrl0_mem.connect( (comp_dirctrl0, "memory", "50ps"), (comp_memory0, "direct_link", "50ps") )
link_dirctrl1_mem = sst.Link("link_dirctrl1_mem")
link_dirctrl1_mem.connect( (comp_dirctrl1, "memory", "50ps"), (comp_memory1, "direct_link", "50ps") )
# End of generated output.
