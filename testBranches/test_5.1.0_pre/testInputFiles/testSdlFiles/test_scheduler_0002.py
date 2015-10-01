# Automatically generated SST Python input
import sst
import os

# Define SST core options
sst.setProgramOption("timebase", "1 ps")
sst.setProgramOption("stopAtCycle", "0 ns")

# Define the simulation components
comp_scheduler = sst.Component("scheduler", "scheduler.schedComponent")
comp_scheduler.addParams({
      "YumYumPollWait" : """250""",
      "useYumYumSimulationKill" : """true""",
      "printJobLog" : """true""",
      "printYumYumJobLog" : """true""",
      "useYumYumTraceFormat" : """true""",
      "seed" : """42""",
      "jobLogFileName" : """test_scheduler_0002_joblog.csv""",
      "scheduler" : """easy[fifo]""",
      "traceName" : os.environ['SST_TEST_INPUTS'] + '/test_scheduler_0002_joblist.csv'
})
comp_s_1_1 = sst.Component("1.1", "scheduler.nodeComponent")
comp_s_1_1.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "nodeNum" : """0""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0\",\n      \"4.2_error\", \"0\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.1"""
})
comp_s_1_2 = sst.Component("1.2", "scheduler.nodeComponent")
comp_s_1_2.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "nodeNum" : """1""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0\",\n      \"4.2_error\", \"0\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.2"""
})
comp_s_1_3 = sst.Component("1.3", "scheduler.nodeComponent")
comp_s_1_3.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "nodeNum" : """2""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.3"""
})
comp_s_1_4 = sst.Component("1.4", "scheduler.nodeComponent")
comp_s_1_4.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "nodeNum" : """3""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.4"""
})
comp_s_1_5 = sst.Component("1.5", "scheduler.nodeComponent")
comp_s_1_5.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0\",\n      \"4.2_error\", \"0\"""",
      "nodeNum" : """4""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"1\",\n      \"4.2_error\", \"1\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.5"""
})
comp_s_1_6 = sst.Component("1.6", "scheduler.nodeComponent")
comp_s_1_6.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"0\",\n      \"4.2_error\", \"0\"""",
      "nodeNum" : """5""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"1\",\n      \"4.2_error\", \"1\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.6"""
})
comp_s_1_7 = sst.Component("1.7", "scheduler.nodeComponent")
comp_s_1_7.addParams({
      "nodeNum" : """6""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.7"""
})
comp_s_1_8 = sst.Component("1.8", "scheduler.nodeComponent")
comp_s_1_8.addParams({
      "nodeNum" : """7""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """1.8""",
      "errorCorrectionProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\""""
})
comp_s_2_1 = sst.Component("2.1", "scheduler.nodeComponent")
comp_s_2_1.addParams({
      "nodeNum" : """8""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0\",\n      \"4.2_error\", \"0\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """2.1"""
})
comp_s_2_2 = sst.Component("2.2", "scheduler.nodeComponent")
comp_s_2_2.addParams({
      "nodeNum" : """9""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"0.5\",\n      \"4.2_error\", \"0.5\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """2.2"""
})
comp_s_2_3 = sst.Component("2.3", "scheduler.nodeComponent")
comp_s_2_3.addParams({
      "nodeNum" : """10""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorMessageProbability" : """\"8.1_error\", \"1\",\n      \"4.2_error\", \"1\"""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """2.3""",
      "errorPropagationDelay" : """\"8.1_error\", \"0\", \"5\",\n      \"4.2_error\", \"0\", \"5\""""
})
comp_s_2_4 = sst.Component("2.4", "scheduler.nodeComponent")
comp_s_2_4.addParams({
      "jobFailureProbability" : """\"8.1_error\", \"1\",\n      \"4.2_error\", \"1\"""",
      "nodeNum" : """11""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """2.4""",
      "errorPropagationDelay" : """\"8.1_error\", \"7\", \"7\",\n      \"4.2_error\", \"7\", \"7\""""
})
comp_s_4_1 = sst.Component("4.1", "scheduler.nodeComponent")
comp_s_4_1.addParams({
      "nodeNum" : """12""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """4.1"""
})
comp_s_4_2 = sst.Component("4.2", "scheduler.nodeComponent")
comp_s_4_2.addParams({
      "nodeNum" : """13""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """4.2""",
      "faultActivationRate" : """\"4.2_error\",\"2\""""
})
comp_s_8_1 = sst.Component("8.1", "scheduler.nodeComponent")
comp_s_8_1.addParams({
      "nodeNum" : """14""",
      "faultLogFileName" : """test_scheduler_0002_faultlog.csv""",
      "errorLogFileName" : """test_scheduler_0002_errorlog.csv""",
      "type" : """node""",
      "id" : """8.1""",
      "faultActivationRate" : """\"8.1_error\",\"1\""""
})


