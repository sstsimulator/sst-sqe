// Copyright 2009-2015 Sandia Corporation. Under the terms
// of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S.
// Government retains certain rights in this software.
// 
// Copyright (c) 2009-2015, Sandia Corporation
// All rights reserved.
// 
// This file is part of the SST software package. For license
// information, see the LICENSE file in the top level directory of the
// distribution.

#include <sys/time.h>  
 #include <stdio.h>  

int main(int argc, char* argv[]) {
    	struct timeval now;

    	gettimeofday(&now, NULL);
    	double first_time = now.tv_sec+(now.tv_usec/1000000.0);

	int i = 0;
	const int BIG_NUMBER = 32768;
	double sum = 0;

	for(i = 0; i < 32768; i++) {
		sum += (double) i;
	}

    	gettimeofday(&now, NULL);
    	double second_time=now.tv_sec+(now.tv_usec/1000000.0);
    	printf("%.10lf seconds elapsed between timers\n", second_time - first_time);

	printf("Summed valued is %f\n", sum);

	return 0;
}
