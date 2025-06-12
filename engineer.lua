starry3d = {}
eng = require("libengineer")
eng.init()

-- lua modules are obnoxious :)
trippin = {}
function trippin.lib(debug, trippinsrc)
	-- just trippin so it doesn't become "liblibtrippin.a"
	local project = eng.newproj("trippin", "staticlib", "c++14")
	project:pedantic()
	if debug then
		project:debug()
		project:optimization(0)
		project:define({"DEBUG"})
	else
		project:optimization(2)
	end

	project:add_sources({trippinsrc})
	project:target("libtrippin.a")
	return project
end

-- Returns a table with the starry3d project and its dependencies (libtrippin, glfw). `debug` is a bool.
-- The libtrippin field is an engineer project but the glfw field is a function that builds it as a static
-- library. `starrydir` is where you put starry3d. Platform should either be "windows" or "linux". The
-- table also has a `getlinks` function so you know what to link with, and a `getincludes` function to
-- get the bloody includes mate.
function starry3d.lib(debug, starrydir, platform)
	assert(platform == "windows" or platform == "linux")
	local result = {}
	result.libtrippin = trippin.lib(debug, starrydir.."/thirdparty/libtrippin/libtrippin.cpp")
	if platform == "windows" then
		result.libtrippin:target("trippin.lib")
	else
		result.libtrippin:target("libtrippin.a")
	end

	-- glfw wrapper bcuz the actual glfw uses cmake
	result.glfw = function()
		print("Building GLFW (through CMake)")

		-- is it already built?
		local sir = io.open(starrydir.."/build/static/libglfw3.a", "rb")
		if sir ~= nil then
			sir:close()
			print("GLFW already up to date; nothing to do")
			return
		end

		os.execute("mkdir build/glfw")
		-- GLFW_BUILD_EXAMPLES=OFF and GLFW_BUILD_TESTS=OFF because we don't need them
		local cmakecmd = "cmake -S "..starrydir.."/thirdparty/glfw -B build/glfw -D GLFW_LIBRARY_TYPE=STATIC -D GLFW_BUILD_EXAMPLES=OFF -D GLFW_BUILD_TESTS=OFF"

		-- cross compile to windows
		if platform == "windows" then
			-- cmake is insane and can't find a file that exists :D
			os.execute("cp "..starrydir.."/thirdparty/glfw/CMake/x86_64-w64-mingw32.cmake win32.cmake")
			cmakecmd = cmakecmd.." -DCMAKE_TOOLCHAIN_FILE=$(pwd)/win32.cmake"
		end
		os.execute(cmakecmd)
		os.execute("cd build/glfw && make")

		-- engineer expects static libraries there
		os.execute("cp build/glfw/src/libglfw3.a build/static/libglfw3.a")

		if platform == "windows" then
			os.remove("win32.cmake")
		end
	end

	-- imgui is simple enough that we can wrap it in engineer
	result.imgui = eng.newproj("imgui", "staticlib", "c++14")
	result.imgui:pedantic()
	if debug then
		result.imgui:debug()
		result.imgui:optimization(0)
		result.imgui:define({"DEBUG", "_DEBUG"})
	else
		result.imgui:optimization(2)
	end

	result.imgui:add_includes({
		starrydir.."/thirdparty/imgui",
		starrydir.."/thirdparty/imgui/backends",
		starrydir.."/thirdparty/glfw/include"
	})
	result.imgui:add_sources({
		starrydir.."/thirdparty/imgui/imgui.cpp",
		starrydir.."/thirdparty/imgui/imgui_widgets.cpp",
		starrydir.."/thirdparty/imgui/imgui_tables.cpp",
		starrydir.."/thirdparty/imgui/imgui_draw.cpp",
		starrydir.."/thirdparty/imgui/imgui_demo.cpp",
		starrydir.."/thirdparty/imgui/backends/imgui_impl_glfw.cpp",
		starrydir.."/thirdparty/imgui/backends/imgui_impl_opengl3.cpp",
	})

	-- the actual starry3d project
	result.starry3d = eng.newproj("starry3d", "staticlib", "c++14")
	result.starry3d:pedantic()
	if debug then
		result.starry3d:debug()
		result.starry3d:optimization(0)
		result.starry3d:define({"DEBUG"})
	else
		result.starry3d:optimization(2)
	end

	result.starry3d:add_includes({
		starrydir.."/src",
		starrydir.."/thirdparty",
		starrydir.."/thirdparty/libtrippin",
		starrydir.."/thirdparty/glfw/include",
		starrydir.."/thirdparty/stb",
		starrydir.."/thirdparty/imgui",
		starrydir.."/thirdparty/imgui/backends",
	})
	result.starry3d:add_sources({
		starrydir.."/src/st_common.cpp",
		starrydir.."/src/st_window.cpp",
		starrydir.."/src/st_render.cpp",
		starrydir.."/src/st_imgui.cpp",
	})

	-- mate
	if platform == "windows" then
		result.starry3d:target("starry3d.lib")
		result.imgui:target("imgui.lib")
		result.starry3d:define({"ST_WINDOWS"})
	else
		result.starry3d:target("libstarry3d.a")
		result.imgui:target("libimgui.a")
		result.starry3d:define({"ST_LINUX"})
	end
	result.starry3d:gen_compile_commands()

	if platform == "windows" then
		result.getlinks = function()
			return {"starry3d", "trippin", "imgui", "glfw3", "opengl32", "gdi32", "winmm", "comdlg32", "ole32", "pthread", "stdc++"}
		end
	else
		result.getlinks = function()
			return {"starry3d", "trippin", "imgui", "glfw3", "X11", "Xrandr", "GL", "Xinerama", "m", "pthread", "dl", "rt", "stdc++"}
		end
	end

	result.getincludes = function()
		return {
			starrydir.."/src",
			starrydir.."/thirdparty",
			starrydir.."/thirdparty/libtrippin",
			starrydir.."/thirdparty/glfw/include",
			starrydir.."/thirdparty/stb",
			starrydir.."/thirdparty/imgui",
			starrydir.."/thirdparty/imgui/backends"
		}
	end

	return result
end

local debug = true
local platform = "linux"

eng.option("mode", "Either debug or release", function(val)
	assert(val == "debug" or val == "release")
	if val == "debug" then debug = true
	elseif val == "release" then debug = false end
end)

eng.option("platform", "Either linux or windows. Windows requires mingw64-gcc", function(val)
	assert(val == "linux" or val == "windows")
	platform = val
	if val == "windows" then
		eng.cc = "x86_64-w64-mingw32-gcc"
		eng.cxx = "x86_64-w64-mingw32-g++"
	end
end)

eng.recipe("build-lib", "Builds the library lmao.", function()
	local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
	thegreatstarryhandsomestacktechnologything.libtrippin:build()
	thegreatstarryhandsomestacktechnologything.glfw()
	thegreatstarryhandsomestacktechnologything.starry3d:build()
end)

eng.recipe("build", "Builds everything ever.", function()
	eng.run_recipe("build-lib")
	if platform == "windows" then
		os.execute("cd sandbox && ./engineer build")
	else
		os.execute("cd sandbox && ./engineer build platform=windows")
	end
end)

eng.recipe("clean", "Cleans the project lmao.", function()
	local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
	thegreatstarryhandsomestacktechnologything.starry3d:clean()
	os.execute("cd sandbox && ./engineer clean")
end)

-- lua modules are obnoxious and idk how to fix this properly
if arg[1] == "?shutup" then
	eng.run()
end

return starry3d
