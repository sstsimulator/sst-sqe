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

# Which Repository to use for SQE (default is https://github.com/sstsimulator/sst)
if [[ ${SST_TOPSSTREPO:+isSet} != isSet ]] ; then
    SST_TOPSSTREPO=https://github.com/sstsimulator/sst
fi

###

# Which branches to use for each repo (default is devel)
if [[ ${SST_SQEBRANCH:+isSet} != isSet ]] ; then
    SST_SQEBRANCH=devel
    SST_SQEBRANCH="detached"
else
    echo ' ' ;  echo ' ' ; echo ' ' ; echo ' ' 
    echo " Attempting to set SQE branch is no op"
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

if [[ ${SST_TOPSSTBRANCH:+isSet} != isSet ]] ; then
    SST_TOPSSTBRANCH=devel
fi

echo "#############################################################"
echo "===== BAMBOO.SH STARTED ====="
echo "  GitHub SQE Repository and Branch = $SST_SQEREPO $SST_SQEBRANCH"
echo "  GitHub CORE Repository and Branch = $SST_COREREPO $SST_COREBRANCH"
echo "  GitHub ELEMENTS Repository and Branch = $SST_ELEMENTSREPO $SST_ELEMENTSBRANCH"
echo "  GitHub Top SST Repository and Branch = $SST_TOPSSTREPO $SST_TOPSSTBRANCH"
echo "#############################################################"


# Root of directory checked out, where this script should be found
export SST_ROOT=`pwd`

echo "#############################################################"
echo "  Version February 2 1100 hours "
echo ' '
pwd
ls -la
echo ' '
pushd ../sqe
echo "               SQE branch"
git branch
echo ' '
popd

##  Check out other repositories except second time on Make Dist test
if [[ ${SST_TEST_ROOT:+isSet} != isSet ]] ; then
    echo "PWD = `pwd`"

   echo "     TimeoutEx -t 300 git clone -b $SST_TOPSSTBRANCH  $SST_TOPSSTREPO . "
   TimeoutEx -t 300 git clone -b $SST_TOPSSTBRANCH $SST_TOPSSTREPO .
   retVal=$?
   if [ $retVal != 0 ] ; then
      echo "\"git clone of $SST_TOPSSTREPO \" FAILED.  retVal = $retVal"
      exit
   fi
   echo " "
   echo " the sst Repo has been cloned. Core and Elements to go"
   ls

   mkdir -p sst
   pushd sst
   pwd
   ls -l

   echo "     TimeoutEx -t 300 git clone -b $SST_COREBRANCH $SST_COREREPO core "
   TimeoutEx -t 300 git clone -b $SST_COREBRANCH $SST_COREREPO core
   retVal=$?
   if [ $retVal != 0 ] ; then
      echo "\"git clone of $SST_COREREPO \" FAILED.  retVal = $retVal"
      exit
   fi
   pushd core
   git log -n 1 | grep commit
   popd


   echo "     TimeoutEx -t 300 git clone -b $SST_ELEMENTSBRANCH $SST_ELEMENTSREPO elements "
   TimeoutEx -t 300 git clone -b $SST_ELEMENTSBRANCH $SST_ELEMENTSREPO elements
   retVal=$?
   if [ $retVal != 0 ] ; then
      echo "\"git clone of $SST_ELEMENTSREPO \" FAILED.  retVal = $retVal"
      exit
   fi
   pushd elements

   if [[ ${SST_ELEMENTS_RESET:+isSet} == isSet ]] ; then
       echo "     Desired element SHA1 is ${SST_ELEMENTS_RESET}"
       git reset --hard ${SST_ELEMENTS_RESET}
       retVal=$?
       if [ $retVal != 0 ] ; then
          echo "\"git reset --hard ${SST_ELEMENTS_RESET} \" FAILED.  retVal = $retVal"
          exit
       fi
   fi

   git log -n 1 | grep commit
   
   popd
   ls -l
   popd
   ln -s `pwd`/../sqe/buildsys/deps .
   ln -s `pwd`/../sqe/test .
fi


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
# Location where SST files are installed
export SST_INSTALL=${SST_BASE}/local
# Location where SST build files are installed
export SST_INSTALL_BIN=${SST_INSTALL}/bin

# Location where SST dependencies are installed. This only specifies
# the root; dependencies may be installed in various locations under
# this directory. The user can override this value by setting the
# exporting the SST_INSTALL_DEPS_USER variable in their environment.
export SST_INSTALL_DEPS=${SST_BASE}/local
# Initialize build type to null
export SST_BUILD_TYPE=""
# Load test definitions
echo "bamboo.sh: This directory is:"
pwd
echo "bamboo.sh: ls test/include"
ls test/include
echo "bamboo.sh: ls deps/include"
ls deps/include
echo "bamboo.sh: Sourcing test/include/testDefinitions.sh"
. test/include/testDefinitions.sh
echo "bamboo.sh: Done sourcing test/include/testDefinitions.sh"
# Load dependency definitions
echo "bamboo.sh: deps/include/depsDefinitions.sh"
. deps/include/depsDefinitions.sh
echo "bamboo.sh: Done sourcing deps/include/depsDefinitions.sh"

