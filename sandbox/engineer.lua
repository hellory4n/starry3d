starry3d = require("starry3d")
eng = require("libengineer")
eng.init()

local projma = eng.newproj("sandbox", "executable", "c99")
projma:pedantic()

projma:add_includes({"src"})
projma:add_sources({
	"src/main.c"
})

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
	-- copy assets folder
	os.execute("mkdir -p build/bin/assets")
	os.execute("cp -r assets/* build/bin/assets")

	if debug then
		projma:debug()
		projma:optimization(0)
	else
		projma:optimization(2)
	end

	local starry3dma = starry3d.lib(debug, "..", platform)
	projma:add_includes(starry3dma.getincludes())
	projma:link(starry3dma.getlinks())

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
end)

eng.recipe("run", "Builds and runs the project", function()
	eng.run_recipe("build")
	print("") -- separation
	os.execute("./build/bin/sandbox")
end)

eng.run()
