#pragma once

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
	#define ST_DLLEXPORT __declspec(dllexport)
#else
	#define ST_DLLEXPORT __attribute__((visibility("default")))
#endif

typedef struct st_Api {
	void (*shitfuck)(void);
} st_Api;

// returns userdata
typedef void *(*st_Init_Proc)(st_Api ctx);
typedef void (*st_Free_Proc)(st_Api ctx, void* userdata);

#ifdef __cplusplus
} // extern "C"
#endif
