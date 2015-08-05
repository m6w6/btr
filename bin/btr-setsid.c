#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <program> [args...]\n", argv[0]);
		return EXIT_FAILURE;
	}

	if (getpid() == getpgrp()) {
		pid_t pid = fork();

		switch (pid) {
		case 0:
			break;
		case -1:
			perror("fork");
			return EXIT_FAILURE;
		default:
			return EXIT_SUCCESS;
		}
	}

	if (setsid() < 0) {
		perror("setsid");
		return EXIT_FAILURE;
	}

	execvp(argv[1], &argv[1]);
	perror("exec");
	return EXIT_FAILURE;
}