# Uncomment the following line or export from your environment to
# retain binaries after build
#export SST_RETAIN_BIN=1
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
 
   export JENKINS_PROJECT=`echo $WORKSPACE | awk -F'/' '{print $6}'`
   export BAMBOO_PROJECT=$1

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
         echo "      Suites to explictly OMIT from the \"all\" project:"
         ls testSuite_*sh | grep  -f __omitlist__
         echo ' '
         #   Build the Suite list for the "All" project
         ls testSuite_*sh | grep -v -f __omitlist__ > Suite.list
         echo "all() {" > files.for.all
         sed  s\%^%\${SST_TEST_SUITES}/% Suite.list >> files.for.all
         echo "}" >> files.for.all
         . files.for.all               # Source the subroutine including list
         popd
         all
         return
    fi
    
    # New CHDL test
    if [[ ${SST_DEPS_INSTALL_CHDL:+isSet} == isSet ]] ; then
        ${SST_TEST_SUITES}/testSuite_chdlComponent.sh
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
    if [ $1 == "sstmainline_config_memH_Ariel" ]
    then
        ${SST_TEST_SUITES}/testSuite_diropenMP.sh
        ${SST_TEST_SUITES}/testSuite_dirSweepB.sh
        ${SST_TEST_SUITES}/testSuite_dirSweepI.sh
        ${SST_TEST_SUITES}/testSuite_dirSweep.sh
        ${SST_TEST_SUITES}/testSuite_dirnoncacheable_openMP.sh
        ${SST_TEST_SUITES}/testSuite_noncacheable_openMP.sh
        ${SST_TEST_SUITES}/testSuite_openMP.sh
        ${SST_TEST_SUITES}/testSuite_Sweep_openMP.sh
        ${SST_TEST_SUITES}/testSuite_dir3LevelSweep.sh
        return
    fi

    #
    #   Run short list for FAST
    #
    if [ $1 == "sstmainline_config_fast" -o $1 == "sstmainline_config_fast_static" ]
    then
        ${SST_TEST_SUITES}/testSuite_BadPort.sh
        ${SST_TEST_SUITES}/testSuite_cassini_prefetch.sh
        ${SST_TEST_SUITES}/testSuite_check_maxrss.sh
        ${SST_TEST_SUITES}/testSuite_embernightly.sh
        ${SST_TEST_SUITES}/testSuite_hybridsim.sh
        ${SST_TEST_SUITES}/testSuite_memHierarchy_sdl.sh
        ${SST_TEST_SUITES}/testSuite_memHSieve.sh
        ${SST_TEST_SUITES}/testSuite_merlin.sh
        ${SST_TEST_SUITES}/testSuite_simpleMessageGeneratorComponent.sh
        ${SST_TEST_SUITES}/testSuite_miranda.sh
        ${SST_TEST_SUITES}/testSuite_prospero.sh
        ${SST_TEST_SUITES}/testSuite_qsimComponent.sh
        ${SST_TEST_SUITES}/testSuite_scheduler.sh
        ${SST_TEST_SUITES}/testSuite_simpleComponent.sh
        ${SST_TEST_SUITES}/testSuite_simpleLookupTableComponent.sh
        ${SST_TEST_SUITES}/testSuite_simpleDistribComponent.sh
        ${SST_TEST_SUITES}/testSuite_simpleRNGComponent.sh
        ${SST_TEST_SUITES}/testSuite_simpleStatisticsComponent.sh
        ${SST_TEST_SUITES}/testSuite_cacheTracer.sh
        ${SST_TEST_SUITES}/testSuite_SiriusZodiacTrace.sh
        ${SST_TEST_SUITES}/testSuite_sst_mcopteron.sh
        ${SST_TEST_SUITES}/testSuite_VaultSim.sh
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
        ${SST_TEST_SUITES}/testSuite_memHSieve.sh
        ${SST_TEST_SUITES}/testSuite_hybridsim.sh
        ${SST_TEST_SUITES}/testSuite_miranda.sh
        ${SST_TEST_SUITES}/testSuite_cassini_prefetch.sh
        ${SST_TEST_SUITES}/testSuite_prospero.sh
        ${SST_TEST_SUITES}/testSuite_Ariel.sh
        return
    fi
    
     #
     #   Suites that used by the devel AutoTester 
     #   These tests should be quick to minimize waits for approving pull requests
     #

    if [ $1 == "sstmainline_config_develautotester" ]
    then
        if [[ $SST_ROOT == *Ariel* ]] ; then
            pushd ${SST_TEST_SUITES}
            ln -s ${SST_TEST_SUITES}/testSuite_Ariel.sh testSuite_Ariel_extra.sh
            ${SST_TEST_SUITES}/testSuite_Ariel_extra.sh
            popd
        fi
        ${SST_TEST_SUITES}/testSuite_SiriusZodiacTrace.sh
        ${SST_TEST_SUITES}/testSuite_embernightly.sh
        ${SST_TEST_SUITES}/testSuite_BadPort.sh
        ${SST_TEST_SUITES}/testSuite_memHierarchy_sdl.sh
        ${SST_TEST_SUITES}/testSuite_memHSieve.sh
        ${SST_TEST_SUITES}/testSuite_hybridsim.sh
        ${SST_TEST_SUITES}/testSuite_miranda.sh
        ${SST_TEST_SUITES}/testSuite_cassini_prefetch.sh
        ${SST_TEST_SUITES}/testSuite_prospero.sh
        ${SST_TEST_SUITES}/testSuite_Ariel.sh
        return
    fi
    

    if [ $kernel != "Darwin" ]
    then
        # Only run if the OS *isn't* Darwin (MacOS)
        ${SST_TEST_SUITES}/testSuite_qsimComponent.sh
#       ${SST_TEST_SUITES}/testSuite_hybridsim.sh
    elif [ $1 == "sstmainline_config_macosx_static" -a $macosVersion == "10.9" ]
    then
    #   Run an extra pass of the mcOpteron test
        ln -s ${SST_TEST_SUITES}/testSuite_sst_mcopteron.sh ${SST_TEST_SUITES}/testSuite_sst_mcopteron2.sh
        ${SST_TEST_SUITES}/testSuite_sst_mcopteron2.sh
    fi
    #
    #   Only run if configured for ariel
    #
#    if [[ $1 == sstmainline_config_linux_with_ariel* ]]
#    then
#         ${SST_TEST_SUITES}/testSuite_Ariel.sh
#    else
#         ${SST_TEST_SUITES}/testSuite_scheduler.sh
#    fi

    #  
    #    Only if macsim was requested
    #
    if [ -d ${SST_ROOT}/sst/elements/macsimComponent ] ; then
         ${SST_TEST_SUITES}/testSuite_macsim.sh
    fi

    ${SST_TEST_SUITES}/testSuite_Ariel.sh
    ${SST_TEST_SUITES}/testSuite_hybridsim.sh
    ${SST_TEST_SUITES}/testSuite_SiriusZodiacTrace.sh
    ${SST_TEST_SUITES}/testSuite_memHierarchy_sdl.sh
    ${SST_TEST_SUITES}/testSuite_memHSieve.sh
    ${SST_TEST_SUITES}/testSuite_sst_mcopteron.sh


    ${SST_TEST_SUITES}/testSuite_simpleComponent.sh
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
 
    ${SST_TEST_SUITES}/testSuite_simpleDistribComponent.sh
    ${SST_TEST_SUITES}/testSuite_EmberSweep.sh

