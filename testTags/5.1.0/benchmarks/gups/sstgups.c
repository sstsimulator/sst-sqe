#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
#include <pthread.h>

unsigned int N;
unsigned int UPDATES;
unsigned int ITERATIONS;
unsigned int SEED;
unsigned int* values;
unsigned int* update_index;

double getseconds() {
	struct timeval tp;
	struct timezone tzone;
	
	gettimeofday( &tp, &tzone );
	return ((double) tp.tv_sec) + ((double) tp.tv_usec * 1.0e-6);
}

typedef struct {
	int start;
	int stop;
	unsigned int* values;
	unsigned int* update_index;
} thread_gups_info;

void* thread_gups(void* thread_data) {
	thread_gups_info* thr_info = (thread_gups_info*) thread_data;

	const int start  = thr_info->start;
	const int stop   = thr_info->stop;
	int counter;

	for(counter = start; counter < stop; counter++) {
		thr_info->values[thr_info->update_index[counter]] ^= thr_info->update_index[counter];
	}

	pthread_exit((void*) thread_data);
}

int main(int argc, char* argv[]) {

	printf("--------------------------------------------------------\n");
	printf("SST GUPS Benchmark\n");
	printf("--------------------------------------------------------\n");
	
	if(argc > 1) {
		UPDATES = (unsigned int) atoi(argv[1]);
	} else {
		UPDATES = 32768;
	}
	
	if(argc > 2) {
		N = (unsigned int) atoi(argv[2]);
	} else {
		N = 10000000;
	}

	if(argc > 3) {
		ITERATIONS = (unsigned int) atoi(argv[3]);
	} else {
		ITERATIONS = 10000;
	}

	if(argc > 4) {
		SEED = (unsigned int) atoi(argv[4]);
	} else {
		SEED = 101010101;
	}

	srand(SEED);

	int thread_count = 1;
	if(argc > 5) {
		thread_count = atoi(argv[5]);
	}

	values = (unsigned int*) malloc(sizeof(unsigned int) * N);
	update_index = (unsigned int*) malloc(sizeof(unsigned int) * UPDATES);
	
	unsigned int counter;
	unsigned int itr_counter;
	
	for(counter = 0; counter < N; counter++) {
		values[counter] = 1;
	}

	printf("Benchmark Parameters:\n");
	printf("-> N:                  %u\n", N);
	printf("-> Updates:            %u\n", UPDATES);
	printf("-> Iterations:         %u\n", ITERATIONS);
	printf("-> N size (bytes):     %lu\n", sizeof(unsigned int) * N);
	printf("-> N size (kB):        %lu\n", (sizeof(unsigned int) * N)/1024);
	printf("-> N size (MB):        %f\n", ((double)(sizeof(unsigned int) * N))/(1024.0 * 1024.0));
	printf("-> Threads:            %d\n", thread_count);
	printf("--------------------------------------------------------\n");
	printf("Performing random update benchmark...\n");
	double update_time = 0;

	thread_gups_info thread_info[thread_count];
	const int per_thread_block = UPDATES / thread_count;

	for(counter = 0; counter < thread_count; counter++) {
		thread_info[counter].start = counter * per_thread_block;
		thread_info[counter].stop  = (counter + 1) * per_thread_block;
		thread_info[counter].values = values;
		thread_info[counter].update_index = update_index;
	}

	thread_info[thread_count-1].stop = UPDATES;

	pthread_t the_threads[thread_count];
	pthread_attr_t thread_attr;
	pthread_attr_init(&thread_attr);
	pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_JOINABLE);

	void* thr_status;

	for(itr_counter = 0; itr_counter < ITERATIONS; itr_counter++) {
		for(counter = 0; counter < UPDATES; counter++) {
			update_index[counter] = rand() % N;
		}

		double start = getseconds();
		// Create the other threads
		for(counter = 1; counter < thread_count; counter++) {
			pthread_create(&the_threads[counter], &thread_attr, thread_gups, (void*) &thread_info[counter]);
		}

		for(counter = thread_info[0].start; counter < thread_info[0].stop; counter++) {
			values[update_index[counter]] ^= update_index[counter];
		}

		// Join up with the other threads
		for(counter = 1; counter < thread_count; counter++) {
			pthread_join(the_threads[counter], &thr_status);
		}

		double end = getseconds();
		update_time += (end - start);
	}

	printf("Benchmarking completed.\n");
	
	double total_updates = ((double) ITERATIONS * UPDATES) / (1e9);
	
	printf("--------------------------------------------------------\n");
	printf("Benchmark Information:\n");
	printf("-> Time (seconds):     %15.10f\n", update_time  );
	printf("-> Total GigaUpdates:  %15.10f\n", total_updates);
	printf("-> GUP/s:              %15.10f\n", (total_updates/update_time));
	
	unsigned long long int total = 0;
	for(counter = 0; counter < N; counter++) {
		total += values[counter];
	}
	
	printf("--------------------------------------------------------\n");
	printf("Total sum values is:   %llu\n", total);
	printf("--------------------------------------------------------\n");
	
}
