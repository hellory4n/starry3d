local Test = require("testrunner")

function app_init()
	require("tmath")
	Test.run_all()
end
