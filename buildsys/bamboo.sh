#!/bin/bash
# bamboo.sh

# Description:

# A shell script to command a build ala Jenkins

# Because there are pre-make steps that need to occur due to the use
# of the GNU Autotools, this script simplifies the build activation by
# consolidating the build steps.

# Jenkins will checkout sst-sqe containing this files and the deps 
# and test trees, from the githup repository prior to invocation of this
# script. Plow through the build, exiting if something goes wrong.

echo "************************ BAMBOO.SH STARTING ************************"
echo ' '
pwd
df -h .
echo ' '

#-------------------------------------------------------------------------
# Function: TimeoutEx
# Description:
#   Purpose:
#       This function is a wrapper Around the TimeoutEx.sh which will execute 
#       a command with a timeout 
#   Input:
#       $@: Variable number of parameters depending upon module command operation
#   Output: Any output from the command being run.
#   Return value: The return value of the command being run or !=0 to indicate 
#   a timeout or error.
TimeoutEx() {
    # Call (via "source") the moduleex.sh script with the passed in parameters  
    $SST_ROOT/../sqe/test/utilities/TimeoutEx.sh $@
    # Get the return value from the moduleex.sh
    return $retval  
}


cloneOtherRepos() {
##  Check out other repositories except second time on Make Dist test

if [ ! -d ../../distTestDir ] ; then
## if [[ ${SST_TEST_ROOT:+isSet} != isSet ]] ; then
    echo "PWD = `pwd`"

## Set the clone depth parameter
   _DEPTH_="--depth 1"
   if [[ ${SST_GIT_CLONE_DEPTH_PARAMETER:+isSet} == isSet ]] ; then
       if [ ${SST_GIT_CLONE_DEPTH_PARAMETER} == "none" ] ; then
           _DEPTH_=""
       else
           _DEPTH_="${SST_GIT_CLONE_DEPTH_PARAMETER}"
       fi
   fi
   echo " Cloning depth parameter set to \"${_DEPTH_}\""
## Cloning sst-core into <path>/devel/trunk   
   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      echo " "
      echo "     TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_COREBRANCH $SST_COREREPO sst-core "
      TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_COREBRANCH $SST_COREREPO sst-core
      retVal=$?
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of $SST_COREREPO \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf sst-core
             continue
         fi
         exit
      fi
   done
   echo " "
   echo " The sst-core Repo has been cloned."
   ls -l
   pushd sst-core
   
   # Test for override of the branch to some other SHA1 
   if [[ ${SST_CORE_RESET:+isSet} == isSet ]] ; then
       echo "     Desired sst-element SHA1 is ${SST_CORE_RESET}"
       git reset --hard ${SST_CORE_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_CORE_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi
   
   git log -n 1 | grep commit
   ls -l
   popd


## Cloning sst-elements into <path>/devel/trunk     
   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      date
      echo " "
      echo "     TimeoutEx -t 250 git clone ${_DEPTH_} -b $SST_ELEMENTSBRANCH $SST_ELEMENTSREPO sst-elements "
      date
      TimeoutEx -t 250 git clone ${_DEPTH_} -b $SST_ELEMENTSBRANCH $SST_ELEMENTSREPO sst-elements
      retVal=$?
      date
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of $SST_ELEMENTSREPO \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf sst-elements
             continue
         fi
 
         exit
      fi
   done
   echo " "
   echo " The sst-elements Repo has been cloned."
   ls -l
   pushd sst-elements

   # Test for override of the branch to some other SHA1 
   if [[ ${SST_ELEMENTS_RESET:+isSet} == isSet ]] ; then
       echo "     Desired sst-element SHA1 is ${SST_ELEMENTS_RESET}"
       git reset --hard ${SST_ELEMENTS_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_ELEMENTS_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi

   git log -n 1 | grep commit
   ls -l
   popd
   
## Cloning sst-macro into <path>/devel/trunk     
   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      date
      echo " "
      echo "     TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_MACROBRANCH $SST_MACROREPO sst-macro "
      date
      TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_MACROBRANCH $SST_MACROREPO sst-macro
      retVal=$?
      date
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of $SST_MACROREPO \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf sst-macro
             continue
         fi
 
         exit
      fi
   done
   echo " "
   echo " The sst-macro Repo has been cloned."
   ls -l
   pushd sst-macro

   # Test for override of the branch to some other SHA1 
   if [[ ${SST_MACRO_RESET:+isSet} == isSet ]] ; then
       echo "     Desired sst-macro SHA1 is ${SST_MACRO_RESET}"
       git reset --hard ${SST_MACRO_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_MACRO_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi

   git log -n 1 | grep commit
   ls -l
   popd
   
## Cloning sst-external-element into <path>/devel/trunk     
   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      date
      echo " "
      echo "     TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_EXTERNALELEMENTBRANCH $SST_EXTERNALELEMENTREPO sst-external-element "
      date
      TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_EXTERNALELEMENTBRANCH $SST_EXTERNALELEMENTREPO sst-external-element
      retVal=$?
      date
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of https://github.com/sstsimulator/sst-external-element.git \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf sst-external-element
             continue
         fi
 
         exit
      fi
   done
   echo " "
   echo " The sst-external-element Repo has been cloned."
   ls -l
   pushd sst-external-element

   # Test for override of the branch to some other SHA1 
   if [[ ${SST_EXTERNALELEMENT_RESET:+isSet} == isSet ]] ; then
       echo "     Desired sst-external-element SHA1 is ${SST_EXTERNALELEMENT_RESET}"
       git reset --hard ${SST_EXTERNALELEMENT_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_EXTERNALELEMENT_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi

   git log -n 1 | grep commit
   ls -l
   popd
   
## Cloning juno into <path>/devel/trunk     
   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      date
      echo " "
      echo "     TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_JUNOBRANCH $SST_JUNOREPO juno "
      date
      TimeoutEx -t 90 git clone ${_DEPTH_} -b $SST_JUNOBRANCH $SST_JUNOREPO juno
      retVal=$?
      date
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of https://github.com/sstsimulator/juno.git \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf juno
             continue
         fi
 
         exit
      fi
   done
   echo " "
   echo " The juno Repo has been cloned."
   ls -l
   pushd juno

   # Test for override of the branch to some other SHA1 
   if [[ ${SST_JUNO_RESET:+isSet} == isSet ]] ; then
       echo "     Desired JUNO SHA1 is ${SST_JUNO_RESET}"
       git reset --hard ${SST_JUNO_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_JUNO_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi

   git log -n 1 | grep commit
   ls -l
   popd
   
# Link the deps and test directories to the trunk   
   echo " Creating Symbolic Links to the sqe directories (deps & test)"
   ls -l
   ln -s `pwd`/../sqe/buildsys/deps .
   ln -s `pwd`/../sqe/test .
   ls -l
# Define the path to the Elements Reference files
   export SST_REFERENCE_ELEMENTS=$SST_ROOT/sst-elements/src/sst/elements
fi

echo "#### FINISHED SETTING UP DIRECTORY STRUCTURE  ########"
}
#=========================================================================
#Functions
#=========================================================================

#-------------------------------------------------------------------------
# Function: dotests
# Description:
#   Purpose:
#       Based on build type and architecture, run tests
#   Input:
#       $1 (build type): kind of build to run tests for
#   Output: none
#   Return value: 0 if success
###-BEGIN-DOTESTS
dotests() {
    # Build type is available as SST_BUILD_TYPE global, if
    # needed to be selective about the tests that are run.

    # NOTE: Bamboo does a fresh checkout of code each time, so there
    # are no residuals left over from the last build. The directories
    # initialized here are ephemeral, and not kept in CM/SVN.

    #  Want to remove the external environment variables that have been added
    #  in bamboo to the LD_LIBRARY_PATH.
    #  For the tests, they should come from the sst wrapper not from bamboo.sh!
    #    May 2015 - is believed only CHDL and hybridsim tests require the 
    #               SST_DEPS_INSTAL_xxxx `external element environment variables.

    #  Second parameter is compiler choice, if non-default.
    #  If it is Intel, Need a GCC library also
    #    Going to load the gcc-4.8.1 module for now

   echo "-- Number processers"
   if [ `uname` == "Darwin" ] ; then
       sysctl -n hw.ncpu
   else
       grep -c processor /proc/cpuinfo
   fi
   echo ' '
   
   ps -ef | grep omp | grep -v comp

   if [[ ${SST_TEST_WITH_NO_ELEMENTS_WRITE:+isSet} == isSet ]] ; then
       echo "#################################################### "
       echo ' '
       echo "     ENFORCING no write to elements by SQE tests"
       echo ' '
       echo "#################################################### "
       chmod -w -R $SST_ROOT/sst-elements/src/sst/elements
   fi
   echo "bamboo.sh: This directory is:"
   pwd
   echo "bamboo.sh: ls test/include"
   ls test/include
   echo "bamboo.sh: Sourcing test/include/testDefinitions.sh"
   . test/include/testDefinitions.sh
   echo "bamboo.sh: Done sourcing test/include/testDefinitions.sh"
 
   export JENKINS_PROJECT=`echo $WORKSPACE | awk -F'/' '{print $6}'`
   export BAMBOO_SCENARIO=$1

echo " #####################################################"
   echo "parameter \$2 is $2  "
echo " #####################################################"

    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ||
       [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] ; then
    #    This subroutine is in test/include/testDefinitions.sh
    #    (It is a subroutine, but testSubroutines is only sourced
    #        into test Suites, not bamboo.sh.
         multithread_multirank_patch_Suites
    fi
    #    The following is to include the map-by numa parameter
    export NUMA_PARAM=" "
    if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
           set_map-by_parameter
    fi
    #       Recover library path
    export LD_LIBRARY_PATH=$SAVE_LIBRARY_PATH
    export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH 

    echo "     LD_LIBRARY_PATH includes:"
    echo $LD_LIBRARY_PATH | sed 's/:/\n/g'
    echo ' '

    # Initialize directory to hold testOutputs
    rm -Rf ${SST_TEST_OUTPUTS}
    mkdir -p ${SST_TEST_OUTPUTS}

    # Initialize directory to hold Bamboo-compatible XML test results
    rm -Rf ${SST_TEST_RESULTS}
    mkdir -p ${SST_TEST_RESULTS}

    # Initialize directory to hold temporary test input files
    rm -Rf ${SST_TEST_INPUTS_TEMP}
    mkdir -p ${SST_TEST_INPUTS_TEMP}
   
    # Do we run the Macro Tests    
    if [ $1 == "sst-macro_withsstcore_mac" ]   || [ $1 == "sst-macro_nosstcore_mac" ] ||
       [ $1 == "sst-macro_withsstcore_linux" ] || [ $1 == "sst-macro_nosstcore_linux" ] ; then
        ${SST_TEST_SUITES}/testSuite_macro.sh
        # We currently dont want to run any other tests
        return
    fi    

    if [[ $1 == *sstmainline_config_valgrind* ]] ; then
        
        echo "                   module list"
        ModuleEx list
        
        ####   export variables  Library path, PATH, SST_ROOT, SST_TEST_ROOT
        #
        echo $LD_LIBRARY_PATH | grep /usr/local/lib
        if [ $? != 0 ]
        then
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
        fi
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SST_BASE/local/sst-core/lib
        ##     Source the install location variables from the build
        . ../../SST_deps_env.sh

##    GEM5SST, QSIM and CHDL have been omitted from this list

        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SST_DEPS_INSTALL_DRAMSIM:$SST_DEPS_INSTALL_HYBRIDSIM:$SST_DEPS_INSTALL_NVDIMMSIM:$SST_DEPS_INSTALL_GOBLIN_HMCSIM

        if [ `uname` == "Darwin" ] 
        then
           export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH
        fi
         
        export PATH=/home/jpvandy/bin:$PATH:$SST_INSTALL_BIN_USER
        
        export SST_ROOT=$SST_BASE/devel/trunk
        
        export SST_TEST_ROOT=`pwd`/test
        ####    Source the testDefinitions
        . test/include/testDefinitions.sh
        
        echo ' '; echo "Inserting Valgrind commands" ; echo ' '
        ./test/utilities/insertValgrind

     #   Only run EmberSweep in Valgrind if explict request.
     #       In that case run only EmberSweep Suite.
        if [[ $1 == "sstmainline_config_valgrind_ES" ]] ; then
            ${SST_TEST_SUITES}/testSuite_EmberSweep.sh
            return
        fi
        if [[ $1 == "sstmainline_config_valgrind_ES2" ]] ; then
            ${SST_TEST_SUITES}/testSuite_ES2.sh
            return
        fi
    fi

    if [[ $1 == *sstmainline_config_test_output_config* ]]
    then
        ./test/utilities/Build-output-config-check
        pwd
        ls -l run.for.output.config
        ./run.for.output.config
        return
    fi

    #   Enable the --output-config option in (most) tests
    #      (activated by Environment Variable)

    if [[ ${SST_TEST_OUTPUT_CONFIG:+isSet} == isSet ]] ; then
        echo ' '; echo "Generating \"--output-config\" test" ; echo ' '
        ./test/utilities/GenerateOutputConfigTest
    fi

    # Run test suites


    # DO NOT pass args to the test suite, it confuses
    # shunit. Use an environment variable instead.

      if [ $1 == "sstmainline_config_all" ] ; then 

         pushd ${SST_ROOT}/test/testSuites
         echo \$SST_TEST_SUITES = $SST_TEST_SUITES
         echo "     Content of file, SuitesToOmitFromAll"
         cat SuitesToOmitFromAll
         echo ' '
         ## strip any comment off
         cat SuitesToOmitFromAll | awk  '{print $1}' > __omitlist__        
         echo "      Suites to explictly OMIT from the \"all\" scenario:"
         ls testSuite_*sh | grep  -f __omitlist__
         echo ' '
         #   Build the Suite list for the "All" scenario
         ls testSuite_*sh | grep -v -f __omitlist__ > Suite.list
         echo "all() {" > files.for.all
         sed  s\%^%\${SST_TEST_SUITES}/% Suite.list >> files.for.all
         echo "}" >> files.for.all
         . files.for.all               # Source the subroutine including list
         popd
         all
         return
    fi

    if [ $1 == "sstmainline_config_no_gem5" ] ; then
        ${SST_TEST_SUITES}/testSuite_Ariel.sh
    fi
 
    #
    #  Run only Streams test only
    #
    if [ $1 == "sstmainline_config_stream" ]
    then
        ${SST_TEST_SUITES}/testSuite_stream.sh
        return
    fi

    #
    #  Run only openMP 
    #
    if [ $1 == "sstmainline_config_openmp" ]
    then
        ${SST_TEST_SUITES}/testSuite_Sweep_openMP.sh
        return
    fi

    #
    #  Run only dirSweep3Cache
    #
    if [ $1 == "sstmainline_config_dir3cache" ]
    then
        ${SST_TEST_SUITES}/testSuite_dir3LevelSweep.sh
        return
    fi

    #
    #  Run only diropenMP 
    #
    if [ $1 == "sstmainline_config_diropenmp" ]
    then
        ${SST_TEST_SUITES}/testSuite_dirSweep.sh
        return
    fi

    #
    #  Run only dirSweepB
    #
    if [ $1 == "sstmainline_config_diropenmpB" ]
    then
        ${SST_TEST_SUITES}/testSuite_dirSweepB.sh
        return
    fi

    #
    #  Run only dirSweepI
    #
    if [ $1 == "sstmainline_config_diropenmpI" ]
    then
        ${SST_TEST_SUITES}/testSuite_dirSweepI.sh
        return
    fi

    #
    #  Run only dir Non Cacheable
    #
    if [ $1 == "sstmainline_config_dirnoncacheable" ]
    then
        ${SST_TEST_SUITES}/testSuite_dirnoncacheable_openMP.sh
        return
    fi

    #
    #  Run only openMP and memHierarchy 
    #
    if [ $1 == "sstmainline_config_memH_only" ]
    then
        ${SST_TEST_SUITES}/testSuite_openMP.sh
        ${SST_TEST_SUITES}/testSuite_memHierarchy_bin.sh
        return
    fi

    #
    #   Test for the new memH via Ariel testing
    #
    #   With optional split into two tests
    #
    if [ $1 == "sstmainline_config_memH_Ariel" ]
    then
        GROUP=0
        if [[ ${SST_SWEEP_SPLIT:+isSet} == isSet ]] ; then
            GROUP=${SST_SWEEP_SPLIT}
        fi
        if [ $GROUP != 2 ] ; then
            ${SST_TEST_SUITES}/testSuite_openMP.sh
            ${SST_TEST_SUITES}/testSuite_diropenMP.sh
            ${SST_TEST_SUITES}/testSuite_dirSweepB.sh
            ${SST_TEST_SUITES}/testSuite_dirSweep.sh
        fi
        if [ $GROUP == 1 ] ; then 
            return
        fi
        ${SST_TEST_SUITES}/testSuite_dirnoncacheable_openMP.sh
        ${SST_TEST_SUITES}/testSuite_noncacheable_openMP.sh
        ${SST_TEST_SUITES}/testSuite_dirSweepI.sh
        ${SST_TEST_SUITES}/testSuite_Sweep_openMP.sh
        ${SST_TEST_SUITES}/testSuite_dir3LevelSweep.sh
        return
    fi

     #
     #   Suites that used MemHierarchy, but not openMP
     #

    if [ $1 == "sstmainline_config_memH_wo_openMP" ]
    then
        if [[ $SST_ROOT == *Ariel* ]] ; then
            pushd ${SST_TEST_SUITES}
            ln -s ${SST_TEST_SUITES}/testSuite_Ariel.sh testSuite_Ariel_extra.sh
            ${SST_TEST_SUITES}/testSuite_Ariel_extra.sh
            popd
        fi
        export SST_BUILD_PROSPERO_TRACE_FILE=1
        pushd ${SST_TEST_SUITES}
          ln -s ${SST_TEST_SUITES}/testSuite_prospero.sh testSuite_prospero_pin.sh
          ${SST_TEST_SUITES}/testSuite_prospero_pin.sh
          unset SST_BUILD_PROSPERO_TRACE_FILE
        popd
        ${SST_TEST_SUITES}/testSuite_SiriusZodiacTrace.sh
        ${SST_TEST_SUITES}/testSuite_embernightly.sh
        ${SST_TEST_SUITES}/testSuite_BadPort.sh
        ${SST_TEST_SUITES}/testSuite_memHierarchy_sdl.sh
        ${SST_TEST_SUITES}/testSuite_memHA.sh
        ${SST_TEST_SUITES}/testSuite_memHSieve.sh
        ${SST_TEST_SUITES}/testSuite_CramSim.sh
        ${SST_TEST_SUITES}/testSuite_hybridsim.sh
        ${SST_TEST_SUITES}/testSuite_miranda.sh
        ${SST_TEST_SUITES}/testSuite_cassini_prefetch.sh
        ${SST_TEST_SUITES}/testSuite_prospero.sh
        ${SST_TEST_SUITES}/testSuite_Ariel.sh
        return
    fi
    
    PATH=${PATH}:${SST_ROOT}/../sqe/test/utilities
    if [ $1 == "sstmainline_config_develautotester_linux" ] ; then
        $SST_ROOT/../sqe/test/utilities/invokeSuite memHierarchy_sdl 2 2 all autotest_multirank_plus_multithread_2x2
        invokeSuite ES2     2 2 ES2=1:106  autotest_multirank_plus_multithread
        invokeSuite merlin  2 2 dragon_128 autotest_multirank_plus_multithread
        invokeSuite CramSim 2 2 4_         autotest_multirank_plus_multithread
    fi
    
    if [ $1 == "sstmainline_config_develautotester_mac" ] ; then
        $SST_ROOT/../sqe/test/utilities/invokeSuite memHierarchy_sdl 2 2 all autotest_multirank_plus_multithread_2x2
        invokeSuite ES2     2 2 ES2=1:106  autotest_multirank_plus_multithread
        invokeSuite merlin  2 2 dragon_128 autotest_multirank_plus_multithread
        invokeSuite CramSim 2 2 4_         autotest_multirank_plus_multithread
    fi
    
    ${SST_TEST_SUITES}/testSuite_Ariel.sh
    ${SST_TEST_SUITES}/testSuite_juno.sh
    ${SST_TEST_SUITES}/testSuite_Samba.sh
    ${SST_TEST_SUITES}/testSuite_Messier.sh
    ${SST_TEST_SUITES}/testSuite_CramSim.sh
    ${SST_TEST_SUITES}/testSuite_hybridsim.sh
    ${SST_TEST_SUITES}/testSuite_SiriusZodiacTrace.sh
    ${SST_TEST_SUITES}/testSuite_memHierarchy_sdl.sh
    ${SST_TEST_SUITES}/testSuite_memHA.sh
    ${SST_TEST_SUITES}/testSuite_memHSieve.sh


    ${SST_TEST_SUITES}/testSuite_simpleComponent.sh
    ${SST_TEST_SUITES}/testSuite_sstexternalelement.sh
    ${SST_TEST_SUITES}/testSuite_sst_info_test.sh
    ${SST_TEST_SUITES}/testSuite_simpleLookupTableComponent.sh
    ${SST_TEST_SUITES}/testSuite_cacheTracer.sh
    ${SST_TEST_SUITES}/testSuite_miranda.sh
    ${SST_TEST_SUITES}/testSuite_BadPort.sh
    ${SST_TEST_SUITES}/testSuite_scheduler.sh
    ${SST_TEST_SUITES}/testSuite_scheduler_DetailedNetwork.sh

    # Add other test suites here, i.e.
    # ${SST_TEST_SUITES}/testSuite_moe.sh
    # ${SST_TEST_SUITES}/testSuite_larry.sh
    # ${SST_TEST_SUITES}/testSuite_curly.sh
    # ${SST_TEST_SUITES}/testSuite_shemp.sh
    # etc.

    ${SST_TEST_SUITES}/testSuite_merlin.sh
    ${SST_TEST_SUITES}/testSuite_embernightly.sh
 
    ${SST_TEST_SUITES}/testSuite_simpleSimulation_CarWash.sh
    ${SST_TEST_SUITES}/testSuite_simpleDistribComponent.sh

    # Only run EmberSweep with valgrind with explict request.
    #    Valgrind on 180 test Suite takes 15 hours. (Aug. 2016)
    if [[ $1 != "sstmainline_config_valgrind" ]] ; then
       ${SST_TEST_SUITES}/testSuite_EmberSweep.sh
       ${SST_TEST_SUITES}/testSuite_ES2.sh
    fi

    if [ $1 != "sstmainline_config_no_mpi" ] && [[ $1 != "sstmainline_config_valgrind" ]] ; then
        #  Zoltan test requires MPI to execute.
        #  sstmainline_config_no_gem5 deliberately omits Zoltan, so must skip test.
        #  Valgrind test as inserted here is incompatible with partitioning tests.
        if [ $1 != "sstmainline_config_linux_with_ariel" ] ; then
            ${SST_TEST_SUITES}/testSuite_zoltan.sh
            ${SST_TEST_SUITES}/testSuite_partitioner.sh
        fi
    fi
    ${SST_TEST_SUITES}/testSuite_simpleRNGComponent.sh
    ${SST_TEST_SUITES}/testSuite_simpleStatisticsComponent.sh
      
    if [[ ${INTEL_PIN_DIRECTORY:+isSet} == isSet ]] ; then
        export SST_BUILD_PROSPERO_TRACE_FILE=1
        pushd ${SST_TEST_SUITES}
          ln -s ${SST_TEST_SUITES}/testSuite_prospero.sh testSuite_prospero_pin.sh
          ${SST_TEST_SUITES}/testSuite_prospero_pin.sh
          unset SST_BUILD_PROSPERO_TRACE_FILE
        popd
    fi
    ${SST_TEST_SUITES}/testSuite_prospero.sh
#
    ${SST_TEST_SUITES}/testSuite_check_maxrss.sh
    ${SST_TEST_SUITES}/testSuite_cassini_prefetch.sh
    ${SST_TEST_SUITES}/testSuite_simpleMessageGeneratorComponent.sh
    ${SST_TEST_SUITES}/testSuite_VaultSim.sh

    # Purge SST installation
    if [[ ${SST_RETAIN_BIN:+isSet} != isSet ]]
    then
        rm -Rf ${SST_INSTALL}
    fi

}
###-END-DOTESTS

#-------------------------------------------------------------------------
# Function: ModuleEx
# Description:
#   Purpose:
#       This funciton is a wrapper Around the moduleex.sh command which wraps the module 
#       command used to load/unload  external dependancies.  All calls to module should be 
#       redirected to this function.  If a failure is detected in the module command, it will be
#       noted and this function will cause the bamboo script to exit with the error code.
#   Input:
#       $@: Variable number of parameters depending upon module command operation
#   Output: Any output from the module command.
#   Return value: 0 on success, On error, bamboo.sh will exit with the moduleex.sh error code.
ModuleEx() {
    # Call (via "source") the moduleex.sh script with the passed in parameters  
    . $SST_ROOT/test/utilities/moduleex.sh $@
    # Get the return value from the moduleex.sh
    retval=$?
    if [ $retval -ne 0 ] ; then
        echo "ERROR: 'module' failed via script $SST_ROOT/test/utilities/moduleex.sh with retval= $retval; bamboo.sh exiting"
        exit $retval
    fi
    return $retval  
}

#-------------------------------------------------------------------------
# Function: setConvenienceVars
# Description:
#   Purpose:
#       set convenience vars
#   Input:
#       $1 (depsStr): selected dependencies
#   Output: string containing 'configure' parameters
#   Return value: none
setConvenienceVars() {
    # generate & load convenience variables
    echo "setConvenienceVars() : input = ($1), capturing to SST_deps_env.sh..."
    $SST_DEPS_BIN/sstDependencies.sh $1 queryEnv > $SST_BASE/SST_deps_env.sh
    . $SST_BASE/SST_deps_env.sh
    echo "setConvenienceVars() : SST_deps_env.sh file contents"
    echo "startfile-----"
    cat $SST_BASE/SST_deps_env.sh
    echo "endfile-------"
    echo "setConvenienceVars() : exported variables"
    export | egrep SST_DEPS_
    corebaseoptions="--disable-silent-rules --prefix=$SST_CORE_INSTALL"
    elementsbaseoptions="--disable-silent-rules --prefix=$SST_ELEMENTS_INSTALL --with-sst-core=$SST_CORE_INSTALL"
    macrobaseoptions="--disable-silent-rules --prefix=$SST_CORE_INSTALL"
    externalelementbaseoptions=""
    junobaseoptions=""
    echo "setConvenienceVars() : " 
    echo "           corebaseoptions = $corebaseoptions"
    echo "       elementsbaseoptions = $elementsbaseoptions"
    echo "          macrobaseoptions = $macrobaseoptions"
    echo "externalelementbaseoptions = $externalelementbaseoptions"
    echo "           junobaseoptions = $junobaseoptions"
}

#-------------------------------------------------------------------------
# Function: getconfig
# Description:
#   Purpose:
#       Based on build config and architecture, generate 'configure'
#       parameters.
#   Input:
#       $1 (build configuration): name of build configuration
#       $2 (architecture): build platform architecture from uname
#       $3 (os): operating system name
#   Output: string containing 'configure' parameters
#   Return value: none
getconfig() {

    # Configure default dependencies to use if nothing is explicitly specified
    local defaultDeps="-k default -d default -p default -z default -b default -g default -m default -i default -o default -h default -s none -q none"

    local depsStr=""

    # Determine compilers
    local mpicc_compiler=`which mpicc`
    local mpicxx_compiler=`which mpicxx`

    if [[ ${CC:+isSet} = isSet ]]
    then
        local cc_compiler=$CC
    else
        local cc_compiler=`which gcc`
    fi

    if [[ ${CXX:+isSet} = isSet ]]
    then
        local cxx_compiler=$CXX
    else
        local cxx_compiler=`which g++`
    fi

    local cc_environment="CC=${cc_compiler} CXX=${cxx_compiler}"
    local mpi_environment="MPICC=${mpicc_compiler} MPICXX=${mpicxx_compiler}"

#    # make sure that sstmacro is suppressed
#    if [ -e ./sst/elements/macro_component/.unignore ] && [ -f ./sst/elements/macro_component/.unignore ]
#    then
#        rm ./sst/elements/macro_component/.unignore
#    fi


    case $1 in
        sstmainline_config) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}   --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_all) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-libphx=$LIBPHX_HOME/src --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-metis=${METIS_HOME}   $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_stream|sstmainline_config_openmp|sstmainline_config_diropenmp|sstmainline_config_diropenmpB|sstmainline_config_diropenmpI|sstmainline_config_dirnoncacheable|sstmainline_config_dir3cache|sstmainline_config_memH_Ariel) 
            #-----------------------------------------------------------------
            # sstmainline_config  One only of stream, openmp diropemMP
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z none -g none -m none -i none -o none -h none -s none -M none -N default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_linux_with_ariel_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_linux_with_ariel_no_gem5
            #     This option used for configuring SST with supported stabledevel deps,
            #     Intel PIN, and Ariel, but without Gem5 
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z 3.83 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-metis=${METIS_HOME} $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_no_gem5
            #     This option used for configuring SST with supported stabledevel deps
            #     Some compilers (gcc 4.7, 4.8, intel 13.4) have problems building gem5,
            #     so this option removes gem5 in order to evaluate the rest of the build
            #     under those compilers.
            #-----------------------------------------------------------------
            ### touch sst/elements/ariel/.ignore
            ls -a sst-elements/src/sst/elements/ariel
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}  $elementsMiscEnv --with-pin=$SST_DEPS_INSTALL_INTEL_PIN"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_no_mpi)
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with MPI disabled
            #-----------------------------------------------------------------
            if [[ ${MPIHOME:+isSet} == isSet ]] ; then
                echo ' ' ; echo " Test is flawed!  MPI module is loaded!" ; echo ' '
                exit 1
            fi
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z none -g none -m none -i none -o none -h none -s none -q none  -M none -N default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv --disable-mpi"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM $elementsMiscEnv  --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_static
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-metis=${METIS_HOME} $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_static_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_static   WITH OUT GEM5
            #     This option used for configuring a static SST without Gem5
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-metis=${METIS_HOME} --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_clang_core_only) 
            #-----------------------------------------------------------------
            # sstmainline_config_clang_core_only
            #     This option used for configuring SST with no deps to build the core with clang
            #-----------------------------------------------------------------
            depsStr="-G default -k none -d 2.2.2 -p none -z none -g none -m none -i none -o none -h none -s none -q none -M none -N default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_macosx) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g stabledevel -m none -i none -o none -h none -s none -q none -z 3.83 -N default -M 2.2.0"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME} $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_macosx_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_no_gem5
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z 3.83  -g none -m none -i none -o none -h none -s none -q none -M none -N default -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions ${MTNLION_FLAG} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM ${MTNLION_FLAG} --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}  --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_macosx_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_static
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g stabledevel -m none -i none -o none -h none -s none -q none -z 3.83 -N default -M 2.2.0"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions  --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-metis=${METIS_HOME} $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_test_output_config)
            #-----------------------------------------------------------------
            # sstmainline_config_test_output_config
            #     This option used for verifying the SST "--output-config" option
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-qsim=$SST_DEPS_INSTALL_QSIM $elementsMiscEnv --with-pin=$SST_DEPS_INSTALL_INTEL_PIN"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_memH_wo_openMP)
            #-----------------------------------------------------------------
            # sstmainline_config_memH_wo_openMP
            #     This option used for configuring SST with memHierarchy, but with out open MP
            #     with Intel PIN, and Ariel 
            #     (Might as well skip building scheduler)
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            touch sst-elements/src/sst/elements/scheduler/.ignore
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z none -m none -o none -h none -s none -q none -M none -N default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_develautotester_linux)
            #-----------------------------------------------------------------
            # sstmainline_config_develautotester_linux
            #     THIS IS THE CONFIGURATION USED FOR THE DEVEL AUTOTESTER, THE
            #     BUILD AND TESTS SHOULD BE AS QUICK AS POSSIBLE, WE ARE WILLING
            #     TO SACRIFICE SOME COVERAGE TO GET A GENERAL WARM FUZZY ON THE 
            #     PULL REQUESTS TO DEVEL BRANCH BEING NOT CATASTROPIC FAILURES
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}   --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_develautotester_mac)
            #-----------------------------------------------------------------
            # sstmainline_config_develautotester_mac
            #     THIS IS THE CONFIGURATION USED FOR THE DEVEL AUTOTESTER, THE
            #     BUILD AND TESTS SHOULD BE AS QUICK AS POSSIBLE, WE ARE WILLING
            #     TO SACRIFICE SOME COVERAGE TO GET A GENERAL WARM FUZZY ON THE 
            #     PULL REQUESTS TO DEVEL BRANCH BEING NOT CATASTROPIC FAILURES
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -z 3.83  -g none -m none -i none -o none -h none -s none -q none -M none -N default -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions ${MTNLION_FLAG} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM ${MTNLION_FLAG} --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}  --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
            
        # ====================================================================
        # ====                                                            ====
        # ====  Experimental/exploratory build configurations start here  ====
        # ====                                                            ====
        # ====================================================================
        sstmainline_config_dist_test|sstmainline_config_make_dist_no_gem5)
            #-----------------------------------------------------------------
            # sstmainline_config_dist_test
            #      Do a "make dist"  (creating a tar file.)
            #      Then,  untar the created tar-file.
            #      Invoke bamboo.sh, (this file), to build sst from the tar.  
            #            Yes, bamboo invoked from bamboo.
            #      Finally, run tests to validate the created sst.
            #-----------------------------------------------------------------
            depsStr="-d none -g none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="$elementsbaseoptions  --with-glpk=${GLPK_HOME} --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-metis=${METIS_HOME}"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
            
        sstmainline_config_valgrind|sstmainline_config_valgrind_ES|sstmainline_config_valgrind_ES2) 
            #-----------------------------------------------------------------
            # sstmainline_config_valgrind
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-G default -k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-metis=${METIS_HOME}   --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sst-macro_withsstcore_mac) 
            #-----------------------------------------------------------------
            # macro_withsstcore
            #     This option used for configuring sst-core and sst-macro
            #     NOTE: sst-macro is built with sst-core integration
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${cc_environment} ${mpi_environment}"
            depsStr="-G default -k none -d none -p none -g none -m none -i none -o none -h none -s none -q none -M none -N one -z none -c none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$macrobaseoptions"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which clang` CXX=`which clang++` --with-pth=$PTH_HOME --disable-regex --with-sst-core=$SST_CORE_INSTALL"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;
   
        sst-macro_nosstcore_mac) 
            #-----------------------------------------------------------------
            # macro_nosstcore
            #     This option used for configuring sst-core and sst-macro
            #     NOTE: sst-macro is NOT built with sst-core integration (using standalone integration)
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${cc_environment} ${mpi_environment}"
            depsStr="-G default -k none -d none -p none -g none -m none -i none -o none -h none -s none -q none -M none -N one -z none -c none"
            setConvenienceVars "$depsStr"
            coreConfigStr="NOBUILD"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which clang` CXX=`which clang++` --with-pth=$PTH_HOME --disable-regex"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;
   
        sst-macro_withsstcore_linux) 
            #-----------------------------------------------------------------
            # macro_withsstcore
            #     This option used for configuring sst-core and sst-macro
            #     NOTE: sst-macro is built with sst-core integration
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${cc_environment} ${mpi_environment}"
            depsStr="-G default -k none -d none -p none -g none -m none -i none -o none -h none -s none -q none -M none -N one -z none -c none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$macrobaseoptions"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which gcc` CXX=`which g++` --disable-regex --disable-unordered-containers --with-sst-core=$SST_CORE_INSTALL"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;
   
        sst-macro_nosstcore_linux) 
            #-----------------------------------------------------------------
            # macro_nosstcore
            #     This option used for configuring sst-core and sst-macro
            #     NOTE: sst-macro is NOT built with sst-core integration (using standalone integration)
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${cc_environment} ${mpi_environment}"
            depsStr="-G default -k none -d none -p none -g none -m none -i none -o none -h none -s none -q none -M none -N one -z none -c none"
            setConvenienceVars "$depsStr"
            coreConfigStr="NOBUILD"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which gcc` CXX=`which g++` --disable-regex --disable-unordered-containers"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;
            
  ## perhaps do no more here
        default)
            #-----------------------------------------------------------------
            # default
            #     Do the default build. But this is probably not what you want!
            #-----------------------------------------------------------------
            depsStr="$defaultDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="$elementsbaseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        *)
            #-----------------------------------------------------------------
            #  Unrecognized Scenario,  This is an error in the bamboo code
            #-----------------------------------------------------------------
            echo ' ' ; echo "Unrecognized Scenario,  This is an error in the bamboo code"
            echo " UNRECOGNIZED:   ${1}"
            exit 1            
            ;;
    esac

    export SST_SELECTED_DEPS="$depsStr"
    export SST_SELECTED_CORE_CONFIG="$coreConfigStr"
    export SST_SELECTED_ELEMENTS_CONFIG="$elementsConfigStr"
    export SST_SELECTED_MACRO_CONFIG="$macroConfigStr"
    export SST_SELECTED_EXTERNALELEMENT_CONFIG="$externalelementConfigStr"
    export SST_SELECTED_JUNO_CONFIG="$junoConfigStr"
}


