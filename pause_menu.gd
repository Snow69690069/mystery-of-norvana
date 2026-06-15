extends Control

signal resume(origin: String)
signal settings(origin: String)
signal main_menu(origin: String)
signal exit(origin: String)


func _ready() -> void:
	pass
	


func _on_resume_pressed() -> void:
	resume.emit("pause_menu")



func _on_settings_pressed() -> void:
	settings.emit("pause_menu")


func _on_main_menu_pressed() -> void:
	main_menu.emit("pause_menu")


func _on_exit_pressed() -> void:
	exit.emit("pause_menu")
	print("Ola")
