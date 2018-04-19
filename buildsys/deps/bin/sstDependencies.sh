#!/bin/bash
# sstDependencies.sh

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
. ${PARENT_DIR}/include/depsDefinitions.sh


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

    if [ ! -z "${SST_BUILD_DISKSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DiskSim
        #-----------------------------------------------------------------------
        sstDepsStage_disksim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DiskSim code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_DRAMSIM}" ]
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

    if [ ! -z "${SST_BUILD_NVDIMMSIM}" ]
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

    if [ ! -z "${SST_BUILD_HYBRIDSIM}" ]
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

    if [ ! -z "${SST_BUILD_PARMETIS}" ]
    then
        #-----------------------------------------------------------------------
        # ParMETIS
        #-----------------------------------------------------------------------
        sstDepsStage_parmetis
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ParMETIS code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_ZOLTAN}" ]
    then
        #-----------------------------------------------------------------------
        # Zoltan
        #-----------------------------------------------------------------------
        sstDepsStage_zoltan
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Zoltan code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_BOOST}" ]
    then
        #-----------------------------------------------------------------------
        # Boost
        #-----------------------------------------------------------------------
        sstDepsStage_boost
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Boost code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_GEM5}" ]
    then
        #-----------------------------------------------------------------------
        # gem5
        #-----------------------------------------------------------------------
        sstDepsStage_gem5
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: gem5 code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_MCPAT}" ]
    then
        #-----------------------------------------------------------------------
        # McPAT
        #-----------------------------------------------------------------------
        sstDepsStage_mcpat
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: McPAT code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_MACSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Macsim
        #-----------------------------------------------------------------------
        sstDepsStage_macsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Macsim code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_INTSIM}" ]
    then
        #-----------------------------------------------------------------------
        # IntSim
        #-----------------------------------------------------------------------
        sstDepsStage_intsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: IntSim code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_ORION}" ]
    then
        #-----------------------------------------------------------------------
        # ORION
        #-----------------------------------------------------------------------
        sstDepsStage_orion
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ORION code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_HOTSPOT}" ]
    then
        #-----------------------------------------------------------------------
        # HotSpot
        #-----------------------------------------------------------------------
        sstDepsStage_hotspot
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: HOTSPOT code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_SSTMACRO}" ]
    then
        #-----------------------------------------------------------------------
        # sstmacro 
        #-----------------------------------------------------------------------
        sstDepsStage_sstmacro
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: sstmacro code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_QSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Qsim
        #-----------------------------------------------------------------------
        sstDepsStage_qsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Qsim code staging failure"
            return $retval
        fi
    fi
   
  if [ ! -z "${SST_BUILD_OMNET}" ]
    then
        #-----------------------------------------------------------------------
        # PhoenixSim
        #-----------------------------------------------------------------------
        sstDepsStage_omnet
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Omnet++ code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_PORTALS4}" ]
    then
        #-----------------------------------------------------------------------
        # Portals4
        #-----------------------------------------------------------------------
        sstDepsAnnounce -h $FUNCNAME -m "No staging for Portals-4"
    fi
   
  if [ ! -z "${SST_BUILD_CHDL}" ]
    then
        #-----------------------------------------------------------------------
        # CHDL
        #-----------------------------------------------------------------------
        sstDepsStage_chdl
        retval_chdl=$?
        if [ $retval_chdl -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: chdl staging failure"
            return $retval
        fi

	sstDepsStage_chdl_stl
        retval_chdl=$?
        if [ $retval_chdl -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: chdl staging failure"
            return $retval
        fi

        sstDepsStage_chdl_module
        retval_chdl=$?
        if [ $retval_chdl -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: chdl staging failure"
            return $retval
        fi

    fi

    if [ ! -z "${SST_BUILD_GOBLIN_HMCSIM}" ]
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

    if [ ! -z "${SST_BUILD_HBM_DRAMSIM2}" ]
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

    if [ ! -z "${SST_BUILD_RAMULATOR}" ]
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

    if [ ! -z "${SST_BUILD_DISKSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DiskSim
        #-----------------------------------------------------------------------
        # If an x86_64 Linux platform, patch DiskSim
        if [ $SST_DEPS_CPU_ARCH = "x86_64" ]
        then
            pushd ${SST_DEPS_SRC_STAGING}
            sstDepsAnnounce -h $FUNCNAME -m "Patching DiskSim"
            patch -p1 -i ${SST_DEPS_PATCHFILES}/disksim_4.0_64bit.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  DiskSim patch failure"
                return $retval
            fi

            popd
        fi
    fi

    if [ ! -z "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        if [ $SST_DEPS_OS_NAME = "Linux" ] && [ ! -z $SST_BUILD_DRAMSIM_STATIC ]
        then
            # Patching to build static version for Linux
            pushd ${SST_DEPS_SRC_STAGING}
            sstDepsAnnounce -h $FUNCNAME -m "Patching DRAMSim"
            patch -p0 -i ${SST_DEPS_PATCHFILES}/DRAMSim-sst.linux.patch
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

    if [ ! -z "${SST_BUILD_PARMETIS}" ]
    then
        #-----------------------------------------------------------------------
        # ParMetis
        #-----------------------------------------------------------------------
        if [ $SST_DEPS_OS_NAME = "Linux" ]
        then
            # Patching to build for Linux
            pushd ${SST_DEPS_SRC_STAGING}
            patch -p0 -i ${SST_DEPS_PATCHFILES}/ParMetis.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ParMetis (Linux) patch failure"
                return $retval
            fi

            popd

        elif [ $SST_DEPS_OS_NAME = "Darwin" ]
        then
            # Patching to build for Mac OS X
            # REASON: Mac OS has malloc.h in /usr/include/sys, not /usr/include
            pushd ${SST_DEPS_SRC_STAGING}
            patch -p0 -i ${SST_DEPS_PATCHFILES}/ParMetis_MacOSX_include.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ParMetis (Mac OS X) patch failure"
                return $retval
            fi

            popd

        fi
    fi

 
    if [ ! -z ${SST_BUILD_OMNET} ]
    then
        #-----------------------------------------------------------------------
        # PhoenixSim/OMNeT++ 4.1
        #-----------------------------------------------------------------------
        # On any platform, patch OMNeT++ 4.1
        pushd ${SST_DEPS_SRC_STAGING}
        sstDepsAnnounce -h $FUNCNAME -m "Patching Omnet++"
        patch -p0 -i ${SST_DEPS_PATCHFILES}/omnet-4.1-diff.patch
        popd   
    fi

##     if [ ! -z "${SST_BUILD_PORTALS4}" ]
##     then
##         #-----------------------------------------------------------------------
##         # Portals4
##         #                 Gem5 is required
##         #-----------------------------------------------------------------------
##         
##         sstDepsAnnounce -h $FUNCNAME -m "Patching Gem5 SConscript for Portals 4"
## 
##         if [ -z "${SST_BUILD_GEM5}" ]
##         then
##             echo "ERROR: sstDependencies.sh:  gem5 is required for Portals 4"
##             return -1
##         fi
##                 pushd ${SST_DEPS_SRC_STAGED_GEM5}
##                 cd src
##                 patch -p0 -i ${SST_DEPS_PATCHFILES}/gem5-patched-portals4.patch
##                 retval=$?
##                 if [ $retval -ne 0 ]
##                 then
##                 # bail out on error
##                     echo "ERROR: sstDependencies.sh:  gem5 ( portals4 ) patch failure"
##                     return $retval
##                 fi
## 
##                 cd ..
##                 popd
##     fi

    if [ ! -z "${SST_BUILD_IRIS}" ]
    then
        #-----------------------------------------------------------------------
        # Iris test
        #-----------------------------------------------------------------------
        
        sstDepsAnnounce -h $FUNCNAME -m "Patching for Iris test case"
        # Patching to build for Iris
        echo "NO PATCH         No Patch       NO PATCH"
    fi

    if [ ! -z ${SST_BUILD_SSTMACRO_2_3_0} ]
    then
	#-----------------------------------------------------------------------
	# sstmacro-2.3.0
	#-----------------------------------------------------------------------
			# Patch sstmacro-2.3.0
			pushd ${SST_DEPS_SRC_STAGING}/sstmacro-2.3.0
			sstDepsAnnounce -h $FUNCNAME -m "Patching sstmacro"
			patch -p0 -i ${SST_DEPS_PATCHFILES}/sstmacro-2.3.0.patch
    			popd   
	fi



    if [ ! -z ${SST_BUILD_MACSIM_2_0_3} ]
    then
        #-----------------------------------------------------------------------
        # macsim-2.0.3
        #-----------------------------------------------------------------------

             # Patch macsim-2.0.3
             # Assumes pwd is SST_ROOT  (trunk)

             cd $SST_ROOT
             sstDepsAnnounce -h $FUNCNAME -m "Patching macsim-2.0.3"
             patch -p0 -i ${SST_DEPS_PATCHFILES}/macsim_2.0.3.patch
    fi

    if [ ! -z ${SST_BUILD_MACSIM_2_0_4} ]
    then
        #-----------------------------------------------------------------------
        # macsim-2.0.4
        #-----------------------------------------------------------------------

             # Patch macsim-2.0.4
             # Assumes pwd is SST_ROOT  (trunk)

             cd $SST_ROOT
             sstDepsAnnounce -h $FUNCNAME -m "Patching macsim-2.0.4"
             patch -p0 -i ${SST_DEPS_PATCHFILES}/macsim_2.0.4.patch
    fi

    if [ ! -z ${SST_BUILD_RAMULATOR_STABLEDEVEL} ]
    then
        #-----------------------------------------------------------------------
        # Ramulator-stabledevel
        #-----------------------------------------------------------------------

            # Patch ramulator sha 7d2e72306c6079768e11a1867eb67b60cee34a1c

            # Patching to build static version for Linux
            sstDepsAnnounce -h $FUNCNAME -m "Patching ramulator "
            pushd ${SST_DEPS_SRC_STAGING/ramulator}
            
            ls -lia
            
            patch -p1 -i ${SST_DEPS_PATCHFILES}/ramulator_gcc48Patch.patch
            retval=$?
            if [ $retval -ne 0 ]
            then
                # bail out on error
                echo "ERROR: sstDependencies.sh:  ramulator patch failure"
                return $retval
            fi

            patch -p1 -i ${SST_DEPS_PATCHFILES}/ramulator_libPatch.patch
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

    if [ ! -z "${SST_BUILD_DISKSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DiskSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_disksim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: DiskSim deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_DRAMSIM}" ]
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

    if [ ! -z "${SST_BUILD_NVDIMMSIM}" ]
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

    if [ ! -z "${SST_BUILD_HYBRIDSIM}" ]
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


    if [ ! -z "${SST_BUILD_PARMETIS}" ]
    then
        #-----------------------------------------------------------------------
        # ParMETIS
        #-----------------------------------------------------------------------
        sstDepsDeploy_parmetis
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ParMETIS deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_ZOLTAN}" ]
    then
        #-----------------------------------------------------------------------
        # Zoltan
        #-----------------------------------------------------------------------
        # !!! NOTE: Zoltan depends on ParMETIS, so ParMETIS needs to be
        # !!! built first
        sstDepsDeploy_zoltan
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Zoltan deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_BOOST}" ]
    then
        #-----------------------------------------------------------------------
        # Boost
        #-----------------------------------------------------------------------
        sstDepsDeploy_boost
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Boost deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_MCPAT}" ]
    then
        #-----------------------------------------------------------------------
        # McPAT
        #-----------------------------------------------------------------------
        sstDepsDeploy_mcpat
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: McPAT deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_MACSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Macsim
        #-----------------------------------------------------------------------
        sstDepsDeploy_macsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Macsim deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_INTSIM}" ]
    then
        #-----------------------------------------------------------------------
        # IntSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_intsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: IntSim deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_ORION}" ]
    then
        #-----------------------------------------------------------------------
        # ORION
        #-----------------------------------------------------------------------
        sstDepsDeploy_orion
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: ORION deployment failure"
            return $retval
        fi
    fi


    if [ ! -z "${SST_BUILD_HOTSPOT}" ]
    then
        #-----------------------------------------------------------------------
        # HotSpot
        #-----------------------------------------------------------------------
        sstDepsDeploy_hotspot
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: HotSpot deployment failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_SSTMACRO}" ]
    then
        #-----------------------------------------------------------------------
        # sstmacro
        #-----------------------------------------------------------------------
        # NOTE: requires that Boost be deployed first
        sstDepsDeploy_sstmacro
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: sstmacro deployment failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_QSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Qsim
        #-----------------------------------------------------------------------
        sstDepsDeploy_qsim
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Qsim deployment failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_OMNET}" ]
    then
        #-----------------------------------------------------------------------
        # PhoenixSim
        #-----------------------------------------------------------------------
        sstDepsDeploy_omnet
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Omnet++ code staging failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_ARIEL_PIN}" ]
    then
        #-----------------------------------------------------------------------
        # Ariel Pintool
        #-----------------------------------------------------------------------
        sstDepsDeploy_ariel-pin
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: Ariel Pintotl code deployment failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_CHDL}" ]
    then
        #-----------------------------------------------------------------------
        # CHDL
        #-----------------------------------------------------------------------
        sstDepsDeploy_chdl
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: CHDL code deployment failure"
            return $retval
        fi

	sstDepsDeploy_chdl_stl
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: CHDL-stl code deployment failure"
            return $retval
        fi

	sstDepsDeploy_chdl_module
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: CHDL-module code deployment" \
		 "failure"
            return $retval
        fi
    fi

    if [ ! -z "${SST_BUILD_GOBLIN_HMCSIM}" ]
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
    
    if [ ! -z "${SST_BUILD_HBM_DRAMSIM2}" ]
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
    
    if [ ! -z "${SST_BUILD_RAMULATOR}" ]
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
    
    #     Put Gem5 Last, so no one else can be affected by gcc module hanky-panky

    if [ ! -z "${SST_BUILD_GEM5}" ]
    then
        #-----------------------------------------------------------------------
        # gem5
        #-----------------------------------------------------------------------
        sstDepsDeploy_gem5
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: gem5 deployment failure"
            return $retval
        fi
    fi

    #     Put Gem5 Last, so no one else can be affected by gcc module hanky-panky
	
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

    if [ ! -z "${SST_BUILD_DISKSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DiskSim
        #-----------------------------------------------------------------------
        sstDepsQuery_disksim
    fi


    if [ ! -z "${SST_BUILD_DRAMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # DRAMSim
        #-----------------------------------------------------------------------
        sstDepsQuery_dramsim
    fi 


    if [ ! -z "${SST_BUILD_NVDIMMSIM}" ]
    then
        #-----------------------------------------------------------------------
        # NVDIMMSim
        #-----------------------------------------------------------------------
        sstDepsQuery_nvdimmsim
    fi 


    if [ ! -z "${SST_BUILD_HYBRIDSIM}" ]
    then
        #-----------------------------------------------------------------------
        # HybridSim
        #-----------------------------------------------------------------------
        sstDepsQuery_hybridsim
    fi 


    if [ ! -z "${SST_BUILD_PARMETIS}" ]
    then
        #-----------------------------------------------------------------------
        # ParMETIS
        #-----------------------------------------------------------------------
        sstDepsQuery_parmetis
    fi


    if [ ! -z "${SST_BUILD_ZOLTAN}" ]
    then
        #-----------------------------------------------------------------------
        # Zoltan
        #-----------------------------------------------------------------------
        sstDepsQuery_zoltan
    fi


    if [ ! -z "${SST_BUILD_BOOST}" ]
    then
        #-----------------------------------------------------------------------
        # Boost
        #-----------------------------------------------------------------------
        sstDepsQuery_boost
    fi


    if [ ! -z "${SST_BUILD_GEM5}" ]
    then
        #-----------------------------------------------------------------------
        # gem5
        #-----------------------------------------------------------------------
        sstDepsQuery_gem5
    fi


    if [ ! -z "${SST_BUILD_MCPAT}" ]
    then
        #-----------------------------------------------------------------------
        # McPAT
        #-----------------------------------------------------------------------
        sstDepsQuery_mcpat
    fi


    if [ ! -z "${SST_BUILD_INTSIM}" ]
    then
        #-----------------------------------------------------------------------
        # IntSim
        #-----------------------------------------------------------------------
        sstDepsQuery_intsim
    fi


    if [ ! -z "${SST_BUILD_ORION}" ]
    then
        #-----------------------------------------------------------------------
        # ORION
        #-----------------------------------------------------------------------
        sstDepsQuery_orion
    fi


    if [ ! -z "${SST_BUILD_HOTSPOT}" ]
    then
        #-----------------------------------------------------------------------
        # HotSpot
        #-----------------------------------------------------------------------
        sstDepsQuery_hotspot
    fi

    if [ ! -z "${SST_BUILD_SSTMACRO}" ]
    then
        #-----------------------------------------------------------------------
        # sstmacro 
        #-----------------------------------------------------------------------
        sstDepsQuery_sstmacro
    fi

    if [ ! -z "${SST_BUILD_QSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Qsim
        #-----------------------------------------------------------------------
        sstDepsQuery_qsim
    fi

    if [ ! -z "${SST_BUILD_PHOENIXSIM}" ]
    then
        #-----------------------------------------------------------------------
        # Omnet++ / PhoenixSim
        #-----------------------------------------------------------------------
        sstDepsQuery_omnet
    fi

    if [ ! -z "${SST_BUILD_CHDL}" ]
    then
        #-----------------------------------------------------------------------
        # CHDL
        #-----------------------------------------------------------------------
        sstDepsQuery_chdl
	sstDepsQuery_chdl_stl
	sstDepsQuery_chdl_module
    fi

    if [ ! -z "${SST_BUILD_GOBLIN_HMCSIM}" ]
    then
        #-----------------------------------------------------------------------
        # GOBLIN_HMCSIM
        #-----------------------------------------------------------------------
        sstDepsQuery_goblin_hmcsim
    fi

    if [ ! -z "${SST_BUILD_HBM_DRAMSIM2}" ]
    then
        #-----------------------------------------------------------------------
        # HBM_DRAMSIM2
        #-----------------------------------------------------------------------
        sstDepsQuery_hbm_dramsim2
    fi

    if [ ! -z "${SST_BUILD_RAMULATOR}" ]
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
    if [ ! -d ${SST_DEPS_SRC_STAGING} ]
    then
        mkdir -p ${SST_DEPS_SRC_STAGING}
    fi

    if [ ! -d ${SST_DEPS_INSTALL_DEPS} ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}
    fi


    if   [ $# -eq 1 ] && [ $1 = "restageDeps" ]
    then
        # Purge deps staging area and deps install area
        rm -Rf ${SST_DEPS_SRC_STAGING}/*
        rm -Rf ${SST_DEPS_INSTALL_DEPS}/*

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
        
    elif [ $# -eq 1 ] && [ $1 = "develBuild" ]
    then
        # Purge deps install area, leave staged area alone
        rm -Rf ${SST_DEPS_INSTALL_DEPS}/*

        # Deploy dependencies (build from staged area and install)
        sstDepsDeploy
        retval=$?
        if [ $retval -ne 0 ]
        then
            # bail out on error
            echo "ERROR: sstDependencies.sh: dependency deployment failure"
            return $retval
        fi

    elif [ $# -eq 1 ] && [ $1 = "cleanBuild" ]
    then
        # Purge deps staging area and deps install area
        rm -Rf ${SST_DEPS_SRC_STAGING}/*
        rm -Rf ${SST_DEPS_INSTALL_DEPS}/*

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

    elif [ $# -eq 1 ] && [ $1 = "queryEnv" ]
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
# $ sstDependencies.sh -k [arg1] -d [arg2] -p [arg3] -z [arg4] -b [arg5]
#   -g [arg6] -m [arg7] -i [arg8] -o [arg9] -h [arg10] -s [arg11] 
#   -q [arg12] [buildtype]
# where
#   -k DiskSim version (default|static|none)
#   -d DRAMSim version (default|stabledevel|2.2|r4b00b22|none)
#   -p ParMETIS version (default|3.1.1|none)
#   -z Zoltan version (default|3.2|3.83.8.3|none)
#   -b Boost version (default|1.50|1.49|1.43|none)
#   -g gem5 version (default|4.0|stabledevel|gcc-4.6.4|none)
#   -G Goblim HMCSim (default|stabledevel|none)
#   -m McPAT version (default|beta|none)
#   -M macsim version (default|1.1|1.2_pre|1.2|2.0.3|2.0.4|2.1.0|2.2.0)
#   -i IntSim version (default|static|none)
#   -o ORION version (default|static|none)
#   -h HotSpot version (default|static|none)
#   -s sstmacro version (default|2.2.0|2.3.0|2.4.0-beta1|2.4.0|stabledevel|none)
#   -q qsim version (default|0.1.3|SST-2.3|stabledevel|none)
#   -e phoenixsim (default)
#   -4 portals4 version (default|none|stabledevel)
#   -I iris test version (default|none|stabledevel)
#   -N nvdimmsim (default)
#   -a Ariel Pintool (2.13-61206)
#   -c chdl (default)
#   -H HBM_DRAMSim2 (default)
#   -r Ramulator (default)
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

while getopts :k:d:p:z:b:g:G:m:M:i:o:h:H:r:s:q:e:4:I:N:a:c: opt

do
    case "$opt" in
        k) # DiskSim
            echo "# found the -k (disKsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|static) # build default DiskSim
                    echo "# (default) static: will build static DiskSim (except on MacOS)"
                        # Do not build DiskSim on Mac OS X or 32-bit Linux
                    if [ ! $SST_DEPS_OS_NAME = "Darwin" ]
                    then
                        . ${SST_DEPS_BIN}/sstDep_disksim_4.0.sh
                    fi
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build DiskSim"
                    ;;
                *) # unknown DiskSim argument
                    echo "# Unknown argument '$OPTARG', will not build DiskSim"
                    ;;
            esac
            ;;
        d) # DRAMSim
            echo "# found the -d (Dramsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest DRAMSim from repository ("stable development")
                    echo "# (default) stabledevel: build latest DRAMSim from repository"
                    . ${SST_DEPS_BIN}/sstDep_dramsim_stabledevel.sh
                    ;;
                2.2.2) # build DRAMSim v2.2.2
                    echo "# 2.2.2: build DRAMSim v2.2.2 release"
                    . ${SST_DEPS_BIN}/sstDep_dramsim_v2.2.2.sh
                    ;;
                2.2.1) # build DRAMSim v2.2.1
                    echo "# 2.2.1: build DRAMSim v2.2.1 release"
                    . ${SST_DEPS_BIN}/sstDep_dramsim_v2.2.1.sh
                    ;;
                2.2) # build DRAMSim v2.2 (tagged DRAMSim release)
                    echo "# 2.2: build DRAMSim v2.2 tagged release"
                    . ${SST_DEPS_BIN}/sstDep_dramsim_v2.2.sh
                    ;;
                r4b00b22) # build DRAMSim commit ID 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f
                    echo "# r4b00b22: build DRAMSim commit ID 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f"
                    . ${SST_DEPS_BIN}/sstDep_dramsim_r4b00b22.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build DRAMSim"
                    ;;
                *) # unknown DRAMSim argument
                    echo "# Unknown argument '$OPTARG', will not build DRAMSim"
                    ;;
            esac
            ;;
        p) # ParMETIS
            echo "# found the -p (Parmetis) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|3.1.1) # build default ParMETIS
                    echo "# (default) 3.1.1: will build ParMETIS 3.1.1"
                    . ${SST_DEPS_BIN}/sstDep_parmetis_3.1.1.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build ParMETIS"
                    ;;
                *) # unknown ParMETIS argument
                    echo "# Unknown argument '$OPTARG', will not build ParMETIS"
                    ;;
            esac
            ;;
        z) # Zoltan
            echo "# found the -z (Zoltan) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|3.8) # build default Zoltan
                    echo "# (default) 3.8: will build Zoltan 3.8"
                    . ${SST_DEPS_BIN}/sstDep_zoltan_3.8.sh
                    ;;
                3.83) # build Zoltan 3.83
                    echo "#  will build Zoltan 3.83"
                    . ${SST_DEPS_BIN}/sstDep_zoltan_3.83.sh
                    ;;
                3.2) # build default Zoltan
                    echo "#  will build Zoltan 3.2"
                    . ${SST_DEPS_BIN}/sstDep_zoltan_3.2.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Zoltan"
                    ;;
                *) # unknown Zoltan argument
                    echo "# Unknown argument '$OPTARG', will not build Zoltan"
                    ;;
            esac
            ;;
        b) # Boost
            echo "# found the -b (Boost) option, with value $OPTARG"

            if [ $SST_DEPS_OS_NAME = "Darwin" ]
            then
                # Macos now uses modules to select Boost, no need to build it
                echo "#  NOTE: Sorry, -b option deprecated on Mac OS; Boost selection done in bamboo.sh"

            else
                # Linux uses modules to select Boost, no need to build it
                echo "#  NOTE: Sorry, -b option deprecated on Linux"
            fi
            ;;
        g) # sst-gem5
            echo "# found the -g (Gem5) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                SST-3.1.1) # build for 3.1.1 release
                    echo "# SST-3.1.1: will build gem5 3.1.1 tagged"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-3.1.1.sh
                    ;;
                SST-3.1.1-with-sstdevice) # build for 3.1.1 release (with SSTDEVICE enabled)
                    echo "# SST-3.1.1: will build gem5 3.1.1 tagged (with SSTDEVICE enabled)"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-3.1.1_with_sstdevice.sh
                    ;;
                SST-3.1.0) # build for 3.1.0 release
                    echo "# SST-3.1.0: will build gem5 3.1.0 tagged"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-3.1.0.sh
                    ;;
                SST-3.1.0-with-sstdevice) # build for 3.1.0 release (with SSTDEVICE enabled)
                    echo "# SST-3.1.0: will build gem5 3.1.0 tagged (with SSTDEVICE enabled)"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-3.1.0_with_sstdevice.sh
                    ;;
                SST-3.0.0) # build for 3.0.0 release
                    echo "# SST-3.0.0: will build gem5 3.0.0 tagged"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-3.0.0.sh
                    ;;
                SST-2.3.1) # build for 2.3.1 release
                    echo "# SST-2.3.0: will build gem5 2.3.1 tagged"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-2.3.1.sh
                    ;;
                SST-2.3.0) # build for 2.3.0 release
                    echo "# SST-2.3.0: will build gem5 2.3.0 tagged"
                    . ${SST_DEPS_BIN}/sstDep_gem5_SST-2.3.0.sh
                    ;;
                stabledevel) # build latest sst-gem5
                    echo "# stabledevel: will build latest repository sst-gem5"
                    . ${SST_DEPS_BIN}/sstDep_gem5_stabledevel.sh
                    ;;
                stabledevel-with-sstdevice) # build latest sst-gem5 (with SSTDEVICE enabled)
                    echo "# stabledevel-with-sstdevice: will build latest repository sst-gem5 (with SSTDEVICE enabled)"
                    . ${SST_DEPS_BIN}/sstDep_gem5_stabledevel_with_sstdevice.sh
                    ;;
                stabledevel-static) # build latest sst-gem5 (static library)
                    echo "# stabledevel-static: will build latest repository sst-gem5 (static library)"
                    . ${SST_DEPS_BIN}/sstDep_gem5_stabledevel_static.sh
                    ;;
                gcc-4.6.4) # build latest sst-gem5 using gcc-4.6.4
                    echo "# gcc-4.6.4: will build latest repository sst-gem5 using gcc-4.6.4" 
                    . ${SST_DEPS_BIN}/sstDep_gem5_mixed_ompi_1.7.2_gcc_4.6.4.sh
                    ;;
                default|004) # build default sst-gem5
                    # Don't build for Mac OS X
                    if [ ! $SST_DEPS_OS_NAME = "Darwin" ]
                    then
                        echo "# (default) 004: will build sst-gem5 v004"
                        . ${SST_DEPS_BIN}/sstDep_gem5_sstv004.sh
                    fi
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build gem5"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build gem5"
                    ;;
            esac
            ;;
        G) # Goblin_HMCSIM
            echo "# found the -G (goblin_hmcsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|stabledevel) # build latest Goblin_HMCSIM from repository ("stable development")
                    echo "# (default) stabledevel: build latest Goblin_HMCSIM from repository"
                    . ${SST_DEPS_BIN}/sstDep_goblin_hmcsim_stabledevel.sh
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
                    . ${SST_DEPS_BIN}/sstDep_hbm_dramsim2_stabledevel.sh
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
                    . ${SST_DEPS_BIN}/sstDep_ramulator_stabledevel.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Ramulator"
                    ;;
                *) # unknown Ramulator argument
                    echo "# Unknown argument '$OPTARG', will not build Ramulator"
                    ;;
            esac
            ;;
        m) # McPAT
            echo "# found the -m (Mcpat) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|beta) # build default McPAT
                    echo "# (default) beta: will build McPAT beta"
                    . ${SST_DEPS_BIN}/sstDep_mcpat_beta.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build McPaT"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build McPAT"
                    ;;
            esac
            ;;
        M) # Macsim
            echo "# found the -M (Macsim) option, with value $OPTARG"

      echo "#    MACsim doesn't build with PDES core"
      if [ ! 0 ] ; then
            # process arg
            case "$OPTARG" in
                default) # build default Macsim
                    echo "# build Macsim"
                    . ${SST_DEPS_BIN}/sstDep_macsim.sh
                    ;;
                1.1) # build Macsim 1.1
                    echo "# 1.1: build Macsim 1.1"
                    . ${SST_DEPS_BIN}/sstDep_macsim_1.1.sh
                    ;;
                1.2_pre) # build Macsim 1.2_pre
                    echo "# 1.2_pre: build Macsim 1.2_pre"
                    . ${SST_DEPS_BIN}/sstDep_macsim_1.2_pre.sh
                    ;;
                1.2) # build Macsim 1.2
                    echo "# 1.2: build Macsim 1.2"
                    . ${SST_DEPS_BIN}/sstDep_macsim_1.2.sh
                    ;;
                2.0.3) # build Macsim 2.0.3
                    echo "# 2.0.3: build Macsim 2.0.3"
                    . ${SST_DEPS_BIN}/sstDep_macsim_2.0.3.sh
                    ;;
                2.0.4) # build Macsim 2.0.4
                    echo "# 2.0.4: build Macsim 2.0.4"
                    . ${SST_DEPS_BIN}/sstDep_macsim_2.0.4.sh
                    ;;
                2.1.0) # build Macsim 2.1.0
                    echo "# 2.1.0: build Macsim 2.1.0"
                    . ${SST_DEPS_BIN}/sstDep_macsim_2.1.0.sh
                    ;;
                2.2.0) # build Macsim 2.2.0
                    echo "# 2.2.0: build Macsim 2.2.0"
                    . ${SST_DEPS_BIN}/sstDep_macsim_2.2.0.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Macsim"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build Macsim"
                    ;;
            esac
      fi
            ;;
        i) # IntSim
            echo "# found the -i (Intsim) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|static) # build default IntSim
                    echo "# (default) static: will build static IntSim"
                    . ${SST_DEPS_BIN}/sstDep_intsim_static.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build IntSim"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build IntSim"
                    ;;
            esac
            ;;
        o) # ORION
            echo "# found the -o (Orion) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|static) # build default Orion
                    echo "# (default) static: will build static Orion"
                    . ${SST_DEPS_BIN}/sstDep_orion_static.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build Orion"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build Orion"
                    ;;
            esac
            ;;
        h) # HotSpot
            echo "# found the -h (Hotspot) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                default|static) # build default HotSpot
                    echo "# (default) static: will build static HotSpot"
                    . ${SST_DEPS_BIN}/sstDep_hotspot_static.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build HotSpot"
                    ;;
                *) # unknown gem5 argument
                    echo "# Unknown argument '$OPTARG', will not build HotSpot"
                    ;;
            esac
            ;;
        s) # sstmacro
            echo "# found the -s (sstmacro) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                2.2.0) # build sstmacro 2.2.0
                    echo "# 2.2.0: will build sstmacro 2.2.0"
                    . ${SST_DEPS_BIN}/sstDep_sstmacro_2.2.0.sh
                    ;;
                default|2.3.0) # build sstmacro 2.3.0
                    echo "# 2.3.0: will build sstmacro 2.3.0"
                    . ${SST_DEPS_BIN}/sstDep_sstmacro_2.3.0.sh
                    ;;
                2.4.0) # build sstmacro 2.4.0
                    echo "# 2.4.0: will build sstmacro 2.4.0"
                    . ${SST_DEPS_BIN}/sstDep_sstmacro_2.4.0.sh
                    ;;
                2.4.0-beta1) # build sstmacro 2.4.0
                    echo "# 2.4.0-beta1: will build sstmacro 2.4.0-beta1"
                    . ${SST_DEPS_BIN}/sstDep_sstmacro_2.4.0-beta1.sh
                    ;;
                stabledevel) # build latest sstmacro
                    echo "# default: will build latest repository sstmacro"
                    . ${SST_DEPS_BIN}/sstDep_sstmacro_stabledevel.sh
                    ;;
                none) # do not build (explicit)
                    echo "# none: will not build sstmacro"
                    ;;
                *) # unknown sstmacro argument
                    echo "# Unknown argument '$OPTARG', will not build sstmacro"
                    ;;
            esac
            ;;
        q) # Qsim
            echo "# found the -q (Qsim) option, with value $OPTARG.   (Ignore on MacOS)"
            echo "#  Option set to none"
            OPTARG="none"
            # process arg
                  ##   Qsim currently doesn't run on MacOS because of 32/64 bit issues.
            ##if [ ! $SST_DEPS_OS_NAME = "Darwin" ]
            ##then
                case "$OPTARG" in
                    default|0.1.4) # build Qsim 0.1.4
                        echo "# (default) 0.1.4: will build Qsim 0.1.4"
                        . ${SST_DEPS_BIN}/sstDep_qsim_0.1.4.sh
                        ;;
                    SST-3.0) # build Qsim for SST 3.0 (tagged for SST 3.0)
                        # NOTE: This is the same tagged revision as SST-2.3
                        echo "# SST-3.0.0: will build Qsim version SST-3.0"
                        . ${SST_DEPS_BIN}/sstDep_qsim_SST-3.0.sh
                        ;;
                    SST-2.3) # build Qsim for SST 2.3 (tagged for SST 2.3)
                        echo "# SST-2.3: will build Qsim version SST-2.3"
                        . ${SST_DEPS_BIN}/sstDep_qsim_SST-2.3.sh
                        ;;
                    0.2.1) # build Qsim 0.2.1
                        echo "# 0.2.1: will build Qsim 0.2.1"
                        . ${SST_DEPS_BIN}/sstDep_qsim_0.2.1.sh
                        ;;
                    0.1.3) # build Qsim 0.1.3
                        echo "# 0.1.3: will build Qsim 0.1.3"
                        . ${SST_DEPS_BIN}/sstDep_qsim_0.1.3.sh
                        ;;
                    stabledevel) # build latest Qsim
                        echo "# stabledevel: will build latest repository Qsim"
                        . ${SST_DEPS_BIN}/sstDep_qsim_stabledevel.sh
                        ;;
                    none) # do not build (explicit)
                        echo "# none: will not build Qsim"
                        ;;
                    *) # unknown Qsim argument
                        echo "# Unknown argument '$OPTARG', will not build Qsim"
                        ;;
                esac
            ;;
        e) # OMNeT++ / PhoenixSim
            echo "# found the -e (omnet++/PhoenixSim) option, with value $OPTARG"
            case "$OPTARG" in
                *) # build default version of PhoenixSim
                    echo "#default build of Omnet++"
                   # Linux uses modules to select OMNET++, no need to build it
                    echo "#  NOTE: Sorry, -e option deprecated on Linux. Using prebuilt under Modules."
                    ;;
            esac
            ;;
            # NOTE: tried to get this to work (err on missing
            # mandatory OPTARG), but the feature appears broken.
            # ":") echo "Mandatory option missing: $opt"
            #     ;;
        4)  # Do portals 4
            echo "# found the -4 (portals4) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                stabledevel)   # Test Portals 4
                    echo "# stabledevel: will use Portals 4"
                    . ${SST_DEPS_BIN}/sstDep_portals4_stabledevel.sh
                    ;;
                none|default)  # Do not do the Portals 4 test 
                    echo "# default: will not test Portals 4"
                    ;;
            esac
            ;; 
        I)  # Do Iris test
            echo "# found the -I (Iris) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                stabledevel)   # do the Iris test
                    echo "# stabledevel: Do the Iris test"
                             # instead of sourcing a file simply set the flag
                    export SST_BUILD_IRIS=1
                    ;;
                none|default)  # Do not do the Iris test case
                    echo "# default: will not do the Iris test "
                    ;;
            esac
            ;; 

        N)  # Do NVDIMMSIM
            echo "# found the -N (NVDIMMSIM) option, with value $OPTARG. (Ignore on MacOS.)"
            # process arg
                     ##   This exclusion was inserted for Clang.
                     ##   Oct 2013  MacOS GCC fails on NVDIMMSim because of std=c++0x
                     ##   Clang fails because c++ 4.2.1 headers files do not have "unordered_map"
            case "$OPTARG" in
                default)
                    echo "# default will be built"
                    . ${SST_DEPS_BIN}/sstDep_nvdimmsim.sh
 
                    echo "# HybridSim will be built"
                    . ${SST_DEPS_BIN}/sstDep_hybridsim.sh
                    ;;
                none)  # Do not build NVDIMMSim
                    echo "# none: will not build NVDIMMSim"
                    ;;
            esac   
            ;;

        a)  # Build Ariel Pin Tool 
            echo "# found the -a (Ariel Pin Tool) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                2.13-61206)   # Build Ariel Pin Tool 
                    echo "# 2.13-61206: Build Ariel Pin Tool"
                    . ${SST_DEPS_BIN}/sstDep_ariel-pin-2.13-61206.sh
                    ;;
                none|default)  # Do not build Ariel Pin Tool
                    echo "# default: will not build Ariel Pin Tool"
                    ;;
            esac
            ;; 

        c)  # Build CHDL
            echo "# found the -c (chdl) option, with value $OPTARG"
            # process arg
            case "$OPTARG" in
                none|default)  # Do not build CHDL
                    echo "# none:  will not build CHDL"
                    ;;
            esac
            ;; 

        *) echo "# unknown option: $opt"
            ;;
    esac
done

shift $[ $OPTIND - 1 ]

sstDepsDoDependencies $1
retval=$?
if [ $retval -ne 0 ]
then
    # bail out on error
    echo "ERROR: sstDependencies.sh: sstDepsDoDependences code failure"
    exit -1
fi

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

