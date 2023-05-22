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

## export SST_BUILDOUTOFSOURCE=1
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
    echo "PWD $LINENO = `pwd`"

## Set the clone depth parameter
## For git clone operations in bamboo.sh, the depth is defaulted to 1"
## Setting the environment variable to "none" omits depth limiting.
   _DEPTH_="--depth 1"
   if [[ ${SST_GIT_CLONE_DEPTH_PARAMETER:+isSet} == isSet ]] ; then
       if [ "${SST_GIT_CLONE_DEPTH_PARAMETER}" == "none" ] ; then
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

   echo "-- Number processers"
   if [ `uname` == "Darwin" ] ; then
       sysctl -n hw.ncpu
   else
       grep -c processor /proc/cpuinfo
   fi
   echo ' '
   echo "MR= $SST_MULTI_RANK_COUNT, MT= $SST_MULTI_THREAD_COUNT"

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
   echo "SST_MULTI_THREAD_COUNT: ${SST_MULTI_THREAD_COUNT}"
   echo "SST_MULTI_RANK_COUNT: ${SST_MULTI_RANK_COUNT}"
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

    # FOR TESTS WITHOUT CORE, WE USE THE ORIG BAMBOO TESTSUITE; OTHERWISE
    # LET THE NEW TESTFRAMEWORKS RUN, NORMALLY
    # Do we run the Macro Tests
    if [ $1 == "sst-macro_nosstcore_mac" ] ||
       [ $1 == "sst-macro_nosstcore_linux" ] ||
       [ $1 ==  sst_Macro_make_dist ] ; then

        ${SST_TEST_SUITES}/testSuite_macro.sh
        # We currently dont want to run any other tests
        return
    fi
    # FOR TESTS WITH CORE, WE SKIP ALL OTHER TESTS AND
    # LET THE NEW TESTFRAMEWORKS RUN
    if [ $1 == "sst-macro_withsstcore_mac" ] ||
       [ $1 == "sst-macro_withsstcore_linux" ] ; then

        # We currently dont want to run any other tests
        export SST_MULTI_RANK_COUNT=1
        export SST_MULTI_THREAD_COUNT=1
        return
    fi

##########################################################################3


    #   Enable the --output-config option in (most) tests
    #      (activated by Environment Variable)

    if [[ ${SST_TEST_OUTPUT_CONFIG:+isSet} == isSet ]] ; then
        echo ' '; echo "Generating \"--output-config\" test" ; echo ' '
        ./test/utilities/GenerateOutputConfigTest
    fi

