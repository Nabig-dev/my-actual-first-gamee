class_name MessageDispatcherWrapper
extends Node








var _message_dispatcher = MessageDispatcher.new()


func connect_message(message_type: String, obj: Object, function: String) -> void :
	_message_dispatcher.connect_message(message_type, obj, function)



func disconnect_message(message_type: String, obj: Object, function: String) -> void :
	_message_dispatcher.disconnect_message(message_type, obj, function)



func disconnect_all_message() -> void :
	_message_dispatcher.disconnect_all_message()



func emit_message(message_type: String, message_data: Dictionary) -> bool:
	return _message_dispatcher.emit_message(message_type, message_data)
