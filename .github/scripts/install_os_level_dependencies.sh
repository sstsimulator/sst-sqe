#!/bin/bash

# install_os_level_dependencies.sh: Install dependencies at the operating
# system level needed for GitHub CI runs.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
if command -v brew; then
    brew install \
         autoconf \
         automake \
         coreutils \
         doxygen \
         libtool \
         lmod \
         ncurses \
         open-mpi \
         pygments
    python -m pip install blessings
    # echo "source /opt/homebrew/opt/lmod/init/profile" >> ~/.bashrc
elif command -v apt-get; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y update
    sudo apt-get -y install \
         autoconf \
         automake \
         doxygen \
         libopenmpi-dev \
         libtool-bin \
         lmod \
         python3-blessings \
         python3-pygments
    # echo "source /usr/share/lmod/lmod/init/bash" >> ~/.bashrc
fi
