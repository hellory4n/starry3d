local Test = require("testrunner")

function app.on_init()
	require("mathext")
	Test.run_all()
end
