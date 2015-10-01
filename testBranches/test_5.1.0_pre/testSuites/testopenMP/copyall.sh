#!/bin/bash


for nextdir in `ls -d ./*`; do
	BASEDIR=`pwd`

	if [ -d "$nextdir" ]; then
		echo "Building in $nextdir ..."

		cd $nextdir
                    echo " THIS IS Darwin like code"
		    cp $nextdir ${nextdir}.x
		cd $BASEDIR
	fi
done
