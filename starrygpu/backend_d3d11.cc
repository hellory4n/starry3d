#include "backend_d3d11.h"
#include "sgpu_internal.h"
#include "starrygpu.h"
#include <cassert>
#include <cstddef>
#include <new>
#include <stringapiset.h>

#define WIN32_LEAN_AND_MEAN
#include <d3d11.h>
#include <dxgi1_3.h>
#include <wrl.h>

// usual unfuckening
#undef min
#undef max
#undef near
#undef far
#undef small

// mouthful
template <typename T>
using ComPtr = Microsoft::WRL::ComPtr<T>;

struct sgpu_d3d11_ctx {
    ComPtr<ID3D11Device> device = NULL;
    ComPtr<ID3D11DeviceContext> device_ctx = NULL;
    ComPtr<IDXGIFactory2> dxgi_factory = NULL;
    ComPtr<IDXGISwapChain1> swapchain = NULL;
    ComPtr<ID3D11RenderTargetView> render_target = NULL;

    sgpu_device_t device_info;
    bool has_device_info;
};

/// remember to free lol lmao even
static char* _utf16_to_utf8(const wchar_t* src) {
    int size = WideCharToMultiByte(CP_UTF8, 0, src, -1, NULL, 0, NULL, NULL);
    assert(size != 0);

    char* dst = (char*)calloc(size, sizeof(char));
    int result = WideCharToMultiByte(CP_UTF8, 0, src, -1, dst, size, NULL, NULL);
    assert(result != 0);
    return dst;
}

extern "C" sgpu_error_t sgpu_d3d11_init(sgpu_settings_t settings, sgpu_ctx_t* ctx) {
    ctx->d3d11 = new sgpu_d3d11_ctx();
    if (!ctx->d3d11) {
        return SGPU_ERROR_OUT_OF_CPU_MEMORY;
    }
    // i fucking love c+++++++++++++++++++
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    // technically could be a mysterious driver error, who knows
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&d3d11_ctx->dxgi_factory)))) {
        sgpu_log_error(ctx, "couldn't create dxgi factory");
        return SGPU_ERROR_INCOMPATIBLE_GPU;
    }

    const D3D_FEATURE_LEVEL device_feature_level = D3D_FEATURE_LEVEL_11_0;
    if (FAILED(D3D11CreateDevice(
            NULL,
            D3D_DRIVER_TYPE_HARDWARE,
            NULL,
            0,
            &device_feature_level,
            1,
            D3D11_SDK_VERSION,
            &d3d11_ctx->device,
            NULL,
            &d3d11_ctx->device_ctx))) {
        sgpu_log_error(ctx, "couldn't create device");
        return SGPU_ERROR_INCOMPATIBLE_GPU;
    }

    DXGI_SWAP_CHAIN_DESC1 swapchain_desc {};
    swapchain_desc.Width = settings.window_system.get_width(settings.window_system.userdata);
    swapchain_desc.Height = settings.window_system.get_height(settings.window_system.userdata);
    swapchain_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
    swapchain_desc.SampleDesc.Count = 1;
    swapchain_desc.SampleDesc.Quality = 0;
    swapchain_desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapchain_desc.BufferCount = 2;
    swapchain_desc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
    swapchain_desc.Scaling = DXGI_SCALING_STRETCH;
    swapchain_desc.Flags = 0;

    DXGI_SWAP_CHAIN_FULLSCREEN_DESC swapchain_fullscreen_desc {};
    swapchain_fullscreen_desc.Windowed = true;

    // i don't even know when this would fail
    if (FAILED(d3d11_ctx->dxgi_factory->CreateSwapChainForHwnd(
            d3d11_ctx->device.Get(),
            (HWND)settings.window_system.win32_handle,
            &swapchain_desc,
            &swapchain_fullscreen_desc,
            NULL,
            &d3d11_ctx->swapchain))) {
        sgpu_log_error(ctx, "couldn't create swapchain");
        return SGPU_ERROR_UNKNOWN;
    }

    ComPtr<ID3D11Texture2D> backbuffer = NULL;
    if (FAILED(d3d11_ctx->swapchain->GetBuffer(
            0,
            IID_PPV_ARGS(&backbuffer)))) {
        sgpu_log_error(ctx, "couldn't get swapchain backbuffer");
        return SGPU_ERROR_UNKNOWN;
    }

    if (FAILED(d3d11_ctx->device->CreateRenderTargetView(
            backbuffer.Get(),
            NULL,
            &d3d11_ctx->render_target))) {
        sgpu_log_error(ctx, "couldn't create render target view");
        return SGPU_ERROR_UNKNOWN;
    }

    // show any warnings if necessary
    sgpu_d3d11_query_device(ctx);

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_deinit(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    // no im not putting this in the destructor
    if (d3d11_ctx->has_device_info) {
        // evil const cast because the user shouldn't change it but microslop
        // makes us do an allocation
        free((char*)d3d11_ctx->device_info.vendor_name);
        free((char*)d3d11_ctx->device_info.device_name);
    }

    delete d3d11_ctx;
}

