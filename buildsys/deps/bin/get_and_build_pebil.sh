#!/usr/bin/env bash

# get_and_build_pebil.sh: Clone and install
# https://github.com/epanalytics/PEBIL/tree/feature/sst
#
# This is intentionally more procedural than the sstDep_*.sh scripts, since
# PEBIL must be built after SST.

set -euo pipefail

export SST_DEPS_SRC_STAGED_PEBIL="${SST_DEPS_SRC_STAGING}"/pebil
git clone -b feature/sst https://github.com/epanalytics/PEBIL.git "${SST_DEPS_SRC_STAGED_PEBIL}"
pushd "${SST_DEPS_SRC_STAGED_PEBIL}"
# Avoid "Host key verification failed.; fatal: Could not read from remote repository."
perl -i'' -pe 's{git\@github\.com:}{https://github.com/}g' .gitmodules
git submodule init external/epa-inst-libs
git submodule update
SST_CONFIG="${SST_CORE_INSTALL_BIN}"/sst-config
loc_sst_core_install="$("${SST_CONFIG}" --prefix)"
loc_sst_elements_source="$("${SST_CONFIG}" SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_SOURCE_ROOT)"
CC="$("${SST_CONFIG}" --CC)" \
  CXX="$("${SST_CONFIG}" --CXX)" \
  MPICC="$("${SST_CONFIG}" --MPICC)" \
  MPICXX="$("${SST_CONFIG}" --MPICXX)" \
  MPI_CPPFLAGS="$("${SST_CONFIG}" --MPI_CPPFLAGS)"\
  ./configure \
  --with-sst-core="${loc_sst_core_install}" \
  --with-sst-elements="${loc_sst_elements_source}"
# shellcheck disable=SC1091
source "${SST_DEPS_SRC_STAGED_PEBIL}"/bashrc
make all -j"$(nproc)"
popd
