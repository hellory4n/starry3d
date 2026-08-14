local Test = require("testrunner")

function app.on_init()
	dofile("math.lua")
	Test.run_all()
end
