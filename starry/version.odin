package starry

VERSION_NUM :: 0_08_00
VERSION_MAJOR :: 0
VERSION_MINOR :: 8
VERSION_PATCH :: 0
VERSION_STR :: "v0.8.0"
AUTHORS :: "hellory4n"

EngineInfo :: struct {
	authors:       string,
	version_str:   string,
	version_num:   i64,
	version_major: i64,
	version_minor: i64,
	version_patch: i64,
}

// lua: `app.engine_info`
engine_info :: proc() -> EngineInfo
{
	return {
		authors = AUTHORS,
		version_str = VERSION_STR,
		version_num = VERSION_NUM,
		version_major = VERSION_MAJOR,
		version_minor = VERSION_MINOR,
		version_patch = VERSION_PATCH,
	}
}
