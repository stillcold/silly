#ifndef	_X_LOG_H
#define	_X_LOG_H

#define LOG_MAX_LEN	(1024)

void x_log_start();
void x_log_raw(const char *fmt, ...);
void x_log(const char *fmt, ...);

#endif

