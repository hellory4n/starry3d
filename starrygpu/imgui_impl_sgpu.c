#include "imgui_impl_sgpu.h"
#include "starrygpu.h"
#ifdef SGPU_GL
#include "lib/dcimgui_impl_opengl3.h"
#endif

void cImGui_ImplSgpu_Init(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    (void)ctx;
    cImGui_ImplOpenGL3_InitEx("#version 450 core");
#endif
}

void cImGui_ImplSgpu_Shutdown(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    (void)ctx;
    cImGui_ImplOpenGL3_Shutdown();
#endif
}

void cImGui_ImplSgpu_NewFrame(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    (void)ctx;
    cImGui_ImplOpenGL3_NewFrame();
#endif
}

void cImGui_ImplSgpu_RenderDrawData(ImDrawData* draw_data, sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    (void)ctx;
    cImGui_ImplOpenGL3_RenderDrawData(draw_data);
#endif
}
