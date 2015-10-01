#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {

	double the_sum = 0;
	const int updates = 64;

	#pragma omp parallel
	{
        	int ID = omp_get_thread_num();
        	printf(" Hello from thread %d \n", ID);
		int i = 0;
		for(i = 0; i < updates; ++i) {
			#pragma omp atomic
			the_sum += 2.0;
		}
	}

	printf("Updates: %d, Sum is: %f\n", updates, the_sum);

}
