#!/bin/bash

THISDIR=`pwd`

if [ -e "m5threads" ]; then
	echo "Removing old m5threads download..."
	rm -rf ./m5threads
fi

# M5THR_URL="http://repo.gem5.org/m5threads/archive/tip.tar.bz2"

# echo "Downloading m5threads..."

# wget $M5THR_URL

# tar xvfj tip.tar.bz2

tar xvfj ${SST_DEPS_SRC_PRISTINE}/m5threads-dcec9ee72f99.tar.bz2
ls

mv m5threads-* m5threads

cd m5threads

echo "Building m5threads..."
make

cd $THISDIR

# rm tip.tar.bz2