#-------------------------------------------------------------------------
# Function: linuxSetBoostMPI
# Description:
#   Purpose: Performs selection and loading of Bost and MPI modules
#            for Linux
#   Input:
#      $1 - Bamboo Project
#      $2 - mpi request
#      $3 - boost  request
#      $4   compiler (optional)
#   Output:
#   Return value:
linuxSetBoostMPI() {

   if [[ ${SST_STOP_AFTER_BUILD:+isSet} != isSet ]] ; then
      # For some reason, .bashrc is not being run prior to
      # this script. Kludge initialization of modules.
   
      echo "Attempt to initialize the modules utility.  Look for modules init file in 1 of 2 places"
      
      echo "Location 1: ls -l /etc/profile.modules"
      ls -l /etc/profile.modules
      if [ -f /etc/profile.modules ] ; then
          . /etc/profile.modules
          echo "bamboo.sh: loaded /etc/profile.modules"
      else
          echo "Location 2: ls -l /etc/profile.d/modules.sh"
          ls -l /etc/profile.d/modules.sh
          if [ -r /etc/profile.d/modules.sh ] ; then 
              source /etc/profile.d/modules.sh 
              echo "bamboo.sh: loaded /etc/profile.d/modules"
          fi
      fi
   fi
   
   echo "Testing modules utility via ModuleEx..."
   echo "ModuleEx avail"
   ModuleEx avail
   if [ $? -ne 0 ] ; then
       echo " ModuleEx Failed"
       exit 1
   fi    

   # build MPI and Boost selectors
   if [[ "$2" =~ openmpi.* ]]
   then
       # since Boost flavor labeled with "ompi" not "openmpi"
       mpiStr="ompi-"$(expr "$2" : '.*openmpi-\([0-9]\(\.[0-9][0-9]*\)*\)')
   else
       mpiStr=${2}
   fi

   if [ $compiler = "default" ]
   then
       desiredMPI="${2}"
       desiredBoost="${3}.0_${mpiStr}"
       ModuleEx unload swig/swig-2.0.9
   else
       desiredMPI="${2}_${4}"
       desiredBoost="${3}.0_${mpiStr}_${4}"
       # load non-default compiler
       if   [[ "$4" =~ gcc.* ]]
       then
           ModuleEx load gcc/${4}
           ModuleEx load swig/swig-2.0.9
           echo "LOADED gcc/${4} compiler"
       elif [[ "$4" =~ intel.* ]]
       then
           ModuleEx load intel/${4}
           if [[ "$4" == *intel-15* ]] ; then
               ModuleEx load gcc/gcc-4.8.1
               IntelExtraConfigStr="CXXFLAGS=-gxx-name=`which g++` CFLAGS=-gcc-name=`which gcc`"
           fi

       fi
   fi
   # Check to see if we are loading Boost 1.56 or greater, if so, we no longer
   # need to include mpi, so change the desiredBoost name as appropriate
   case $3 in
       boost-1.56|boost-1.58|boost-1.61) 
           echo "Choosing nompi version of boost for Boost 1.56 and greater"
           if [ $compiler = "default" ]
           then
               desiredBoost="${3}.0-nompi"
           else
               desiredBoost="${3}.0-nompi_${4}"
           fi  
           ;;
   esac
   
   echo "CHECK:  \$2: ${2}"
   echo "CHECK:  \$3: ${3}"
   echo "CHECK:  \$4: ${4}"
   echo "CHECK:  \$desiredMPI: ${desiredMPI}"
   echo "CHECK:  \$desiredBoost: ${desiredBoost}"
   gcc --version 2>&1 | grep ^g
   python --version

   # load MPI
   case $2 in
       openmpi-1.6.5)
           echo "OpenMPI (openmpi-1.6.5) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
       openmpi-1.8)
           echo "OpenMPI (openmpi-1.8) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
        openmpi-1.10)
           echo "OpenMPI (openmpi-1.10) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
       none)
           echo "MPI requested as \"none\".    No MPI loaded"
           ModuleEx unload mpi # unload any default 
           ;;
       *)
           echo "Default MPI option, loading mpi/${desiredMPI}"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI} 2>catch.err
           if [ -s catch.err ] 
           then
               cat catch.err
               exit 1
           fi
           ;;
   esac

   # load corresponding Boost
   case $3 in
       boost-1.54)
           echo "bamboo.sh: Boost 1.54 selected"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost}
           ;;
       boost-1.56)
           echo "bamboo.sh: Boost 1.56 selected"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost}
           ;;
       *)
           echo "bamboo.sh: \"Default\" Boost selected"
           echo "Third argument was $3"
           echo "Loading boost/${desiredBoost}"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost} 2>catch.err
           if [ -s catch.err ] 
           then
               cat catch.err
               exit 1
           fi
           ;;
   esac
   echo "bamboo.sh: BOOST_HOME=${BOOST_HOME}"
   export SST_DEPS_INSTALL_BOOST=${BOOST_HOME}
   echo "bamboo.sh: SST_DEPS_INSTALL_BOOST=${SST_DEPS_INSTALL_BOOST}"

   # Load other modules that were built with the default compiler
   if [ $compiler = "default" ]
   then
       # GNU Linear Programming Kit (GLPK)
       echo "bamboo.sh: Load GLPK"
       # Load available GLPK, whatever version it is
       ModuleEx load glpk
       # System C