#gem5    if [ $1 != "sstmainline_config_gcc_4_8_1" -a $1 != "sstmainline_config_no_mpi" ] && [[ $1 != *no_gem5* ]] 
#gem5    then
#gem5        # Don't run gem5 dependent test suites in these configurations
#gem5        # because gem5 is not enabled in them.
#gem5        ${SST_TEST_SUITES}/testSuite_M5.sh
#gem5        ${SST_TEST_SUITES}/testSuite_memHierarchy_bin.sh
#gem5
#gem5        # These also fail in gem5 with CentOS 6.6 (libgomp-4.4.7-11 vs libgomp-4.4.7-4)  
#gem5        #         Also fail on current (Jan 21, 2015) TOSS VM
#gem5#################################  February 3rd
#gem5#   remove the TOSS and CentOS 6.6 exclusion
#gem5#        Tests have been converted to use prebuilt binaries.
#gem5#
#gem5#        CentOS_version=`cat /etc/centos-release`
#gem5#        echo " CentOS Version is ${CentOS_version}"
#gem5#        if [ "${CentOS_version}" == "CentOS release 6.6 (Final)" ] ; then
#gem5#           echo " This is CentOS 6.6,  omit running OpenMP tests.  Gem-5 is \"defunct\""
#gem5#        elif [ "${SST_TEST_HOST_OS_DISTRIB}" == "toss" ] ; then
#gem5#           echo " This is TOSS,  omit running OpenMP tests.  Gem-5 is \"defunct\""
#gem5#        else
#gem5           ${SST_TEST_SUITES}/testSuite_openMP.sh
#gem5           ${SST_TEST_SUITES}/testSuite_diropenMP.sh
#gem5           ${SST_TEST_SUITES}/testSuite_stream.sh
#gem5           ${SST_TEST_SUITES}/testSuite_noncacheable_openMP.sh
#gem5#        fi
#gem5    fi

    if [ $1 != "sstmainline_config_no_mpi" ] ; then
        #  Zoltan test requires MPI to execute.
        #  sstmainline_config_no_gem5 deliberately omits Zoltan, so must skip test.
        if [ $1 != "sstmainline_config_linux_with_ariel" ] ; then
            ${SST_TEST_SUITES}/testSuite_zoltan.sh
            ${SST_TEST_SUITES}/testSuite_partitioner.sh
        fi
    fi
    ${SST_TEST_SUITES}/testSuite_simpleRNGComponent.sh
    ${SST_TEST_SUITES}/testSuite_simpleStatisticsComponent.sh
      
    HOST=`uname -n | awk -F. '{print $1}'`

    if [ $HOST == "sst-test" ] ; then
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

###     ## run only on HardWare
###     
###     if [ $HOST == "sst-test" ] || [ $HOST == "johnslion" ] ; then
###         echo " $HOST: Running the Wall Clock timing test"
###         ${SST_TEST_SUITES}/testSuite_simpleClockerComponent.sh
###     else
###         echo " $HOST: Not Running the Wall Clock timing test"
###     fi
### 
###     ## run above only on HardWare
    

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
    baseoptions="--disable-silent-rules --prefix=$SST_INSTALL --with-boost=$SST_DEPS_INSTALL_BOOST"
    echo "setConvenienceVars() : baseoptions = $baseoptions"
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

    local mpi_environment="CC=${cc_compiler} CXX=${cxx_compiler} MPICC=${mpicc_compiler} MPICXX=${mpicxx_compiler}"

    # make sure that sstmacro is suppressed
    if [ -e ./sst/elements/macro_component/.unignore ] && [ -f ./sst/elements/macro_component/.unignore ]
    then
        rm ./sst/elements/macro_component/.unignore
    fi

    # On MacOSX Lion, suppress the following:
