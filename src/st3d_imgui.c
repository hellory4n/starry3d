// pain.
#define CIMGUI_USE_GLFW
#define CIMGUI_USE_OPENGL3
// cimgui.h is included here
#include "st3d_imgui.h"
#include <cimgui_impl.h>
#include <GLFW/glfw3.h>

#include "st3d.h"
#include <libtrippin.h>

static ImGuiIO* tr_ioptr;

void st3d_imgui_new(void)
{
	igCreateContext(NULL);

	tr_ioptr = igGetIO_Nil();
	tr_ioptr->ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
	tr_ioptr->ConfigFlags |= ImGuiConfigFlags_DockingEnable;
	tr_ioptr->ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;

	ImGui_ImplGlfw_InitForOpenGL(st3d_get_window_handle(), false);
	ImGui_ImplOpenGL3_Init("#version 330 core");

	igStyleColorsDark(NULL);

	tr_liblog("initialized cimgui");
}

void st3d_imgui_free(void)
{
	ImGui_ImplOpenGL3_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	igDestroyContext(NULL);

	tr_log("deinitialized cimgui");
}

void st3d_imgui_begin(void)
{
	ImGui_ImplOpenGL3_NewFrame();
	ImGui_ImplGlfw_NewFrame();
	igNewFrame();
}

void st3d_imgui_end(void)
{
	igRender();
	ImGui_ImplOpenGL3_RenderDrawData(igGetDrawData());

	if (tr_ioptr->ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
		GLFWwindow* backup_current_window = glfwGetCurrentContext();
		igUpdatePlatformWindows();
		igRenderPlatformWindowsDefault(NULL, NULL);
		glfwMakeContextCurrent(backup_current_window);
	}
}
