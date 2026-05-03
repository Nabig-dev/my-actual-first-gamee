



tool 
class_name DTS

var translations = {}


func _init():
	translations_initial_load()


func translate(message: String) -> String:
	var translation
	
	translation = _get_translation(message)
	
	return translation

func translations_initial_load():
	var translations_resources = ["en", "zh_CN", "es", "fr", "de"]
	translations = {}
	
	for resource in translations_resources:
		var t: PHashTranslation = load("res://addons/dialogic/Localization/dialogic." + resource + ".translation")
		if translations.has(t.locale):
			translations[t.locale].append(t)
		else:
			translations[t.locale] = [t]



func get_translations() -> Dictionary:
	return translations


func _get_translation(message) -> String:
	var returned_translation = message
	var default_fallback = "en"
	
	var editor_plugin = EditorPlugin.new()
	var editor_settings = editor_plugin.get_editor_interface().get_editor_settings()
	var locale = editor_settings.get("interface/editor/editor_language")
	
	var cases = translations.get(
		locale, 
		translations.get(default_fallback, [PHashTranslation.new()])
		)
	for case in cases:
		returned_translation = (case as PHashTranslation).get_message(message)
		if returned_translation:
			break
		else:
			
			returned_translation = message
	
	
	return returned_translation
