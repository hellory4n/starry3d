#include <webgpu/wgpu.h>
#include <GLFW/glfw3.h>
#include <libtrippin.h>
#include "st3d.h"

// btw st3di means st3d internal :D

// disaster (variables)
static TrArena arena;

// render crap
static WGPUDevice device;
static WGPUQueue queue;

// window crap
static GLFWwindow* window;

// WINDOW CRAP

static void window_init(const char* title, int32_t width, int32_t height)
{
	if (!glfwInit()) {
		tr_panic("glfw: couldn't initialize");
	}

	// glfw doesn't know about webgpu
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
	// for now that's gonna crash and die??
	glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

	window = glfwCreateWindow(width, height, title, NULL, NULL);
	if (window == NULL) {
		tr_panic("glfw: couldn't create window");
	}

	tr_log(TR_LOG_LIB_INFO, "glfw: created window");
}

static void window_free(void)
{
	glfwDestroyWindow(window);
	tr_log(TR_LOG_LIB_INFO, "glfw: closed window");
}

void st3d_end_drawing(void)
{
	st3di_tick();
	glfwSwapBuffers(window);
}

void st3d_poll_events(void)
{
	glfwPollEvents();
}

bool st3d_is_closing(void)
{
	return glfwWindowShouldClose(window);
}

void st3d_close(void)
{
	glfwSetWindowShouldClose(window, true);
}

// RENDER CRAP

// i love callbacks

typedef struct {
	WGPUAdapter adapter;
	bool request_ended;
} St3diAdapterData;

static void on_adapter_received(WGPURequestAdapterStatus status, WGPUAdapter adapter, char const* msg, void* data)
{
	St3diAdapterData* man = data;
	if (status == WGPURequestAdapterStatus_Success) {
		man->adapter = adapter;
	}
	else {
		tr_panic("wgpu: couldn't get adapter: %s", msg);
	}
	man->request_ended = true;
}

static WGPUAdapter request_adapter(WGPUInstance instance, WGPURequestAdapterOptions const * options)
{
	St3diAdapterData data;
	wgpuInstanceRequestAdapter(instance, options, on_adapter_received, &data);
	tr_assert(data.request_ended, "uh oh");
	return data.adapter;
}

typedef struct {
	WGPUDevice device;
	bool request_ended;
} St3diDeviceData;

static void on_device_received(WGPURequestDeviceStatus status, WGPUDevice adapter, char const* msg, void* data)
{
	St3diDeviceData* man = data;
	if (status == WGPURequestDeviceStatus_Success) {
		man->device = adapter;
	}
	else {
		tr_panic("wgpu: couldn't get device: %s", msg);
	}
	man->request_ended = true;
}

static WGPUDevice request_device(WGPUAdapter adapter, WGPUDeviceDescriptor const* descriptor)
{
	St3diDeviceData data;
	wgpuAdapterRequestDevice(adapter, descriptor, on_device_received, &data);
	tr_assert(data.request_ended, "uh oh");
	return data.device;
}

static void on_device_lost(WGPUDeviceLostReason reason, char const* message, void* data)
{
	(void)data;
	tr_log(TR_LOG_WARNING, "wgpu: device lost (reason %i): %s", reason, message);
	tr_log(TR_LOG_WARNING, "wgpu: this is either normal or a catastrophic internal failure");
}

static void on_device_error(WGPUErrorType type, char const* message, void* data)
{
	(void)data;
	// not sure if it should panic
	#ifdef DEBUG
	tr_panic("wgpu: uncaptured device error (type %i): %s", type, message);
	#else
	tr_log(TR_LOG_ERROR, "wgpu: uncaptured device error (type %i): %s", type, message);
	#endif
}

static void on_queue_submitted_work_done(WGPUQueueWorkDoneStatus status, void* data)
{
	(void)data;
	tr_log(TR_LOG_LIB_INFO, "wgpu: queue work finished with status %i", status);
}

