#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>

char* timer(int length, char* message) {
	struct timespec len;
	len.tv_sec = length;
	len.tv_nsec = 0;
	nanosleep(&len, NULL);
	printf("%s", message);
	return message;
}

char* start(int length, char* message) {
	pid_t proc;
	proc = fork();
	if(proc == 0) {
		return timer(length, message);
	}
	exit(0);
}
