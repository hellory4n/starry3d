add_rules("mode.debug", "mode.release")

-- TODO could manually recreate the project from the cmakelists
-- no wayland support tho bcuz that requires some weird header generation and i don't want to deal with that
package("glfw")
	add_deps("cmake")
	set_sourcedir("thirdparty/glfw")

	on_install(function(pkg)
		local configs = {
			"-DGLFW_LIBRARY_TYPE=STATIC",
			"-DGLFW_BUILD_EXAMPLES=OFF",
			"-DGLFW_BUILD_TESTS=OFF"
		}
		import("packages.tools.cmake").install(pkg, configs)
	end)
package_end()

target("imgui")
	set_kind("static")
	set_languages("cxx20")

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

	add_deps("trippin", "imgui")
	add_packages("glfw")

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
