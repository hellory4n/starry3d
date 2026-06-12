package starrylib

// It's like a callback, but with more of them.
Signal :: struct($Payload: typeid) {
	listeners: [dynamic]Signal_Listener(Payload),
}

@(private)
Signal_Listener :: struct($Payload: typeid) {
	callback:  proc(userdata: rawptr, payload: Payload),
	user_data: rawptr,
}

new_signal :: proc($Payload: typeid, allocator := context.allocator) -> (signal: Signal(Payload))
{
	signal.listeners = make([dynamic]Signal_Listener(Payload), allocator)
	return
}

free_signal :: proc(signal: ^$T/Signal)
{
	delete(signal.listeners)
}

connect_to_signal :: proc(
	signal: ^$T/Signal($Payload),
	callback: proc(userdata: rawptr, payload: Payload),
	user_data: rawptr = nil,
)
{
	append(
		&signal.listeners,
		Signal_Listener(Payload){callback = callback, user_data = user_data},
	)
}

emit_signal :: proc(signal: ^$T/Signal($Payload), payload: Payload)
{
	for listener in signal.listeners {
		listener.callback(listener.user_data, payload)
	}
}
