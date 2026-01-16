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
    // questionable for c++ but i don't care
    ctx->d3d11 = sgpu_malloc(ctx, sizeof(sgpu_d3d11_ctx));
    if (!ctx->d3d11) {
        return SGPU_ERROR_OUT_OF_CPU_MEMORY;
    }
    sgpu_d3d11_ctx* d3d11_ctx = (sgpu_d3d11_ctx*)ctx->d3d11;

    return SGPU_OK;
}

extern "C" void sgpu_d3d11_deinit(sgpu_ctx_t* ctx) {
    sgpu_free(ctx, ctx->d3d11);
}
