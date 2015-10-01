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

#include <stdlib.h>
#include <stdio.h>


int main(int argc, char* argv[]) {

	char* check_env_message = getenv("MESSAGE");
	char* check_env_missing = getenv("MISSING");

	if(check_env_message == NULL) {
		printf("[FAILED] *Error* could not find environment variable \'MESSAGE\'\n");
	} else {
		printf("[PASSED] Found \'MESSAGE\'=[%s]\n", check_env_message);
	}

	if(check_env_missing == NULL) {
		printf("[PASSED] Could not find \'MISSING\' correct behavior\n");
	} else {
		printf("[FAILED] *Error* Found \'MISSING\' correct behavior (=[%s])\n", check_env_missing);
	}

	printf("Complete.\n");
}
