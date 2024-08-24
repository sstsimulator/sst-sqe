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

    if [ -n "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        sstDepsStage_dramsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DRAMSim code staging failure"
            return $retval
        fi
    fi

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

    if [ -n "${SST_BUILD_NVDIMMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # NVDIMMSim
        #-----------------------------------------------------------------------
        sstDepsStage_nvdimmsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: NVDIMMSim code staging failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_HYBRIDSIM}" ]
    then
        #-----------------------------------------------------------------------
        # HybridSim
        #-----------------------------------------------------------------------
        sstDepsStage_hybridsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: HybridSim code staging failure"
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

    if [ -n "${SST_BUILD_HBM_DRAMSIM2}" ]
    then
        #-----------------------------------------------------------------------
        # HBM_DRAMSIM2
        #-----------------------------------------------------------------------
        sstDepsStage_hbm_dramsim2
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: hbm_dramsim2 code staging failure"
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

    if [ -n "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        if [[ "${SST_DEPS_OS_NAME}" == "Linux" ]] && [ -n "${SST_BUILD_DRAMSIM_STATIC}" ]
        then
            # Patching to build static version for Linux
            pushd "${SST_DEPS_SRC_STAGING}"
            sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Patching DRAMSim"
            patch -p0 -i "${SST_DEPS_PATCHFILES}"/DRAMSim-sst.linux.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  DRAMSim (Linux) patch failure"
                return $retval
            fi
            popd
        fi
        # if [ $SST_DEPS_OS_NAME = "Darwin" ]
        # then
        #     # Patching to build for Mac OS X
        #     pushd ${SST_DEPS_SRC_STAGING}
        #     patch -p0 -i ${SST_DEPS_PATCHFILES}/DRAMSim-sst.MacOS.patch
        #     retval=$?
        #     if [ $retval -ne 0 ]
        #     then
        #         # bail out on error
        #         echo "ERROR: sstDependencies.sh:  DRAMSim-sst.MacOS patch failure"
        #         return $retval
        #     fi

        #     popd
        # fi

    fi

    if [ -n "${SST_BUILD_NVDIMMSIM}" ]
    then
        pushd "${SST_DEPS_SRC_STAGED_NVDIMMSIM}"
        sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Patching NVDIMMSim"
        patch -p0 -i "${SST_DEPS_PATCHFILES}"/NVDIMMSim.patch
        retval=$?
        if [ $retval -ne 0 ]
        then
            echo "ERROR: sstDependencies.sh:  NVDIMMSim patch failure"
            return $retval
        fi
        popd
    fi

    if [ -n "${SST_BUILD_HYBRIDSIM}" ]
    then
        pushd "${SST_DEPS_SRC_STAGED_HYBRIDSIM}"
        sstDepsAnnounce -h "${FUNCNAME[0]}" -m "Patching HybridSim"
        patch -p0 -i "${SST_DEPS_PATCHFILES}"/HybridSim.patch
        retval=$?
        if [ $retval -ne 0 ]
        then
            echo "ERROR: sstDependencies.sh:  HybridSim patch failure"
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

    if [ -n "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_dramsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DRAMSim deployment failure"
            return $retval
        fi
    fi

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

    if [ -n "${SST_BUILD_NVDIMMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # NVDIMMSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_nvdimmsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: NVDIMMSim deployment failure"
            return $retval
        fi
    fi

    if [ -n "${SST_BUILD_HYBRIDSIM}" ]
    then
        #-----------------------------------------------------------------------
        # HybridSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_hybridsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: HybridSim deployment failure"
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

    if [ -n "${SST_BUILD_HBM_DRAMSIM2}" ]
    then
        #-----------------------------------------------------------------------
        # HBM_DRAMSIM2
        #-----------------------------------------------------------------------
        sstDepsDeploy_hbm_dramsim2
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: hbm_dramsim2 deployment failure"
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

    if [ -n "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        sstDepsQuery_dramsim
    fi

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

    if [ -n "${SST_BUILD_NVDIMMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # NVDIMMSim
        #-----------------------------------------------------------------------
        sstDepsQuery_nvdimmsim
    fi


    if [ -n "${SST_BUILD_HYBRIDSIM}" ]
    then
        #-----------------------------------------------------------------------
        # HybridSim
        #-----------------------------------------------------------------------
        sstDepsQuery_hybridsim
    fi


    if [ -n "${SST_BUILD_GOBLIN_HMCSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GOBLIN_HMCSIM
        #-----------------------------------------------------------------------
        sstDepsQuery_goblin_hmcsim
    fi

    if [ -n "${SST_BUILD_HBM_DRAMSIM2}" ]
    then
        #-----------------------------------------------------------------------
        # HBM_DRAMSIM2
        #-----------------------------------------------------------------------
        sstDepsQuery_hbm_dramsim2
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
# $ sstDependencies.sh -d [arg2] -p [arg3] -z [arg4] -b [arg5]
#   -g [arg6] -m [arg7] -i [arg8] -o [arg9] -h [arg10] [buildtype]
# where
#   -d DRAMSim version (default|stabledevel|2.2|2.2.2|r4b00b22|none)
#   -D DRAMsim3 version (default|stabledevel|none)
#   -G Goblim HMCSim (default|stabledevel|none)
#   -N nvdimmsim (default)
#   -H HBM_DRAMSim2 (default)
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

while getopts :D:d:G:H:r:N:A: opt

do
    case "$opt" in
        d) # DRAMSim
            echo "# found the -d (Dramsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest DRAMSim from repository ("stable development")
                    echo "# (default) stabledevel: build latest DRAMSim from repository"
                    # shellcheck source=buildsys/deps/bin/sstDep_dramsim_stabledevel.sh
                    . "${SST_DEPS_BIN}"/sstDep_dramsim_stabledevel.sh
                    ;;
                2.2.2) # build DRAMSim v2.2.2
                    echo "# 2.2.2: build DRAMSim v2.2.2 release"
                    # shellcheck source=buildsys/deps/bin/sstDep_dramsim_v2.2.2.sh
                    . "${SST_DEPS_BIN}"/sstDep_dramsim_v2.2.2.sh
                    ;;
                2.2.1) # build DRAMSim v2.2.1
                    echo "# 2.2.1: build DRAMSim v2.2.1 release"
                    # shellcheck source=buildsys/deps/bin/sstDep_dramsim_v2.2.1.sh
                    . "${SST_DEPS_BIN}"/sstDep_dramsim_v2.2.1.sh
                    ;;
                2.2) # build DRAMSim v2.2 (tagged DRAMSim release)
                    echo "# 2.2: build DRAMSim v2.2 tagged release"
                    # shellcheck source=buildsys/deps/bin/sstDep_dramsim_v2.2.sh
                    . "${SST_DEPS_BIN}"/sstDep_dramsim_v2.2.sh
                    ;;
                r4b00b22) # build DRAMSim commit ID 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f
                    echo "# r4b00b22: build DRAMSim commit ID 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f"
                    # shellcheck source=buildsys/deps/bin/sstDep_dramsim_r4b00b22.sh
                    . "${SST_DEPS_BIN}"/sstDep_dramsim_r4b00b22.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build DRAMSim"
                    ;;
                *) # unknown DRAMSim argument
                    echo "# Unknown argument '$OPTARG', will not build DRAMSim"
                    ;;
            esac
            ;;
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
        H) # HBM_DRAMSim2
            echo "# found the -H (hbm_dramsim2) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest HBM_DRAMSim2 from repository ("stable development")
                    echo "# (default) stabledevel: build latest HBM_DRAMSim2 from repository"
                    # shellcheck source=buildsys/deps/bin/sstDep_hbm_dramsim2_stabledevel.sh
                    . "${SST_DEPS_BIN}"/sstDep_hbm_dramsim2_stabledevel.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build HBM_DRAMSim2"
                    ;;
                *) # unknown HBM_DRAMSim2 argument
                    echo "# Unknown argument '$OPTARG', will not build HBM_DRAMSim2"
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
        N)  # Do NVDIMMSIM
            echo "# found the -N (NVDIMMSIM) option, with value $OPTARG."
            # process arg
            case "$OPTARG" in
                default)
                    echo "# default will be built"
                    # shellcheck source=buildsys/deps/bin/sstDep_nvdimmsim.sh
                    . "${SST_DEPS_BIN}"/sstDep_nvdimmsim.sh

                    echo "# HybridSim will be built"
                    # shellcheck source=buildsys/deps/bin/sstDep_hybridsim.sh
                    . "${SST_DEPS_BIN}"/sstDep_hybridsim.sh
                    ;;
                none)  # Do not build NVDIMMSim
                    echo "# none: will not build NVDIMMSim"
                    ;;
            esac
            ;;
        A)  # Build GPGPUSim
            echo "# found the -A (GPGPUSim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                1.1|stabledevel)   # Build GPGPUSim
                    echo "# ${OPTARG}: Build GPGPUSim 1.1 tag"
                    # shellcheck source=buildsys/deps/bin/sstDep_GPGPUSim.sh
                    . "${SST_DEPS_BIN}"/sstDep_GPGPUSim.sh 1.1
                    ;;
                master)   # Build GPGPUSim
                    echo "# ${OPTARG}: Build GPGPUSim master branch"
                    # shellcheck source=buildsys/deps/bin/sstDep_GPGPUSim.sh
                    . "${SST_DEPS_BIN}"/sstDep_GPGPUSim.sh master
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
