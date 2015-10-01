#!/bin/bash

for nextdir in `ls -d ./*`; do
	BASEDIR=`pwd`

	if [ -d "$nextdir" ]; then
		echo "Building in $nextdir ..."

		cd $nextdir
		if [ `uname` == "Darwin" ]
		then
                    echo " THIS IS Darwin Only code"
		    cp $nextdir ${nextdir}.x
                else
                    if [[ "$nextdir" != *pthread* ]]; then
		       make clean
	 	       make
                    fi
		fi
		cd $BASEDIR
	fi
done
