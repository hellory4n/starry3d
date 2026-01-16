#include "backend_d3d11.h"
#include "sgpu_internal.h"
#include "starrygpu.h"
#include <cstddef>

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
    // questionable for c++ but i don't care
    ctx->d3d11 = sgpu_malloc(ctx, sizeof(sgpu_d3d11_ctx));
    if (!ctx->d3d11) {
        return SGPU_ERROR_OUT_OF_CPU_MEMORY;
    }
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    // technically could be a mysterious driver error, who knows
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&d3d11_ctx->dxgi_factory)))) {
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
        return SGPU_ERROR_INCOMPATIBLE_GPU;
    }

    DXGI_SWAP_CHAIN_DESC1 swapchain_desc {};
    swapchain_desc.Width = settings.window_system.get_width(settings.window_system.userdata);
    swapchain_desc.Height = settings.window_system.get_height(settings.window_system.userdata);
    swapchain_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
    swapchain_desc.SampleDesc.Count = 1;
    swapchain_desc.SampleDesc.Quality = 0;
    swapchain_desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapchain_desc.BufferCount = 3;
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
        return SGPU_ERROR_UNKNOWN;
    }

    ComPtr<ID3D11Texture2D> backbuffer = NULL;
    if (FAILED(d3d11_ctx->swapchain->GetBuffer(
            0,
            IID_PPV_ARGS(&backbuffer)))) {
        return SGPU_ERROR_UNKNOWN;
    }

    if (FAILED(d3d11_ctx->device->CreateRenderTargetView(
            backbuffer.Get(),
            nullptr,
            &d3d11_ctx->render_target))) {
        return SGPU_ERROR_UNKNOWN;
    }

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_deinit(sgpu_ctx_t* ctx) {
    sgpu_free(ctx, ctx->d3d11);
}

extern "C" void sgpu_d3d11_swap_buffers(const sgpu_ctx_t* ctx) {
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
        return SGPU_ERROR_UNKNOWN;
    }

    ComPtr<ID3D11Texture2D> backbuffer = NULL;
    if (FAILED(d3d11_ctx->swapchain->GetBuffer(
            0,
            IID_PPV_ARGS(&backbuffer)))) {
        return SGPU_ERROR_UNKNOWN;
    }

    if (FAILED(d3d11_ctx->device->CreateRenderTargetView(
            backbuffer.Get(),
            nullptr,
            &d3d11_ctx->render_target))) {
        return SGPU_ERROR_UNKNOWN;
    }

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_flush(const sgpu_ctx_t* ctx) {
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;
    d3d11_ctx->device_ctx->Flush();
}
