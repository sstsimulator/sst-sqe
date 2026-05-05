#!/bin/bash
# sstDep_ramulator2_stabledevel.sh

# Description:

# A bash script containing functions to process SST's Ramulator2
# dependency.

echo "# Loading Deps File sstDep_ramulator2_stabledevel.sh"

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
# shellcheck disable=SC1091
. "${PARENT_DIR}"/include/depsDefinitions.sh

# Environment variable unique to Ramulator2
export SST_BUILD_RAMULATOR2=1
# Environment variable uniquely identifying this script
export SST_BUILD_RAMULATOR2_STABLEDEVEL=1
#===============================================================================
# Ramulator2
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_ramulator2
# Purpose:
#     Prepare Ramulator2 code
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Ramulator2 code
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_RAMULATOR2=${SST_DEPS_SRC_STAGING}/ramulator2
sstDepsStage_ramulator2 ()
{
    sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Staging ramulator2 stabledevel"

    pushd "${SST_DEPS_SRC_STAGING}"

   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      echo " "
      date
      echo ' '
      echo "git clone https://github.com/CMU-SAFARI/ramulator2.git ramulator2"
      git clone https://github.com/CMU-SAFARI/ramulator2.git ramulator2
      retVal=$?
      echo ' '
      date
      echo ' '
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of ramulator2 \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$((Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf ramulator2
             continue                        ## Try another
         fi
         return $retVal
      fi
   done
   echo " "

    if [ "$retVal" -ne 0 ]                     ## retVal from git clone
    then
        # bail out on error
        echo "ERROR: sstDep_ramulator2_stabledevel.sh: ramulator2 git fetch failure"
        sstDepsAnnounce -h "${FUNCNAME[0]}" -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return "$retVal"
    fi

    #  Move into the ramulator2 directory
    pushd "${SST_DEPS_SRC_STAGED_RAMULATOR2}"
    git checkout 011ccd77ff7788a35812fbe0446f5f327497022d
    # shellcheck disable=SC2046
    echo "ramulator2.git" $(git log HEAD | sed 4q) >&2

    find ../../../.. -name "sst_frontend.cpp" -exec cp {} src/frontend/impl/external_wrapper/. \;
    sed -i '\#impl/external_wrapper/gem5_frontend.cpp#a impl/external_wrapper/sst_frontend.cpp' src/frontend/CMakeLists.txt

    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_ramulator2
# Purpose:
#     Build and install SST Ramulator2 dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Ramulator2 dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_ramulator2 ()
{
    sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Deploying Ramulator2 stabledevel"

    pushd "${SST_DEPS_SRC_STAGED_RAMULATOR2}"

    mkdir build
    cd build
    pwd

    cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..   # NOTE: CMake version 3 or greater required
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        cmake --version
        echo "ERROR: sstDep_ramulator2_stabledevel.sh: cmake failure - is CMake Ver3 or greater???"
        popd
        return $retval
    fi

    # Build and install RAMULATOR2
    make VERBOSE=1

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_ramulator2_stabledevel.sh: ramulator2 make failure"
        popd
        return $retval
    fi

    set -x
    LD_LIBRARY_PATH=${SST_DEPS_SRC_STAGED_RAMULATOR2}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH

    popd
    set +x

    # NOTE: There is no "make install" for Ramulator2.  Instead make a
    #       link to the compilied directory
    if [ ! -d "${SST_DEPS_INSTALL_DEPS}"/packages ]
    then
        mkdir -p "${SST_DEPS_INSTALL_DEPS}"/packages
    fi

    ln -s "${SST_DEPS_SRC_STAGED_RAMULATOR2}" "${SST_DEPS_INSTALL_DEPS}"/packages/Ramulator2

}

# Installation location as used by SST's "./configure --with-ramulator2=..."
export SST_DEPS_INSTALL_RAMULATOR2=${SST_DEPS_INSTALL_DEPS}/packages/Ramulator2
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_ramulator2
# Purpose:
#     Query SST Ramulator2 dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Ramulator2 dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_ramulator2 ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_RAMULATOR2=\"REPOSITORY\""
    # shellcheck disable=SC2153
    echo "export SST_DEPS_INSTALL_RAMULATOR2=\"${SST_DEPS_INSTALL_RAMULATOR2}\""
}
