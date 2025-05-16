--[[
	Engineer v1.0.2

	Bestest build system ever
	More information at https://github.com/hellory4n/libtrippin/tree/main/engineerbuild

	Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>

	Permission to use, copy, modify, and/or distribute this
	software for any purpose with or without fee is hereby
	granted.

	THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
	ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
	EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
	INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
	WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
	WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
	USE OR PERFORMANCE OF THIS SOFTWARE.
]]

-- bestest build system ever
eng = {
	-- why?
	util = {},
	-- C compiler
	cc = "",
	-- C++ compiler
	cxx = "",

	-- Table of strings with functions (no arguments, no returns)
	recipes = {},
	-- Table of strings and more strings
	recipe_description = {},
	-- Table of strings with functions (no arguments, no returns)
	options = {},
	-- Table of strings and more strings
	option_description = {},

	-- constants
	CONSOLE_COLOR_RESET = "\27[0m",
	CONSOLE_COLOR_LIB = "\27[0;90m",
	CONSOLE_COLOR_BLUE = "\27[0;34m",
	CONSOLE_COLOR_WARN = "\27[0;93m",
	CONSOLE_COLOR_ERROR = "\27[0;91m",
}

-- Runs a command with no output
function eng.util.silentexec(command)
	-- TODO this will definitely break at some point
	return os.execute(command.." > /dev/null 2>&1")
end

-- Prints a table for debugging. This entire function is stolen.
function eng.util.print_table(node)
	local cache, stack, output = {},{},{}
	local depth = 1
	local output_str = "{\n"

	while true do
		local size = 0
		for k,v in pairs(node) do
			size = size + 1
		end

		local cur_index = 1
		for k,v in pairs(node) do
			if (cache[node] == nil) or (cur_index >= cache[node]) then

				if (string.find(output_str,"}",output_str:len())) then
					output_str = output_str..",\n"
				elseif not (string.find(output_str,"\n",output_str:len())) then
					output_str = output_str.."\n"
				end

				-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
				table.insert(output,output_str)
				output_str = ""

				local key
				if (type(k) == "number" or type(k) == "boolean") then
					key = "["..tostring(k).."]"
				else
					key = "['"..tostring(k).."']"
				end

				if (type(v) == "number" or type(v) == "boolean") then
					output_str = output_str..string.rep('\t',depth)..key.." = "..tostring(v)
				elseif (type(v) == "table") then
					output_str = output_str..string.rep('\t',depth)..key.." = {\n"
					table.insert(stack,node)
					table.insert(stack,v)
					cache[node] = cur_index+1
					break
				else
					output_str = output_str..string.rep('\t',depth)..eng.CONSOLE_COLOR_RESET..key..eng.CONSOLE_COLOR_RESET.." = '"..tostring(v).."'"
				end

				if (cur_index == size) then
					output_str = output_str.."\n"..string.rep('\t',depth-1).."}"
				else
					output_str = output_str..","
				end
			else
				-- close the table
				if (cur_index == size) then
					output_str = output_str.."\n"..string.rep('\t',depth-1).."}"
				end
			end

			cur_index = cur_index + 1
		end

		if (size == 0) then
			output_str = output_str.."\n"..string.rep('\t',depth-1).."}"
		end

		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
			depth = cache[node] == nil and depth + 1 or depth - 1
		else
			break
		end
	end

	-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
	table.insert(output,output_str)
	output_str = table.concat(output)

	print(output_str)
end