#       echo "bamboo.sh: Load System C"
#       ModuleEx load systemc/systemc-2.3.0
       # METIS 5.1.0
       echo "bamboo.sh: Load METIS 5.1.0"
       ModuleEx load metis/metis-5.1.0
       # Other misc
#       echo "bamboo.sh: Load libphx"
#       ModuleEx load libphx/libphx-2014-MAY-08

   else # otherwise try to load compiler-specific tool variant
       # GNU Linear Programming Kit (GLPK)
       ModuleEx avail | egrep -q "glpk/glpk-4.54_${compiler}"
       if [ $? == 0 ] ; then
           echo "bamboo.sh: Load GLPK (gcc ${compiler} variant)"
           ModuleEx load glpk/glpk-4.54_${compiler}
       else 
           echo "bamboo.sh: module GLPK (gcc ${compiler} variant) Not Available"
       fi
       # METIS 5.1.0
       ModuleEx avail | egrep -q "metis/metis-5.1.0_${compiler}"
       if [ $? == 0 ] ; then
if [[ ${compiler} != *intel-15* ]] ; then
           echo "bamboo.sh: Load METIS 5.1.0 (gcc ${compiler} variant)"
           ModuleEx load metis/metis-5.1.0_${compiler}
echo ' ####################################################################### '
  echo "              DO NOT LOAD METIS FOR Intel 15  Compiler "
