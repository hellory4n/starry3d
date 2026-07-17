package studio

global: struct {
	project_dir: string,
	popups:      struct {
		about:           bool,
		project_manager: bool,
	},
}

is_project_loaded :: proc() -> bool
{
	return len(global.project_dir) > 0
}