function eng.util.endswith(str, suffix)
	return str:sub(-#suffix) == suffix
end

-- As the name implies, it gets a file's checksum.
function eng.util.get_checksum(file)
	local fh = assert(io.popen("sha256sum "..file, "r"))
	local out = fh:read("*a")
	fh:close()
	-- take only the hex faffery
	return out:match("^(%S+)")
end

-- Initializes engineer™
function eng.init()
	-- get c compiler
	local cc = os.getenv("CC")
	if cc ~= nil and cc ~= "" then
		eng.cc = cc
	else
		if eng.util.silentexec("command -v clang") then
			eng.cc = "clang"
		elseif eng.util.silentexec("command -v gcc") then
			eng.cc = "gcc"
		else
			error(eng.CONSOLE_COLOR_ERROR ..
				"no C compiler found. please install gcc or clang, and make sure it's in the PATH" ..
				eng.CONSOLE_COLOR_RESET)
		end
	end

	-- get c++ compiler
	local cxx = os.getenv("CXX") or os.getenv("CPP")
	if cxx ~= nil and cxx ~= "" then
		eng.cxx = cxx
	else
		if eng.util.silentexec("command -v clang++") then
			eng.cxx = "clang++"
		elseif eng.util.silentexec("command -v g++") then
			eng.cxx = "g++"
		else
			error(eng.CONSOLE_COLOR_ERROR ..
				"no C++ compiler found. please install gcc or clang, and make sure it's in the PATH" ..
				eng.CONSOLE_COLOR_RESET)
		end
	end

	-- default help recipe
	eng.recipe("help", "Shows what you're seeing right now", function()
		print("Engineer v1.0.0\n")
		print("Recipes:")

		-- some sorting lamo
		local rkeys = {}
		for recipe, _ in pairs(eng.recipe_description) do
			table.insert(rkeys, recipe)
		end
		table.sort(rkeys)

		-- actually list the shitfuck
		for _, recipe in ipairs(rkeys) do
			print(string.format("%-16s", "- "..recipe..": ")..eng.recipe_description[recipe])
		end

		-- mate
		print("\nOptions: (usage: <option>=<value>)")
		local okeys = {}
		for option, _ in pairs(eng.option_description) do
			table.insert(okeys, option)
		end
		table.sort(okeys)

		for _, option in ipairs(okeys) do
			print(string.format("%-16s", "- "..option..": ")..eng.option_description[option])
		end
	end)
end

-- Makes a recipe. The callback will be called when the recipe is used. The description will be used for
-- the default help recipe.
function eng.recipe(name, description, callback)
	eng.recipes[name] = callback
	eng.recipe_description[name] = description
end

-- Adds an option. The callback takes in whatever value the option has (string), and is only called
-- if that option is used. The description will be used for the default help recipe.
function eng.option(name, description, callback)
	eng.options[name] = callback
	eng.option_description[name] = description
end

-- Put this at the end of your build script so it actually does something
function eng.run()
	-- if theres no arguments just show the help crap
	if #arg == 0 then
		eng.recipes["help"]()
		return
	end

	local opts = {}
	local recipes = {}

	for _, argma in ipairs(arg) do
		local key, val = argma:match("^([%w%-_]+)=?(%S*)$")
		-- man.
		if key == "" then key = nil end
		if val == "" then val = nil end

		-- we have to sort options and recipes so options are set before recipes
		if key and val then
			table.insert(opts, {key = key, val = val})
		elseif key then
			table.insert(recipes, key)
		end
	end

	for _, mate in ipairs(opts) do
		if eng.options[mate.key] ~= nil then
			eng.options[mate.key](mate.val)
		else
			print(eng.CONSOLE_COLOR_WARN.."unknown option \""..mate.key.."\""..eng.CONSOLE_COLOR_RESET)
		end
	end

	for _, recipema in ipairs(recipes) do
		if eng.recipes[recipema] ~= nil then
			eng.recipes[recipema]()
		else
			print(eng.CONSOLE_COLOR_WARN.."unknown recipe \""..recipema.."\""..eng.CONSOLE_COLOR_RESET)
		end
	end
end

-- Forces a recipe to run
function eng.run_recipe(recipe)
	eng.recipes[recipe]()
end

-- project metatable
local project_methods = {}
local project = {
	__index = project_methods,
}

-- Creates a new project. The type can be either "executable", "sharedlib", or "staticlib". The standard
-- is all lowercase, e.g. c99, c++11
function eng.newproj(name, type, std)
	assert(type == "executable" or type == "sharedlib" or type == "staticlib",
		eng.CONSOLE_COLOR_ERROR.."type must be executable, sharedlib, or staticlib"..eng.CONSOLE_COLOR_RESET)

	local t = setmetatable({}, project)
	t.name = name
	t.type = type
	t.builddir = "build"
	t.cflags = " -std="..std.." "
	-- so static and shared libraries just work :)
	t.ldflags = "-L. -L"..t.builddir.."/static -L"..t.builddir.."/bin -Wl,-rpath=. -Wl,-rpath=./build/bin "
	t.sources = {}
	t.targetma = name
	return t
end

-- Adds compile flags to the project. It's recommended to use project methods instead of manually adding
-- flags wherever possible.
function project_methods.add_cflags(proj, cflags)
	proj.cflags = proj.cflags.." "..cflags