echo ' ####################################################################### '
fi
       else
           echo "bamboo.sh: module METIS 5.1.0 (gcc ${compiler} variant) Not Available"
       fi
       # Other misc
   fi
}


#-------------------------------------------------------------------------
# Function: ldModules_MacOS_Clang
# Description:
#   Purpose: Performs selection and loading of Boost and MPI and 
#            other compiler specific modules for MacOS Yosemite
#   Parameters:   name of Clang compiler such as (clang-700.1.76)
#                 Also need $2 and $3 passed along

ldModules_MacOS_Clang() {
    ClangVersion=$1            #   example "clang-700.0.72" $2 $3
                        ModuleEx avail
                        # Use Boost and MPI built with CLANG from Xcode
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for $ClangVersion
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_$ClangVersion
                        # # System C
                        # echo "bamboo.sh: Load System C"
                        # ModuleEx load systemc/systemc-2.3.0_$ClangVersion
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_$ClangVersion
                        
                        # PTH 2.0.7
                        echo "bamboo.sh: Load PTH 2.0.7"
                        ModuleEx load pth/pth-2.0.7
                        
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_$ClangVersion

                        # load MPI
                        echo " ****** Loading MPI ********"
                        echo "Request (\$2) is ${2}"
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_$ClangVersion
                                ;;
                            none)
                                echo  "No MPI loaded as requested"
                                ;;
                            *)
                                echo "Unrecognized MPI request"
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_$ClangVersion 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_$ClangVersion
                                ;;
                            boost_default|boost-1.61)
                                echo "Boost 1.61 selected"
                                ModuleEx add boost/boost-1.61.0-nompi_$ClangVersion
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_$ClangVersion 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                        export CC=`which clang`
                        export CXX=`which clang++`
                        echo "    Modules loaded"
                        ModuleEx list
                        $CC --version
}
#-------------------------------------------------------------------------
# Function: darwinSetBoostMPI
# Description:
#   Purpose: Performs selection and loading of Boost and MPI modules
#            for MacOS
#   Input:
#   Output:
#   Return value:
darwinSetBoostMPI() {
    # Obtain Mac OS version (works only on MacOS!!!)
    macosVersionFull=`sw_vers -productVersion`
echo "  ******************* macosVersionFull= $macosVersionFull "
###    macosVersion=${macosVersionFull%.*}
    macosVersion=`echo ${macosVersionFull} | awk -F. '{print $1 "." $2 }'`
echo "  ******************* macosVersion= $macosVersion "

    if [[ $macosVersion = "10.8" && $compiler = "clang-503.0.40" ]]
    then
        echo "Probably un-needed  JVD"
    else
        # macports or hybrid clang/macports
        PATH="/opt/local/bin:/usr/local/bin:$PATH"
        export PATH
    fi


    # Point to aclocal per instructions from sourceforge on MacOSX installation
    export ACLOCAL_FLAGS="-I/opt/local/share/aclocal $ACLOCAL_FLAGS"
    echo $ACLOCAL_FLAGS

    # Initialize modules for Jenkins (taken from $HOME/.bashrc on Mac)
    if [ -f /etc/profile.modules ]
    then
        . /etc/profile.modules
        echo "bamboo.sh: loaded /etc/profile.modules. Available modules"
        ModuleEx avail
        # put any module loads here
        echo "bamboo.sh: Loading Modules for MacOSX"
        # Do things specific to the MacOS version
        case $macosVersion in
################################################################################
            10.10) # Yosemite
                ModuleEx avail
                # Depending on specified compiler, load Boost and MPI
                case $compiler in

                    clang-700.0.72)
                        # Use Boost and MPI built with CLANG from Xcode 6.3
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-700.0.72
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-700.0.72
                        # # System C
                        # echo "bamboo.sh: Load System C"
                        # ModuleEx load systemc/systemc-2.3.0_clang-700.0.72
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-700.0.72
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-700.0.72

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-700.0.72
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-700.0.72 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_clang-700.0.72
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-700.0.72 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                        export CC=`which clang`
                        export CXX=`which clang++`
                        ModuleEx list
                        ;;

                    clang-700.1.76)
                        ldModules_MacOS_Clang clang-700.1.76 $2 $3   #  Xcode 7.1
                        ;;
                    *)
                        # unknown compiler, use default
                        echo "bamboo.sh: Unknown compiler selection. Assuming clang."
                        ModuleEx unload boost
                        ModuleEx unload mpi
                        ModuleEx add mpi/openmpi-1.8_$compiler
                        ModuleEx add boost/boost-1.56.0-nompi_$compiler
                        ModuleEx list
                        ;;  
                esac
                ;;

