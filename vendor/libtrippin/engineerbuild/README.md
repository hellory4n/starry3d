# Engineer™

Got so annoyed at Make that I made my own build system.

This works by pretty much just being Make, but in Lua. (no esoteric language)

All of the C files are just for testing, they're not part of Engineer™

## Features

- No esoteric language
- Only external dependency is lua
- You can specify options and stuff
- You can control the entire build process
- Incremental builds
- Support for clangd's `compile_commands.json`

## Limitations

- Linux only
- GCC/Clang only
- You probably can't use a massive IDE with it
- It's made by some random guy

## Usage

You need 3 files, `libengineer.lua`, `engineer`, and `engineer.lua` where your build script is.

Put these are the beginning and end:

```lua
eng = require("libengineer")
eng.init()

-- your crap goes here

eng.run()
```

First you need commands. Engineer has recipes, which are subcommands, and options, which are options.

```lua
eng.option("platform", "Sets the platform it'll get compiled to", function(val)
    print("Building for "..val)
end)

eng.recipe("build", "Builds the project", function()
    print("Building the handsome project...")
end)
```

Conveniently Engineer provides a default "help" recipe:

```plaintext
$ ./engineer
Engineer v1.0.0

Recipes:
- build:        Builds the project
- help:         Shows what you're seeing right now

Options: (usage: <option>=<value>)
- platform:     Sets the platform it'll get compiled to
```

Now to actually do something useful you can use projects:

```lua
-- name, type (executable, sharedlib, staticlib), standard
local crapplication = eng.newproj("crapplication", "executable", "c99")
-- configured with methods
crapplication:pedantic()
crapplication:add_includes({"src"})
crapplication:add_srcs({"src/main.c", "src/something_else.c"})
crapplication:target("The_Crapplication™")
```

It doesn't do anything until you build it:

```lua
eng.recipe("build", "Builds the project", function()
    crapplication:build()
end)
```

Additional recipes you can have:

```lua
eng.recipe("clean", "Cleans the project", function()
    crapplication:clean()
end)

eng.recipe("run", "Runs the project", function()
    eng.run_recipe("build")
    os.execute("./build/bin/The_Crapplication™")
end)
```

Full sample:

```lua
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
```

## FAQ

### Isn't that just Premake?

No they're quite different, the only thing in common is Lua.

### Have you tried \[build system] you fucking moron?

No fuck off.

## Cheatsheet

I sure love documentation.

```lua
--[[
    MAIN LIBRARY
]]

-- Initializes engineer™
function eng.init()

-- Makes a recipe. The callback will be called when the recipe is used. The description will
-- be used for the default help recipe.
function eng.recipe(name: string, description: string, callback: function)

-- Adds an option. The callback takes in whatever value the option has (string), and is only
-- called if that option is used. The description will be used for the default help recipe.
function eng.option(name: string, description: string, callback: function)

-- Put this at the end of your build script so it actually does something
function eng.run()

-- Forces a recipe to run
function eng.run_recipe(recipe: string)

--[[
    PROJECTS
]]

-- Creates a new project. The type can be either "executable", "sharedlib", or "staticlib".
-- The standard is all lowercase, e.g. c99, c++11
function eng.newproj(name: string, type: string, std: string): project

-- Adds compile flags to the project. It's recommended to use project methods instead of
-- manually adding flags wherever possible.
function project:add_cflags(cflags: string)

-- Adds linker flags to the project. It's recommended to use project methods instead of
-- manually adding flags wherever possible.
function project:add_ldflags(ldflags: string)

-- Links multiple libraries to the project (it's a list). This shouldn't have any prefixes/
-- suffixes, so for example use "trippin" instead of "libtrippin", "trippin.dll",
-- "libtrippin.a", etc
function project:link(libs: string[])

-- Adds multiple source files to the project (it's a list).
function project:add_sources(srcs: string[])

-- Adds multiple include directories to the project (it's a list).
function project:add_includes(incs: string[])

-- Sets the project's target. e.g. crapplication.exe, libfaffery.so, etc
function project:target(target: string)

-- Adds common flags to make the compiler more obnoxious
function project:pedantic()

-- Enables debug info
function project:debug()

-- Sets the optimization level, from 0 (no optimization) to 3 (max optimization)
function project:optimization(level: integer)

-- Adds multiple defines (it's a list) to the project
function project:define(defines: string[])

-- Returns a list of source files that changed. Internal utility for incremental builds to
-- work.
function project:get_changed_files(): string[]

-- Builds and links the entire project
function project:build()

-- As the name implies, it cleans the project
function project:clean()

-- Generates a compile_commands.json file for clangd to use
function project:gen_compile_commands()

--[[
    UTILITY LIBRARY
]]

-- Runs a command with no output
function eng.util.silentexec(command: string)

-- Prints a table for debugging. This entire function is stolen.
function eng.util.print_table(node: table)

-- Does exactly what the name says.
function eng.util.endswith(str: string, suffix: string): bool

-- As the name implies, it gets a file's checksum.
function eng.util.get_checksum(file: string): string
```