# Define the simulation links
link_sched_1_1 = sst.Link("link_sched_1_1")
link_sched_1_1.connect( (comp_scheduler, "nodeLink0", "0ps"), (comp_s_1_1, "Scheduler", "0ps") )
link_sched_1_2 = sst.Link("link_sched_1_2")
link_sched_1_2.connect( (comp_scheduler, "nodeLink1", "0ps"), (comp_s_1_2, "Scheduler", "0ps") )
link_sched_1_3 = sst.Link("link_sched_1_3")
link_sched_1_3.connect( (comp_scheduler, "nodeLink2", "0ps"), (comp_s_1_3, "Scheduler", "0ps") )
link_sched_1_4 = sst.Link("link_sched_1_4")
link_sched_1_4.connect( (comp_scheduler, "nodeLink3", "0ps"), (comp_s_1_4, "Scheduler", "0ps") )
link_sched_1_5 = sst.Link("link_sched_1_5")
link_sched_1_5.connect( (comp_scheduler, "nodeLink4", "0ps"), (comp_s_1_5, "Scheduler", "0ps") )
link_sched_1_6 = sst.Link("link_sched_1_6")
link_sched_1_6.connect( (comp_scheduler, "nodeLink5", "0ps"), (comp_s_1_6, "Scheduler", "0ps") )
link_sched_1_7 = sst.Link("link_sched_1_7")
link_sched_1_7.connect( (comp_scheduler, "nodeLink6", "0ps"), (comp_s_1_7, "Scheduler", "0ps") )
link_sched_1_8 = sst.Link("link_sched_1_8")
link_sched_1_8.connect( (comp_scheduler, "nodeLink7", "0ps"), (comp_s_1_8, "Scheduler", "0ps") )
link_s_1_1_2_1 = sst.Link("link_s_1_1_2_1")
link_s_1_1_2_1.connect( (comp_s_1_1, "Parent0", "0ps"), (comp_s_2_1, "Child0", "0ps") )
link_s_1_2_2_1 = sst.Link("link_s_1_2_2_1")
link_s_1_2_2_1.connect( (comp_s_1_2, "Parent0", "0ps"), (comp_s_2_1, "Child1", "0ps") )
link_s_1_3_2_2 = sst.Link("link_s_1_3_2_2")
link_s_1_3_2_2.connect( (comp_s_1_3, "Parent0", "0ps"), (comp_s_2_2, "Child0", "0ps") )
link_s_1_4_2_2 = sst.Link("link_s_1_4_2_2")
link_s_1_4_2_2.connect( (comp_s_1_4, "Parent0", "0ps"), (comp_s_2_2, "Child1", "0ps") )
link_s_1_5_2_3 = sst.Link("link_s_1_5_2_3")
link_s_1_5_2_3.connect( (comp_s_1_5, "Parent0", "0ps"), (comp_s_2_3, "Child0", "0ps") )
link_s_1_6_2_3 = sst.Link("link_s_1_6_2_3")
link_s_1_6_2_3.connect( (comp_s_1_6, "Parent0", "0ps"), (comp_s_2_3, "Child1", "0ps") )
link_s_1_7_2_4 = sst.Link("link_s_1_7_2_4")
link_s_1_7_2_4.connect( (comp_s_1_7, "Parent0", "0ps"), (comp_s_2_4, "Child0", "0ps") )
link_s_1_8_2_4 = sst.Link("link_s_1_8_2_4")
link_s_1_8_2_4.connect( (comp_s_1_8, "Parent0", "0ps"), (comp_s_2_4, "Child1", "0ps") )
link_s_2_1_4_1 = sst.Link("link_s_2_1_4_1")
link_s_2_1_4_1.connect( (comp_s_2_1, "Parent0", "0ps"), (comp_s_4_1, "Child0", "0ps") )
link_s_2_2_4_1 = sst.Link("link_s_2_2_4_1")
link_s_2_2_4_1.connect( (comp_s_2_2, "Parent0", "0ps"), (comp_s_4_1, "Child1", "0ps") )
link_s_2_3_4_2 = sst.Link("link_s_2_3_4_2")
link_s_2_3_4_2.connect( (comp_s_2_3, "Parent0", "0ps"), (comp_s_4_2, "Child0", "0ps") )
link_s_2_4_4_2 = sst.Link("link_s_2_4_4_2")
link_s_2_4_4_2.connect( (comp_s_2_4, "Parent0", "0ps"), (comp_s_4_2, "Child1", "0ps") )
link_s_4_1_8_1 = sst.Link("link_s_4_1_8_1")
link_s_4_1_8_1.connect( (comp_s_4_1, "Parent0", "0ps"), (comp_s_8_1, "Child0", "0ps") )
link_s_4_2_8_1 = sst.Link("link_s_4_2_8_1")
link_s_4_2_8_1.connect( (comp_s_4_2, "Parent0", "0ps"), (comp_s_8_1, "Child1", "0ps") )
# End of generated output.
