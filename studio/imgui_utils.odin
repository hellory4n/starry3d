package studio

import im "../thirdparty/imgui"

open_url :: proc(url: cstring)
{
	// this is what im.TextLinkOpenURL calls internally
	g := im.GetCurrentContext()
	g.PlatformIO.Platform_OpenInShellFn(g, url)
}
