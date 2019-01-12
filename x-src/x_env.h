#ifndef _X_ENV_H
#define _X_ENV_H

int silly_env_init();
const char *silly_env_get(const char *key);
void silly_env_set(const char *key, const char *value);
void silly_env_exit();

#endif

