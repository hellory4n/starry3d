starry3d = require("starry3d")
eng = require("libengineer")
eng.init()

-- you just have to edit these
local assets = "assets"
local starrydir = ".."
local project = eng.newproj("sandbox", "executable", "c99")
project:add_includes({"src"})
project:add_sources({
	"src/main.c"
})
project:pedantic()

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
		project:target("sandbox.exe")
		-- so it doesn't complain about pthread
		project:add_ldflags(" -static ")
		eng.cc = "x86_64-w64-mingw32-gcc"
		eng.cxx = "x86_64-w64-mingw32-g++"
	end
end)

eng.recipe("build", "Builds the project lmao.", function()
	-- copy assets folder
	os.execute("mkdir -p build/bin/"..assets)
	os.execute("cp -r "..assets.."/* build/bin/"..assets)

	if debug then
		project:debug()
		project:optimization(0)
	else
		project:optimization(2)
	end

	local starry3dma = starry3d.lib(debug, starrydir, platform)
	project:add_includes(starry3dma.getincludes())
	project:link(starry3dma.getlinks())
	project:gen_compile_commands()

	-- actually build
	starry3dma.libtrippin:build()
	starry3dma.glfw()
	starry3dma.starry3d:build()
	project:build()
end)

eng.recipe("clean", "Cleans the project lmao.", function()
	local starry3dma = starry3d.lib(debug, "..", platform)
	starry3dma.starry3d:clean()
	project:clean()
	os.remove("log.txt")
end)

eng.recipe("run", "Builds and runs the project", function()
	eng.run_recipe("build")
	print("") -- separation
	if platform == "windows" then
		os.execute("wine build/bin/sandbox.exe")
	else
		os.execute("gdb -q -ex run -ex \"quit\" --args build/bin/sandbox")
	end
end)

eng.recipe("run-gdb", "Runs the project with gdb", function()
	eng.run_recipe("build")
	print("") -- separation
	os.execute("gdb build/bin/sandbox")
end)

eng.run()