################################################################################
            10.11) # El Capitan
echo    "This is El Capitan, Compiler is $compiler"
                   ldModules_MacOS_Clang $compiler  $2 $3   # any Xcode 
                   ;;

################################################################################
            10.12) # Sierra
echo    "This is Sierra, Compiler is $compiler"
                   ldModules_MacOS_Clang $compiler  $2 $3   # any Xcode 
                   ;;

################################################################################

            10.13) # High Sierra
echo    "This is High Sierra, Compiler is $compiler"
                   ldModules_MacOS_Clang $compiler  $2 $3   # any Xcode 
                   ;;

################################################################################
            *) # unknown
                 echo "bamboo.sh: Unknown Mac OS version. $macosVersion"
                 echo ' '
                 exit
                 ;;
        esac

        echo "bamboo.sh: BOOST_HOME=${BOOST_HOME}"
        export SST_DEPS_INSTALL_BOOST=${BOOST_HOME}

    fi

    echo "bamboo.sh: MacOS build."
    echo "bamboo.sh:   MPI = $2, Boost = $3"
}

#-------------------------------------------------------------------------
# Function: setUPforMakeDisttest
# Description:
#   Purpose: Unpack the make-dist tars and set the environment for testing 
#          
#   Input:
#   Output:
#   Return value:
setUPforMakeDisttest() {
     echo "Setting up to build from the tars created by make dist"
     echo "---   PWD  `pwd`"           ## Original trunk
#                             CORE
#            May 24th, 2016     file is: sstcore-6.0.0.tar.gz
     LOC_OF_TAR=""
     if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
         LOC_OF_TAR="-builddir" 
     fi 
     cd ${SST_ROOT}/sst-core${LOC_OF_TAR}
     Package=`ls| grep 'sst.*tar.gz' | awk -F'.tar' '{print $1}'`
     echo  PACKAGE is $Package
     tarName=${Package}.tar.gz
     ls $tarName
     if [ $? != 0 ] ; then
         ls
         echo Can NOT find Tar File $Package .tar.gz
         exit 1
     fi
     mkdir -p $SST_ROOT/distTestDir/trunk
     cd $SST_ROOT/distTestDir/trunk
     mv $SST_ROOT/sst-core${LOC_OF_TAR}/$tarName .
     if [ $? -ne 0 ] ; then
          echo "Move failed  \$SST_ROOT/$tarName to ."
          exit 1
     fi
     echo "   Untar the created file, $tarName"
     echo "---   PWD  `pwd`"    
     tar xzf $tarName
     if [ $? -ne 0 ] ; then
          echo "Untar of $tarName failed"
          exit 1
     fi
     mv $Package sst-core

#                          ELEMENTS
#         May 17, 2016    file name is sst-elements-library-devel.tar.gz
     cd $SST_ROOT/sst-elements${LOC_OF_TAR}
     echo "---   PWD  `pwd`"    
     Package=`ls| grep 'sst-.*tar.gz' | awk -F'.tar' '{print $1}'`
     echo  PACKAGE is $Package
     tarName=${Package}.tar.gz
     ls $tarName
     if [ $? != 0 ] ; then
         ls
         echo Can NOT find Tar File $Package .tar.gz
         exit 1
     fi
     cd $SST_ROOT/distTestDir/trunk
     mv $SST_ROOT/sst-elements${LOC_OF_TAR}/$tarName .
     if [ $? -ne 0 ] ; then
          echo "Move failed  \$SST_ROOT/$tarName to ."
          exit 1
     fi
     echo "   Untar the created file, $tarName"
     tar xzf $tarName
     if [ $? -ne 0 ] ; then
          echo "Untar of $tarName failed"
          exit 1
     fi
     echo "---   PWD  `pwd`"    
     mv $Package sst-elements

echo "===============   MOVE IN THE EXTERNAL ELEMENT & JUNO ====================="
echo " PWD=`pwd` "
     mv $SST_ROOT/sst-external-element .
     mv $SST_ROOT/juno .

echo "=============================="
     echo "Move in items not in the trunk, that are need for the bamboo build and test"

echo "####################################################################"
echo ' '
     echo "---   PWD  `pwd`"    
echo  "   We are in distTestDir/trunk"
     cp  $SST_ROOT/../sqe/buildsys/bamboo.sh .
     if [ -e ./deps ] ; then
        cp -r $SST_ROOT/deps/bin ./deps       ## the deps scripts
        cp -r $SST_ROOT/deps/include ./deps          ## the deps scripts
        cp -r $SST_ROOT/deps/patches ./deps          ## the deps scripts
     else
        cp -r $SST_ROOT/deps .          ## the deps scripts
     fi
     if [ ! -e ./deps/bin ] ; then
         echo " FAILED  FAILED FAILED FAILED FAILED FAILED FAILED"
         echo SST_ROOT = $SST_ROOT
         ls $SST_ROOT/deps
         echo " FAILED  FAILED FAILED FAILED FAILED FAILED FAILED"
         exit
     fi
     echo "                   List the directories in sst-elements/src/sst/elements"
     ls sst-elements/src/sst/elements
     echo ' '

     ln -s ../../test              ## the subtree of tests
     ls -l
     echo SST_INSTALL_DEPS =  $SST_INSTALL_DEPS
        ## pristine is not at the same relative depth on Jenkins as it is for me.
     echo "  Find pristine"
     if [ $SST_BASE == "/home/jwilso" ] ; then
         PRISTINE="/home/jwilso/sstDeps/src/pristine"
     else 
         find $SST_BASE -name pristine
         PRISTINE=`find $SST_BASE -name pristine`
     fi
     echo "\$PRISTINE = $PRISTINE"
     ls $PRISTINE/*
     if [[ $? != 0 ]] ; then
         echo " Failed to find pristine "
         exit 1
     fi
     export SST_BASE=$SST_ROOT
     export SST_DEPS_USER_DIR=$SST_ROOT
     export SST_DEPS_USER_MODE=1
     export SST_INSTALL_DEPS=$SST_BASE/local
     mkdir -p ../../sstDeps/src
     pushd ../../sstDeps/src
     ln -s $PRISTINE .
     ls -l pristine
     popd
     echo "           ------ verify the file removal"
     pwd
     ls
     #       Why did we copy bamboo.sh and deps, but link test ????
     echo "  Why did we copy bamboo.sh and deps, but link test ????"?
     pushd ../../       # Back to orginal trunk
     ls | awk '{print "rm -rf " $1}' | grep -v -d deps -e distTestDir -e test > rm-extra
     . ./rm-extra
     ls
     popd
     echo "               extra Files removed ------------  "

     echo SST_DEPS_USER_DIR= $SST_DEPS_USER_DIR
     if [ $buildtype == "sstmainline_config_dist_test" ] ; then
         distScenario="sstmainline_config_all"
     else
         distScenario="sstmainline_config_no_gem5"
     fi

     echo "---   PWD  `pwd`"    
     cd $SST_ROOT/distTestDir/trunk  
     # unlike regular test, make dist does move bamboo to trunk
              ##  Here is the bamboo invocation within bamboo
     echo "         INVOKE bamboo for the build from the dist tar"
     ./bamboo.sh $distScenario $SST_DIST_MPI $SST_DIST_BOOST $SST_DIST_PARAM4
     retval=$?
     echo "         Returned from bamboo.sh $retval"
     if [ $retval != 0 ] ; then
         echo "bamboo build reports failure  retval = $reval"
         exit 1
     fi
}         #### End of setUPforMakeDistest  ####

#-------------------------------------------------------------------------
# Function: dobuild
# Description:
#   Purpose: Performs the actual build
#   Input:
#     -t <build type>
#     -a <architecture>
#   Output: none
#   Return value: 0 if success
dobuild() {

    # process cmdline options
    OPTIND=1
    while getopts :t:a:k: opt
    do
        case "$opt" in
            t) # build type
                buildtype=$OPTARG
                ;;
            a) # architecture
                local architecture=$OPTARG
                ;;
            k) #kernel
                local kernel=$OPTARG
                ;;
            *) # unknown option 
                echo "dobuild () : Unknown option $opt"
                return 126 # command can't execute
                ;;
        esac
    done

    export PATH=$SST_CORE_INSTALL_BIN:$SST_ELEMENTS_INSTALL_BIN:$PATH

    # obtain dependency and configure args
    getconfig $buildtype $architecture $kernel

    # after getconfig is run,
    # $SST_SELECTED_DEPS now contains selected dependencies 
    # $SST_SELECTED_CORE_CONFIG now contains config line for the SST-CORE
    # $SST_SELECTED_ELEMENTS_CONFIG now contains config line for the SST-ELEMENTS
    # $SST_SELECTED_MACRO_CONFIG now contains config line for the SST-MACRO
    # $SST_SELECTED_EXTERNALELEMENT_CONFIG now contains config line for the externalelement
    # $SST_SELECTED_JUNO_CONFIG now contains config line for the juno
    # based on buildtype, configure and build dependencies
    # build, patch, and install dependencies
    $SST_DEPS_BIN/sstDependencies.sh $SST_SELECTED_DEPS cleanBuild
    retval=$?
    if [ $retval -ne 0 ]
    then
        return $retval
    fi

    echo "==================== SETTING UP TO BUILD SST CORE ELEMENTS AND/OR MACRO ====="
    SAVE_LIBRARY_PATH=$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=${SST_INSTALL_DEPS}/lib:${SST_INSTALL_DEPS}/lib/sst:${SST_DEPS_INSTALL_GEM5SST}:${SST_INSTALL_DEPS}/packages/DRAMSim:${SST_DEPS_INSTALL_NVDIMMSIM}:${SST_DEPS_INSTALL_HYBRIDSIM}:${SST_INSTALL_DEPS}/packages/Qsim/lib:${SST_DEPS_INSTALL_CHDL}/lib:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BOOST_LIBS
    # Mac OS X needs some help finding dylibs
    if [ $kernel == "Darwin" ]
    then
	    export DYLD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${DYLD_LIBRARY_PATH}
    fi
    
    # Dump pre-build environment and modules status
    echo "--------------------PRE-BUILD ENVIRONMENT VARIABLE DUMP--------------------"
    env | sort
    echo "--------------------PRE-BUILD ENVIRONMENT VARIABLE DUMP--------------------"
    echo "--------------------modules status--------------------"
    ModuleEx avail
    ModuleEx list
    echo "--------------------modules status--------------------"

    ### BUILDING THE SST-CORE
    if [[ $SST_SELECTED_CORE_CONFIG == "NOBUILD" ]]
    then
        echo "============== SST CORE - NO BUILD REQUIRED ==============="
    else
        echo "==================== Building SST CORE ===================="
        
        # autogen to create ./configure
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"autogen.sh\" on SST-CORE..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Autogen SST-CORE
        ### First Run autogen in the source dir to create the configure file
        echo "NOTE: Autogen Must be run in SST-CORE Source Dir to create configuration file"
        echo "Current Working Dir = `pwd`"
        echo "pushd sst-core"
        pushd sst-core
        echo "Autogen Working Dir = `pwd`"
        ls -l
        echo "=== Running autogen.sh ==="
        
        ./autogen.sh
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo "Done with Autogen"
        echo "popd"
        popd
        echo "Current Working Dir = `pwd`"
        ls -l

        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: autogen on SST-CORE complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "

        # Check to see if we are supposed to build out of the source
        if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
            echo "NOTICE: BUILDING SST-CORE OUT OF SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "mkdir ./sst-core-builddir"
            mkdir ./sst-core-builddir
            echo "pushd sst-core-builddir"
            pushd sst-core-builddir
            echo "Current Working Dir = `pwd`"
            ls -l
            coresourcedir="../sst-core"
        else
            echo "NOTICE: BUILDING SST-CORE IN SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "pushd sst-core"
            pushd sst-core
            echo "Current Working Dir = `pwd`"
            ls -l
            coresourcedir="."
        fi        

        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"configure\" on SST-CORE..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "bamboo.sh: config args = $SST_SELECTED_CORE_CONFIG"
        
        # Configure SST-CORE
        echo "=== Running $coresourcedir/configure <config args> ==="
        $coresourcedir/configure $SST_SELECTED_CORE_CONFIG
        retval=$?
        if [ $retval -ne 0 ]
        then
            # Something went wrong in configure, so dump config.log
            echo "bamboo.sh: Uh oh. Something went wrong during configure of sst-core.  Dumping config.log"
            echo "--------------------dump of config.log--------------------"
            sed -e 's/^/#dump /' ./config.log
            echo "--------------------dump of config.log--------------------"
            return $retval
        fi
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: configure on SST-CORE complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        
        # Check to see if we are actually performing make dist 
        echo "at this time \$buildtype is $buildtype"
        if [[ $buildtype == *_dist_* ]] ; then
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make dist on SST-CORE"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            make dist
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make dist on SST_CORE is complete without error"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo " "
            ls -ltr | tail -5
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: After make dist on SST_CORE do the make install "
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        fi
        
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make on SST-CORE"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    
        if [ $kernel == "Darwin" ]
        then
            # Mac OS X 
            echo "$ otool -L $coresourcedir/src/sst/core/sstsim.x"
            otool -L $coresourcedir/src/sst/core/sstsim.x
        else
            echo "$ ldd $coresourcedir/src/sst/core/sstsim.x"
            ldd $coresourcedir/src/sst/core/sstsim.x
        fi
        echo "SST-CORE BUILD INFO============================================================"
                
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-CORE complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-CORE"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Install SST-CORE
        echo "=== Running make -j4 install ==="
        make -j4 install
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo
        echo "=== DUMPING The SST-CORE installed sstsimulator.conf file ==="
        echo "cat $SST_CORE_INSTALL/etc/sst/sstsimulator.conf"
        cat $SST_CORE_INSTALL/etc/sst/sstsimulator.conf
        echo "=== DONE DUMPING ==="
        echo
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-CORE complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
            if [ $kernel == "Darwin" ]
            then
                # Mac OS X 
                echo "$ otool -L $coresourcedir/src/sst/core/sstsim.x"
                otool -L $coresourcedir/src/sst/core/sstsim.x
            else
                echo "$ ldd $coresourcedir/src/sst/core/sstsim.x"
                ldd $coresourcedir/src/sst/core/sstsim.x
            fi
            echo "SST-CORE BUILD INFO============================================="
                    
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make on SST-CORE complete without error"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo " "
            
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make install on SST-CORE"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            
            # Install SST-CORE
            echo "=== Running make -j4 install ==="
            make -j4 install
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make install on SST-CORE complete without error"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo " "
            
            # Go back to devel/trunk
            echo "popd"
            popd
            echo "Current Working Dir = `pwd`"
            ls -l
    fi

    ### BUILDING THE SST-ELEMENTS
    if [[ $SST_SELECTED_ELEMENTS_CONFIG == "NOBUILD" ]]
    then
        echo "============== SST ELEMENTS - NO BUILD REQUIRED ==============="
    else
        echo "==================== Building SST ELEMENTS ===================="

        # autogen to create ./configure
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"autogen.sh\" on SST-ELEMENTS..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Autogen SST-ELEMENTS
        ### First Run autogen in the source dir to create the configure file
        echo "NOTE: Autogen Must be run in SST-ELEMENTS Source Dir to create configuration file"
        echo "Current Working Dir = `pwd`"
        echo "pushd sst-elements"
        pushd ${SST_ROOT}/sst-elements
        echo "Autogen Working Dir = `pwd`"
        ls -l
        echo "=== Running autogen.sh ==="
        
        ./autogen.sh
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo "Done with Autogen"

        popd
        echo "Current Working Dir = `pwd`"
        ls -l

        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: autogen on SST-ELEMENTS complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        # Check to see if we are supposed to build out of the source
        if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
            echo "NOTICE: BUILDING SST-ELEMENTS OUT OF SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "mkdir ./sst-elements-builddir"
            mkdir ./sst-elements-builddir
            echo "pushd sst-elements-builddir"
            pushd sst-elements-builddir
            echo "Current Working Dir = `pwd`"
            ls -l
            elementssourcedir="../sst-elements"
        else
            echo "NOTICE: BUILDING SST-ELEMENTS IN SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "pushd sst-elements"
            pushd ${SST_ROOT}/sst-elements
            echo "Current Working Dir = `pwd`"
            ls -l
            elementssourcedir="."
        fi        
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"configure\" on SST-ELEMENTS..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "bamboo.sh: config args = $SST_SELECTED_ELEMENTS_CONFIG"
        
        # Configure SST-ELEMENTS
        echo "=== Running $elementssourcedir/configure <config args> ==="
        $elementssourcedir/configure $SST_SELECTED_ELEMENTS_CONFIG
        retval=$?
        if [ $retval -ne 0 ]
        then
            # Something went wrong in configure, so dump config.log
            echo "bamboo.sh: Uh oh. Something went wrong during configure of sst-elements.  Dumping config.log"
            echo "--------------------dump of config.log--------------------"
            sed -e 's/^/#dump /' ./config.log
            echo "--------------------dump of config.log--------------------"
            return $retval
        fi
        
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: configure on SST-ELEMENTS complete without error"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
echo "################################## DEBUG DATA ########################"
ls
ls src
ls src/sst
ls src/sst/elements/
ls src/sst/elements/*/*m4
echo "##################### END ######## DEBUG DATA ########################"
        
        # Check to see if we are actually performing make dist 
        echo "at this time \$buildtype is $buildtype"
        if [[ $buildtype == *_dist_* ]] ; then
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make dist on SST-ELEMENTS"
            echo ' '    
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            make dist
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '    
            echo "bamboo.sh: make dist on SST-ELEMENTS is complete without error"
            echo ' '    
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo " "
            ls -ltr | tail -5
            return $retval        ##   This is in dobuild
        fi
        
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-ELEMENTS"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # Compile SST-ELEMENTS
        echo "=== Running make -j4 all ==="
        make -j4 all
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-ELEMENTS complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-ELEMENTS"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Install SST-ELEMENTS
        echo "=== Running make -j4 install ==="
        make -j4 install
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo
        echo "=== DUMPING The SST-ELEMENTS installed $HOME/.sst/sstsimulator.conf file ==="
        echo "cat $HOME/.sst/sstsimulator.conf"
        cat $HOME/.sst/sstsimulator.conf
        echo "=== DONE DUMPING ==="
        echo
        
        echo
        echo "=== DUMPING The SST-ELEMENTS installed sstsimulator.conf file located at $SST_CONFIG_FILE_PATH ==="
        echo "cat $SST_CONFIG_FILE_PATH"
        cat $SST_CONFIG_FILE_PATH
        echo "=== DONE DUMPING ==="
        echo
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-ELEMENTS complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        # Go back to devel/trunk
        echo "popd"
        popd
        echo "Current Working Dir = `pwd`"
        ls -l
    fi

    ### BUILDING THE SST-MACRO
    if [[ $SST_SELECTED_MACRO_CONFIG == "NOBUILD" ]]
    then
        echo "============== SST MACRO - NO BUILD REQUIRED ==============="
    else
        echo "==================== Building SST MACRO ===================="
        
        # bootstrap to create ./configure
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"bootstrap.sh\" on SST-MACRO..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # bootstrap SST-MACRO
        ### First Run bootstrap in the source dir to create the configure file
        echo "NOTE: bootstrap Must be run in SST-Macro Source Dir to create configuration file"
        echo "Current Working Dir = `pwd`"
        echo "pushd sst-macro"
        pushd ${SST_ROOT}/sst-macro
        echo "bootstrap Working Dir = `pwd`"
        ls -l
        echo "=== Running bootstrap.sh ==="
        
        ./bootstrap.sh
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo "Done with bootstrap"

        popd
        echo "Current Working Dir = `pwd`"
        ls -l
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: bootstrap on SST-MACRO complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "

        # Check to see if we are supposed to build out of the source
        if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
            echo "NOTICE: BUILDING SST-MACRO OUT OF SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "mkdir ./sst-macro-builddir"
            mkdir ./sst-macro-builddir
            echo "pushd sst-macro-builddir"
            pushd sst-macro-builddir
            echo "Current Working Dir = `pwd`"
            ls -l
            macrosourcedir="../sst-macro"
        else
            echo "NOTICE: BUILDING SST-MACRO IN SOURCE DIR"
            echo "Starting Dir = `pwd`"
            echo "pushd sst-macro"
            pushd ${SST_ROOT}/sst-macro
            echo "Current Working Dir = `pwd`"
            ls -l
            macrosourcedir="."
        fi        
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: running \"configure\" on SST-MACRO..."
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "bamboo.sh: config args = $SST_SELECTED_MACRO_CONFIG"

        # Configure SSTMACRO
        echo "=== Running $macrosourcedir/configure <config args> ==="
        $macrosourcedir/configure $SST_SELECTED_MACRO_CONFIG
        retval=$?
        if [ $retval -ne 0 ]
        then
            # Something went wrong in configure, so dump config.log
            echo "bamboo.sh: Uh oh. Something went wrong during configure of sst-macro.  Dumping config.log"
            echo "--------------------dump of config.log--------------------"
            sed -e 's/^/#dump /' ./config.log
            echo "--------------------dump of config.log--------------------"
            return $retval
        fi

        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: configure on SST-MACRO complete without error"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-MACRO"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # Compile SST-MACRO
        echo "=== Running make -j4 ==="
        make -j4 
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-MACRO complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-MACRO"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Install SST-MACRO
        echo "=== Running make -j4 install ==="
        make -j4 install
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo
        echo "=== DUMPING The SST-MACRO installed $HOME/.sst/sstsimulator.conf file ==="
        echo "cat $HOME/.sst/sstsimulator.conf"
        cat $HOME/.sst/sstsimulator.conf
        echo "=== DONE DUMPING ==="
        echo
        
        echo
        echo "=== DUMPING The SST-MACRO installed sstsimulator.conf file located at $SST_CONFIG_FILE_PATH ==="
        echo "cat $SST_CONFIG_FILE_PATH"
        cat $SST_CONFIG_FILE_PATH
        echo "=== DONE DUMPING ==="
        echo
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-MACRO complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        # Go back to devel/trunk
        echo "popd"
        popd
        echo "Current Working Dir = `pwd`"
        ls -l
    fi

    ### BUILDING THE SST-EXTERNALELEMENT
    if [[ $SST_SELECTED_EXTERNALELEMENT_CONFIG == "NOBUILD" ]]
    then
        echo "============== SST EXTERNAL-ELEMENT - NO BUILD REQUIRED ==============="
    else
        echo "==================== Building SST EXTERNAL-ELEMENT ===================="
        

        # Building SST-EXTERNAL-ELEMENTS
        echo "pushd sst-external-element/src"
        pushd ${SST_ROOT}/sst-external-element/src
        echo "Build Working Dir = `pwd`"
       
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-EXTERNAL-ELEMENTS"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # Compile SST-EXTERNAL-ELEMENTS
        echo "=== Running make -j4 ==="
        make -j4 
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on SST-EXTERNAL-ELEMENTS complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-EXTERNAL-ELEMENTS"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Install SST-EXTERNAL-ELEMENTS
        echo "=== Running make -j4 install ==="
        make -j4 install
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo
        echo "=== DUMPING The SST-EXTERNAL-ELEMENTS installed $HOME/.sst/sstsimulator.conf file ==="
        echo "cat $HOME/.sst/sstsimulator.conf"
        cat $HOME/.sst/sstsimulator.conf
        echo "=== DONE DUMPING ==="
        echo
        
        echo
        echo "=== DUMPING The SST-EXTERNAL-ELEMENTS installed sstsimulator.conf file located at $SST_CONFIG_FILE_PATH ==="
        echo "cat $SST_CONFIG_FILE_PATH"
        cat $SST_CONFIG_FILE_PATH
        echo "=== DONE DUMPING ==="
        echo
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on SST-EXTERNAL-ELEMENTS complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        # Go back to devel/trunk
        echo "popd"
        popd
        echo "Current Working Dir = `pwd`"
        ls -l
    fi
    
    ### BUILDING THE JUNO
    if [[ $SST_SELECTED_JUNO_CONFIG == "NOBUILD" ]]
    then
        echo "============== JUNO - NO BUILD REQUIRED ==============="
    else
        echo "==================== Building JUNO ===================="
        

        # Building JUNO
        echo "pushd juno/src"
        pushd ${SST_ROOT}/juno/src
        echo "Build Working Dir = `pwd`"
       
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on JUNO"
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # Compile JUNO
        echo "=== Running make -j4 ==="
        make -j4 
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make on JUNO complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on JUNO"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        # Install JUNO
        echo "=== Running make -j4 install ==="
        make -j4 install
        retval=$?
        if [ $retval -ne 0 ]
        then
            return $retval
        fi

        echo
        echo "=== DUMPING The JUNO installed $HOME/.sst/sstsimulator.conf file ==="
        echo "cat $HOME/.sst/sstsimulator.conf"
        cat $HOME/.sst/sstsimulator.conf
        echo "=== DONE DUMPING ==="
        echo
        
        echo
        echo "=== DUMPING The JUNO installed sstsimulator.conf file located at $SST_CONFIG_FILE_PATH ==="
        echo "cat $SST_CONFIG_FILE_PATH"
        cat $SST_CONFIG_FILE_PATH
        echo "=== DONE DUMPING ==="
        echo
        
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo "bamboo.sh: make install on JUNO complete without error"
        echo ' '    
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        
        # Go back to devel/trunk
        echo "popd"
        popd
        echo "Current Working Dir = `pwd`"
        ls -l
    fi
}