#    #      PhoenixSim
#    if [ $3 == "Darwin" ]
#    then
#        echo "$USER" > ./sst/elements/PhoenixSim/.ignore
#    fi

    case $1 in
        sstmainline_config) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -g none -m none -i none -o none -h none -s none -q none -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME}  --with-chdl=$SST_DEPS_INSTALL_CHDL --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $miscEnv"
            ;;
        sstmainline_config_VaultSim) 
            #-----------------------------------------------------------------
            # sstmainline_config    -- temporary for testing with VaultSim
            #    This one should be refined or incorporated into something else with dir changed.
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM $miscEnv --with-libphx=$LIBPHX_HOME/src --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN"
            ;;
        sstmainline_config_all) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-libphx=$LIBPHX_HOME/src --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-metis=${METIS_HOME}  --with-chdl=$SST_DEPS_INSTALL_CHDL $miscEnv"
            ;;
        sstmainline_config_stream|sstmainline_config_openmp|sstmainline_config_diropenmp|sstmainline_config_diropenmpB|sstmainline_config_diropenmpI|sstmainline_config_dirnoncacheable|sstmainline_config_dir3cache|sstmainline_config_memH_Ariel) 
            #-----------------------------------------------------------------
            # sstmainline_config  One only of stream, openmp diropemMP
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -g none -m none -i none -o none -h none -s none -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $miscEnv"
            ;;
        sstmainline_config_linux_with_ariel) 
            #-----------------------------------------------------------------
            # sstmainline_config_linux_with_ariel
            #     This option used for configuring SST with supported stabledevel deps,
            #     Intel PIN, and Ariel 
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-metis=${METIS_HOME} $miscEnv"
            ;;
        sstmainline_config_linux_with_ariel_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_linux_with_ariel_no_gem5
            #     This option used for configuring SST with supported stabledevel deps,
            #     Intel PIN, and Ariel, but without Gem5 
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z 3.83 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN --with-metis=${METIS_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN $miscEnv"
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
            ls -a sst/elements/ariel
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g none -m none -i none -o none -h none -s none -q none -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} --with-chdl=$SST_DEPS_INSTALL_CHDL $miscEnv --with-pin=$SST_DEPS_INSTALL_INTEL_PIN"
            ;;
        sstmainline_config_no_gem5_intel_gcc_4_8_1) 
            #-----------------------------------------------------------------
            # sstmainline_config_no_gem5_wo_chdl
            #     This option used for configuring SST with supported stabledevel deps
            #     Some compilers (gcc 4.7, 4.8, intel 13.4) have problems building gem5,
            #     so this option removes gem5 in order to evaluate the rest of the build
            #     under those compilers. Omit chdl.  
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c none"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv $IntelExtraConfigStr"
            ;;

        sstmainline_config_no_gem5_intel_gcc_4_8_1_with_c) 
            #-----------------------------------------------------------------
            # sstmainline_config_no_gem5_wo_chdl
            #     This option used for configuring SST with supported stabledevel deps
            #     Some compilers (gcc 4.7, 4.8, intel 13.4) have problems building gem5,
            #     so this option removes gem5 in order to evaluate the rest of the build
            #     under those compilers. Include chdl.  
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} --with-chdl=$SST_DEPS_INSTALL_CHDL $miscEnv $IntelExtraConfigStr"
            ;;

        sstmainline_config_fast_intel_build_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_no_gem5_wo_chdl
            #     This option used for configuring SST with supported stabledevel deps
            #     Some compilers (gcc 4.7, 4.8, intel 13.4) have problems building gem5,
            #     so this option removes gem5 in order to evaluate the rest of the build
            #     under those compilers. Omit chdl.  CXXFLAGS=-gxx-name=/usr/local/module-pkgs/gcc/4.8.1/bin/g++ CFLAGS=-gcc-name=/usr/local/module-pkgs/gcc/4.8.1/bin/gcc"
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d none -p none  -g none -m none -i none -o none -h none -s none -q none -M none  -z none -c none"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv $IntelExtraConfigStr"
            ModuleEx unload metis
            ;;

        sstmainline_config_no_mpi|sstmainline_config_fast) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="CC=${cc_compiler} CXX=${cxx_compiler}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM $miscEnv --disable-mpi"
            ;;

        sstmainline_config_gem5_gcc_4_6_4) 
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST, forcing gem5 to be built with gcc-4.6.4
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g gcc-4.6.4 -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83 -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} --with-chdl=$SST_DEPS_INSTALL_CHDL $miscEnv"
            ;;

        sstmainline_config_gcc_4_8_1) 
            #-----------------------------------------------------------------
            # sstmainline_config_gcc_4_8_1
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-qsim=$SST_DEPS_INSTALL_QSIM $miscEnv"
            ;;
        sstmainline_config_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_static
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv"
            ;;

        sstmainline_config_static_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_static   WITH OUT GEM5
            #     This option used for configuring a static SST without Gem5
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M 2.2.0 -N default -z 3.83"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $miscEnv"
            ;;

        sstmainline_config_fast_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_fast_static
            #     This option used for quick static run omiting many options
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="CC=${cc_compiler} CXX=${cxx_compiler}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g none -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --enable-static --disable-shared $miscEnv --disable-mpi"
            ;;

        sstmainline_config_clang_core_only) 
            #-----------------------------------------------------------------
            # sstmainline_config_clang_core_only
            #     This option used for configuring SST with no deps to build the core with clang
            #-----------------------------------------------------------------
            depsStr="-k none -d 2.2.2 -p none -z none -b none -g none -m none -i none -o none -h none -s none -q none -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM"
            ;;
        sstmainline_config_macosx) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q none -z 3.83 -N default -M 2.2.0"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv"
            ;;
        sstmainline_config_macosx_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_no_gem5
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z 3.83  -b 1.50 -g none -m none -i none -o none -h none -s none -q none -M none -N default -c default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions ${MTNLION_FLAG} --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} --with-chdl=$SST_DEPS_INSTALL_CHDL $miscEnv"
            ;;
        sstmainline_config_macosx_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_static
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q none -z 3.83 -N default -M 2.2.0"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv"
            ;;
        sstmainline_config_macosx_static_no_gem5) 
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_static_no_gem5
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g none -m none -i none -o none -h none -s none -q none -z 3.83 -N default -M 2.2.0"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-metis=${METIS_HOME} $miscEnv"
            ;;
        sstmainline_config_static_macro_devel) 
            #-----------------------------------------------------------------
            # sstmainline_config_static_macro_devel
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g stabledevel -m none -i none -o none -h none -s stabledevel -q 0.2.1 -M none"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-sstmacro=$SST_DEPS_INSTALL_SSTMACRO  --with-qsim=$SST_DEPS_INSTALL_QSIM --enable-static --disable-shared $miscEnv"
            ;;
        sstmainline_sstmacro_xconfig) 
            #-----------------------------------------------------------------
            # sstmainline_sstmacro_xconfig
            #     This option used for configuring SST with sstmacro latest mainline UNSTABLE
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g stabledevel -m none -i none -o none -h none -s stabledevel -q 0.2.1 -M none"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-sstmacro=$SST_DEPS_INSTALL_SSTMACRO  --with-qsim=$SST_DEPS_INSTALL_QSIM $miscEnv"
            ;;
        sstmainline_config_test_output_config)
            #-----------------------------------------------------------------
            # sstmainline_config_test_output_config
            #     This option used for verifying the SST "--output-config" option
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q 0.2.1 -M none -N default -z 3.83"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --with-qsim=$SST_DEPS_INSTALL_QSIM $miscEnv --with-zoltan=$SST_DEPS_INSTALL_ZOLTAN --with-pin=$SST_DEPS_INSTALL_INTEL_PIN"
            ;;
        sstmainline_config_xml2python_static) 
            #-----------------------------------------------------------------
            # sstmainline_config_xml2python
            #     This option used for verifying the auto generation of Python input files
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -b 1.50 -g stabledevel -m none -i none -o none -h none -s none -q none -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-gem5=$SST_DEPS_INSTALL_GEM5SST --with-gem5-build=opt --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-glpk=${GLPK_HOME} --enable-static --disable-shared $miscEnv"
            ;;
        sstmainline_config_memH_wo_openMP)
            #-----------------------------------------------------------------
            # sstmainline_config_memH_wo_openMP
            #     This option used for configuring SST with memHierarchy, but with out open MP
            #     with Intel PIN, and Ariel 
            #     (Might as well skip building scheduler)
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            touch sst/elements/scheduler/.ignore
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -m none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $miscEnv"
            ;;
        sstmainline_config_develautotester)
            #-----------------------------------------------------------------
            # sstmainline_config_develautotester
            #     This option used for configuring SST with memHierarchy, but with out open MP
            #     with Intel PIN, and Ariel 
            #     (Might as well skip building scheduler)
            #     THIS IS THE CONFIGURATION USED FOR THE DEVEL AUTOTESTER, THE
            #     BUILD AND TESTS SHOULD BE AS QUICK AS POSSIBLE, WE ARE WILLING
            #     TO SACRIFICE SOME COVERAGE TO GET A GENERAL WARM FUZZY ON THE 
            #     PULL REQUESTS TO DEVEL BRANCH BEING NOT CATASTROPIC FAILURES
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            touch sst/elements/scheduler/.ignore
            miscEnv="${mpi_environment}"
            depsStr="-k none -d 2.2.2 -p none -z none -m none -o none -h none -s none -q 0.2.1 -M none -N default"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-qsim=$SST_DEPS_INSTALL_QSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $miscEnv"
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
            configStr="$baseoptions  --with-glpk=${GLPK_HOME} --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-metis=${METIS_HOME}"
   
  ## perhaps do no more here
            ;;
        default)
            #-----------------------------------------------------------------
            # default
            #     Do the default build. But this is probably not what you want!
            #-----------------------------------------------------------------
            depsStr="$defaultDeps"
            setConvenienceVars "$depsStr"
            configStr="$baseoptions --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM"
            ;;

        *)
            #-----------------------------------------------------------------
            #  Unrecognized Project,  This is an error in the bamboo code
            #-----------------------------------------------------------------
            echo ' ' ; echo "Unrecognized Project,  This is an error in the bamboo code"
            echo " UNRECOGNIZED:   ${1}"
            exit 1            
            ;;
    esac

    export SST_SELECTED_DEPS="$depsStr"
    export SST_SELECTED_CONFIG="$configStr"
#    echo $configStr
}


