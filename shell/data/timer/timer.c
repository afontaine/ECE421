#include <time.h>
#include <unistd.h>


char* timer(int length, char* message) {
	clock_t start = clock();
	clock_t end = clock();
	while((end - start) / CLOCKS_PER_SEC < length) {
		usleep(1000);
		end = clock();
	}
	return message;
}

char* start(int length, char* message) {
	return timer(length, message);
}