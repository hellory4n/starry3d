#include "backend_d3d11.h"
#include "sgpu_internal.h"
#include "starrygpu.h"
#include <cstddef>
#include <new>

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
};

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
            nullptr,
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
            nullptr,
            &d3d11_ctx->render_target))) {
        sgpu_log_error(ctx, "couldn't create render target view");
        return SGPU_ERROR_UNKNOWN;
    }

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_deinit(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    delete d3d11_ctx;
}

extern "C" void sgpu_d3d11_swap_buffers(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    d3d11_ctx->swapchain->Present(1, 0);
}

extern "C" sgpu_error_t sgpu_d3d11_recreate_swapchain(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
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
            nullptr,
            &d3d11_ctx->render_target))) {
        sgpu_log_error(ctx, "couldn't recreate render target view");
        return SGPU_ERROR_UNKNOWN;
    }

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_flush(sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    d3d11_ctx->device_ctx->Flush();
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