#-------------------------------------------------------------------------
# Function: ExitOfScriptHandler
# Trap the exit command and perform end of script processing.
function ExitOfScriptHandler {
    echo "EXIT COMMAND TRAPPED...."
    echo
    echo "=== DUMPING The SST-ELEMENTS installed sstsimulator.conf file ==="
    echo "cat $HOME/.sst/sstsimulator.conf"
    cat $HOME/.sst/sstsimulator.conf
    echo "=== DONE DUMPING ==="
    echo
}

#=========================================================================
# main
# $1 = build type
# $2 = MPI type
# $3 = boost type
# $4 = compiler type
#=========================================================================
trap ExitOfScriptHandler EXIT

#=========================================================================
# Definitions
#=========================================================================

# Check Environement variables that control what Repo and branch we are planning
# to use.  Most of the time the defaults are used, but by setting the Environment
# variables, we can control what (and from where) files are pulled.
# This feature is critical for the autotesters as files may come from a different 
# branch and/or fork

# Which Repository to use for SQE (default is https://github.com/sstsimulator/sst-sqe)
if [[ ${SST_SQEREPO:+isSet} != isSet ]] ; then
    SST_SQEREPO=https://github.com/sstsimulator/sst-sqe
fi

# Which Repository to use for CORE (default is https://github.com/sstsimulator/sst-core)
if [[ ${SST_COREREPO:+isSet} != isSet ]] ; then
    SST_COREREPO=https://github.com/sstsimulator/sst-core
