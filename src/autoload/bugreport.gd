extends PanelContainer

signal opened
signal closed

var cfg_path: = "res://webhook.cfg"
var _cfg: ConfigFile

var _texture_to_snd: Texture

var _prev_paused_value: bool

onready var _http: = $HTTPRequest

func _ready():
	
	get_parent().visible = false

	_cfg = ConfigFile.new()
	var err: = _cfg.load(cfg_path)
	if err != OK:
		push_error("Bugreporter couldn't load config. Reason: %s" % err)

	get_node("%BtnSend").disabled = true
	get_node("%TextureImgPreview").texture = null
	get_node("%BtnClearImg").visible = false

func _input(event: InputEvent) -> void :
	
	if Features.has("debug") == false:
		return
	
	if (
		event is InputEventKey
		and event.is_pressed()
		and (event.as_text() == "Control+Alt" or event.as_text() == "Alt+Control")
		and get_parent().visible == false
	):
		start_report()

func start_report() -> void :
	get_parent().visible = true
	get_node("%LnNickname").grab_focus()
	emit_signal("opened")
	_prev_paused_value = get_tree().paused
	get_tree().paused = true

func _check_enable_send_btn() -> void :
	var nickname_length: int = get_node("%LnNickname").text.length()
	var msg_length: int = _get_msg_length()
	
	if (
		nickname_length < 1
		or nickname_length > 100
		or msg_length < 5
		or msg_length > 700
	):
		get_node("%BtnSend").disabled = true
	else:
		get_node("%BtnSend").disabled = false

func _get_msg_length() -> int:
	return get_node("%TxtMsg").text.length()

func _on_BtnSend_pressed() -> void :
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	
	
	var color_msg: int = 2926009
	
	var msg_title: String
	
	
	if get_node("%OptType").selected == 0:
		color_msg = 15935762
		msg_title = "Bug Report"
	
	
	else:
		msg_title = "Feedback"
	
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	
	msg_title = "%s - %s/%s/%s %d:%d" % [
		msg_title, datetime["day"], datetime["month"], 
		datetime["year"], datetime["hour"], 
		datetime["minute"]
	]

	var request_body: = []
	var json_payload: = {
		"username": "%s:" % "Vampire Killer", 
		"tts": _cfg.get_value("webhook", "tts", false), 
	}
	var embed = {
			"title": "%s" % [msg_title], 
			"color": color_msg, 
		}
	var fields: = []
	
	fields.push_back({
		"name": "", 
		"value": "```%s```" % get_node("%TxtMsg").text
	})
	
	fields.push_back({
		"name": "Contact Info:", 
		"value": get_node("%LnNickname").text
	})

	fields.push_back({
		"name": "Device:", 
		"value": "CPU: %s\nGPUName: %s\nGPUVendor: %s\nDeviceName: %s\nOS: %s\nLang: %s\nScreenSize: %s\nScreenFreshRate: %s\n\n**%s**" % [
			OS.get_processor_name(), 
			VisualServer.get_video_adapter_name(), 
			VisualServer.get_video_adapter_vendor(), 
			OS.get_model_name(), 
			OS.get_name(), OS.get_locale(), 
			OS.get_screen_size(), OS.get_screen_refresh_rate(), 
			OS.get_unique_id()
		]
	})
	
	
	if get_node("%LnImgPath").text != "attachment://screenshot0.png":
		_texture_to_snd = FuncsFiles.create_texture_from_filepath(
			get_node("%LnImgPath").text
		)
	
	if _texture_to_snd != null:
		get_node("%BtnClearImg").visible = true
		get_node("%TextureImgPreview").texture = _texture_to_snd
		embed["image"] = {
			"url": "attachment://screenshot0.png", 
		}
		
		request_body.push_back(_texture_to_snd)
	
	
	

	embed["fields"] = fields
	json_payload["embeds"] = [embed]
	
	request_body.push_front(json_payload)
	var payload: = _array_to_form_data(request_body)
	
	if fields.empty():
		return
	
	_http.request(_cfg.get_value("webhook", "url", ""), 
			PoolStringArray(["connection: keep-alive", "Content-type: multipart/form-data; boundary=boundary"]), 
			true, 
			HTTPClient.METHOD_POST, 
			payload
	)
	



