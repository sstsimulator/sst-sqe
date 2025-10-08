#!/bin/bash

# Description:

# A bash script to process the dependencies for SST, which includes
# 1) Invoke each dependency's pre-patch preparation
# 2) Apply patches to the dependencies, as needed
# 3) Invoke each dependency's installation procedure

# Preconditions:

# 1) Code package for each dependency is installed in
#    ${SST_DEPS_SRC_PRISTINE}, and is in the format expected by its
#    associated ${SST_DEPS_BIN}/sstDep_{dependency}.sh processing
#    script.
#
# 2) All patchfiles used by this script are readable and
#    installed in ${SST_DEPS_PATCHFILES}
#
# 3) The directory ${SST_DEPS_SRC_STAGING} is writeable
#
# 4) The directory ${SST_DEPS_INSTALL_DEPS} is writeable

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
# shellcheck source=buildsys/deps/include/depsDefinitions.sh
. "${PARENT_DIR}"/include/depsDefinitions.sh


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDoStaging
# Purpose:
#     Prepare pristine code for patching
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Package-dependent staging of pristine dependency code completed.
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDoStaging ()
{
    #
    # For each dependency package, perform its specific
    # staging. Staging order should not matter here.
    #

    if [ -n "${SST_BUILD_DRAMSIM3}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMsim3
        #-----------------------------------------------------------------------
        sstDepsStage_dramsim3
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DRAMsim3 code staging failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_GPGPUSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GPGPUSim
        #-----------------------------------------------------------------------
        sstDepsStage_GPGPUSim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: GPGPUSim code staging failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_GOBLIN_HMCSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GOBLIN_HMCSIM
        #-----------------------------------------------------------------------
        sstDepsStage_goblin_hmcsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: goblin_hmcsim code staging failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_RAMULATOR}" ]
    then
        #-----------------------------------------------------------------------
        # RAMULATOR
        #-----------------------------------------------------------------------
        sstDepsStage_ramulator
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ramulator code staging failure"
            return $retval
        fi
    fi
}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsPatchSource
# Purpose:
#     Patch source code in preparation for building
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Dependency code patched successfully
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsPatchSource ()
{
    #
    # Patch source packages in the staging area as needed
    #

    if [ -n "${SST_BUILD_DRAMSIM3}" ]
    then
        pushd "${SST_DEPS_SRC_STAGED_DRAMSIM3}"
        sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Patching DRAMSim3"
        patch -p0 -i "${SST_DEPS_PATCHFILES}"/dramsim3_cmake_version.patch
        retval=$?
        if [ $retval -ne 0 ]
        then
            echo "ERROR: sstDependencies.sh:  DRAMSim3 patch failure"
            return $retval
        fi
        popd
    fi

    if [ -n "${SST_BUILD_RAMULATOR_STABLEDEVEL}" ]
    then
        #-----------------------------------------------------------------------
        # Ramulator-stabledevel
        #-----------------------------------------------------------------------

            # Patch ramulator sha 7d2e72306c6079768e11a1867eb67b60cee34a1c

            # Patching to build static version for Linux
            sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Patching ramulator "
            pushd "${SST_DEPS_SRC_STAGING}"/ramulator

            ls -lia

            patch -p1 -i "${SST_DEPS_PATCHFILES}"/ramulator_gcc48Patch.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ramulator patch failure"
                return $retval
            fi

            patch -p0 -i "${SST_DEPS_PATCHFILES}"/ramulator_include.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ramulator patch failure"
                return $retval
            fi

            patch -p1 -i "${SST_DEPS_PATCHFILES}"/ramulator_libPatch.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ramulator patch failure"
                return $retval
            fi

            popd
    fi
}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy
# Purpose:
#     Perform package-specific steps for deployment of dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Package-dependent building and staging of dependencies complted
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy ()
{
    #
    # Deploy each dependency
    #

    if [ -n "${SST_BUILD_DRAMSIM3}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMsim3
        #-----------------------------------------------------------------------
        sstDepsDeploy_dramsim3
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DRAMsim3 deployment failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_GPGPUSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GPGPUSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_GPGPUSim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: GPGPUSim code deployment failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_GOBLIN_HMCSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GOBLIN_HMCSIM
        #-----------------------------------------------------------------------
        sstDepsDeploy_goblin_hmcsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: goblin_hmcsim deployment failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_RAMULATOR}" ]
    then
        #-----------------------------------------------------------------------
        # RAMULATOR
        #-----------------------------------------------------------------------
        sstDepsDeploy_ramulator
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ramulator deployment failure"
            return $retval
        fi
    fi

}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDoQuery
# Purpose:
#     Perform package-specific steps for query of dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Package-dependent query of dependencies completed
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDoQuery ()
{
    #
    # Query each dependency
    #

    if [ -n "${SST_BUILD_DRAMSIM3}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMsim3
        #-----------------------------------------------------------------------
        sstDepsQuery_dramsim3
    fi

    if [ -n "${SST_BUILD_GPGPUSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GPGPUSim
        #-----------------------------------------------------------------------
        sstDepsQuery_GPGPUSim
    fi

    if [ -n "${SST_BUILD_GOBLIN_HMCSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GOBLIN_HMCSIM
        #-----------------------------------------------------------------------
        sstDepsQuery_goblin_hmcsim
    fi

    if [ -n "${SST_BUILD_RAMULATOR}" ]
    then
        #-----------------------------------------------------------------------
        # RAMULATOR
        #-----------------------------------------------------------------------
        sstDepsQuery_ramulator
    fi
}

#===============================================================================
# "main" function

sstDepsDoDependencies ()
{

    # create staging and installation directories, if needed
    if [ ! -d "${SST_DEPS_SRC_STAGING}" ]
    then
        mkdir -p "${SST_DEPS_SRC_STAGING}"
    fi

    if [ ! -d "${SST_DEPS_INSTALL_DEPS}" ]
    then
        mkdir -p "${SST_DEPS_INSTALL_DEPS}"
    fi


    if   [ $# -eq 1 ] && [[ "${1}" == "restageDeps" ]]
    then
        # Purge deps staging area and deps install area
        rm -Rf "${SST_DEPS_SRC_STAGING:?}"/*
        rm -Rf "${SST_DEPS_INSTALL_DEPS:?}"/*

        # Restage source code from pristine
        sstDepsDoStaging
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency code staging failure"
            return $retval
        fi

        # Patch staged source code
        sstDepsPatchSource
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency code patch failure"
            return $retval
        fi

    elif [ $# -eq 1 ] && [[ "${1}" == "develBuild" ]]
    then
        # Purge deps install area, leave staged area alone
        rm -Rf "${SST_DEPS_INSTALL_DEPS:?}"/*

        # Deploy dependencies (build from staged area and install)
        sstDepsDeploy
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency deployment failure"
            return $retval
        fi

    elif [ $# -eq 1 ] && [[ "${1}" == "cleanBuild" ]]
    then
        # Purge deps staging area and deps install area
        rm -Rf "${SST_DEPS_SRC_STAGING:?}"/*
        rm -Rf "${SST_DEPS_INSTALL_DEPS:?}"/*

        sstDepsAnnounce -h "sstDepsDoDependencies" -m "Begin Staging "
        # Restage source code from pristine
        sstDepsDoStaging
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency code staging failure"
            return $retval
        fi

        # Patch staged source code
        sstDepsAnnounce -h "sstDepsDoDependencies" -m "Begin Patching "
        sstDepsPatchSource
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency code patch failure"
            return $retval
        fi

        # Deploy dependencies (build from staged area and install)
        sstDepsAnnounce -h "sstDepsDoDependencies" -m "Begin Deploys  "
        sstDepsDeploy
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency deployment failure"
            return $retval
        fi

    elif [ $# -eq 1 ] && [[ "${1}" == "queryEnv" ]]
    then
        # Print suggested environment
        echo "# --------------------------------------------------------------------"
        echo "# Consider exporting the following variables to your environment"
        echo "# to aid in configuring SST. This can be done by saving this output"
        echo "# to a script file and sourcing it from your shell."
        sstDepsDoQuery
        showedQuery=1
    else
        echo "ERROR: sstDependencies.sh: unknown dependency option or insufficient dependency option"
        echo "       Did you forget to specify restageDeps, develBuild, or cleanBuild?"
        return 1
    fi

}

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# main function
# Usage:
# $ sstDependencies.sh -z [arg4] -b [arg5]
#   -g [arg6] -m [arg7] -i [arg8] -o [arg9] -h [arg10] [buildtype]
# where
#   -D DRAMsim3 version (default|stabledevel|none)
#   -G Goblim HMCSim (default|stabledevel|none)
#   -r Ramulator (default)
#   -A GPGPUSim (stabledevel|1.1|master|default|none)
#
#   [buildtype] = (restageDeps|develBuild|cleanBuild)
#
#   NOTE:
#     - ALL arguments are mandatory
#     - Assume that selecting all default is safest
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

# use getopts
OPTIND=1

while getopts :D:G:r:A: opt

do
    case "$opt" in
        D) # DRAMsim3
            echo "# found the -D (DRAMsim3) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest DRAMsim3 from repository ("stable development")
                    echo "# (default) stabledevel: build latest DRAMsim3 from repository"
                    if [[  ${SST_WITHOUT_DRAMSIM3:+isSet} == isSet ]] ; then
                        echo "  DRAMSIM3 IS NOT ENABLED BY SST_WITHOUT_DRAMSIM3 flag"
                    else
                        # shellcheck source=buildsys/deps/bin/sstDep_dramsim3_stabledevel.sh
                        . "${SST_DEPS_BIN}"/sstDep_dramsim3_stabledevel.sh
                    fi
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build DRAMsim3"
                    ;;
                *) # unknown DRAMSim argument
                    echo "# Unknown argument '$OPTARG', will not build DRAMsim3"
                    ;;
            esac
            ;;
        G) # Goblin_HMCSIM
            echo "# found the -G (goblin_hmcsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest Goblin_HMCSIM from repository ("stable development")
                    echo "# (default) stabledevel: build latest Goblin_HMCSIM from repository"
                    # shellcheck source=buildsys/deps/bin/sstDep_goblin_hmcsim_stabledevel.sh
                    . "${SST_DEPS_BIN}"/sstDep_goblin_hmcsim_stabledevel.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Goblin_HMCSIM"
                    ;;
                *) # unknown Goblin_HMCSIM argument
                    echo "# Unknown argument '$OPTARG', will not build Goblin_HMCSIM"
                    ;;
            esac
            ;;
        r) # Ramulator
            echo "# found the -r (ramulator) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest Ramulator from repository ("stable development")
                    echo "# (default) stabledevel: build latest Ramulator from repository"
                    # shellcheck source=buildsys/deps/bin/sstDep_ramulator_stabledevel.sh
                    . "${SST_DEPS_BIN}"/sstDep_ramulator_stabledevel.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Ramulator"
                    ;;
                *) # unknown Ramulator argument
                    echo "# Unknown argument '$OPTARG', will not build Ramulator"
                    ;;
            esac
            ;;
        A)  # Build GPGPUSim
            echo "# found the -A (GPGPUSim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                1.1|stabledevel)   # Build GPGPUSim
                    echo "# ${OPTARG}: Build GPGPUSim 1.1 tag"
                    # shellcheck source=buildsys/deps/bin/sstDep_gpgpusim.sh
                    . "${SST_DEPS_BIN}"/sstDep_gpgpusim.sh 1.1
                    ;;
                master)   # Build GPGPUSim
                    echo "# ${OPTARG}: Build GPGPUSim master branch"
                    # shellcheck source=buildsys/deps/bin/sstDep_gpgpusim.sh
                    . "${SST_DEPS_BIN}"/sstDep_gpgpusim.sh master
                    ;;
                none|default)  # Do not build GPGPUSim
                    echo "# default: will not build GPGPUSim"
                    ;;
            esac
            ;;
        *) echo "# unknown option: $opt"
            ;;
    esac
done

shift $(( OPTIND - 1 ))

sstDepsDoDependencies "${1}"
retval=$?
if [ $retval -ne 0 ]
then
    # bail out on error
    echo "ERROR: sstDependencies.sh: sstDepsDoDependences code failure"
    exit $retval
fi

if [ -z "${showedQuery}" ]
then
    # Print suggested environment
    echo ""
    echo "# --------------------------------------------------------------------"
    echo "# Consider exporting the following variables to your environment"
    echo "# to aid in configuring SST. This can be done by saving this output"
    echo "# to a script file and sourcing it from your shell."
    sstDepsDoQuery
fi