### NOTE: $1 is set to sstmainline_config_all is set when doing a make dist test, we want to avoid this

    #
    #  Run only GPU test only
    #
    if [[ ($1 == "sstmainline_config_linux_with_cuda") || ($1 == "sstmainline_config_linux_with_cuda_no_mpi") ]]
    then
        ${SST_TEST_SUITES}/testSuite_gpgpu.sh
        return
    fi

     #
     #   Suites that used MemHierarchy, but not openMP
     #

    if [ $1 == "sstmainline_config_memH_wo_openMP" ]
    then
        return
    fi

    PATH=${PATH}:${SST_ROOT}/../sqe/test/utilities

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

    # Decide if we need to build core with a specific python
    if [[ ${SST_PYTHON_USER_SPECIFIED:+isSet} == isSet ]] ; then
        corebaseoptions="--disable-silent-rules --prefix=$SST_CORE_INSTALL --with-python=$SST_PYTHON_CFG_EXE"
    else
        corebaseoptions="--disable-silent-rules --prefix=$SST_CORE_INSTALL"
    fi

    elementsbaseoptions="--disable-silent-rules --prefix=$SST_ELEMENTS_INSTALL --with-sst-core=$SST_CORE_INSTALL"
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
    local defaultDeps="-d none"

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

    # Build default dependencies: ramulator, HBMDramSim2, GoblinHMCSim, DramSim3, DramSim2, NVDimmSim, no cuda
    # Other dependencies are loaded as modules
    local allDeps="-r default -H default -G default -D default -d 2.2.2 -N default -A none"

    # Configure SST Elements with all dependencies except those requiring special handling. Pin is not support on Mac.

    case $1 in
        sstmainline_config|sstmainline_config_all|sstmainline_config_linux_with_ariel_no_gem5|sstmainline_config_no_gem5|sstmainline_config_memH_wo_openMP)
            #-----------------------------------------------------------------
            # sstmainline_config
            #     This option used for configuring SST with supported stabledevel deps
            # sstmainline_config_all
            #     This option is used when calling bamboo a second time during a make dist test
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_coreonly_config)
            #-----------------------------------------------------------------
            # sstmainline_coreonly_config
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-r none" # Dependencies only needed for elements
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="NOBUILD"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;
        sstmainline_config_linux_with_cuda)
            #-----------------------------------------------------------------
            # sstmainline_config_linux_with_cuda
            #     This option used for configuring SST with supported stabledevel deps,
            #     Intel PIN, Ariel, and Cuda
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            export SST_WITH_CUDA=1
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-r default -H default -G default -D default -d 2.2.2 -N none -A 1.1"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv --disable-mem-pools"
            elementsConfigStr="$elementsbaseoptions --with-cuda=$CUDA_ROOT --with-gpgpusim=$SST_DEPS_INSTALL_GPGPUSIM --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            # Must Setup the GPGPUSIM Environment
            echo "SETUP THE GPGPUSIM ENVIRONMENT"
            echo "==== ENV BEFORE GPGPUSIM ENV SETUP ==="
            env|sort
            echo ". ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment"
            . ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment
            echo "==== ENV AFTER  GPGPUSIM ENV SETUP ==="
            env|sort
            ;;
        sstmainline_config_linux_with_cuda_no_mpi)
            #-----------------------------------------------------------------
            # sstmainline_config_linux_with_cuda_no_mpi
            #     This option used for configuring SST with supported stabledevel deps,
            #     Intel PIN, Ariel, and Cuda
            #-----------------------------------------------------------------
            if [[ ${MPIHOME:+isSet} == isSet ]] ; then
                echo ' ' ; echo " Test is flawed!  MPI module is loaded!" ; echo ' '
                exit 1
            fi
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="-r default -H default -G default -D default -d 2.2.2 -N none -A 1.1"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv --disable-mem-pools --disable-mpi"
            elementsConfigStr="$elementsbaseoptions --with-cuda=$CUDA_ROOT --with-gpgpusim=$SST_DEPS_INSTALL_GPGPUSIM --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            # Must Setup the GPGPUSIM Environment
            echo "SETUP THE GPGPUSIM ENVIRONMENT"
            echo "==== ENV BEFORE GPGPUSIM ENV SETUP ==="
            env|sort
            echo ". ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment"
            . ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment
            echo "==== ENV AFTER  GPGPUSIM ENV SETUP ==="
            env|sort
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
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv --disable-mpi"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_clang_core_only)
            #-----------------------------------------------------------------
            # sstmainline_config_clang_core_only
            #     This option used for configuring SST with no deps to build the core with clang
            #-----------------------------------------------------------------
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="$elementsbaseoptions"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;
        sstmainline_config_macosx|sstmainline_config_macosx_no_gem5)
            #-----------------------------------------------------------------
            # sstmainline_config_macosx
            #     This option used for configuring SST with supported stabledevel deps
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_memH_wo_openMP)
            #-----------------------------------------------------------------
            # sstmainline_config_memH_wo_openMP
            #     This option used for configuring SST with memHierarchy, but with out open MP
            #     with Intel PIN, and Ariel
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --with-pin=$SST_DEPS_INSTALL_INTEL_PIN $elementsMiscEnv $coreMiscEnv"
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
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
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
            depsStr="-r none"
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
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
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
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="NOBUILD"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which gcc` CXX=`which g++` --disable-regex --disable-unordered-containers"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;

        sst_Macro_make_dist)
            #-----------------------------------------------------------------
            # sst_Macro_make_dist
            #      Do a "make dist"  (creating a tar file.)
            #      Then,  untar the created tar-file.
            #      Invoke bamboo.sh, (this file), to build sst from the tar.
            #            Yes, bamboo invoked from bamboo.
            #      Finally, run tests to validate the created sst.
            #-----------------------------------------------------------------
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="NOBUILD"
            macroConfigStr="--prefix=$SST_MACRO_INSTALL CC=`which gcc` CXX=`which g++` --disable-regex --disable-unordered-containers --with-sst-core=$SST_CORE_INSTALL"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;

        sstmainline_config_dist_test|sstmainline_config_make_dist_no_gem5|sstmainline_config_make_dist_test)
            #-----------------------------------------------------------------
            # sstmainline_config_dist_test
            #      Do a "make dist"  (creating a tar file.)
            #      Then,  untar the created tar-file.
            #      Invoke bamboo.sh, (this file), to build sst from the tar.
            #            Yes, bamboo invoked from bamboo.
            #      Finally, run tests to validate the created sst.
            #-----------------------------------------------------------------
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="$elementsbaseoptions"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_core_make_dist_test)
            #-----------------------------------------------------------------
            # sstmainline_config_core_make_dist_test
            #      Do a "make dist"  (creating a tar file.)
            #      Then,  untar the created tar-file.
            #      Invoke bamboo.sh, (this file), to build sst from the tar.
            #            Yes, bamboo invoked from bamboo.
            #      Finally, run tests to validate the created sst.
            #-----------------------------------------------------------------
            depsStr="-r none"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions"
            elementsConfigStr="NOBUILD"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="NOBUILD"
            junoConfigStr="NOBUILD"
            ;;

        # ====================================================================
        # ====                                                            ====
        # ====  Experimental/exploratory build configurations start here  ====
        # ====                                                            ====
        # ====================================================================
        sstmainline_config_static|sstmainline_config_static_no_gem5)
            #-----------------------------------------------------------------
            # sstmainline_config_static
            #     This option used for configuring SST with supported stabledevel deps
            # 2023-Jan-6 Probably doesn't work
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions --enable-static --disable-shared $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --enable-static --disable-shared $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
            ;;

        sstmainline_config_macosx_static)
            #-----------------------------------------------------------------
            # sstmainline_config_macosx_static
            #     This option used for configuring SST with supported stabledevel deps
            # 2023-Jan-6 Probably doesn't work
            #-----------------------------------------------------------------
            export | egrep SST_DEPS_
            coreMiscEnv="${cc_environment} ${mpi_environment}"
            elementsMiscEnv="${cc_environment}"
            depsStr="$allDeps"
            setConvenienceVars "$depsStr"
            coreConfigStr="$corebaseoptions  --enable-static --disable-shared $coreMiscEnv"
            elementsConfigStr="$elementsbaseoptions --with-hbmdramsim=$SST_DEPS_INSTALL_HBM_DRAMSIM2 --with-ramulator=$SST_DEPS_INSTALL_RAMULATOR --with-goblin-hmcsim=$SST_DEPS_INSTALL_GOBLIN_HMCSIM --with-dramsim3=$SST_DEPS_INSTALL_DRAMSIM3  --with-dramsim=$SST_DEPS_INSTALL_DRAMSIM --with-nvdimmsim=$SST_DEPS_INSTALL_NVDIMMSIM --with-hybridsim=$SST_DEPS_INSTALL_HYBRIDSIM --enable-static --disable-shared $elementsMiscEnv"
            macroConfigStr="NOBUILD"
            externalelementConfigStr="$externalelementbaseoptions"
            junoConfigStr="$junobaseoptions"
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
            elementsConfigStr="$elementsbaseoptions"
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


   if [[ ${SST_CORE_PREVIEW:+isSet} == isSet ]] ; then
      export SST_SELECTED_CORE_CONFIG="${SST_SELECTED_CORE_CONFIG} --enable-preview-build"
   fi
}

#-------------------------------------------------------------------------
# Function: linuxSetMPI
# Description:
#   Purpose: Performs selection and loading of Bost and MPI modules
#            for Linux
#   Input:
#      $1 - Bamboo Project
#      $2 - mpi request
#      $3   compiler (optional)
#   Output:
#   Return value:
linuxSetMPI() {

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

   # build MPI selector
   if [[ "$2" =~ openmpi.* ]]
   then
       mpiStr="ompi-"$(expr "$2" : '.*openmpi-\([0-9]\(\.[0-9][0-9]*\)*\)')
   else
       mpiStr=${2}
   fi

   if [ $compiler = "default" ]
   then
       desiredMPI="${2}"
   else
       desiredMPI="${2}_${4}"
       # load non-default compiler
       if   [[ "$3" =~ gcc.* ]]
       then
           ModuleEx load gcc/${4}
           echo "LOADED gcc/${4} compiler"
       elif [[ "$3" =~ intel.* ]]
       then
           ModuleEx load intel/${4}
           if [[ "$3" == *intel-15* ]] ; then
               ModuleEx load gcc/gcc-4.8.1
               IntelExtraConfigStr="CXXFLAGS=-gxx-name=`which g++` CFLAGS=-gcc-name=`which gcc`"
           fi

       fi
   fi

   echo "CHECK:  \$2: ${2}"
   echo "CHECK:  \$3: ${3}"
   echo "CHECK:  \$desiredMPI: ${desiredMPI}"
   gcc --version 2>&1 | grep ^g

   # load MPI
   case $2 in
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

    # Load other modules that were built with the default compiler
    if [ $compiler = "default" ]
    then
        # GNU Linear Programming Kit (GLPK)
        echo "bamboo.sh: Load GLPK"
        # Load available GLPK, whatever version it is
        ModuleEx load glpk
       
        # METIS 5.1.0
        echo "bamboo.sh: Load METIS 5.1.0"
        ModuleEx avail | grep bundled
        if [ $? == 0 ] ; then
            echo " Bingo ###################################################"
            ModuleEx load metis/metis-5.1.0-bundled
        else
            ModuleEx load metis/metis-5.1.0
        fi
        echo "      This is what is loaded for METIS"
        ModuleEx list | grep metis

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
#   Purpose: Performs selection and loading of MPI and
#            other compiler specific modules for MacOS
#   Parameters:   name of Clang compiler such as (clang-700.1.76)
#                 Also need $2 passed along

ldModules_MacOS_Clang() {
    ClangVersion=$1            #   example "clang-700.0.72" $2
    ModuleEx avail
    # Use MPI built with CLANG from Xcode
    ModuleEx unload mpi

    # Load other modules for $ClangVersion
    # GNU Linear Programming Kit (GLPK)
    echo "bamboo.sh: Load GLPK"
    ModuleEx load glpk/glpk-4.54_$ClangVersion
        
    # METIS 5.1.0
    echo "bamboo.sh: Load METIS 5.1.0"
    ModuleEx load metis/metis-5.1.0_$ClangVersion

    # PTH 2.0.7
    echo "bamboo.sh: Load PTH 2.0.7"
    ModuleEx load pth/pth-2.0.7

    # load MPI
    echo " ****** Loading MPI ********"
    echo "Request (\$2) is ${2}"
    case $2 in
        ompi_default)
            echo "OpenMPI 4.0.5 selected"
            ModuleEx add mpi/openmpi-4.0.5_$ClangVersion
            ;;
        none)
            echo  "No MPI loaded as requested"
            ;;
        *)
            echo "User Defined MPI request"
            echo "MPI option, loading users mpi/$2"
            ModuleEx load mpi/$2_$ClangVersion 2>catch.err
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
# Function: darwinSetMPI
# Description:
#   Purpose: Performs selection and loading of MPI modules
#            for MacOS
#   Input:
#   Output:
#   Return value:
darwinSetMPI() {
    # Obtain Mac OS version (works only on MacOS!!!)
    macosVersionFull=`sw_vers -productVersion`
    echo "  ******************* macosVersionFull= $macosVersionFull "
    ###    macosVersion=${macosVersionFull%.*}
    macosVersion=`echo ${macosVersionFull} | awk -F. '{print $1 "." $2 }'`
    echo "  ******************* macosVersion= $macosVersion "


    # macports or hybrid clang/macports
    PATH="/opt/local/bin:/usr/local/bin:$PATH"
    export PATH

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
        ldModules_MacOS_Clang $compiler $2  # any Xcode

    else
        echo "ERROR: unable to locate /etc/profile.modules - cannot load modules"
        exit
    fi

    echo "bamboo.sh: MacOS build."
    echo "bamboo.sh:   MPI = $2"
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
    echo "---   PWD $LINENO  `pwd`"           ## Original trunk
     
    LOC_OF_TAR=""
    if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
        LOC_OF_TAR="-builddir"
    fi
    cd ${SST_ROOT}/sst-core${LOC_OF_TAR}
    echo "---   $LINENO  PWD $LINENO  `pwd`"
    ls
    Package=`ls| grep 'sst.*tar.gz' | awk -F'.tar' '{print $1}'`
    echo  PACKAGE is $Package
    tarName=${Package}.tar.gz
    ls $tarName
    if [ $? != 0 ] ; then
        ls
        echo "Can NOT find CORE Tar File $Package .tar.gz"
        exit 1
    fi
    mkdir -p $SST_ROOT/distTestDir/trunk
    cd $SST_ROOT/distTestDir/trunk
    mv $SST_ROOT/sst-core${LOC_OF_TAR}/$tarName .
    if [ $? -ne 0 ] ; then
        echo "Move failed  \$SST_ROOT/$tarName to ."
    fi
    rm -rf $SST_ROOT/sst-core
    echo "   Untar the created file, $tarName"
    echo "---   PWD $LINENO  `pwd`"
    tar xzf $tarName
    if [ $? -ne 0 ] ; then
        echo "Untar of $tarName failed"
    fi
    echo ' ' ; echo "--------   going to do the core move"
    echo PWD $LINENO is `pwd`
    mv $Package sst-core
    echo "             ---------------------- done with core ------"
############## JVD ################################################
    echo "$LINENO test for sstmainline_config_make_dist_test "
    if  [ $1 ==  sstmainline_config_make_dist_test ] ; then
#                          ELEMENTS
#         May 17, 2016    file name is sst-elements-library-devel.tar.gz
         cd $SST_ROOT/sst-elements${LOC_OF_TAR}
         echo "---   PWD $LINENO  `pwd`"
         Package=`ls| grep 'sst-.*tar.gz' | awk -F'.tar' '{print $1}'`
         echo  PACKAGE is $Package
         tarName=${Package}.tar.gz
         ls $tarName
         if [ $? != 0 ] ; then
             ls
             echo "Can NOT find ELEMENTS Tar File $Package .tar.gz"
         fi
         cd $SST_ROOT/distTestDir/trunk
         echo PWD $LINENO is `pwd`
         echo going to move the elements tar to here.

         mv $SST_ROOT/sst-elements${LOC_OF_TAR}/$tarName .
         if [ $? -ne 0 ] ; then
              echo "Move failed  \$SST_ROOT/$tarName to ."
         fi
         echo "   Untar the created file, $tarName"
         tar xzf $tarName
         if [ $? -ne 0 ] ; then
              echo "Untar of $tarName failed"
         fi
         echo "---   PWD $LINENO  `pwd`"
         mv $Package sst-elements
    echo "$LINENO   END of Non Macro segment (else follows)"
############### JVD  ###################################################

     fi

     if  [ $1 ==  sst_Macro_make_dist ] ; then

        echo "$LINENO -- Begin Macro section"
        echo PWD $LINENO `pwd`
        ls
        # MACRO
        cd $SST_ROOT/sst-macro${LOC_OF_TAR}
        echo "---   PWD $LINENO  `pwd`"
        ls
        Package=`ls| grep 'sst.*tar.gz' | awk -F'.tar' '{print $1}'`
        echo  PACKAGE is $Package
        tarName=${Package}.tar.gz
        ls $tarName
        if [ $? != 0 ] ; then
            echo " PWD $LINENO   `pwd`"
            ls
            echo Can NOT find Tar File $Package .tar.gz
            exit 1
        fi
        cd $SST_ROOT/distTestDir/trunk
        mv $SST_ROOT/sst-macro${LOC_OF_TAR}/$tarName .
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
        echo "---   PWD $LINENO  `pwd`"
        mv $Package sst-macro
    fi
############  JVD  ##################################################################
    echo "  ---- This is make dist code, but not for Macro,  line = $LINENO"
    if  [ $1 ==  sstmainline_config_make_dist_test ] ; then
        # Move the REFERENCE File pointer
        export SST_REFERENCE_ELEMENTS=$SST_ROOT/distTestDir/trunk/sst-elements/src/sst/elements
        echo "SST_REFERENCE_ELEMENTS = $SST_REFERENCE_ELEMENTS"

        popd
        rm -rf $SST_ROOT/sst-elements
########### JVD   #############################################################
        echo "===============   MOVE IN THE EXTERNAL ELEMENT & JUNO =========="
        echo " PWD $LINENO=`pwd` "
        mv $SST_ROOT/sst-external-element .
        mv $SST_ROOT/juno .
    fi
    echo "---   PWD $LINENO  `pwd`"

    echo "=============================="
    echo "Move in items not in the trunk, that are need for the bamboo build and test"

    echo "####################################################################"
    echo ' '
    echo "---   PWD $LINENO  `pwd`"
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
     if [[ $buildtype == "sst_Macro_make_dist" ]] ; then
         echo " Macro make dist:  There is no sst-elements directory "
     else
         echo "                   List the directories in sst-elements/src/sst/elements"
         ls sst-elements/src/sst/elements
     fi
     echo ' '

     ln -s ../../test              ## the subtree of tests
     echo " ----  The subttees of test  --- "
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
     ls | awk '{print "rm -rf " $1}' | grep -v -e deps -e distTestDir -e test -e sstDeps > rm-extra
     echo "---   PWD $LINENO  `pwd`"
     echo "       LIST THE EXTRA FILES to be removed"
     cat rm-extra
     . ./rm-extra
     ls
     popd

     echo SST_DEPS_USER_DIR= $SST_DEPS_USER_DIR

     ### RENAME THE CONFIG TEST TO SOMETHING ELSE SO WHEN BAMBOO IS CALLED AGAIN,
     ### IT BUILDS THE EXTRACTED DISTRIBTUION AND TESTS NORMALLY.
     if [ $buildtype == "sstmainline_config_make_dist_test" ] ; then
         distScenario="sstmainline_config_all"
     elif [ $buildtype == "sstmainline_config_core_make_dist_test" ] ; then
         distScenario="sstmainline_coreonly_config"
     elif [ $buildtype == "sstmainline_config_dist_test" ] ; then
         distScenario="sstmainline_config_all"
     elif [ $buildtype == "sst_Macro_make_dist" ] ; then
         distScenario="sst-macro_withsstcore_linux"
     else
         distScenario="sstmainline_config_no_gem5"
     fi

     echo "---   PWD $LINENO  `pwd`"
     cd $SST_ROOT/distTestDir/trunk
     # unlike regular test, make dist does move bamboo to trunk
              ##  Here is the bamboo invocation within bamboo
     echo "         INVOKE bamboo for the build from the dist tar"
     ./bamboo.sh $distScenario $SST_DIST_MPI $SST_DIST_BOOST $SST_DIST_PARAM4 $SST_DIST_CUDA $SST_DIST_PYTHON
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
    export LD_LIBRARY_PATH=${SST_INSTALL_DEPS}/lib:${SST_INSTALL_DEPS}/lib/sst:${SST_DEPS_INSTALL_GEM5SST}:${SST_INSTALL_DEPS}/packages/DRAMSim:${SST_DEPS_INSTALL_NVDIMMSIM}:${SST_DEPS_INSTALL_HYBRIDSIM}:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
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
        pwd
        echo "                                   LINE  $LINENO "
        ls -ltrd * | tail -20
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
        echo "    PWD $LINENO is `pwd` "
        echo " resourcedir is $coresourcedir"
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
        echo "     ------------   After configure files at coresourcedir are:"
        echo "                                   LINE  $LINENO "
        ls -ltrd $coresourcedir/* | tail -14
        echo " Local files are ------------"
        echo "                                   LINE  $LINENO "
        ls -ltrd *
        echo  " ---------"


        echo ' '
        echo "bamboo.sh: configure on SST-CORE complete without error"
        echo ' '
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " "
        pwd
        echo "                                   LINE  $LINENO "
        ls -ltrd * | tail -20


        # Check to see if we are actually performing make dist
        echo "at this time \$buildtype is $buildtype"
        if [ $buildtype == "sstmainline_config_dist_test" ] ||
           [[ $buildtype == *make_dist* ]] ; then
#           [ $buildtype == "sstmainline_config_make_dist_no_gem5" ] ||
#           [ $buildtype == "sstmainline_config_make_dist_test" ] ||
#           [ $buildtype == "sst_Macro_make_dist" ] ; then
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST-CORE"
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            make dist
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST_CORE is complete without error"
            pwd
            ls | grep tar
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo " "
            ls -ltr | tail -5
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: After make dist on SST_CORE do the make install "
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
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

        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ' '
        echo "bamboo.sh: make clean on SST-CORE"
        echo ' '
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"        
        make clean

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
        pwd
        echo "                                   LINE  $LINENO "

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
        pwd
        echo "                                   LINE  $LINENO "
        ls -ltrd * | tail -20

        echo "################################## DEBUG DATA ########################"
        ls
        ls src
        ls src/sst
        ls src/sst/elements/
        ls src/sst/elements/*/*m4
        echo "##################### END ######## DEBUG DATA ########################"

        # Check to see if we are actually performing make dist
        echo "at this time \$buildtype is $buildtype"
        if [ $buildtype == "sstmainline_config_dist_test" ] ||
           [ $buildtype == "sstmainline_config_make_dist_no_gem5" ] ||
           [ $buildtype == "sstmainline_config_make_dist_test" ] ; then
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST-ELEMENTS"
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            make dist
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST-ELEMENTS is complete without error"
            pwd
            ls | grep tar
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo " "
            ls -ltr | tail -5
            popd
            return $retval       ##  This is in dobuild
        else

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

            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ' '
            echo "bamboo.sh: make clean on SST-ELEMENTS"
            echo ' '
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            make clean

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
        fi   ###### end of make or make dist on Elements
    fi

    echo "PWD $LINENO = `pwd`   A Macro decision point -------------"
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

        pwd
        echo "                                   LINE  $LINENO "
        ls -ltrd * | tail -20
        # Check to see if we are actually performing make dist
        echo "at this time \$buildtype is $buildtype"
        if [[ $buildtype == "sst_Macro_make_dist" ]] ; then
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST-MACRO"
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            make dist
            retval=$?
            if [ $retval -ne 0 ]
            then
                return $retval
            fi
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo ' '
            echo "bamboo.sh: make dist on SST-MACRO is complete without error"
            pwd
            ls | grep tar
            echo ' '
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++ makeDist"
            echo " "
            ls -ltr | tail -5
            echo "about to \"return $retval\" to dobuild from setUPforMakeDist"
            return $retval        ##   This is in dobuild
        fi

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

    echo "PWD $LINENO = `pwd`    -------  BUILD EXTERNAL elements"
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
}

#=========================================================================
# main
# $1 = build type
# $2 = MPI type
# $3 = boost type
# $4 = compiler type
# $5 = Cuda version
# $6 = pythonX (X = 2 | 3)
#=========================================================================
# Build type options
# USED
#   sstmainline_config
#   sstmainline_config_all - indirectly used when bamboo is called a second time during make dist tests
#   sstmainline_coreonly_config
#   sstmainline_config_no_gem5
#   sstmainline_config_no_mpi
#   sstmainline_config_macosx_no_gem5
#   sstmainline_config_memH_wo_openMP
#   sstmainline_config_make_dist_test
#   sstmainline_config_core_make_dist_test
#   sst-macro_withsstcore_mac
#   sst-macro_nosstcore_mac
#   sst-macro_withsstcore_linux
#   sst-macro_nosstcore_linux
#   sst_Macro_make_dist
#   documentation
#
# UNUSED
#   default
#   sstmainline_config_linux_with_ariel_no_gem5
#   sstmainline_config_with_cuda
#   sstmainline_config_with_cuda_no_mpi
#   sstmainline_config_static
#   sstmainline_config_static_no_gem5
#   sstmainline_config_macosx
#   sstmainline_config_macosx_static
#   sstmainline_config_dist_test
#   sstmainline_config_make_dist_no_gem5
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

# Which branches to use for each repo (default is devel)
if [[ ${SST_SQEBRANCH:+isSet} != isSet ]] ; then
    SST_SQEBRANCH="v13.0.0_beta"
else
    echo ' ' ;  echo ' ' ; echo ' ' ; echo ' '
    echo " Attempting to set SQE branch other than devel"
    echo " SQE branch is selected by configure in Jenkins"
    echo "  SELECTED SST_SQEBRANCH =  ${SST_SQEBRANCH}"
    echo ' ' ;  echo ' ' ; echo ' ' ; echo ' '
fi

if [[ ${SST_COREBRANCH:+isSet} != isSet ]] ; then
    SST_COREBRANCH="v13.0.0_beta"
fi

if [[ ${SST_ELEMENTSBRANCH:+isSet} != isSet ]] ; then
    SST_ELEMENTSBRANCH="v13.0.0_beta"
fi

if [[ ${SST_MACROBRANCH:+isSet} != isSet ]] ; then
    SST_MACROBRANCH="v13.0.0_beta"
fi

if [[ ${SST_EXTERNALELEMENTBRANCH:+isSet} != isSet ]] ; then
    SST_EXTERNALELEMENTBRANCH="v13.0.0_beta"
fi

if [[ ${SST_JUNOBRANCH:+isSet} != isSet ]] ; then
    SST_JUNOBRANCH="v13.0.0_beta"
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
echo "  Version Feb 1 2018 0900 hours "
echo ' '
pwd
ls -la
   echo ' '
if [ -d ${SST_BASE}/devel/sqe ] ; then
   echo "PWD $LINENO = `pwd`"
   pushd ${SST_BASE}/devel/sqe
   echo "PWD $LINENO = `pwd`"
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
echo "@@@@@@  \$0 = $0 ######"
echo "@@@@@@  \$1 = $1 ######"
echo "@@@@@@  \$2 = $2 ######"
echo "@@@@@@  \$3 = $3 ######"
echo "@@@@@@  \$4 = $4 ######"
echo "@@@@@@  \$5 = $5 ######"
echo "@@@@@@  \$6 = $6 ######"
echo  $0 $1 $2 $3 $4 $5 $6
echo `pwd`

if [ $# -lt 3 ] || [ $# -gt 6 ]
then
    # need build type and MPI type as argument

    echo "Usage : $0 <buildtype> <mpitype> <boost type> <[compiler type (optional)]> <[cuda version (optional)]> <[python3 version (optional)]>"
    exit 0

else
    # get desired compiler, if option provided
    compiler=""

    case $4 in
        none|default|"")
            echo "bamboo.sh: \$4 is empty, null or default; setting compiler to default"
            compiler="default"
            ;;
        *) # unknown option
            echo "bamboo.sh: setting compiler to $4"
            compiler="$4"
            ;;
    esac

    echo "bamboo.sh: compiler is set to $compiler"

    # Determine architecture
    arch=`uname -p`
    # Determine kernel name (Linux or MacOS i.e. Darwin)
    kernel=`uname -s`

    echo "bamboo.sh: KERNEL = $kernel"

    case $1 in
        default|sstmainline_config|sstmainline_coreonly_config|sstmainline_config_linux_with_ariel_no_gem5|sstmainline_config_no_gem5|sstmainline_config_static|sstmainline_config_static_no_gem5|sstmainline_config_clang_core_only|sstmainline_config_macosx|sstmainline_config_macosx_no_gem5|sstmainline_config_no_mpi|sstmainline_config_make_dist_test|sstmainline_config_core_make_dist_test|sstmainline_config_dist_test|sstmainline_config_make_dist_no_gem5|documentation|sstmainline_config_all|sstmainline_config_memH_wo_openMP|sstmainline_config_linux_with_cuda|sstmainline_config_linux_with_cuda_no_mpi|sst-macro_withsstcore_mac|sst-macro_nosstcore_mac|sst-macro_withsstcore_linux|sst-macro_nosstcore_linux|sst_Macro_make_dist)
            #   Save Parameters $2, $3, $4, $5 and $6 in case they are need later
            SST_DIST_MPI=$2
            SST_DIST_BOOST="none"
            SST_DIST_PARAM4=$4
            SST_DIST_CUDA=`echo $5 | sed 's/cuda-//g'`
            SST_DIST_PYTHON=$6

            # Configure MPI and Compiler (Linux only)
            if [ $kernel != "Darwin" ]
            then
                linuxSetMPI $1 $2 $4

            else  # kernel is "Darwin", so this is MacOS

                darwinSetMPI $1 $2 $4
            fi

            # Load Cuda Module
            case $5 in
                cuda-8.0.44|cuda-8.0.61|cuda-9.1.85)
                    echo "bamboo.sh: cuda-${SST_DIST_CUDA} selected"
                    ModuleEx unload cuda
                    ModuleEx load cuda/${SST_DIST_CUDA}
                    ;;
                none)
                    echo  "No Cuda loaded as requested"
                    ;;
                *) # unknown option
                    echo  "No Cuda loaded as requested"
                    ;;
            esac

            # Figure out Python Configuration
            # Note: Selecting python is confusing as different system have different links
            #       depending upon versions available. We look for 'python3' first and then
            #       check if 'python' has been symlinked to python3 if needed
            echo ""
            echo "=============================================================="
            echo "=== DETERMINE WHAT PYTHON TO USE"
            echo "=============================================================="
            case $6 in
                python3)
                    echo "BAMBOO PARAM INDICATES SCENARIO NEEDS PYTHON3"
                    export SST_PYTHON_USER_SPECIFIED=1
                    if command -v python3 > /dev/null 2>&1; then
                        export SST_PYTHON_APP_EXE=`command -v python3`
                    else
                        echo "ERROR: USER SELECTED python3 NOT FOUND - IS python ver3.x ON THE SYSTEM?"
                        exit 128
                    fi
                    if python3-config --prefix > /dev/null 2>&1; then
                        export SST_PYTHON_CFG_EXE=`command -v python3-config`
                        export SST_PYTHON_HOME=`python3-config --prefix`
                    else
                        echo "ERROR: USER SELECTED python3-config NOT FOUND - IS python3-devel ON THE SYSTEM?"
                        exit 128
                    fi
                    ;;

                * | none)
                    # Perform a quick check to see if $6 is empty
                    if [ -n "$6" ]; then
                        if [[ $6 != "none" ]] ; then
                            echo "ERROR: ILLEGAL PYTHON OPTION " $6
                            echo "       ONLY none | python3 ALLOWED"
                            exit 128
                        fi
                    fi

                    ## NOTE: This code is for SST Version 12 where Python 2.x is no longer supported
                    echo "NO BAMBOO PARAM EXISTS FOR PICKING A PYTHON VERSION - DETECT AND USE THE DEFAULT SYSTEM PYTHON"

                    # Test to see if python3-config command is avail it should be for all Py3 installs
                    if python3-config --prefix > /dev/null 2>&1; then
                        export SST_PYTHON_CFG_EXE=`command -v python3-config`
                        export SST_PYTHON_HOME=`python3-config --prefix`
                        echo "--- FOUND PYTHON3 via python3-config..."

                        if command -v python3 > /dev/null 2>&1; then
                            export SST_PYTHON_APP_EXE=`command -v python3`
                        else
                            echo "ERROR: Python3 is detected to be Default on system (via python3-config), but python3 app IS NOT FOUND - IS python3 configured properly ON THE SYSTEM?"
                            exit 128
                        fi
                    else
                        ## NOTE: This is the last chance...
                        ##       try finding 'python-config'
                        echo "--- DID NOT FIND python3-config, SEARCHING FOR python-config..."

                        # Test to see if python-config command is avail
                        if python-config --prefix > /dev/null 2>&1; then
                            export SST_PYTHON_CFG_EXE=`command -v python-config`
                            export SST_PYTHON_HOME=`python-config --prefix`
                            echo "--- FOUND PYTHON via python-config..."

                            if command -v python > /dev/null 2>&1; then
                                ## Check that python is an acceptably new version of python
                                pyver=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
                                pyverX=$(echo "${version//./}")
                                if [["$pyverX" -lt "350" ]]
                                then
                                    echo "ERROR: FOUND python but version is TOO OLD (<3.5.0)."
                                    exit 128
                                fi
                                export SST_PYTHON_APP_EXE=`command -v python`
                            else
                                echo "ERROR: Python app IS NOT FOUND - IS Python Version 3.x ON THE SYSTEM?"
                                exit 128
                            fi
                        else
                            ## No Python3 or Python found, this seems quite wrong...
                            echo "ERROR: NO DEFAULT PYTHON FOUND ON SYSTEM - Is something wrong in the detection script?"
                            exit 128
                        fi
                    fi
                    ;;
            esac

            echo "=============================================================="
            echo "=== FINAL PYTHON DETECTED VARIABLES"
            echo "=============================================================="
            export SST_PYTHON_VERSION=`$SST_PYTHON_APP_EXE --version 2>&1`
            echo "SST_PYTHON_APP_EXE =" $SST_PYTHON_APP_EXE
            echo "SST_PYTHON_CFG_EXE =" $SST_PYTHON_CFG_EXE
            echo "SST_PYTHON_HOME =" $SST_PYTHON_HOME
            echo "FOUND PYTHON VERSION =" $SST_PYTHON_VERSION
            if [[ ${SST_PYTHON_USER_SPECIFIED:+isSet} == isSet ]] ; then
                echo "SST_PYTHON_USER_SPECIFIED = 1 - BUILD CORE WITH SPECIFIED PYTHON"
                echo "   USING PATH TO pythonX-config = " $SST_PYTHON_CFG_EXE
            else
                echo "SST_PYTHON_USER_SPECIFIED = <UNDEFINED> - ALLOW CORE TO FIND PYTHON TO BUILD WITH"
            fi
            echo "=============================================================="

            # Figure out PIN Configuration
            if [[  ${SST_WITHOUT_PIN:+isSet} == isSet ]] ; then
                echo "  PIN IS NOT ENABLED BY SST_WITHOUT_PIN flag"
            else
                # Check that the default Intel PIN module is available
                # For Linux = pin/pin-3.26-98960-g1fc9d60e6-gcc-linux
                #           ModuleEx puts the avail output on Stdout (where it belongs.)
                ModuleEx avail | egrep -q "pin/pin-3.26"
                if [ $? == 0 ]
                then
                # if `pin module is available, use pin/pin-3.26.
                    if [ $kernel != "Darwin" ] ; then
                        echo "USING INTEL PIN ENVIRONMENT MODULE pin-3.26-98690-g1fc9d60e6-gcc-linux"
                        echo "LOADING INTEL PIN ENVIRONMENT MODULE"
                        ModuleEx load pin/pin-3.26-98690-g1fc9d60e6-gcc-linux
                        echo  $INTEL_PIN_DIRECTORY
                        ls $INTEL_PIN_DIRECTORY
                        export SST_USING_PIN3=1
                    else        ##    MacOS   (Darwin)
                        echo "Pin is not supported on MacOS"
                    fi
                else
                    echo "INTEL PIN VER 3 ENVIRONMENT MODULE NOT FOUND ON THIS HOST."
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

            echo "PWD $LINENO = `pwd`"
            ;;

        *)
            echo "$0 : unknown action \"$1\""
            retval=1
            ;;
    esac
