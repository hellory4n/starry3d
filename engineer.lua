starry3d = {}
eng = require("libengineer")
eng.init()

-- i tried importing libtrippin's engineer.lua but then it cant find libengineer???
trippin = {
	lib = function(debug)
		-- just trippin so it doesn't become "liblibtrippin.a"
		local project = eng.newproj("trippin", "staticlib", "c99")
		project:pedantic()
		if debug then
			project:debug()
			project:optimization(0)
		else
			project:optimization(2)
		end

		project:add_sources({"vendor/libtrippin/libtrippin.c"})
		project:target("libtrippin.a")
		return project
	end
}

-- Returns a table with the starry3d project and its dependencies (libtrippin, glfw). `debug` is a bool.
-- The libtrippin field is an engineer project but the glfw field is a function that builds it as a static
-- library. `starrydir` is where you put starry3d. Platform should either be "windows" or "linux".
function starry3d.lib(debug, starrydir, platform)
	assert(platform == "windows" or platform == "linux")
	local result = {}
	result.libtrippin = trippin.lib(debug)
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

		os.execute("mkdir "..starrydir.."/build/glfw")
		-- GLFW_BUILD_EXAMPLES=OFF and GLFW_BUILD_TESTS=OFF because we don't need them
		local cmakecmd = "cmake -S "..starrydir.."/vendor/glfw -B "..starrydir..
			"/build/glfw -D GLFW_LIBRARY_TYPE=STATIC -D GLFW_BUILD_EXAMPLES=OFF -D GLFW_BUILD_TESTS=OFF"

		-- cross compile to windows
		if platform == "windows" then
			cmakecmd = cmakecmd.." -D CMAKE_TOOLCHAIN_FILE="..
				starrydir.."/vendor/glfw/CMake/x86_64-w64-mingw32.cmake"
		end
		os.execute(cmakecmd)
		os.execute("cd "..starrydir.."/build/glfw && make")

		-- engineer expects static libraries there
		if platform == "linux" then
			os.execute("cp "..starrydir.."/build/glfw/src/libglfw3.a "..starrydir.."/build/static/libglfw3.a")
		else
			os.execute("cp "..starrydir.."/build/glfw/src/glfw3.lib "..starrydir.."/build/static/glfw3.lib")
		end
	end

	-- the actual starry3d project
	result.starry3d = eng.newproj("starry3d", "staticlib", "c99")
	result.starry3d:pedantic()
	if debug then
		result.starry3d:debug()
		result.starry3d:optimization(0)
	else
		result.starry3d:optimization(2)
	end

	result.starry3d:add_includes({
		starrydir.."/src",
		starrydir.."/vendor",
		starrydir.."/vendor/glfw/include",
		starrydir.."/vendor/libtrippin",
		starrydir.."/vendor/linmath",
		starrydir.."/vendor/nuklear",
		starrydir.."/vendor/nuklear/demo/glfw_opengl3", -- just for glfw/opengl3 integration lmao
		starrydir.."/vendor/stb",
		starrydir.."/vendor/whereami/src",
	})
	result.starry3d:add_sources({
		starrydir.."/src/st_common.c",
		starrydir.."/src/st_render.c",
		starrydir.."/src/st_ui.c",
		starrydir.."/src/st_voxel.c",
		starrydir.."/src/st_window.c",
	})

	-- mate
	if platform == "windows" then
		result.starry3d:target("starry3d.lib")
		result.starry3d:link({"glfw3", "opengl32", "gdi32", "winmm", "comdlg32", "lole32", "pthread"})
		result.starry3d:define({"ST_WINDOWS"})
	else
		result.starry3d:target("libstarry3d.a")
		result.starry3d:link({"glfw3", "X11", "Xrandr", "GL", "Xinerama", "m", "pthread", "dl", "rt"})
		result.starry3d:define({"ST_LINUX"})
	end
	result.starry3d:gen_compile_commands()

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
end)

eng.recipe("build", "Builds the library lmao.", function()
	local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
	thegreatstarryhandsomestacktechnologything.libtrippin:build()
	thegreatstarryhandsomestacktechnologything.glfw()
	thegreatstarryhandsomestacktechnologything.starry3d:build()
end)

eng.recipe("clean", "Cleans the project lmao", function()
	local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
	thegreatstarryhandsomestacktechnologything.starry3d:clean()
end)

eng.run()
return starry3d
