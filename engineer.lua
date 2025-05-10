starry3d = {}
eng = require("libengineer")
eng.init()

-- i tried importing libtrippin's engineer.lua but then it cant find libengineer???
trippin = {
	lib = function(debug, trippinsrc)
		-- just trippin so it doesn't become "liblibtrippin.a"
		local project = eng.newproj("trippin", "staticlib", "c99")
		project:pedantic()
		if debug then
			project:debug()
			project:optimization(0)
		else
			project:optimization(2)
		end

		project:add_sources({trippinsrc})
		project:target("libtrippin.a")
		return project
	end
}

-- Returns a table with the starry3d project and its dependencies (libtrippin, glfw). `debug` is a bool.
-- The libtrippin field is an engineer project but the glfw field is a function that builds it as a static
-- library. `starrydir` is where you put starry3d. Platform should either be "windows" or "linux". The
-- table also has a `getlinks` function so you know what to link with, and a `getincludes` function to
-- get the bloody includes mate.
function starry3d.lib(debug, starrydir, platform)
	assert(platform == "windows" or platform == "linux")
	local result = {}
	result.libtrippin = trippin.lib(debug, starrydir.."/vendor/libtrippin/libtrippin.c")
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
		local cmakecmd = "cmake -S "..starrydir.."/vendor/glfw -B build/glfw -D GLFW_LIBRARY_TYPE=STATIC -D GLFW_BUILD_EXAMPLES=OFF -D GLFW_BUILD_TESTS=OFF"

		-- cross compile to windows
		if platform == "windows" then
			-- cmake is insane and can't find a file that exists :D
			os.execute("cp "..starrydir.."/vendor/glfw/CMake/x86_64-w64-mingw32.cmake win32.cmake")
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
		result.starry3d:link({"glfw3", "opengl32", "gdi32", "winmm", "comdlg32", "ole32", "pthread"})
		result.starry3d:define({"ST_WINDOWS"})
	else
		result.starry3d:target("libstarry3d.a")
		result.starry3d:link({"glfw3", "X11", "Xrandr", "GL", "Xinerama", "m", "pthread", "dl", "rt"})
		result.starry3d:define({"ST_LINUX"})
	end
	result.starry3d:gen_compile_commands()

	if platform == "windows" then
		result.getlinks = function()
			return {"starry3d", "trippin", "glfw3", "opengl32", "gdi32", "winmm", "comdlg32", "ole32", "pthread"}
		end
	else
		result.getlinks = function()
			return {"starry3d", "trippin", "glfw3", "X11", "Xrandr", "GL", "Xinerama", "m", "pthread", "dl", "rt"}
		end
	end

	result.getincludes = function()
		return {
			starrydir.."/src",
			starrydir.."/vendor",
			starrydir.."/vendor/glfw/include",
			starrydir.."/vendor/libtrippin",
			starrydir.."/vendor/linmath",
			starrydir.."/vendor/nuklear",
			starrydir.."/vendor/nuklear/demo/glfw_opengl3", -- just for glfw/opengl3 integration lmao
			starrydir.."/vendor/stb",
			starrydir.."/vendor/whereami/src",
		}
	end

	return result
end

-- lua modules are tricky and i cant find any info on how to get it to not fucking run this when
-- being imported
-- the engineer script sets that argument
-- its supposed to be ignored by eng.run()
-- im hacking my own build system
-- send help.
if arg[1] == "?deargod?" then
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

	eng.recipe("build-lib", "Builds the library lmao.", function()
		local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
		thegreatstarryhandsomestacktechnologything.libtrippin:build()
		thegreatstarryhandsomestacktechnologything.glfw()
		thegreatstarryhandsomestacktechnologything.starry3d:build()
	end)

	eng.recipe("build", "Builds everything ever.", function()
		eng.run_recipe("build-lib")
		os.execute("cd sandbox && ./engineer build")
	end)

	eng.recipe("clean", "Cleans the project lmao.", function()
		local thegreatstarryhandsomestacktechnologything = starry3d.lib(debug, ".", platform)
		thegreatstarryhandsomestacktechnologything.starry3d:clean()
		os.execute("cd sandbox && ./engineer clean")
	end)

	eng.run()
end

return starry3d
