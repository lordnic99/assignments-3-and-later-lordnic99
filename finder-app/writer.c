#include <stdio.h>
#include <sys/syslog.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
	openlog(NULL, LOG_PID, LOG_USER);
	if(argc != 3) {
		fprintf(stderr,"%s","Illegal parameters!\n");
    syslog(LOG_ERR, "%s","Illegal parameters!");
		return 1;
	}
	
	FILE *text_file = fopen(argv[1],"w");
	syslog(LOG_DEBUG,"%s%s%s%s","Writing ",argv[2]," to ",argv[1]);
	closelog();
	fprintf(text_file,"%s",argv[2]);
	fclose(text_file);
	return 0;
}