func _array_to_form_data(array: Array) -> String:
	










	var file_counter: = 0
	var output = ""
	
	
	for element in array:
		output += "--boundary\n"

		if element is Dictionary:
			output += "Content-Disposition: form-data; name=\"payload_json\"\nContent-Type: application/json\n\n"
			output += to_json(element) + "\n"

		elif element is Texture:
			output += "Content-Type: image/png; name=\"files[%s]\"\n" % file_counter
			output += "Content-Disposition: attachment; filename=\"screenshot%s.png\"\n" % file_counter
			output += "Content-Transfer-Encoding: base64\nX-Attachment-Id: f_ljiz6nfz0\nContent-ID: <f_ljiz6nfz0>"
			output += "\n\n"
			output += Marshalls.raw_to_base64(_texture_to_png_bytes(element)) + "\n"
			file_counter += 1
		






	
	output += "--boundary--"

	return output


func _texture_to_png_bytes(texture: Texture, max_size: = 8000000) -> PoolByteArray:
	var img: = texture.get_data()
	var bytes: PoolByteArray = img.save_png_to_buffer()
	
	while bytes.size() > max_size:
		
		
		img.resize(img.get_width() / 2, img.get_height() / 2)
		bytes = img.save_png_to_buffer()
	
	return bytes


func _on_BtnClose_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_parent().visible = false
	emit_signal("closed")
	get_tree().paused = _prev_paused_value


func _on_HTTPRequest_request_completed(result, response_code, _headers, _body) -> void :
	
	
	if (
		result == 0
		and response_code in [200, 204]
	):
		get_node("%TxtMsg").text = ""
		get_node("%LnImgPath").text = ""
		get_node("%BtnClearImg").visible = true
		_texture_to_snd = null
		get_node("%TextureImgPreview").texture = _texture_to_snd
		get_node("%BtnClearImg").visible = false
		_on_TxtMsg_text_changed()
		Notification.show_notif("Message Sended!")
		Audio.play_sfx("ui_success")
	
	
	else:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif(
			"Error with send: result:%d, response:%d"
			%[result, response_code]
		)

func _on_TxtMsg_text_changed() -> void :
	_check_enable_send_btn()
	var txt_lenght: int = _get_msg_length()
	
	if txt_lenght > 700:
		get_node("%LblCharLimit").modulate = Color.red
	else:
		get_node("%LblCharLimit").modulate = Color.white
	
	get_node("%LblCharLimit").text = "(%s)" % [str(700 - txt_lenght)]


func _on_LnNickname_text_changed(new_text: String) -> void :
	_check_enable_send_btn()
	var txt_lenght: int = new_text.length()
	
	if txt_lenght > 100:
		get_node("%LnNickname").modulate = Color.red
	else:
		get_node("%LnNickname").modulate = Color.white


func _on_BtnOpenImg_pressed() -> void :
	get_node("%NativeDialogOpenFile").show()
	Audio.play_sfx("ui_accept")


func _on_NativeDialogOpenFile_files_selected(files: PoolStringArray) -> void :
	
	if files.size() == 1:
		get_node("%LnImgPath").text = files[0]
		get_node("%TextureImgPreview").texture = FuncsFiles.create_texture_from_filepath(
			files[0]
		)
		get_node("%BtnClearImg").visible = true
	
	get_node("%NativeDialogOpenFile").hide()


func _on_BtnScreenshot_pressed() -> void :
	modulate.a = 0
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img: = get_viewport().get_texture().get_data()
	img.flip_y()
	var textur: = ImageTexture.new()
	textur.create_from_image(img)
	_texture_to_snd = textur
	get_node("%TextureImgPreview").texture = _texture_to_snd
	get_node("%BtnClearImg").visible = true
	Audio.play_sfx("ui_accept")
	get_node("%LnImgPath").text = "attachment://screenshot0.png"
	modulate.a = 1


func _on_BtnClearImg_pressed() -> void :
	get_node("%LnImgPath").text = ""
	get_node("%TextureImgPreview").texture = null
	_texture_to_snd = null
	get_node("%BtnClearImg").visible = false
	Audio.play_sfx("ui_cancel")