#-------------------------------------------------------------------------
# Function: linuxSetBoostMPI
# Description:
#   Purpose: Performs selection and loading of Bost and MPI modules
#            for MacOS
#   Input:
#   Output:
#   Return value:
linuxSetBoostMPI() {

   # For some reason, .bashrc is not being run prior to
   # this script. Kludge initialization of modules.

   if [ $SST_TEST_HOST_OS_DISTRIB_VERSION != "16.04" ] ; then
       if [ -f /etc/profile.modules ] ; then
           . /etc/profile.modules
           echo "bamboo.sh: loaded /etc/profile.modules. Available modules"
           ModuleEx avail
       fi
   else
       ls -l /etc/profile.d/modules.sh
       if [ -r /etc/profile.d/modules.sh ] ; then 
           source /etc/profile.d/modules.sh 
           echo " bamboo.sh:  Available modules"
           ModuleEx avail
           if [ $? -ne 0 ] ; then
               echo " ModuleEx Failed"
               exit 1
           fi    
       fi
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
       boost-1.56|boost-1.58) 
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
       mpich2_stable|mpich2-1.4.1p1)
           echo "MPICH2 stable (mpich2-1.4.1p1) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
       openmpi-1.7.2)
           echo "OpenMPI 1.7.2 (openmpi-1.7.2) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
       ompi_1.6_stable|openmpi-1.6)
           echo "OpenMPI stable (openmpi-1.6) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
       openmpi-1.4.4)
           echo "OpenMPI (openmpi-1.4.4) selected"
           ModuleEx unload mpi # unload any default to avoid conflict error
           ModuleEx load mpi/${desiredMPI}
           ;;
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
       boost-1.43)
           echo "bamboo.sh: Boost 1.43 selected"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost}
           ;;
       boost-1.48)
           echo "bamboo.sh: Boost 1.48 selected"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost}
           ;;
       boost-1.50)
           echo "bamboo.sh: Boost 1.50 selected"
           ModuleEx unload boost
           ModuleEx load boost/${desiredBoost}
           ;;
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
       myBoost)
           if [ $2 == "openmpi-1.8" ] ; then
               export BOOST_HOME=/home/jpvandy/local/packages/boost/boost-1.54.0_ompi-1.8_mine
               export BOOST_LIBS=/home/jpvandy/local/packages/boost/boost-1.54.0_ompi-1.8_mine/lib
               export BOOST_INCLUDE=/home/jpvandy/local/packages/boost/boost-1.54.0_ompi-1.8_mine/include
           else
               export BOOST_LIBS=/home/jpvandy/User-Build-Oct14/local/module-pkgs/boost/boost-1.54.0/lib
               export BOOST_HOME=/home/jpvandy/User-Build-Oct14/local/module-pkgs/boost/boost-1.54.0
               export BOOST_INCLUDE=/home/jpvandy/User-Build-Oct14/local/module-pkgs/boost/boost-1.54.0/include
           fi
           ;; 
       noMpiBoost)
           export BOOST_LIBS=/home/jpvandy/local/packages/boost-1.54_no-mpi/lib
           export BOOST_HOME=/home/jpvandy/local/packages/boost-1.54_no-mpi
           export BOOST_INCLUDE=/home/jpvandy/local/packages/boost-1.54_no-mpi/include
           export LD_LIBRARY_PATH=$BOOST_LIBS:$LD_LIBRARY_PATH
           ;;
       noMpiBoost-1.56)
           export BOOST_LIBS=/home/jpvandy/local/packages/boost-1.56_no-mpi/lib
           export BOOST_HOME=/home/jpvandy/local/packages/boost-1.56_no-mpi
           export BOOST_INCLUDE=/home/jpvandy/local/packages/boost-1.56_no-mpi/include
           export LD_LIBRARY_PATH=$BOOST_LIBS:$LD_LIBRARY_PATH
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
#       echo "bamboo.sh: Load libphx (gcc 4.6.4 variant)"
#       ModuleEx load libphx/libphx-2014-MAY-08_${compiler}
   fi
}


#-------------------------------------------------------------------------
# Function: ldModulesYosemiteClang
# Description:
#   Purpose: Performs selection and loading of Boost and MPI and 
#            other compiler specific modules for MacOS Yosemite
#   Parameter:   name of Clang compiler such as (clang-700.1.76)

ldModulesYosemiteClang() {
    ClangVersion=$1            #   example "clang-700.0.72"
                        ModuleEx avail
                        # Use Boost and MPI built with CLANG from Xcode 6.3
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
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_$ClangVersion

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_$ClangVersion
                                ;;
                            *)
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
    macosVersion=${macosVersionFull%.*}

    if [[ $macosVersion = "10.8" && $compiler = "clang-503.0.40" ]]
    then
        # Mountain Lion + clang PATH                    
        PATH="$HOME/Documents/GNUTools/Automake/1.14.1/bin:$HOME/Documents/GNUTools/Autoconf/2.69.0/bin:$HOME/Documents/GNUTools/Libtool/2.4.2/bin:$HOME/Documents/wget-1.15/bin:$PATH"
        export PATH

        # Mountain Lion requires this extra flag passed to SST ./configure
        # Mavericks does not require this.
        MTNLION_FLAG="--disable-cxx11"
        export MTNLION_FLAG
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
            10.6) # Snow Leopard
                # use modules Boost, built-in MPI, default compiler
                ModuleEx unload boost
                ModuleEx add boost/boost-1.50.0
                ModuleEx list
                ;;
            10.7) # Lion
                # use modules Boost and MPI, default compiler (gcc)
                ModuleEx unload mpi
                ModuleEx unload boost

