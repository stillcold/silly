#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>

#include "x.h"
#include "x_daemon.h"
#include "x_log.h"

static int pidfile;
extern int daemon(int, int);

static void
pidfile_create(const struct x_config *conf)
{
	int err;
	const char *path = conf->pidfile;
	pidfile = -1;
	if (path[0] == '\0')
		return ;
	pidfile = open(path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
	if (pidfile == -1) {
		x_log("[pidfile] create '%s' fail:%s\n", path,
				strerror(errno));
		exit(-1);
	}
	err = flock(pidfile, LOCK_NB | LOCK_EX);
	if (err == -1) {
		char pid[128];
		FILE *fp = fdopen(pidfile, "r+");
		fscanf(fp , "%s\n", pid);
		x_log("[pidfile] lock '%s' fail,"
			"another instace of '%s' alread run\n",
			path, pid);
		fclose(fp);
		exit(-1);
	}
	ftruncate(pidfile, 0);
	return ;
}

static inline void
pidfile_write()
{
	int sz;
	char pid[128];
	if (pidfile == -1)
		return ;
	sz = sprintf(pid, "%d\n", (int)getpid());
	write(pidfile, pid, sz);
	return ;
}

static inline void
pidfile_delete(const struct x_config *conf)
{
	if (pidfile == -1)
		return ;
	close(pidfile);
	unlink(conf->pidfile);
	return ;
}

static inline void
logfileopen(const struct x_config *conf)
{
	int fd;
	fd = open(conf->logpath, O_CREAT | O_WRONLY | O_APPEND, 00666);
	if (fd >= 0) {
		dup2(fd, 1);
		dup2(fd, 2);
		close(fd);
		setvbuf(stdout, NULL, _IOLBF, 0);
		setvbuf(stderr, NULL, _IOLBF, 0);
	}
}

void
x_daemon_start(const struct x_config *conf)
{
	int err;
	if (!conf->daemon)
		return ;
	pidfile_create(conf);
	err = daemon(1, 0);
	if (err < 0) {
		pidfile_delete(conf);
		x_log("[daemon] %s\n", strerror(errno));
		exit(0);
	}
	pidfile_write();
	logfileopen(conf);
	return ;
}

void
x_daemon_sigusr1(const struct x_config *conf)
{
	logfileopen(conf);
	return ;
}

void
x_daemon_stop(const struct x_config *conf)
{
	if (!conf->daemon)
		return ;
	pidfile_delete(conf);
	return ;
}
