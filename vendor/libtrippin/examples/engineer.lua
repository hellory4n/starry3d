eng = require("libengineer")
eng.init()

local crapplication = eng.newproj("crapplication", "executable", "c99")
crapplication:pedantic()
crapplication:add_includes({"src"})
crapplication:add_srcs({"src/main.c", "src/something_else.c"})
crapplication:target("The_Crapplication™")

eng.option("platform", "Sets the platform it'll get compiled to", function(val)
	print("Building for "..val)
end)

eng.recipe("build", "Builds the project", function()
	crapplication:build()
end)

eng.recipe("clean", "Cleans the project", function()
	crapplication:clean()
end)

eng.recipe("run", "Runs the project", function()
	eng.run_recipe("build")
	os.execute("./build/bin/The_Crapplication™")
end)

eng.run()