#              // Lion used to be hardcoded to this configuration, now changed.                            
#              ModuleEx add mpi/openmpi-1.4.4_gcc-4.2.1
#              ModuleEx add boost/boost-1.50.0_ompi-1.4.4_gcc-4.2.1

                #Check for Illegal configurations of Boost and MPI
                if [[ ( $2 = "openmpi-1.7.2" &&  $3 = "boost_default" ) || \
                      ( $2 = "openmpi-1.7.2" &&  $3 = "boost-1.50" )    || \
                      ( $2 = "openmpi-1.4.4" &&  $3 = "boost-1.54" )    || \
                      ( $2 = "ompi_default"  &&  $3 = "boost-1.54" ) ]]
                then
                    echo "ERROR: Invalid configuration of $2 and $3 These two modules cannot be combined"
                    exit 0
                fi
               
                # load MPI
                case $2 in
                    openmpi-1.7.2)
                        echo "OpenMPI 1.7.2 (openmpi-1.7.2) selected"
                        ModuleEx add mpi/openmpi-1.7.2_gcc-4.2.1
                        ;;
                    ompi_default|openmpi-1.4.4)
                        echo "OpenMPI 1.4.4 (Default) (openmpi-1.4.4) selected"
                        ModuleEx add mpi/openmpi-1.4.4_gcc-4.2.1
                        ;;
                    *)
                        echo "Default MPI option, loading mpi/openmpi-1.4.4"
                        ModuleEx load mpi/openmpi-1.4.4_gcc-4.2.1 2>catch.err
                        if [ -s catch.err ] 
                        then
                            cat catch.err
                            exit 0
                        fi
                        ;;
                esac
                                    
                # load corresponding Boost
                case $3 in
                    boost-1.54)
                        echo "Boost 1.54 selected"
                        ModuleEx add boost/boost-1.54.0_ompi-1.7.2_gcc-4.2.1
                        ;;
                    boost_default|boost-1.50)
                        echo "Boost 1.50 (Default) selected"
                        ModuleEx add boost/boost-1.50.0_ompi-1.4.4_gcc-4.2.1
                        ;;
                    *)
                        echo "bamboo.sh: \"Default\" Boost selected"
                        echo "Third argument was $3"
                        echo "Loading boost/Boost 1.50"
                        ModuleEx load boost/boost-1.50.0_ompi-1.4.4_gcc-4.2.1 2>catch.err
                        if [ -s catch.err ] 
                        then
                            cat catch.err
                            exit 0
                        fi
                        ;;
                esac
                export CC=`which gcc`
                export CXX=`which g++`
                ModuleEx list
                ;;
            10.8) # Mountain Lion
                # Depending on specified compiler, load Boost and MPI
                case $compiler in
                    gcc-4.2.1)
                        # Use Selected Boost and MPI built with GCC
                        ModuleEx unload mpi
                        ModuleEx unload boost

                       #Check for Illegal configurations of Boost and MPI
                        if [[ ( $2 = "openmpi-1.7.2" &&  $3 = "boost_default" ) || \
                              ( $2 = "openmpi-1.7.2" &&  $3 = "boost-1.50" )    || \
                              ( $2 = "openmpi-1.6.3" &&  $3 = "boost-1.54" )    || \
                              ( $2 = "ompi_default"  &&  $3 = "boost-1.54" ) ]]
                        then
                            echo "ERROR: Invalid configuration of $2 and $3 These two modules cannot be combined"
                            exit 0
                        fi
                       
                        # load MPI
                        case $2 in
                            openmpi-1.7.2)
                                echo "OpenMPI 1.7.2 (openmpi-1.7.2) selected"
                                ModuleEx add mpi/openmpi-1.7.2_gcc-4.2.1
                                ;;
                            ompi_default|openmpi-1.6.3)
                                echo "OpenMPI 1.6.3 (Default) (openmpi-1.6.3) selected"
                                ModuleEx add mpi/openmpi-1.6.3_gcc-4.2.1
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.6.3"
                                ModuleEx load mpi/openmpi-1.6.3_gcc-4.2.1 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.7.2_gcc-4.2.1
                                ;;
                            boost_default|boost-1.50)
                                echo "Boost 1.50 (Default) selected"
                                ModuleEx add boost/boost-1.50.0_ompi-1.6.3_gcc-4.2.1
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.50"
                                ModuleEx load boost/boost-1.50.0_ompi-1.6.3_gcc-4.2.1 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                        export CC=`which gcc`
                        export CXX=`which g++`
                        ModuleEx list
                        ;;
                        
                        
                    clang-425.0.27)
                        # Use Boost and MPI built with CLANG
                        ModuleEx unload mpi
                        ModuleEx unload boost

                       #Check for Illegal configurations of Boost and MPI
                        if [[ ( $2 = "openmpi-1.7.2" &&  $3 = "boost_default" ) || \
                              ( $2 = "openmpi-1.7.2" &&  $3 = "boost-1.50" )    || \
                              ( $2 = "openmpi-1.6.3" &&  $3 = "boost-1.54" )    || \
                              ( $2 = "ompi_default"  &&  $3 = "boost-1.54" ) ]]
                        then
                            echo "ERROR: Invalid configuration of $2 and $3 These two modules cannot be combined"
                            exit 0
                        fi

                        # load MPI
                        case $2 in
                            openmpi-1.7.2)
                                echo "OpenMPI 1.7.2 (openmpi-1.7.2) selected"
                                ModuleEx add mpi/openmpi-1.7.2_clang-425.0.27
                                ;;
                            ompi_default|openmpi-1.6.3)
                                echo "OpenMPI 1.6.3 (Default) (openmpi-1.6.3) selected"
                                ModuleEx add mpi/openmpi-1.6.3_clang-425.0.27
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.6.3"
                                ModuleEx load mpi/openmpi-1.6.3_clang-425.0.27 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.7.2_clang-425.0.27
                                ;;
                            boost_default|boost-1.50)
                                echo "Boost 1.50 (Default) selected"
                                ModuleEx add boost/boost-1.50.0_ompi-1.6.3_clang-425.0.27
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.50"
                                ModuleEx load boost/boost-1.50.0_ompi-1.6.3_clang-425.0.27 2>catch.err
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
###
                    gcc-4.6.4)
                        # Use Selected Boost and MPI built with MacPorts GCC 4.6.4
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load gcc-4.6.4 specific modules
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_gcc-4.6.4
                        # System C
#                        echo "bamboo.sh: Load System C"
#                        ModuleEx load systemc/systemc-2.3.0_gcc-4.6.4
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_gcc-4.6.4
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_gcc-4.6.4

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_gcc-4.6.4
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_gcc-4.6.4 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac

                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.8_gcc-4.6.4
                                ;;
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_gcc-4.6.4
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx add boost/boost-1.56.0-nompi_gcc-4.6.4 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                        export CC=`which gcc`
                        export CXX=`which g++`
                        ModuleEx list
                        ;;
                        
                    clang-503.0.38)
                        # Use Boost and MPI built with CLANG from Xcode 5.1
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-503.0.38
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-503.0.38
                        # System C
#                        echo "bamboo.sh: Load System C"
#                        ModuleEx load systemc/systemc-2.3.0_clang-503.0.38
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-503.0.38
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-503.0.38

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-503.0.38
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-503.0.38 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.8_clang-503.0.38
                                ;;
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_clang-503.0.38
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-503.0.38 2>catch.err
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

                    clang-503.0.40)
                        # Use Boost and MPI built with CLANG from Xcode 5.1
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-503.0.40
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-503.0.40 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.8_clang-503.0.40
                                ;;
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_clang-503.0.40
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-503.0.40 2>catch.err
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

###
                    *)
                        # unknown compiler, use default
                        echo "bamboo.sh: Unknown compiler selection. Assuming gcc."
                        ModuleEx unload boost
                        ModuleEx unload mpi
                        ModuleEx add boost/boost-1.50.0_ompi-1.6.3_gcc-4.2.1
                        ModuleEx add mpi/openmpi-1.6.3_gcc-4.2.1
                        ModuleEx list
                        ;;  
                esac
                ;;

################################################################################
            10.9) # Mavericks
                # Depending on specified compiler, load Boost and MPI
                case $compiler in
                    gcc-4.6.4)
                        # Use Selected Boost and MPI built with MacPorts GCC 4.6.4
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load gcc-4.6.4 specific modules
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_gcc-4.6.4
                        # System C