fi

# Which Repository to use for ELEMENTS (default is https://github.com/sstsimulator/sst-elements)
if [[ ${SST_ELEMENTSREPO:+isSet} != isSet ]] ; then
    SST_ELEMENTSREPO=https://github.com/sstsimulator/sst-elements
fi

# Which Repository to use for MACRO (default is https://github.com/sstsimulator/sst-macro)
if [[ ${SST_MACROREPO:+isSet} != isSet ]] ; then
    SST_MACROREPO=https://github.com/sstsimulator/sst-macro
fi

# Which Repository to use for EXTERNAL-ELEMENT (default is https://github.com/sstsimulator/sst-external-element)
if [[ ${SST_EXTERNALELEMENTREPO:+isSet} != isSet ]] ; then
    SST_EXTERNALELEMENTREPO=https://github.com/sstsimulator/sst-external-element
fi

# Which Repository to use for JUNO (default is https://github.com/sstsimulator/juno)
if [[ ${SST_JUNOREPO:+isSet} != isSet ]] ; then
    SST_JUNOREPO=https://github.com/sstsimulator/juno
fi
###

# Which branches to use for each repo (default is devel)
if [[ ${SST_SQEBRANCH:+isSet} != isSet ]] ; then
    SST_SQEBRANCH=devel
    SST_SQEBRANCH="detached"
else
    echo ' ' ;  echo ' ' ; echo ' ' ; echo ' ' 
    echo " Attempting to set SQE branch is a no op"
    echo " SQE branch is selected by configure in Jenkins"
    echo "  Ignoring SST_SQEBRANCH =  ${SST_SQEBRANCH}"
    echo ' ' ;  echo ' ' ; echo ' ' ; echo ' ' 
fi
                        
if [[ ${SST_COREBRANCH:+isSet} != isSet ]] ; then
    SST_COREBRANCH=devel
fi
                        
if [[ ${SST_ELEMENTSBRANCH:+isSet} != isSet ]] ; then
    SST_ELEMENTSBRANCH=devel
fi

if [[ ${SST_MACROBRANCH:+isSet} != isSet ]] ; then
    SST_MACROBRANCH=devel
fi

if [[ ${SST_EXTERNALELEMENTBRANCH:+isSet} != isSet ]] ; then
    SST_EXTERNALELEMENTBRANCH=master
fi

if [[ ${SST_JUNOBRANCH:+isSet} != isSet ]] ; then
    SST_JUNOBRANCH=master
fi

echo "#############################################################"
echo "===== BAMBOO.SH PARAMETER SETUP INFORMATION ====="
echo "  GitHub SQE Repository and Branch = $SST_SQEREPO $SST_SQEBRANCH"
echo "  GitHub CORE Repository and Branch = $SST_COREREPO $SST_COREBRANCH"
echo "  GitHub ELEMENTS Repository and Branch = $SST_ELEMENTSREPO $SST_ELEMENTSBRANCH"
echo "  GitHub MACRO Repository and Branch = $SST_MACROREPO $SST_MACROBRANCH"
echo "  GitHub EXTERNAL-ELEMENT Repository and Branch = $SST_EXTERNALELEMENTREPO $SST_EXTERNALELEMENTBRANCH"
echo "  GitHub JUNO Repository and Branch = $SST_JUNOREPO $SST_JUNOBRANCH"
echo "#############################################################"


# Root of directory checked out, where this script should be found
export SST_ROOT=`pwd`
echo " SST_ROOT = $SST_ROOT"

echo "#############################################################"
echo "  Version Oct 4 1330 hours "
echo ' '
pwd
ls -la
   echo ' '
