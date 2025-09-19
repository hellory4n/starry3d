add_rules("mode.debug", "mode.release")

-- pls use the local glfw not the one from the internet thanks
-- TODO why though
package("glfw")
	add_deps("cmake")
	set_sourcedir(path.join(os.scriptdir(), "thirdparty/glfw"))
	set_policy("package.install_always", true)
	set_policy("package.install_locally", true)

	on_install(function(package)
		-- for cross compiling
		if is_plat("windows") and (is_host("linux") or is_host("macosx")) then
			import("package.tools.cmake").build(package, {
				"-D GLFW_LIBRARY_TYPE=STATIC",
				"-D GLFW_BUILD_EXAMPLES=OFF",
				"-D GLFW_BUILD_TESTS=OFF",
				"-DCMAKE_TOOLCHAIN_FILE=$(pwd)/thirdparty/glfw/CMake/x86_64-w64-mingw32.cmake",
			})
		else
			import("package.tools.cmake").build(package, {
				"-D GLFW_LIBRARY_TYPE=STATIC",
				"-D GLFW_BUILD_EXAMPLES=OFF",
				"-D GLFW_BUILD_TESTS=OFF",
			})
		end
	end)
package_end()

add_requires("glfw")

target("imgui")
	set_kind("static")
	set_languages("cxx20")

	add_packages("glfw")

	add_includedirs("thirdparty/imgui", {public = true})
	add_includedirs("thirdparty/imgui/backends", {public = true})
	add_includedirs("thirdparty/glfw/include")

	add_files(
		"thirdparty/imgui/imgui.cpp",
		"thirdparty/imgui/imgui_demo.cpp",
		"thirdparty/imgui/imgui_draw.cpp",
		"thirdparty/imgui/imgui_tables.cpp",
		"thirdparty/imgui/imgui_widgets.cpp",
		"thirdparty/imgui/backends/imgui_impl_opengl3.cpp",
		"thirdparty/imgui/backends/imgui_impl_glfw.cpp"
	)
target_end()

target("stb")
	set_kind("headeronly")
	add_headerfiles("thirdparty/stb/stb_*.h")
target_end()

target("trippin")
	set_kind("static")
	set_languages("cxx20")
	set_warnings("allextra") -- -Wall -Wextra

	add_includedirs("thirdparty/libtrippin", {public = true})
	if is_plat("linux") then
		add_syslinks("m")
	end

	if is_mode("debug") then
		add_defines("DEBUG")
	end
	add_defines("ST_IMGUI")

	add_files(
		"thirdparty/libtrippin/trippin/collection.cpp",
		"thirdparty/libtrippin/trippin/common.cpp",
		"thirdparty/libtrippin/trippin/error.cpp",
		"thirdparty/libtrippin/trippin/iofs.cpp",
		"thirdparty/libtrippin/trippin/log.cpp",
		"thirdparty/libtrippin/trippin/math.cpp",
		"thirdparty/libtrippin/trippin/memory.cpp",
		"thirdparty/libtrippin/trippin/string.cpp"
	)
target_end()

-- TODO include mrshader here
target("starry3d")
	set_kind("static")
	set_languages("cxx20")
	set_warnings("allextra") -- -Wall -Wextra

	add_includedirs(".", {public = true})
	add_includedirs("thirdparty", {public = true})
	add_includedirs("thirdparty/glfw/include")

	if is_plat("windows") then
		add_syslinks("opengl32", "gdi32", "winmm", "comdlg32", "ole32", "pthread")
	elseif is_plat("linux") then
		add_syslinks("X11", "Xrandr", "GL", "Xinerama", "m", "pthread", "dl", "rt")
	end

	if is_mode("debug") then
		add_defines("DEBUG")
	end
	add_defines("ST_IMGUI")

	add_packages("glfw")
	add_deps("trippin", "imgui", "stb")

	add_files(
		"starry/app.cpp",
		"starry/gpu.cpp",
		"starry/internal.cpp",
		"starry/render.cpp",
		"starry/world.cpp",
		"starry/optional/imgui.cpp"
	)
target_end()

target("sandbox")
	set_kind("binary")
	set_languages("cxx20")
	set_warnings("allextra") -- -Wall -Wextra

	add_deps("starry3d")

	if is_mode("debug") then
		add_defines("DEBUG")
	end
	add_defines("ST_IMGUI")

	add_installfiles("assets/*", {prefixdir = "assets"})
	add_includedirs("sandbox/src")
	add_files(
		"sandbox/src/main.cpp",
		"sandbox/src/app.cpp",
		"sandbox/src/debug_mode.cpp",
		"sandbox/src/world.cpp"
	)
target_end()
