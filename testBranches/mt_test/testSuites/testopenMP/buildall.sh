#!/bin/bash

#
#    This was modified February 3rd, 2015 to use only prebuilt binaries.
#	To see previous version get it from Revision #9085 or earlier.
#       Previous versions build the binaries local on most hosts.
#
#          Thread library is required to BUILD a binary, not to execute it.
mkdir -p $SST_TEST_ROOT/testSuites/testopenMP/pthread/m5threads
touch $SST_TEST_ROOT/testSuites/testopenMP/pthread/m5threads/libpthread.a
#
BASEDIR=`pwd`
echo $LD_LIBRARY_PATH

for nextdir in `ls -d ./*`; do
     if [[ "$nextdir" != *pthread* ]]; then

	if [ -d "$nextdir" ]; then
            if [ ! -e $nextdir/${nextdir}.x ] ; then
		echo "Copying in $nextdir ..."

		cd $nextdir
                cp $nextdir ${nextdir}.x
            fi
 
	    cd $BASEDIR
	fi
     fi
done
