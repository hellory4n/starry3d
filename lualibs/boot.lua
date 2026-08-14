-- fix require(), loadfile(), dofile()
package.path = string.format("%s;%s/?.lua", package.path, app.dir())

local old_loadfile = loadfile
function loadfile(filename, mode, env)
	return old_loadfile(app.dir() .. "/" .. filename, mode, env)
end

local old_dofile = dofile
function dofile(filename)
	return old_dofile(app.dir() .. "/" .. filename)
end