extern "C" sgpu_device_t sgpu_d3d11_query_device(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    // no need to query it twice
    if (d3d11_ctx->has_device_info) {
        return d3d11_ctx->device_info;
    }

    // a bit of bullshit
    ComPtr<IDXGIDevice> dxgi_device;
    d3d11_ctx->device->QueryInterface(IID_PPV_ARGS(&dxgi_device));
    ComPtr<IDXGIAdapter> adapter;
    dxgi_device->GetAdapter(&adapter);
    DXGI_ADAPTER_DESC desc;
    adapter->GetDesc(&desc);

    // check optional features
    // crashing if they don't match might be a bit much so it's just warnings for now
    D3D11_FEATURE_DATA_THREADING threading = {};
    d3d11_ctx->device->CheckFeatureSupport(
        D3D11_FEATURE_THREADING,
        &threading,
        sizeof(threading));
    if (!threading.DriverCommandLists || !threading.DriverConcurrentCreates) {
        sgpu_log_warn(ctx, "driver doesn't properly support multithreading");
    }

    D3D11_FEATURE_DATA_DOUBLES doubles = {};
    d3d11_ctx->device->CheckFeatureSupport(
        D3D11_FEATURE_DOUBLES,
        &doubles,
        sizeof(doubles));
    if (!doubles.DoublePrecisionFloatShaderOps) {
        sgpu_log_warn(ctx, "device doesn't support float64s");
    }
    // TODO check texture format

    sgpu_device_t dev {};
    // TODO there must be a way to split the 2 but i don't really care
    dev.vendor_name = "Unknown";
    dev.device_name = _utf16_to_utf8(desc.Description);

    // directx makes these fixed
    dev.max_image_2d_size[0] = D3D11_REQ_TEXTURE1D_U_DIMENSION;
    dev.max_image_2d_size[1] = D3D11_REQ_TEXTURE1D_U_DIMENSION;
    // not sure, couldn't find, not gonna trust a clanker, usually 128 mb tho
    dev.max_storage_buffer_size = 128 * 1024 * 1024;
    // there's another constant but this one is for read-write storage buffers (which is usually what
    // you want storage buffers for)
    dev.max_storage_buffer_bindings = D3D11_PS_CS_UAV_REGISTER_COUNT;
    dev.max_compute_workgroup_size[0] = D3D11_CS_THREAD_GROUP_MAX_X;
    dev.max_compute_workgroup_size[1] = D3D11_CS_THREAD_GROUP_MAX_Y;
    dev.max_compute_workgroup_size[2] = D3D11_CS_THREAD_GROUP_MAX_Z;
    dev.max_compute_workgroup_threads = D3D11_CS_THREAD_GROUP_MAX_THREADS_PER_GROUP;

    d3d11_ctx->device_info = dev;
    return dev;
}

extern "C" void sgpu_d3d11_swap_buffers(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    d3d11_ctx->swapchain->Present(1, 0);
}

extern "C" sgpu_error_t sgpu_d3d11_recreate_swapchain(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    d3d11_ctx->device_ctx->Flush(); // just in case
    d3d11_ctx->render_target.Reset();

    if (FAILED(d3d11_ctx->swapchain->ResizeBuffers(
            0,
            ctx->settings.window_system.get_width(ctx->settings.window_system.userdata),
            ctx->settings.window_system.get_height(ctx->settings.window_system.userdata),
            DXGI_FORMAT_B8G8R8A8_UNORM,
            0))) {
        sgpu_log_error(ctx, "couldn't resize swapchain");
        return SGPU_ERROR_UNKNOWN;
    }

    ComPtr<ID3D11Texture2D> backbuffer = NULL;
    if (FAILED(d3d11_ctx->swapchain->GetBuffer(
            0,
            IID_PPV_ARGS(&backbuffer)))) {
        sgpu_log_error(ctx, "couldn't get swapchain backbuffer");
        return SGPU_ERROR_UNKNOWN;
    }

    if (FAILED(d3d11_ctx->device->CreateRenderTargetView(
            backbuffer.Get(),
            NULL,
            &d3d11_ctx->render_target))) {
        sgpu_log_error(ctx, "couldn't recreate render target view");
        return SGPU_ERROR_UNKNOWN;
    }

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t render_pass) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    if (render_pass.frame.load_action == SGPU_LOAD_ACTION_CLEAR) {
        const float color[] = {
            render_pass.frame.clear_color.r,
            render_pass.frame.clear_color.g,
            render_pass.frame.clear_color.b,
            render_pass.frame.clear_color.a,
        };
        d3d11_ctx->device_ctx->ClearRenderTargetView(d3d11_ctx->render_target.Get(), color);
    }

    d3d11_ctx->device_ctx->OMSetRenderTargets(1, d3d11_ctx->render_target.GetAddressOf(), NULL);
}

extern "C" void sgpu_d3d11_end_render_pass(sgpu_ctx_t* ctx) {
    // noop in d3d11
    (void)ctx;
}

extern "C" void sgpu_d3d11_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    D3D11_VIEWPORT vp = {};
    vp.TopLeftX = (float)viewport.top_left_x;
    vp.TopLeftY = (float)viewport.top_left_y;
    vp.Width = (float)viewport.width;
    vp.Height = (float)viewport.height;
    vp.MinDepth = viewport.min_depth;
    vp.MaxDepth = viewport.max_depth;

    d3d11_ctx->device_ctx->RSSetViewports(1, &vp);
}
