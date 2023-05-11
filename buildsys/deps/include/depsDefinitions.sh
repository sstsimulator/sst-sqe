# Dependency definitions

# NOTE: User may override SST dependency installation location by
# setting the SST_INSTALL_DEPS_USER environment variable to a non-NULL
# directory.

#===============================================================================
# Directories
#===============================================================================

if [[ ${SST_ROOT:+isSet} != isSet ]]
then
    # If SST_ROOT has NOT been set, assume SST_ROOT is up 2 levels from
    # the directory that this file (depsDefinitions.sh) resides in.
    export SST_ROOT="$( cd -P "$( dirname "$0" )"/../.. && pwd )"
fi

if [[ ${SST_BASE:+isSet} != isSet ]]
then
     #if SST_BASE is not set, set it
    if [[ ${SST_DEPS_USER_MODE:+isSet} = isSet ]]
    then
        export SST_BASE=$SST_DEPS_USER_DIR
    else
        export SST_BASE=$HOME
    fi
fi

# Check SST dependency installation preferences
if [[ ${SST_INSTALL_DEPS_USER:+isSet} = isSet ]]
then
    # Let user's environment determine value
    export SST_DEPS_INSTALL_DEPS=$SST_INSTALL_DEPS_USER

elif [[ ${SST_INSTALL_DEPS:+isSet} = isSet ]] && [[ ${SST_INSTALL_DEPS_USER:+isSet} != isSet ]]
then
    # Use SST_INSTALL_DEPS since user has not specified an override
    export SST_DEPS_INSTALL_DEPS=$SST_INSTALL_DEPS

elif [[ ${SST_INSTALL_DEPS:+isSet} != isSet ]] && [[ ${SST_INSTALL_DEPS_USER:+isSet} != isSet ]]
then
    # Worst case scenario: Neither value has been set, so assume a
    # default SST dependency installation of $BASE/local.
    export SST_DEPS_INSTALL_DEPS=$SST_BASE/local

fi

# Location of "deps" directory
export SST_DEPS_ROOT=${SST_ROOT}/deps
# Location of dependency utility scripts
export SST_DEPS_BIN=${SST_DEPS_ROOT}/bin
# Location of dependency utility "header files"
export SST_DEPS_INCLUDE=${SST_DEPS_ROOT}/include

# Location of deps source files
export SST_DEPS_SRC=$SST_BASE/sstDeps/src

# Location where pristine SST dependency source files are. These can
# be tar.gz files, zipfiles, or other archive formats. This can be
# thought of as the "pre-staging" area for SST dependencies.
export SST_DEPS_SRC_PRISTINE=${SST_DEPS_SRC}/pristine

# Location where pristine source files are unarchived and patched as a
# precursor to build and installation. This can be thought of as the
# "staging" area for SST dependencies.
export SST_DEPS_SRC_STAGING=${SST_DEPS_SRC}/staged

# Location of deps patches
export SST_DEPS_PATCHFILES=${SST_DEPS_ROOT}/patches

# Adjust path for Bamboo install preferences
export PATH=${PATH}:${SST_DEPS_BIN}

#===============================================================================
# System definitions
#===============================================================================

SST_DEPS_CPU_ARCH=`uname -m`    # uname CPU architecture
SST_DEPS_OS_NAME=`uname -s`     # uname OS name
SST_DEPS_OS_RELEASE=`uname -r`  # uname OS release

#===============================================================================
# Global utilities
#===============================================================================
# sstDepsAnnounce ()
# Args:
#   -h [header]
#   -m [message]
# Announcement utility. Used for general status annoucements.
sstDepsAnnounce ()
{
    OPTIND=1
    while getopts ":h:m:" opt
    do
        case $opt in
            'h') # header
                local header=$OPTARG
                ;;
            'm') # message
                local message=$OPTARG
                ;;
            '?') # unknown arg
                echo "Unknown option $opt."
                return 1
                ;;
            ':') # missing mandatory arg
                echo "Missing mandatory argument: $OPTARG"
                return 1
                ;;
        esac
    done

    # Make announcement

    echo "SSTDEPS================================================================="
    echo "| $header "
    echo "|"
    echo "|   $message"
    echo "|"
    echo "| $header "
    echo "SSTDEPS================================================================="

}

# sstDepsValidateSha1 ()
# Args:
#   -f [file]
#   -h [expected SHA1 hash]
# File validation utility.
# returns 0 if file SHA1 agrees with given SHA1
# returns 1 otherwise
sstDepsCheckSha1 ()
{
    OPTIND=1
    while getopts ":f:h:" opt
    do
        case $opt in
            'f') # file
                local filename=$OPTARG
                ;;
            'h') # message
                local expected_hash=$OPTARG
                ;;
            '?') # unknown arg
                echo "Unknown option $opt."
                return 1
                ;;
            ':') # missing mandatory arg
                echo "Missing mandatory argument: $OPTARG"
                return 1
                ;;
        esac
    done

    # get SHA1 hash for given file
    calculated_hash=`openssl sha1 ${filename} | awk '{ print $NF }'`

    if [ ${calculated_hash} = ${expected_hash} ]
    then
        echo "sstDepsSha1IsValid (): Good SHA1 of ${filename}. Expected ${expected_hash}, got ${calculated_hash}"
        echo "sstDepsSHA1IsValid (): File content consistent with expected SHA1."
        return 0
    else
        echo "sstDepsSha1IsValid (): Bad SHA1 of ${filename}. Expected ${expected_hash}, got ${calculated_hash}"
        echo "sstDepsSHA1IsValid (): File content inconsistent with expectations or possibly corrupted."
        return 1
    fi

}


# DEBUG <begin>
# echo "DBG depsDefinitions.sh:  SST_ROOT = ${SST_ROOT}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_INSTALL_DEPS = ${SST_DEPS_INSTALL_DEPS}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_INSTALL_DEPS_USER = ${SST_DEPS_INSTALL_DEPS_USER}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_ROOT = ${SST_DEPS_ROOT}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_BIN = ${SST_DEPS_BIN}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_INCLUDE = ${SST_DEPS_INCLUDE}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_SRC = ${SST_DEPS_SRC}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_SRC_PRISTINE = ${SST_DEPS_SRC_PRISTINE}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_SRC_STAGING = ${SST_DEPS_SRC_STAGING}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_PATCHFILES = ${SST_DEPS_PATCHFILES}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_CPU_ARCH = ${SST_DEPS_CPU_ARCH}"
# echo "DBG depsDefinitions.sh:  PATH = ${PATH}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_OS_NAME = ${SST_DEPS_OS_NAME}"
# echo "DBG depsDefinitions.sh:  SST_DEPS_OS_RELEASE = ${SST_DEPS_OS_RELEASE}"
# DEBUG <end>
