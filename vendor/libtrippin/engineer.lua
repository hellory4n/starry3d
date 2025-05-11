libtrippin = {}

local eng = require("engineerbuild.libengineer")
eng.init()

-- Returns the libtrippin project as a static library. Intended to be used for projects that use libtrippin.
-- Just link with "trippin" and build this before your own projects. `debug` is a bool. On linux you have to
-- link with "m" too. `trippinsrc` is where you put libtrippin.c
function libtrippin.lib(debug, trippinsrc)
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
local trippin = libtrippin.lib(false, "libtrippin.c")

-- example projects :(
local example_log = eng.newproj("example_log", "executable", "c99")
example_log:pedantic()
example_log:debug()
example_log:link({"trippin", "m"})
example_log:add_sources({"examples/log.c"})
example_log:add_includes({"..", "."})
example_log:gen_compile_commands() -- just one because it's pretty much the same

local example_math = eng.newproj("example_math", "executable", "c99")
example_math:pedantic()
example_math:debug()
example_math:link({"trippin", "m"})
example_math:add_sources({"examples/math.c"})
example_math:add_includes({"..", "."})

local example_slice_arenas = eng.newproj("example_slice_arenas", "executable", "c99")
example_slice_arenas:pedantic()
example_slice_arenas:debug()
example_slice_arenas:link({"trippin", "m"})
example_slice_arenas:add_sources({"examples/slice_arenas.c"})
example_slice_arenas:add_includes({"..", "."})

local example_vectors = eng.newproj("example_vectors", "executable", "c99")
example_vectors:pedantic()
example_vectors:debug()
example_vectors:link({"trippin", "m"})
example_vectors:add_sources({"examples/log.c"})
example_vectors:add_includes({"..", "."})

eng.option("debug", "true or false", function(val)
	if val == "true" then
		trippin:optimization(0)
		trippin:debug()
	end
end)

eng.recipe("build-lib", "Builds only the library", function()
	trippin:build()
end)

eng.recipe("build", "Builds the library and the examples", function()
	eng.run_recipe("build-lib")
	example_log:build()
	example_math:build()
	example_slice_arenas:build()
	example_vectors:build()
end)

eng.recipe("run-log", "Runs the log example", function()
	eng.run_recipe("build")
	os.execute("./build/bin/example_log")
end)

eng.recipe("run-math", "Runs the math example", function()
	eng.run_recipe("build")
	os.execute("./build/bin/example_math")
end)

eng.recipe("run-slice-arenas", "Runs the slice/arenas example", function()
	eng.run_recipe("build")
	os.execute("./build/bin/example_slice_arenas")
end)

eng.recipe("run-vectors", "Runs the vectors example", function()
	eng.run_recipe("build")
	os.execute("./build/bin/example_vectors")
end)

eng.recipe("clean", "Cleans the project", function()
	trippin:clean()
	example_log:clean()
	example_math:clean()
	example_slice_arenas:clean()
	example_vectors:clean()
end)

eng.run()

return libtrippin
