local Test = require("testrunner")

function app_init()
	require("mathext")
	Test.run_all()
end