fi

echo "PWD $LINENO = `pwd`"
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

        if [ $buildtype == "sstmainline_config_dist_test" ] ||
           [[ $buildtype == *make_dist* ]] ; then
             setUPforMakeDisttest $1 $2 $3 $4
             exit 0                  #  Normal Exit for make dist
        else          #  not make dist
            #    ---  These are probably temporary, but let's line them up properly anyway
            echo "===================================================================================="
            echo "===================================================================================="
            echo "===================================================================================="
            echo "============================== BEFORE TESTING START ================================"
            echo "===================================================================================="
            echo "===================================================================================="
            echo "===================================================================================="
            echo "=== pwd results:"
            pwd
            echo "=== ls results:"
            ls
            echo "==============================ENVIRONMENT DUMP BEFORE TESTING START================="
            env|sort
            echo "==============================ENVIRONMENT DUMP BEFORE TESTING END================="
            #    ---
            if [ -d "test" ] ; then
                echo " \"test\" is a directory"

                #############################################################################
                # ADDING THE NEW TEST FRAMEWORKS INTO THE TEST SYSTEM
                # NOTE: We need to do this because the bamboo.sh script is exec'ed not sourced,
                #       and therefore loads the desired modules and sets up the environment
                #       variables as necessary.  If we dont do it here, then when bamboo.sh
                #       exits, the environment (and loaded modules) are reset, and we would
                #       need to reset these items in the Jenkins script.
                #############################################################################

                if [[ ${SST_TEST_FRAMEWORKS_SST_MACRO_NO_CORE:+isSet} == isSet ]] ; then
                    echo "**************************************************************************"
                    echo "***                                                                    ***"
                    echo "*** RUNING BAMBOO'S dotests() for SST-MACRO WITH NO CORE               ***"
                    echo "***                                                                    ***"
                    echo "**************************************************************************"
                    dotests $1 $4
                    retval=$?
                else
                    # Running Core or Elements testing using the New Frameworks
                    # Get the Paths to the test frameworks applications
                    if command -v sst-test-core > /dev/null 2>&1; then
                        export SST_TEST_FRAMEWORKS_CORE_APP_EXE=`command -v sst-test-core`
                    else
                        echo "ERROR: Cannot Find sst-test-core on system"
                        exit 128
                    fi

                    if command -v sst-test-elements > /dev/null 2>&1; then
                        export SST_TEST_FRAMEWORKS_ELEMENTS_APP_EXE=`command -v sst-test-elements`
                    else
                        echo "ERROR: Cannot Find sst-test-elements on system"
                        exit 128
                    fi
                    echo "=============================================================="
                    echo "=== FOUND FRAMEWORKS APPS"
                    echo "=============================================================="
                    echo "SST_TEST_FRAMEWORKS_CORE_APP_EXE =" $SST_TEST_FRAMEWORKS_CORE_APP_EXE
                    echo "SST_TEST_FRAMEWORKS_ELEMENTS_APP_EXE =" $SST_TEST_FRAMEWORKS_ELEMENTS_APP_EXE

                    echo "**************************************************************************"
                    echo "***                                                                    ***"
                    echo "*** SST CONFIGURATION DUMP                                             ***"
                    echo "***                                                                    ***"
                    echo "**************************************************************************"
                    echo "Running sst-config"
                    cd $SST_ROOT
                    sst-config

                    if [[ ${SST_TEST_FRAMEWORKS_CORE_ONLY:+isSet} == isSet ]] ; then
                        echo "**************************************************************************"
                        echo "***                                                                    ***"
                        echo "*** RUNING NEW TEST FRAMEWORKS CORE TESTS RUNNING INSIDE OF BAMBOO     ***"
                        echo "***                                                                    ***"
                        echo "**************************************************************************"
                        # WE ARE RUNNING THE FRAMEWORKS CORE SET OF TESTS ONLY
                        cd $SST_ROOT
                        $SST_PYTHON_APP_EXE $SST_TEST_FRAMEWORKS_CORE_APP_EXE $SST_TEST_FRAMEWORKS_PARAMS -z -r $SST_MULTI_RANK_COUNT -t $SST_MULTI_THREAD_COUNT
                        retval=$?
                        echo "BAMBOO: SST Frameworks Core Test retval = $retval"
                    else
                        echo " ################################################################"
                        echo " #"
                        echo " #         ENTERING BAMBOO'S dotests() Function  "
                        echo " #"
                        echo " ################################################################"
                        # WE ARE RUNNING THE ORIGINAL SET OF BAMBOO TESTS FIRST
                        dotests $1 $4
                        retval=$?
                        echo "BAMBOO: SST original dotests retval = $retval"

                        # NOW RUN THE FRAMEWORKS ELEMENTS TESTS
                        if [[ ${SST_TEST_FRAMEWORKS_ELEMENTS_WILDCARD_TESTS:+isSet} == isSet ]] ; then
                            echo "**************************************************************************"
                            echo "***                                                                    "
                            echo "*** RUNING NEW TEST FRAMEWORKS ELEMENTS - SUBSET OF TESTS : ${SST_TEST_FRAMEWORKS_ELEMENTS_WILDCARD_TESTS}"
                            echo "***                                                                    "
                            echo "**************************************************************************"
                            # WE ARE RUNNING THE FRAMEWORKS ELEMENTS SUBSET OF TESTS (Set by wildcard) AFTER DOTESTS() HAVE RUN
                            cd $SST_ROOT
                            $SST_PYTHON_APP_EXE $SST_TEST_FRAMEWORKS_ELEMENTS_APP_EXE $SST_TEST_FRAMEWORKS_PARAMS -z -r $SST_MULTI_RANK_COUNT -t $SST_MULTI_THREAD_COUNT -w $SST_TEST_FRAMEWORKS_ELEMENTS_WILDCARD_TESTS
                            frameworks_retval=$?
                            echo "BAMBOO: SST Frameworks Elements Test retval = $frameworks_retval"
                        else
                            echo "**************************************************************************"
                            echo "***                                                                    "
                            echo "*** RUNING NEW TEST FRAMEWORKS CORE AND ELEMENTS - FULL SET OF TESTS"
                            echo "***                                                                    "
                            echo "**************************************************************************"
                            # WE ARE RUNNING THE FRAMEWORKS ELEMENTS FULL SET OF TESTS AFTER DOTESTS() HAVE RUN
                            cd $SST_ROOT
                            
                            $SST_PYTHON_APP_EXE $SST_TEST_FRAMEWORKS_CORE_APP_EXE $SST_TEST_FRAMEWORKS_PARAMS -z -r $SST_MULTI_RANK_COUNT -t $SST_MULTI_THREAD_COUNT
                            core_frameworks_retval=$?
                            $SST_PYTHON_APP_EXE $SST_TEST_FRAMEWORKS_ELEMENTS_APP_EXE $SST_TEST_FRAMEWORKS_PARAMS -k -z -r $SST_MULTI_RANK_COUNT -t $SST_MULTI_THREAD_COUNT
                            elements_frameworks_retval=$?
                            echo "BAMBOO: SST Frameworks Core Test retval = $core_frameworks_retval"
                            echo "BAMBOO: SST Frameworks Elements Test retval = $elements_frameworks_retval"
                        fi

                        # Check the retval result from the bamboo dotests then check the frameworks_retval results with the frameworks run
                        if [ $retval -eq 0 ]; then
                            # Did the dotests pass, if so, then return the results
                            # from the frameworks tests
                            if [ $core_frameworks_retval -eq 0 ]; then
                                retval=$elements_frameworks_retval
                            else
                                retval = $core_frameworks_retval
                            fi
                        fi
                        echo "BAMBOO: Combined Frameworks + dotests retval = $retval"
                    fi
                    echo "BAMBOO: FINAL TESTING RESULTS retval = $retval"
                fi
            fi
        fi
    fi
fi
date

if [ $retval -eq 0 ]
then
    echo "$0 : BAMBOO: Exit Success."
else
    echo "$0 : BAMBOO: Exit Failure."
fi

echo "BAMBOO: JUST BEFORE EXIT retval = $retval"
exit $retval
