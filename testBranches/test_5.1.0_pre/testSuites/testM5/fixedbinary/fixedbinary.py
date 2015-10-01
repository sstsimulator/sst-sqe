# Automatically generated SST Python input
import sst

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "100000s")

# Define the simulation components
comp_system = sst.Component("system", "m5C.M5")
comp_system.addParams({
      "debug" : """0""",
      "info" : """yes""",
      "configFile" : """fixedbinaryM5.xml""",
      "M5debug" : """none""",
      "registerExit" : """yes"""
})


# Define the simulation links
# End of generated output.