if [ -d ${SST_BASE}/devel/sqe ] ; then
   echo "PWD = `pwd`"
   pushd ${SST_BASE}/devel/sqe
   echo "PWD = `pwd`"
   echo "               SQE branch"
   git branch
   echo ' '
   popd
else
   echo "Jenkin forks SQE so it is not tied to a remote repository"
   echo ' '
fi

echo "#### FINISHED SETTING UP DIRECTORY STRUCTURE - NOW SETTING ENV RUNTIME VARS ########"

echo 
echo 
echo
echo "#### DELETING THE HOME/.sst/sstsimulator.conf file ####"
echo "#### NOTE: THIS CODE MAY NEED TO BE REMOVED IN THE NEAR FUTURE"
echo "BEFORE:ls $HOME/.sst/sstsimulator.conf" 
ls $HOME/.sst/sstsimulator.conf 
echo "rm -f $HOME/.sst/sstsimulator.conf" 
rm -f $HOME/.sst/sstsimulator.conf 
echo "AFTER: ls $HOME/.sst/sstsimulator.conf" 
ls $HOME/.sst/sstsimulator.conf 
echo "#### DONE DELETING THE HOME/.sst/sstsimulator.conf file ####"
echo 
echo 
echo 
#	This assumes a directory strucure
#                     SST_BASE   (was $HOME)
#           devel                sstDeps
#           trunk (SST_ROOT)       src

echo SST_DEPS_USER_MODE = ${SST_DEPS_USER_MODE}
if [[ ${SST_DEPS_USER_MODE:+isSet} = isSet ]]
then
    echo  SST_BASE=\$SST_DEPS_USER_DIR
    export SST_BASE=$SST_DEPS_USER_DIR
else
    echo SST_BASE=\$HOME
    export SST_BASE=$HOME
fi
echo ' ' ; echo "        SST_BASE = $SST_BASE" ; echo ' '

# Location of SST library dependencies (deprecated)
export SST_DEPS=${SST_BASE}/local
# Starting Location where SST files are installed
export SST_INSTALL=${SST_BASE}/local

# Location where SST CORE files are installed
export SST_CORE_INSTALL=${SST_INSTALL}/sst-core
# Location where SST CORE build files are installed
export SST_CORE_INSTALL_BIN=${SST_CORE_INSTALL}/bin

# Location where SST ELEMENTS files are installed
export SST_ELEMENTS_INSTALL=${SST_INSTALL}/sst-elements
# Location where SST ELEMENTS build files are installed
export SST_ELEMENTS_INSTALL_BIN=${SST_ELEMENTS_INSTALL}/bin

# Location where SST MACRO files are installed
export SST_MACRO_INSTALL=${SST_INSTALL}/sst-macro

# Final Location where SST executable files are installed
export SST_INSTALL=${SST_CORE_INSTALL}
# Location where SST build files are installed
export SST_INSTALL_BIN=${SST_CORE_INSTALL_BIN}

# Setup the Location to find the sstsimulator.conf file
export SST_CONFIG_FILE_PATH=${SST_CORE_INSTALL}/etc/sst/sstsimulator.conf


# Location where SST dependencies are installed. This only specifies
# the root; dependencies may be installed in various locations under
# this directory. The user can override this value by setting the
# exporting the SST_INSTALL_DEPS_USER variable in their environment.
export SST_INSTALL_DEPS=${SST_BASE}/local
# Initialize build type to null
export SST_BUILD_TYPE=""

cloneOtherRepos 

# Load test definitions
echo "bamboo.sh: This directory is:"
pwd
echo "bamboo.sh: ls deps/include"
ls deps/include
# Load dependency definitions
echo "bamboo.sh: deps/include/depsDefinitions.sh"
. deps/include/depsDefinitions.sh
echo "bamboo.sh: Done sourcing deps/include/depsDefinitions.sh"

# Uncomment the following line or export from your environment to
# retain binaries after build
#export SST_RETAIN_BIN=1


echo "==============================INITIAL ENVIRONMENT DUMP================="
env|sort
echo "==============================INITIAL ENVIRONMENT DUMP================="

retval=0
echo  $0  $1 $2 $3 $4
echo `pwd`

if [ $# -lt 3 ] || [ $# -gt 4 ]
then
    # need build type and MPI type as argument

    echo "Usage : $0 <buildtype> <mpitype> <boost type> <[compiler type (optional)]>"
    exit 0

else
    # get desired compiler, if option provided
    compiler=""
    if [ "x$4" = x ]
    then
        echo "bamboo.sh: \$4 is empty or null, setting compiler to default"
        compiler="default"
    else
        echo "bamboo.sh: setting compiler to $4"
        compiler="$4"
    fi

    echo "bamboo.sh: compiler is set to $compiler"


    # Determine architecture
    arch=`uname -p`
    # Determine kernel name (Linux or MacOS i.e. Darwin)
    kernel=`uname -s`

    echo "bamboo.sh: KERNEL = $kernel"

    case $1 in
        default|sstmainline_config|sstmainline_config_linux_with_ariel_no_gem5|sstmainline_config_no_gem5|sstmainline_config_static|sstmainline_config_static_no_gem5|sstmainline_config_clang_core_only|sstmainline_config_macosx|sstmainline_config_macosx_no_gem5|sstmainline_config_no_mpi|sstmainline_config_test_output_config|sstmainline_config_memH_Ariel|sstmainline_config_dist_test|sstmainline_config_make_dist_no_gem5|documentation|sstmainline_config_stream|sstmainline_config_openmp|sstmainline_config_diropenmp|sstmainline_config_diropenmpB|sstmainline_config_dirnoncacheable|sstmainline_config_diropenmpI|sstmainline_config_dir3cache|sstmainline_config_all|sstmainline_config_memH_wo_openMP|sstmainline_config_develautotester_linux|sstmainline_config_develautotester_mac|sstmainline_config_valgrind|sstmainline_config_valgrind_ES|sstmainline_config_valgrind_ES2|sst-macro_withsstcore_mac|sst-macro_nosstcore_mac|sst-macro_withsstcore_linux|sst-macro_nosstcore_linux)
            #   Save Parameters $2, $3 and $4 in case they are need later
            SST_DIST_MPI=$2
            SST_DIST_BOOST=$3
            SST_DIST_PARAM4=$4

            # Configure MPI, Boost, and Compiler (Linux only)
            if [ $kernel != "Darwin" ]
            then
                linuxSetBoostMPI $1 $2 $3 $4 

            else  # kernel is "Darwin", so this is MacOS

                darwinSetBoostMPI $1 $2 $3 $4
            fi
       if [[  ${SST_WITHOUT_PIN:+isSet} == isSet ]] ; then
            echo "  This run is forced to be without PIN "
       else
            # if Intel PIN module is available, load 2.14 version
            #           ModuleEx puts the avail output on Stdout (where it belongs.)
            ModuleEx avail | egrep -q "pin/pin-2.14-71313"
            if [ $? == 0 ] 
            then
            # if `pin module is available, use 2.14.
                if [ $kernel != "Darwin" ] ; then

                   echo "using Intel PIN environment module  pin-2.14-71313-gcc.4.4.7-linux"
                    #    Compiler is $4
                   if [[ "$4" != gcc-5* ]] ; then
                       echo "Loading Intel PIN environment module"
                       ModuleEx load pin/pin-2.14-71313-gcc.4.4.7-linux
                       echo  $INTEL_PIN_DIRECTORY
                       ls $INTEL_PIN_DIRECTORY
                   else 
                      echo " ################################################################"
                      echo " #"
                      echo " #  pin-2.14-71313-gcc.4.4.7-linux is incompatible with gcc-5.x"
                      echo " #"
                      echo " ################################################################"
                   fi
                else        ##    MacOS   (Darwin)
                   echo "using Intel PIN environment module  pin-2.14-71313-clang.5.1-mac"
                   echo "Loading Intel PIN environment module"
                   ModuleEx load pin/pin-2.14-71313-clang.5.1-mac
                fi
            else
                echo "Intel PIN environment module not found on this host."
            fi
       fi

            echo "bamboo.sh: LISTING LOADED MODULES"
            ModuleEx list

            # Build type given as argument to this script
            export SST_BUILD_TYPE=$1

            if [ $SST_BUILD_TYPE = "documentation" ]
            then
                # build sst-core documentation, create list of undocumented files
                echo "Building SST-CORE Doxygen Documentation"
                pushd $SST_ROOT/sst-core
                ./autogen.sh
                ./configure --disable-silent-rules --prefix=$SST_CORE_INSTALL
                make html 2> ./doc/makeHtmlErrors.txt
                egrep "is not documented" ./doc/makeHtmlErrors.txt | sort > ./doc/undoc.txt
                test -d ./doc/html
                retval=$?
                if [ $retval -ne 0 ]
                then
                    echo "HTML directory not found! - Documentation build has failed"
                    exit 1
                fi
                popd
                
###                # build sst-elements documentation, create list of undocumented files
###                echo "Building SST-ELEMENTS Doxygen Documentation"
###                pushd $SST_ROOT/sst-elements
###                ./autogen.sh
###                ./configure --disable-silent-rules --prefix=$SST_ELEMENTS_INSTALL
###                make html 2> ./doc/makeHtmlErrors.txt
###                egrep "is not documented" ./doc/makeHtmlErrors.txt | sort > ./doc/undoc.txt
###                test -d ./doc/html
###                retval=$?
###                if [ $retval -ne 0 ]
###                then
###                    echo "HTML directory not found! - Documentation build has failed"
###                    exit 1
###                fi
###                popd
                
            else
                # Perform the build
                dobuild -t $SST_BUILD_TYPE -a $arch -k $kernel
                retval=$?
                if [[ ${SST_STOP_AFTER_BUILD:+isSet} == isSet ]] ; then
                    if [ $retval -eq 0 ] ; then
                        echo "$0 : exit success."
                    else
                        echo "$0 : exit failure."
                    fi
                    exit $retval
                fi
            fi

            ;;

        *)
            echo "$0 : unknown action \"$1\""
            retval=1
            ;;
    esac
fi
   
if [ $retval -eq 0 ]
then
    if [ $SST_BUILD_TYPE = "documentation" ]
    then
        # dump list of sst-core undocumented files
        echo "============================== SST-CORE DOXYGEN UNDOCUMENTED FILES =============================="
        sed -e 's/^/#doxygen /' ./sst-core/doc/undoc.txt
        echo "============================== SST-CORE DOXYGEN UNDOCUMENTED FILES =============================="
        retval=0
    else
        # Build was successful, so run tests, providing command line args
        # as a convenience. SST binaries must be generated before testing.

        if [[ $buildtype == *_dist_* ]] ; then  
             setUPforMakeDisttest $1 $2 $3 $4
             exit 0                  #  Normal Exit for make dist
        else          #  not make dist
            #    ---  These are probably temporary, but let's line them up properly anyway
            pwd
            echo "            CHECK ENVIRONMENT VARIABLES "
            env | grep SST
            echo "            End of SST Environs"
            pwd
            ls
            #    ---
            if [ -d "test" ] ; then
                echo " \"test\" is a directory"
                echo " ################################################################"
                echo " #"
                echo " #         ENTERING dotests  "
                echo " #"
                echo " ################################################################"
                dotests $1 $4
            fi
        fi               #   End of sstmainline_config_dist_test  conditional
    fi
fi
date

if [ $retval -eq 0 ]
then
    echo "$0 : exit success."
else
    echo "$0 : exit failure."
fi

exit $retval