end

-- Adds linker flags to the project. It's recommended to use project methods instead of manually adding
-- flags wherever possible.
function project_methods.add_ldflags(proj, ldflags)
	proj.ldflags = proj.ldflags.." "..ldflags
end

-- Links multiple libraries to the project (it's a list). This shouldn't have any prefixes/suffixes, so
-- for example use "trippin" instead of "libtrippin", "trippin.dll", "libtrippin.a", etc
function project_methods.link(proj, libs)
	for _, lib in ipairs(libs) do
		proj.ldflags = proj.ldflags.." -l"..lib.." "
	end
end

-- Adds multiple source files to the project (it's a list).
function project_methods.add_sources(proj, srcs)
	for _, src in ipairs(srcs) do
		table.insert(proj.sources, src)
	end
end

-- Adds multiple include directories to the project (it's a list).
function project_methods.add_includes(proj, incs)
	for _, inc in ipairs(incs) do
		proj.cflags = proj.cflags.." -I"..inc.." "
	end
end

-- Sets the project's build directory. By default this is "build"
--function project_methods.build_dir(proj, dir)
--	proj.build_dir = dir
--	proj.ldflags = proj.ldflags.."-L"..proj.builddir.."/static -L"..proj.builddir.."/bin"
--end

-- Sets the project's target. e.g. crapplication.exe, libfaffery.so, etc
function project_methods.target(proj, target)
	proj.targetma = target
end

-- Adds common flags to make the compiler more obnoxious
function project_methods.pedantic(proj)
	proj.cflags = proj.cflags.." -Werror -Wall -Wextra "
end

-- Enables debug info
function project_methods.debug(proj)
	proj.cflags = proj.cflags.." -g "
end

-- Sets the optimization level, from 0 (no optimization) to 3 (max optimization)
function project_methods.optimization(proj, level)
	if level == 0 then proj.cflags = proj.cflags.." -O0 "
	elseif level == 1 then proj.cflags = proj.cflags.." -O1 "
	elseif level == 2 then proj.cflags = proj.cflags.." -O2 "
	elseif level == 3 then proj.cflags = proj.cflags.." -O3 "
	else error(eng.CONSOLE_COLOR_ERROR.."you bloody scoundrel that's not a valid level"..eng.CONSOLE_COLOR_RESET) end
end

-- Adds multiple defines (it's a list) to the project
function project_methods.define(proj, defines)
	for _, def in ipairs(defines) do
		proj.cflags = proj.cflags.." -D"..def.." "
	end
end

-- Returns a list of source files that changed.
function project_methods.get_changed_files(proj)
	local cachepath = proj.builddir.."/"..proj.name..".cache"

	-- parse old cache
	local old = {}
	do
		local f = io.open(cachepath, "r")
		if f then
		for line in f:lines() do
			local sep = line:find("=")
			if sep then
			local src = line:sub(1, sep-1)
			local sum = line:sub(sep+1)
			old[src] = sum
			end
		end
		f:close()
		end
	end

	-- check if anything changed
	local changed = {}
	local newcache = {}

	for _, src in ipairs(proj.sources) do
		local newsum = eng.util.get_checksum(src)
		table.insert(newcache, src.."="..newsum)
		if old[src] ~= newsum then
		table.insert(changed, src)
		end
	end

	-- make a new cache
	local f, err = io.open(cachepath, "w")
	assert(f, err)
	f:write(table.concat(newcache, "\n"), "\n")
	f:close()

	-- if there was no old cache then everythings new
	if next(old) == nil then
		return proj.sources
	end

	return changed
end

-- Builds and links the entire project
function project_methods.build(proj)
	print("Compiling "..proj.name.." with "..eng.cc.."/"..eng.cxx)

	-- folder? i hardly know 'er!
	eng.util.silentexec("mkdir "..proj.builddir)
	eng.util.silentexec("mkdir "..proj.builddir.."/obj")
	eng.util.silentexec("mkdir "..proj.builddir.."/static")
	eng.util.silentexec("mkdir "..proj.builddir.."/bin")

	-- compile the bloody files
	local objs = {}
	local srcs = proj:get_changed_files()
	-- na
	if #srcs == 0 then
		print(proj.name.." is already up to date; nothing to do")
		return
	end

	for i, src in ipairs(srcs) do
		-- i appreciate c++
		local compiler = ""
		if eng.util.endswith(src, ".c") then
			compiler = eng.cc
		elseif eng.util.endswith(src, ".cpp") or eng.util.endswith(src, ".cc") or
		eng.util.endswith(src, ".cxx") or eng.util.endswith(src, ".c++") then
			compiler = eng.cxx
		else
			print(eng.CONSOLE_COLOR_WARN.."unexpected extension in "..src..", using "..eng.cc..eng.CONSOLE_COLOR_RESET)
			compiler = eng.cc
		end

		local obj = proj.builddir.."/obj/"..src:gsub("/", "_")..".o"
		-- pretty output
		print(eng.CONSOLE_COLOR_BLUE.."["..i.."/"..#srcs.."] "..src..eng.CONSOLE_COLOR_RESET)

		-- compile frfrfr ong no cap ngl tbh
		if proj.type == "sharedlib" then
			proj.cflags = proj.cflags.." -fPIC"
		end
		local success = os.execute(compiler..proj.cflags.." -o "..obj.." -c "..src)
		if not success then
			error(eng.CONSOLE_COLOR_ERROR.."compiling "..src.." failed"..eng.CONSOLE_COLOR_RESET)
		end
		table.insert(objs, obj)
	end

	-- link :)
	-- first get the object files
	local objma = ""
	for _, src in ipairs(proj.sources) do
		objma = objma..proj.builddir.."/obj/"..src:gsub("/", "_")..".o "
	end

	-- link executable
	if proj.type == "executable" then
		print("Linking "..proj.name)
		local success = os.execute(
			-- the ldflags must come last lamo
			eng.cc.." "..objma.." -o "..proj.builddir.."/bin/"..proj.targetma.." "..proj.ldflags
		)
		if not success then
			error(eng.CONSOLE_COLOR_ERROR.."linking "..proj.name.." failed"..eng.CONSOLE_COLOR_RESET)
		end
	end

	-- link static library
	if proj.type == "staticlib" then
		print("Linking "..proj.name)
		os.execute("ar rcs "..proj.builddir.."/static/"..proj.targetma.." "..objma)
	end

	-- link shared library
	if proj.type == "sharedlib" then
		local success = os.execute(
			-- the ldflags must come last lamo
			eng.cc.." -shared "..objma.." -o "..proj.builddir.."/bin/"..proj.targetma.." "..proj.ldflags
		)
		if not success then
			error(eng.CONSOLE_COLOR_ERROR.."linking "..proj.name.." failed"..eng.CONSOLE_COLOR_RESET)
		end
	end

	print("Built "..proj.name.." successfully")
end

-- As the name implies, it cleans the project
function project_methods.clean(proj)
	-- Scary!
	os.execute("rm -rf "..proj.builddir)
end

-- Generates a compile_commands.json file for clangd to use
function project_methods.gen_compile_commands(proj)
	-- i won't even bother making it formatted
	local commands = "["
	for i, src in ipairs(proj.sources) do
		commands = commands.."{"

		-- lua doesn't have a function to get the working directory
		local fh = assert(io.popen("pwd", "r"))
		-- there's a newline and it makes json crash and die
		local cwd = fh:read("*a"):sub(1, -2)
		fh:close()

		-- i appreciate c++
		local compiler = ""
		if eng.util.endswith(src, ".c") then
			compiler = eng.cc
		elseif eng.util.endswith(src, ".cpp") or eng.util.endswith(src, ".cc") or
		eng.util.endswith(src, ".cxx") or eng.util.endswith(src, ".c++") then
			compiler = eng.cxx
		else
			print(eng.CONSOLE_COLOR_WARN.."unexpected extension in "..src..", using "..eng.cc..eng.CONSOLE_COLOR_RESET)
			compiler = eng.cc
		end

		-- man
		local obj = proj.builddir.."/obj/"..src:gsub("/", "_")..".o"
		commands = commands.."\"directory\": \""..cwd.."\",\"file\": \""..cwd.."/"..src.."\", \"command\": \""
		commands = commands..compiler..proj.cflags.." -o "..obj.." -c "..src
		commands = commands.."\"}"

		-- why tf doesn't json support trailing commas
		if i < #proj.sources then
			commands = commands..","
		end
	end
	commands = commands.."]"

	-- mate
	local f = io.open("compile_commands.json", "w")
	assert(f)
	f:write(commands)
	f:close()
end

return eng