static void wgpu_init(void)
{
	// init webgpu
	WGPUInstanceDescriptor desc;
	desc.nextInChain = NULL;
	WGPUInstance instance = wgpuCreateInstance(&desc);
	tr_assert(instance != NULL, "wgpu: couldn't create wgpu instance");
	tr_log(TR_LOG_LIB_INFO, "wgpu: created instance");

	// adapter :D
	WGPURequestAdapterOptions adapter_opts = {0};
	adapter_opts.nextInChain = NULL;
	WGPUAdapter adapter = request_adapter(instance, &adapter_opts);
	wgpuInstanceRelease(instance);
	tr_log(TR_LOG_LIB_INFO, "wgpu: requested adapter");

	// check limits
	WGPUSupportedLimits limits = {0};
	limits.nextInChain = NULL;
	bool success = wgpuAdapterGetLimits(adapter, &limits);
	if (success) {
		tr_log(TR_LOG_LIB_INFO, "wgpu: adapter limits");
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension1D: %u", limits.limits.maxTextureDimension1D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension2D: %u", limits.limits.maxTextureDimension2D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension3D: %u", limits.limits.maxTextureDimension3D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureArrayLayers: %u", limits.limits.maxTextureArrayLayers);
	}

	// what fucking features can we fucking use?
	size_t feature_count = wgpuAdapterEnumerateFeatures(adapter, NULL);
	TrSlice features = tr_slice_new(arena, feature_count, sizeof(WGPUFeatureName));
	wgpuAdapterEnumerateFeatures(adapter, features.buffer);

	tr_log(TR_LOG_LIB_INFO, "wgpu: adapter features");
	for (size_t i = 0; i < features.length; i++) {
		WGPUFeatureName feature = *(WGPUFeatureName*)tr_slice_at(features, i);
		tr_log(TR_LOG_LIB_INFO, "- 0x%.8x", feature);
	}

	// vendor features and shit
	WGPUAdapterProperties props = {0};
	props.nextInChain = NULL;
	wgpuAdapterGetProperties(adapter, &props);
	tr_log(TR_LOG_LIB_INFO, "wgpu: adapter properties");
	tr_log(TR_LOG_LIB_INFO, "- vendorID: %u", props.vendorID);
	if (props.vendorName != NULL) {
		tr_log(TR_LOG_LIB_INFO, "- vendorName: %s", props.vendorName);
	}
	if (props.architecture != NULL) {
		tr_log(TR_LOG_LIB_INFO, "- architecture: %s", props.architecture);
	}
	tr_log(TR_LOG_LIB_INFO, "- deviceID: %u", props.deviceID);
	if (props.name != NULL) {
		tr_log(TR_LOG_LIB_INFO, "- name: %s", props.name);
	}
	if (props.driverDescription != NULL) {
		tr_log(TR_LOG_LIB_INFO, "- driverDescription: %s", props.driverDescription);
	}
	tr_log(TR_LOG_LIB_INFO, "- adapterType: 0x%X", props.adapterType);
	tr_log(TR_LOG_LIB_INFO, "- backendType: 0x%X", props.backendType);

	// request device
	WGPUDeviceDescriptor device_desc = {0};
	device_desc.nextInChain = NULL;
	device_desc.label = "starry3d device";
	device_desc.requiredFeatureCount = 0;
	device_desc.requiredLimits = NULL;
	device_desc.defaultQueue.nextInChain = NULL;
	device_desc.defaultQueue.label = "default queue";
	device_desc.deviceLostCallback = on_device_lost;
	device = request_device(adapter, &device_desc);
	wgpuDeviceSetUncapturedErrorCallback(device, on_device_error, NULL);
	wgpuAdapterRelease(adapter);
	tr_log(TR_LOG_LIB_INFO, "wgpu: requested device");

	// we don't have required limits/features so the device has different limits
	// it uses the minimum available i guess?
	limits = (WGPUSupportedLimits){0};
	limits.nextInChain = NULL;
	success = wgpuDeviceGetLimits(device, &limits);
	if (success) {
		tr_log(TR_LOG_LIB_INFO, "wgpu: device limits");
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension1D: %u", limits.limits.maxTextureDimension1D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension2D: %u", limits.limits.maxTextureDimension2D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureDimension3D: %u", limits.limits.maxTextureDimension3D);
		tr_log(TR_LOG_LIB_INFO, "- maxTextureArrayLayers: %u", limits.limits.maxTextureArrayLayers);
	}

	feature_count = wgpuDeviceEnumerateFeatures(device, NULL);
	wgpuDeviceEnumerateFeatures(device, features.buffer);

	tr_log(TR_LOG_LIB_INFO, "wgpu: device features");
	for (size_t i = 0; i < features.length; i++) {
		WGPUFeatureName feature = *(WGPUFeatureName*)tr_slice_at(features, i);
		tr_log(TR_LOG_LIB_INFO, "- 0x%.8x", feature);
	}

	// get the bloody queue
	queue = wgpuDeviceGetQueue(device);
	wgpuQueueOnSubmittedWorkDone(queue, on_queue_submitted_work_done, NULL);

	tr_log(TR_LOG_LIB_INFO, "wgpu: initialized");
}

static void wgpu_free(void)
{
	wgpuQueueRelease(queue);
	wgpuDeviceRelease(device);

	tr_log(TR_LOG_LIB_INFO, "wgpu: deinitialized");
}

void st3d_init(const char* app, const char* assets, int32_t width, int32_t height)
{
	// gonna use that later :)
	(void)assets;

	tr_init("log.txt");
	arena = tr_arena_new(TR_MB(1));
	wgpu_init();
	window_init(app, width, height);

	tr_log(TR_LOG_LIB_INFO, "initialized starry3d %s", ST3D_VERSION);
}

void st3d_free(void)
{
	wgpu_free();
	window_free();

	tr_arena_free(arena);
	tr_log(TR_LOG_LIB_INFO, "deinitialized starry3d");
	tr_free();
}

void st3di_tick(void)
{
	wgpuDevicePoll(device, false, NULL);
}
