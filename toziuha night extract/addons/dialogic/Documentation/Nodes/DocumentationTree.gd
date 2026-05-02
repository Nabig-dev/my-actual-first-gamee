tool 
extends Tree

var documentation_tree


signal _page_selected(path)





func select_item(path):
	
	pass





func _ready():
	connect("item_selected", self, "_on_item_selected")
	
	
	documentation_tree.set_icon(0, get_icon("Folder", "EditorIcons"))
	

func _on_item_selected():
	var item = get_selected()
	var metadata = item.get_metadata(0)
	if metadata.has("path"):
		emit_signal("_page_selected", metadata["path"])