#                        echo "bamboo.sh: Load System C"
#                        ModuleEx load systemc/systemc-2.3.0_gcc-4.6.4
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_gcc-4.6.4
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_gcc-4.6.4

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_gcc-4.6.4
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_gcc-4.6.4 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac

                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.8_gcc-4.6.4
                                ;;
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_gcc-4.6.4
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx add boost/boost-1.56.0-nompi_gcc-4.6.4 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                        export CC=`which gcc`
                        export CXX=`which g++`
                        ModuleEx list
                        ;;
                        
                    clang-503.0.38)
                        # Use Boost and MPI built with CLANG from Xcode 5.1
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-503.0.38
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-503.0.38
                        # System C
#                        echo "bamboo.sh: Load System C"
#                        ModuleEx load systemc/systemc-2.3.0_clang-503.0.38
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-503.0.38
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-503.0.38

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-503.0.38
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-503.0.38 2>catch.err
                                if [ -s catch.err ] 
                                then
                                    cat catch.err
                                    exit 0
                                fi
                                ;;
                        esac
                                            
                        # load corresponding Boost
                        case $3 in
                            boost_default|boost-1.54)
                                echo "Boost 1.54 selected"
                                ModuleEx add boost/boost-1.54.0_ompi-1.8_clang-503.0.38
                                ;;
                            boost_default|boost-1.56)
                                echo "Boost 1.56 selected"
                                ModuleEx add boost/boost-1.56.0-nompi_clang-503.0.38
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-503.0.38 2>catch.err
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

                    clang-600.0.57)
                        # Use Boost and MPI built with CLANG from Xcode 5.1
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-600.0.57
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-600.0.57
                        # System C
#                         echo "bamboo.sh: Load System C"
#                         ModuleEx load systemc/systemc-2.3.0_clang-600.0.57
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-600.0.57
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-600.0.57

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-600.0.57
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-600.0.57 2>catch.err
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
                                ModuleEx add boost/boost-1.56.0-nompi_clang-600.0.57
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-600.0.57 2>catch.err
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


                    *)
                        # unknown compiler, use default
                        echo "bamboo.sh: Unknown compiler selection. Assuming gcc."
                        ModuleEx unload boost
                        ModuleEx unload mpi
                        ModuleEx add mpi/openmpi-1.8_gcc-4.6.4
                        ModuleEx add boost/boost-1.56.0-nompi_gcc-4.6.4
                        ModuleEx list
                        ;;  
                esac
                ;;
################################################################################
            10.10) # Yosemite
                ModuleEx avail
                # Depending on specified compiler, load Boost and MPI
                case $compiler in
                    clang-600.0.57)
                        # Use Boost and MPI built with CLANG from Xcode 6.2
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-600.0.57
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-600.0.57
                        # # System C
                        # echo "bamboo.sh: Load System C"
                        # ModuleEx load systemc/systemc-2.3.0_clang-600.0.57
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-600.0.57
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-600.0.57

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-600.0.57
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-600.0.57 2>catch.err
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
                                ModuleEx add boost/boost-1.56.0-nompi_clang-600.0.57
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-600.0.57 2>catch.err
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

                    clang-602.0.49)
                        # Use Boost and MPI built with CLANG from Xcode 6.3
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-602.0.49
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-602.0.49
                        # # System C
                        # echo "bamboo.sh: Load System C"
                        # ModuleEx load systemc/systemc-2.3.0_clang-602.0.49
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-602.0.49
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-602.0.49

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-602.0.49
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-602.0.49 2>catch.err
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
                                ModuleEx add boost/boost-1.56.0-nompi_clang-602.0.49
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-602.0.49 2>catch.err
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

                    clang-602.0.53)
                        # Use Boost and MPI built with CLANG from Xcode 6.3
                        ModuleEx unload mpi
                        ModuleEx unload boost

                        # Load other modules for clang-602.0.53
                        # GNU Linear Programming Kit (GLPK)
                        echo "bamboo.sh: Load GLPK"
                        ModuleEx load glpk/glpk-4.54_clang-602.0.53
                        # # System C
                        # echo "bamboo.sh: Load System C"
                        # ModuleEx load systemc/systemc-2.3.0_clang-602.0.53
                        # METIS 5.1.0
                        echo "bamboo.sh: Load METIS 5.1.0"
                        ModuleEx load metis/metis-5.1.0_clang-602.0.53
                        # Other misc
