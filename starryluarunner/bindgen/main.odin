package stbindgen

import "core:fmt"
import "core:odin/ast"
import "core:odin/parser"
import "core:strings"

main :: proc()
{
	bind_package(dir = "starrylib", func_prefix = "st")
}

// thanks to lua syntax we can put a prefix and it'll create the tables automatically,
// like `function prefix.name()`. prints the generated code (pipe it in the shell to save it)
bind_package :: proc(dir: string, func_prefix: string, allocator := context.allocator)
{
	p: parser.Parser
	pkg, ok := parser.parse_package_from_path(dir, &p)
	if !ok {
		fmt.eprintfln("stbindgen: couldn't parse package %q", dir)
	}

	for _, file in pkg.files {
		for decl in file.decls {
			#partial switch v in decl.derived {
			case ^ast.Value_Decl:
				bind_decl(v)
			}
		}
	}
}

bind_decl :: proc(decl: ^ast.Value_Decl)
{
	// TODO look for the @lua_export attribute
	for attr in decl.attributes {
	}
}
