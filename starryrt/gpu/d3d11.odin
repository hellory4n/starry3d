package stgpu

import "core:fmt"
import "core:log"
import "core:strings"
import win "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"

@(private = "file")
global: struct {
	device:          ^d3d11.IDevice,
	device_ctx:      ^d3d11.IDeviceContext,
	dxgi_factory:    ^dxgi.IFactory2,
	swapchain:       ^dxgi.ISwapChain1,
	render_target:   ^d3d11.IRenderTargetView,
	has_device_info: bool,
}

@(private = "file")
parse_hresult :: #force_inline proc(
	hresult: win.HRESULT,
	allocator := context.temp_allocator,
) -> string
{
	buf: [^]u16

	msg_len := win.FormatMessageW(
		flags = win.FORMAT_MESSAGE_FROM_SYSTEM |
		win.FORMAT_MESSAGE_IGNORE_INSERTS |
		win.FORMAT_MESSAGE_ALLOCATE_BUFFER,
		lpSrc = nil,
		msgId = u32(hresult),
		langId = 0,
		buf = (win.LPWSTR)(&buf),
		nsize = 0,
		args = nil,
	)

	out_str, _ := win.utf16_to_utf8(buf[:msg_len], allocator)
	win.LocalFree(buf)

	return out_str
}

@(private = "file")
assert_hresult :: #force_inline proc(hresult: win.HRESULT)
{
	when !ODIN_DISABLE_ASSERT {
		if hresult < 0 {
			str := strings.builder_make_none(context.temp_allocator)
			fmt.sbprintf(
				&str,
				"DirectX error 0x%X: %s",
				u32(hresult),
				parse_hresult(hresult),
			)
			win.MessageBoxW(
				nil,
				win.utf8_to_wstring(string(str.buf[:])),
				win.L("DirectX error"),
				win.MB_ICONERROR | win.MB_OK,
			)

			log.panicf(
				"DirectX error 0x%X: %s",
				u32(hresult),
				parse_hresult(hresult),
			)
		}
	}
}

@(private)
d3d11_new_ctx :: proc(
	generic_glue: Glue,
	app_name: string = "A Starry app",
	app_version: [3]i32 = {0, 0, 0},
	engine_name: string = "A Starrygpu engine",
	engine_version: [3]i32 = {0, 0, 0},
)
{
	glue := generic_glue.(D3D11_Glue)

	feature_levels := []d3d11.FEATURE_LEVEL{d3d11.FEATURE_LEVEL._11_0}
	creation_flags := d3d11.CREATE_DEVICE_FLAGS{.BGRA_SUPPORT}
	// im supposed to instal smth but it gets stuck in a progress bar for a fucking hour
	// when ODIN_DEBUG {
	// 	creation_flags += {.DEBUG}
	// }

	assert_hresult(
		d3d11.CreateDevice(
			pAdapter = nil,
			DriverType = .HARDWARE,
			Software = nil,
			Flags = creation_flags,
			pFeatureLevels = raw_data(feature_levels),
			FeatureLevels = u32(len(feature_levels)),
			SDKVersion = d3d11.SDK_VERSION,
			ppDevice = &global.device,
			pFeatureLevel = nil,
			ppImmediateContext = &global.device_ctx,
		),
	)

	// validation layer
	when ODIN_DEBUG {
		device_debug: ^d3d11.IDebug
		global.device->QueryInterface(d3d11.IDebug_UUID, (^rawptr)(&device_debug))
		if device_debug != nil {
			info_queue: ^d3d11.IInfoQueue
			res := device_debug->QueryInterface(
				d3d11.IInfoQueue_UUID,
				(^rawptr)(&info_queue),
			)
			if win.SUCCEEDED(res) {
				info_queue->SetBreakOnSeverity(.CORRUPTION, true)
				info_queue->SetBreakOnSeverity(.ERROR, true)

				allow_severities := []d3d11.MESSAGE_SEVERITY {
					.CORRUPTION,
					.ERROR,
					.INFO,
				}

				filter := d3d11.INFO_QUEUE_FILTER {
					AllowList = {
						NumSeverities = u32(len(allow_severities)),
						pSeverityList = raw_data(allow_severities),
					},
				}
				info_queue->AddStorageFilterEntries(&filter)
				info_queue->Release()
			}
			device_debug->Release()
		}
	}

	dxgi_device: ^dxgi.IDevice1
	assert_hresult(global.device->QueryInterface(dxgi.IDevice1_UUID, (^rawptr)(&dxgi_device)))
	defer dxgi_device->Release()

	dxgi_adapter: ^dxgi.IAdapter
	assert_hresult(dxgi_device->GetAdapter(&dxgi_adapter))
	defer dxgi_adapter->Release()

	adapter_desc: dxgi.ADAPTER_DESC
	dxgi_adapter->GetDesc(&adapter_desc)
	log.infof("graphics device: %s", transmute(string16)adapter_desc.Description[:])

	assert_hresult(
		dxgi_adapter->GetParent(dxgi.IFactory2_UUID, (^rawptr)(&global.dxgi_factory)),
	)

	swapchain_desc := dxgi.SWAP_CHAIN_DESC1 {
		Width = 0,
		Height = 0,
		Format = .B8G8R8A8_UNORM_SRGB,
		SampleDesc = {Count = 1, Quality = 0},
		BufferUsage = {.RENDER_TARGET_OUTPUT},
		BufferCount = 2,
		Scaling = .STRETCH,
		SwapEffect = .DISCARD,
		AlphaMode = .UNSPECIFIED,
		Flags = {},
	}

	assert_hresult(
		global.dxgi_factory->CreateSwapChainForHwnd(
			pDevice = global.device,
			hWnd = glue.hwnd,
			pDesc = &swapchain_desc,
			pFullscreenDesc = nil,
			pRestrictToOutput = nil,
			ppSwapChain = &global.swapchain,
		),
	)

	framebuffer: ^d3d11.ITexture2D
	assert_hresult(
		global.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, (^rawptr)(&framebuffer)),
	)
	defer framebuffer->Release()

	assert_hresult(
		global.device->CreateRenderTargetView(framebuffer, nil, &global.render_target),
	)
}

@(private)
d3d11_free_ctx :: proc()
{
	global.swapchain->Release()
	global.dxgi_factory->Release()
	global.device_ctx->Release()
	global.device->Release()
}

@(private)
d3d11_start_render_pass :: proc(
	frame_load_action: Load_Action,
	frame_store_action: Store_Action,
	frame_clear_color: [4]f32,
)
{  }

@(private)
d3d11_end_render_pass :: proc()
{  }

@(private)
d3d11_swap_buffers :: proc()
{  }

@(private)
d3d11_recreate_swapchain :: proc()
{  }

@(private)
d3d11_set_viewport :: proc(top_left: [2]i32, size: [2]i32, min_depth: i32, max_depth: i32)
{  }
