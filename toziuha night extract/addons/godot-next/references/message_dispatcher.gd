class_name MessageDispatcher
extends Reference







var _message_handlers: = {}





func connect_message(message_type: String, obj: Object, function: String) -> void :
	assert (obj.has_method(function))
	if not _message_handlers.has(message_type):
		_message_handlers[message_type] = []

	_message_handlers[message_type].push_back([obj, function])






func disconnect_message(message_type: String, obj: Object, function: String) -> void :
	assert (_message_handlers[message_type] != null)
	_message_handlers[message_type].erase([obj, function])



func disconnect_all_message() -> void :
	_message_handlers = {}







func emit_message(message_type: String, message_data: Dictionary) -> bool:
	var handlers = _message_handlers[message_type]
	if handlers != null:
		var invalid = []
		for handler in handlers:
			if is_instance_valid(handler[0]):
				handler[0].call(handler[1], message_type, message_data)
			else:
				invalid.push_back(handler)

		for handler in invalid:
			handlers.erase(handler)

	return handlers != null and not handlers.empty()
