/// read the readme
/// copyright me

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/// Not null terminated, should use mem* functions instead of str* functions
typedef struct sgpu_string_t {
    const char* ptr;
    size_t len;
} sgpu_string_t;

typedef struct sgpu_version_t {
    uint32_t major;
    uint32_t minor;
    uint32_t patch;
} sgpu_version_t;

typedef enum {
    SGPU_OK = 0,
} sgpu_error_t;

typedef struct sgpu_settings_t {
    sgpu_string_t app_name;
    sgpu_string_t engine_name;
    sgpu_version_t app_version;
    sgpu_version_t engine_version;
} sgpu_settings_t;

typedef struct sgpu_ctx_t {
    sgpu_settings_t settings;

    /// validation layer stuff
    bool initialized;
} sgpu_ctx_t;

/// Initializes the graphics context
sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx);

/// Deinitializes the graphics context
void sgpu_deinit(sgpu_ctx_t* ctx);
