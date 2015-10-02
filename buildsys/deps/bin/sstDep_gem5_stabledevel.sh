# !/bin/bash
# sstDep_gem5_stabledevel.sh

# Description: 

# A bash script containing functions to process SST's gem5
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to gem5
export SST_BUILD_GEM5=1
# Environment variable uniquely identifying this script
export SST_BUILD_GEM5_STABLEDEVEL=1
#===============================================================================
# GEM5
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_gem5
# Purpose:g
#     Prepare gem5 for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged gem5 code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_GEM5_VERSION_LOCAL="004"
export SST_DEPS_SRC_STAGED_GEM5=${SST_DEPS_SRC_STAGING}/sst-gem5-devel.devel
sstDepsStage_gem5 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging sstgem5 stabledevel"

    # Fetch latest gem5 from the sstgem5 repository. Once fetched, files
    # should be available in $SST_DEPS_SRC_STAGED_GEM5

    pushd ${SST_DEPS_SRC_STAGING}
    date

    trycount=0
    tryLimit=3
    doneTrying=0

    if [ $SST_DEPS_OS_NAME = "Darwin" ] ; then
        # MacOS is special
        echo "No Clone time limit on MacOS"
        TIMELIMITCODE=""
    else
               ## Impose a 10 minute time limit  (10*60*1000 miliseconds)  on Linux
        echo "Do the following Mercurial clone -- with a 10 minute time limit"
        TIMELIMITCODE="${SST_DEPS_BIN}/sstDep_limitTime.sh -t 600000"
    fi
    until [ $doneTrying -eq 1 ]
    do
        # increment try count
        trycount=`expr $trycount + 1`
        # attempt clone
        if [[ ${SST_DEPS_BUILD_WITH_ORIG_REPOS:+isSet} != isSet ]]
        then
            # if SST_DEPS_BUILD_WITH_ORIG_REPOS is not set or is empty, clone from mirror
            echo "hg clone http://s917191.sandia.gov:8000/ sst-gem5-devel.devel"
            ${TIMELIMITCODE} hg clone http://s917191.sandia.gov:8000/ sst-gem5-devel.devel 

        else
            # clone from the original source repository
            echo "hg clone https://code.google.com/p/sst-gem5-devel.devel"

            ${TIMELIMITCODE}  hg clone https://code.google.com/p/sst-gem5-devel.devel/ sst-gem5-devel.devel
        fi

        if [ $? -ne 0 ]
        then
            # clone has failed
            if [ $trycount -eq $tryLimit ]
            then
                # bail if tryLimit exceeded
                echo "Clone of repository failed after $trycount attempts"
                echo "ERROR: sstDep_gem5_stabledevel.sh: sstmacro hg repository clone failure."
                echo "       Do you need to configure an HTTP proxy in your ~/.hgrc?"
                echo "       Example ~/.hgrc section, where 8030 is an example proxyport:"
                echo "       [http_proxy]"
                echo "       host = yourHttpProxyHostname:8030"
                doneTrying=1
                retVal=1
            else
                # otherwise, try again
                doneTrying=0
                sleepTime=15  # seconds
                echo "ERROR: Clone of repository failed for some reason. Retrying in $sleepTime seconds..."
                rm -rf sst-gem5-devel.devel
                sleep $sleepTime
            fi

        else
            # clone successful
            echo "Clone of repository succeeded in $trycount tries"
            doneTrying=1
            retVal=0

            pushd ${SST_DEPS_SRC_STAGED_GEM5}

            # Since multiple heads exist, explicitly select mainline
            hg update default

            local currentBranch=`hg branch`
            local gem5HeadRevision=`hg head | head -1`
            popd

            sstDepsAnnounce -h $FUNCNAME -m "localRev:headCommit $gem5HeadRevision selected on branch $currentBranch"
        fi

    done

    popd
    return $retVal

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_gem5
# Purpose:
#     Build and install SST gem5 dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed gem5 dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_gem5 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying sstgem5 stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_GEM5}



    # Display compiler environment variables
    echo "CC=${CC}\nCXX=${CXX}\nMPICC=${MPICC}\nMPICXX=${MPICXX}"

    # Use "software construct" (scons) to create libgem5_opt.[dylib,so]

    if [ $SST_DEPS_OS_NAME = "Darwin" ]
    then
        # MacOS is special
        echo "y" > $TMPDIR/yes.in
        scons build/X86_SE/libgem5_opt.dylib --verbose < $TMPDIR/yes.in
    else
        yes "" | scons -j4 build/X86_SE/libgem5_opt.so --verbose
    fi

    # ------------------------------------------------------------------------
    # NOTE: Fri Mar 16 15:27:39 MDT 2012
    #
    # The gem5 repository checks for the following hooks and tries to
    # install them when gem5 is built by the above operation:
    #   hooks.pretxncommit.style=python:style.check_style
    #   hooks.pre-qrefresh.style=python:style.check_style
    #
    # Unfortunately, scons demands acknowledgement to install these,
    # which can block the completion of the repository clone
    # operation. The 'yes' command is used to feed a hard return to
    # scons to force acknowledgement.
    # ------------------------------------------------------------------------


    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_gem5_stabledevel.sh: gem5 scons failure"
        return $retval
    else
	sstDepsAnnounce -h $FUNCNAME -m "SCONS SUCCESSFUL"
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of gem5-sst integration, this is how it is
    # installed
    sstDepsAnnounce -h $FUNCNAME -m "Installing sstgem5 stabledevel"
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_GEM5} ${SST_DEPS_INSTALL_DEPS}/packages/gem5-sst

    popd

}

# Installation location as used by SST's "./configure --with-gem5=..."
export SST_DEPS_INSTALL_GEM5SST=${SST_DEPS_INSTALL_DEPS}/packages/gem5-sst/build/X86_SE
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_gem5
# Purpose:
#     Query SST gem5 dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported gem5 dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_gem5 ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_GEM5SST=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_GEM5SST=\"${SST_DEPS_INSTALL_GEM5SST}\""
}

