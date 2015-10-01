# Automatically generated SST Python input
import sst

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "1000000ns")

# Define the simulation components
comp_system = sst.Component("system", "m5C.M5")
comp_system.addParams({
      "info" : """yes""",
      "M5debug" : """none""",
      "registerExit" : """yes""",
      "configFile" : """luleshM5.xml""",
      "statFile" : """lulesh.stats""",
      "debug" : """0"""
})


# Define the simulation links
# End of generated output.
