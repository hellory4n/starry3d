-- fix require()
package.path = string.format("%s;%s/?.lua", package.path, app.dir())

-- functions used by the preloaded library, but not by users
__st = {}
