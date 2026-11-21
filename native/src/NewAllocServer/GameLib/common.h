#pragma once

#ifndef WIN32
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#endif

void daemonize()
{
#ifndef WIN32
	pid_t pid, sid;

	/* already a daemon */
	if ( getppid() == 1 ) return;

	/* Fork off the parent process */
	pid = fork();
	if (pid < 0) {
		exit(EXIT_FAILURE);
	}
	/* If we got a good PID, then we can exit the parent process. */
	if (pid > 0) {
		exit(EXIT_SUCCESS);
	}

	/* At this point we are executing as the child process */

	/* Change the file mode mask */
	umask(0);

	/* Create a new SID for the child process */
	sid = setsid();
	if (sid < 0) {
		exit(EXIT_FAILURE);
	}

	/* Redirect standard files to /dev/null */
	freopen( "/dev/null", "r", stdin);
	freopen( "/dev/null", "w", stdout);
	freopen( "/dev/null", "w", stderr);
#endif 
}

int createdir(char dir[])
{
	DIR *dirptr = NULL;
	dirptr = opendir(dir);
	if (!dirptr)
	{
		if (ENOENT  == errno)
		{
			mkdir(dir, 0777);
		}
		else
		{
			chmod(dir, 0777);
		}
	}

	if((access(dir, W_OK|X_OK) < 0))
	{
		//log_error("logdir(%s): Not writable", dir);
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] createdir(char dir[]) createdir(log_dir) fail!\n")));
		return -1;
	}

	closedir(dirptr);

	return 0;
}


static char log_dir[128] = "./log";
int createLogFilePath(char szLogFilePath[])
{
	if(-1 == createdir(log_dir))
	{
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] createLogFile(char szLogFile[]) createdir(log_dir) fail!\n")));
		return -1;
	}
	char today_dir[256] = {0};
	struct tm tm;
	time_t now = time (NULL);
	localtime_r(&now, &tm);
	snprintf (today_dir, 255,
		"%s/%04d-%02d-%02d",
		log_dir,tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
	if(-1 == createdir(today_dir))
	{
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] createLogFile(char szLogFile[]) createdir(today_dir) fail!\n")));
		return -1;
	}

	snprintf(szLogFilePath, 256, "%s",today_dir);

	return 0;
}

