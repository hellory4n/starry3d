#include <webgpu/webgpu.h>
#include <libtrippin.h>
#include "st3d.h"

// btw st3di means st3d internal :D

// disaster (variables)
static TrArena arena;

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

	tr_log(TR_LOG_LIB_INFO, "wgpu: initialized");
}

void st3d_init(const char* app, const char* assets, int32_t width, int32_t height)
{
	// gonna use that later :)
	(void)assets;

	arena = tr_arena_new(TR_MB(1));

	wgpu_init();

	tr_log(TR_LOG_LIB_INFO, "initialized starry3d %s", ST3D_VERSION);
}

static void wgpu_free(void)
{}

void st3d_free(void)
{
	wgpu_free();

	tr_arena_free(arena);

	tr_log(TR_LOG_LIB_INFO, "deinitialized starry3d");
}
