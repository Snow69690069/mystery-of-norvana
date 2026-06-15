extends CanvasLayer

signal menu(origin: String)



func _on_menu_pressed() -> void:
	menu.emit("pause_menu")


func _on_inventory_pressed() -> void:
	pass # Replace with function body.