#                        echo "bamboo.sh: Load libphx"
#                        ModuleEx load libphx/libphx-2014-MAY-08_clang-602.0.53

                        # load MPI
                        case $2 in
                            ompi_default|openmpi-1.8)
                                echo "OpenMPI 1.8 (openmpi-1.8) selected"
                                ModuleEx add mpi/openmpi-1.8_clang-602.0.53
                                ;;
                            *)
                                echo "Default MPI option, loading mpi/openmpi-1.8"
                                ModuleEx load mpi/openmpi-1.8_clang-602.0.53 2>catch.err
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
                                ModuleEx add boost/boost-1.56.0-nompi_clang-602.0.53
                                ;;
                            *)
                                echo "bamboo.sh: \"Default\" Boost selected"
                                echo "Third argument was $3"
                                echo "Loading boost/Boost 1.56"
                                ModuleEx load boost/boost-1.56.0-nompi_clang-602.0.53 2>catch.err
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
                        ldModulesYosemiteClang clang-700.1.76    #  Xcode 7.1
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
                   ldModulesYosemiteClang clang-700.1.76    #  Xcode 7.1
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
#   Purpose: Unpack the make-dist tar and set the environment for testing 
#          
#   Input:
#   Output:
#   Return value:
setUPforMakeDisttest() {
     echo "Setting up to build from the tar created by make dist"
     echo "---   PWD  `pwd`"           ## Original trunk
     Package=`ls| grep 'sst-.*tar.gz' | awk -F'.tar' '{print $1}'`
     echo  PACKAGE is $Package
     tarName=${Package}.tar.gz
     ls $tarFile
     if [ $? != 0 ] ; then
         ls
         echo Can NOT find Tar File $Package .tar.gz
         exit 1
     fi
     mkdir $SST_ROOT/distTestDir
     cd $SST_ROOT/distTestDir
     mv $SST_ROOT/$tarName .
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
     mv $Package trunk
     echo "Move in items not in the trunk, that are need for the bamboo build and test"
     cp  $SST_ROOT/../sqe/buildsys/bamboo.sh trunk
     if [ -e trunk/deps ] ; then
        cp -r $SST_ROOT/deps/bin trunk/deps       ## the deps scripts
        cp -r $SST_ROOT/deps/include trunk/deps          ## the deps scripts
        cp -r $SST_ROOT/deps/patches trunk/deps          ## the deps scripts
     else
        cp -r $SST_ROOT/deps trunk          ## the deps scripts
     fi
     if [ ! -e trunk/deps/bin ] ; then
         echo " FAILED  FAILED FAILED FAILED FAILED FAILED FAILED"
         echo SST_ROOT = $SST_ROOT
         ls $SST_ROOT/deps
         echo " FAILED  FAILED FAILED FAILED FAILED FAILED FAILED"
         exit
     fi
     cd trunk
     echo "                   List the directories in sst/elements"
     ls sst/elements
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
         distProject="sstmainline_config_all"
     else
         distProject="sstmainline_config_no_gem5"
     fi

              ##  Here is the bamboo invocation within bamboo
     echo "         INVOKE bamboo for the build from the dist tar"
     ./bamboo.sh $distProject $SST_DIST_MPI $SST_DIST_BOOST $SST_DIST_PARAM4
     retval=$?
     echo "         Returned from bamboo.sh $retval"
     if [ $retval != 0 ] ; then
         echo "bamboo build reports failure  retval = $reval"
         exit 1
     fi
}

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

    export PATH=$SST_INSTALL_BIN:$PATH

    # obtain dependency and configure args
    getconfig $buildtype $architecture $kernel

    # after getconfig is run,
    # $SST_SELECTED_DEPS now contains selected dependencies 
    # $SST_SELECTED_CONFIG now contains config line
    # based on buildtype, configure and build dependencies
    # build, patch, and install dependencies
    $SST_DEPS_BIN/sstDependencies.sh $SST_SELECTED_DEPS cleanBuild
    retval=$?
    if [ $retval -ne 0 ]
    then
        return $retval
    fi

    echo "==================== Building SST ===================="
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

    # autogen to create ./configure
    echo "bamboo.sh: running \"autogen.sh\"..."
    ./autogen.sh
    retval=$?
    if [ $retval -ne 0 ]
    then
        return $retval
    fi
    echo "bamboo.sh: running \"configure\"..."
    echo "bamboo.sh: config args = $SST_SELECTED_CONFIG"

    ./configure $SST_SELECTED_CONFIG
    retval=$?
    if [ $retval -ne 0 ]
    then
        # Something went wrong in configure, so dump config.log
        echo "bamboo.sh: Uh oh. Something went wrong during configure of sst.  Dumping config.log"
        echo "--------------------dump of config.log--------------------"
        sed -e 's/^/#dump /' ./config.log
        echo "--------------------dump of config.log--------------------"
        return $retval
    fi
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ' '    
    echo       Configure complete without error
    echo ' '    
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


    echo "at this time \$buildtype is $buildtype"

    if [[ $buildtype == *_dist_* ]] ; then
        make dist
        retval=$?
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '    
        echo       make dist is done
        echo ' '    
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        ls -ltr | tail -5
        return $retval        ##   This is in dobuild
    fi
    echo   " This is the non dist test path     +++++++++++++++++++++++++++++++++++++++++++++++"
    echo "bamboo.sh: making SST"
    # build SST
    make -j4 all
    retval=$?
    if [ $retval -ne 0 ]
    then
        return $retval
    fi

    # print build and linkage information for warm fuzzy
    echo "SSTBUILD INFO============================================================"
    echo "Built SST with configure string"
    echo "    ./configure ${SST_SELECTED_CONFIG}"
    echo "----------------"
    echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
    if [ $kernel == "Darwin" ]
    then
        # Mac OS X
        echo "DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}"
    fi
    echo "----------------"
    echo "sst exectuable linkage information"

    if [ $kernel == "Darwin" ]
    then
        # Mac OS X 
        echo "$ otool -L ./sst/core/sstsim.x"
        otool -L ./sst/core/sstsim.x
    else
        echo "$ ldd ./sst/core/sstsim.x"
        ldd ./sst/core/sstsim.x
    fi
    echo "SSTBUILD INFO============================================================"

    # install SST
    make -j4 install
    retval=$?
    if [ $retval -ne 0 ]
    then
        return $retval
    fi

}

#=========================================================================
# main
# $1 = build type
# $2 = MPI type
# $3 = boost type
# $4 = compiler type
#=========================================================================

echo "==============================INITIAL ENVIRONMENT DUMP=============================="
env|sort
echo "==============================INITIAL ENVIRONMENT DUMP=============================="

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
        default|sstmainline_config|sstmainline_config_linux_with_ariel|sstmainline_config_linux_with_ariel_no_gem5|sstmainline_config_no_gem5|sstmainline_config_no_gem5_intel_gcc_4_8_1|sstmainline_config_no_gem5_intel_gcc_4_8_1_with_c|sstmainline_config_fast_intel_build_no_gem5|sstmainline_config_no_mpi|sstmainline_config_gcc_4_8_1|sstmainline_config_static|sstmainline_config_static_no_gem5|sstmainline_config_clang_core_only|sstmainline_config_macosx|sstmainline_config_macosx_no_gem5|sstmainline_config_macosx_static|sstmainline_config_macosx_static_no_gem5|sstmainline_config_static_macro_devel|sstmainline_sstmacro_xconfig|sstmainline_config_test_output_config|sstmainline_config_xml2python_static|sstmainline_config_memH_only|sstmainline_config_memH_Ariel|sstmainline_config_dist_test|sstmainline_config_make_dist_no_gem5|documentation|sstmainline_config_VaultSim|sstmainline_config_stream|sstmainline_config_openmp|sstmainline_config_diropenmp|sstmainline_config_diropenmpB|sstmainline_config_dirnoncacheable|sstmainline_config_diropenmpI|sstmainline_config_dir3cache|sstmainline_config_all|sstmainline_config_gem5_gcc_4_6_4|sstmainline_config_fast|sstmainline_config_fast_static|sstmainline_config_memH_wo_openMP|sstmainline_config_develautotester)
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

            echo "bamboo.sh: LISTING LOADED MODULES"
            ModuleEx list

            # Build type given as argument to this script
            export SST_BUILD_TYPE=$1

            if [ $SST_BUILD_TYPE = "documentation" ]
            then
                # build documentation, create list of undocumented files
                ./autogen.sh
                ./configure --disable-silent-rules --prefix=$HOME/local --with-boost=$BOOST_HOME
                make html 2> $SST_ROOT/doc/makeHtmlErrors.txt
                egrep "is not documented" $SST_ROOT/doc/makeHtmlErrors.txt | sort > $SST_ROOT/doc/undoc.txt
                retval=0
            else
                dobuild -t $SST_BUILD_TYPE -a $arch -k $kernel
                retval=$?
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
        # dump list of undocumented files
        echo "============================== DOXYGEN UNDOCUMENTED FILES =============================="
        sed -e 's/^/#doxygen /' $SST_ROOT/doc/undoc.txt
        echo "============================== DOXYGEN UNDOCUMENTED FILES =============================="
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
                echo " ############################  ENTER dotests ################## "
                dotests $1 $4
            fi
        fi               #   End of sstmainline_config_dist_test  conditional
    fi
fi

if [ $retval -eq 0 ]
then
    echo "$0 : exit success."
else
    echo "$0 : exit failure."
fi

exit $retval
