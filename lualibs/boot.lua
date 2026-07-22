-- first lua script loaded by starry

-- fix require()
package.path = string.format("%s;%s/?.lua", package.path, app.dir())
