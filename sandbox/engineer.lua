starry3d = require("starry3d")
eng = require("libengineer")
eng.init()

-- you just have to edit these
local assets = "assets"
local starrydir = ".."
local projma = eng.newproj("sandbox", "executable", "c99")
projma:add_includes({"src"})
projma:add_sources({
	"src/main.c"
})
projma:pedantic()

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
		projma:target("sandbox.exe")
		-- so it doesn't complain about pthread
		projma:add_ldflags(" -static ")
		eng.cc = "x86_64-w64-mingw32-gcc"
		eng.cxx = "x86_64-w64-mingw32-g++"
	end
end)

eng.recipe("build", "Builds the library lmao.", function()
	-- copy assets folder
	os.execute("mkdir -p build/bin/"..assets)
	os.execute("cp -r "..assets.."/* build/bin/"..assets)

	if debug then
		projma:debug()
		projma:optimization(0)
	else
		projma:optimization(2)
	end

	local starry3dma = starry3d.lib(debug, starrydir, platform)
	projma:add_includes(starry3dma.getincludes())
	projma:link(starry3dma.getlinks())
	projma:gen_compile_commands()

	-- actually build
	starry3dma.libtrippin:build()
	starry3dma.glfw()
	starry3dma.starry3d:build()
	projma:build()
end)

eng.recipe("clean", "Cleans the project lmao.", function()
	local starry3dma = starry3d.lib(debug, "..", platform)
	starry3dma.starry3d:clean()
	projma:clean()
	os.remove("log.txt")
end)

eng.recipe("run", "Builds and runs the project", function()
	eng.run_recipe("build")
	print("") -- separation
	if platform == "windows" then
		os.execute("wine build/bin/sandbox.exe")
	else
		os.execute("./build/bin/sandbox")
	end
end)

eng.run()
