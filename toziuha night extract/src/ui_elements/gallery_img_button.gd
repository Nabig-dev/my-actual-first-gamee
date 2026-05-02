extends TextureButton

signal selected(title, texture)

var node_idx: int

func _ready() -> void :
	modulate.a = 0.6
	focus_next = get_path()
	focus_previous = get_path()

func set_texture(textur: Texture) -> void :
	texture_normal = textur


func _on_GalleryImgButton_focus_entered() -> void :
	modulate.a = 1


func _on_GalleryImgButton_focus_exited() -> void :
	modulate.a = 0.6



func _on_GalleryImgButton_button_up() -> void :
	if has_focus() == true:
		emit_signal("selected", name, texture_normal)
