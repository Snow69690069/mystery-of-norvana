extends Node

@export var main_menu_packed: PackedScene
@export var game_scene_packed: PackedScene
@export var buttons_scene_packed: PackedScene

func _enter_tree() -> void:
	load_main_menu("game_start")


func load_main_menu(origin: String) -> void:
	get_tree().paused = false
	if origin == "end_game_screen" or origin == "pause_menu":
		get_node("GameScene").queue_free()
		await get_tree().process_frame
		
		
	var main_menu: Control = main_menu_packed.instantiate()
	main_menu.new_game_pressed.connect(new_game)
	main_menu.settings_pressed.connect(setting_open)
	main_menu.about_pressed.connect(about_open)
	main_menu.exit_pressed.connect(exit_game)
	add_child(main_menu)


func new_game(origin: String) -> void:
	print("new_game called, scene: ", game_scene_packed)
	print("game_scene children: ")
	if origin == "main_menu":
		get_tree().paused = false
		get_node("MainMenu").queue_free()
	if origin == "end_game_screen":
		get_tree().paused = false
		get_node("GameScene").queue_free()
		await get_tree().process_frame
	var game_scene: Node2D = game_scene_packed.instantiate()
	add_child(game_scene)
	print("GameScene added, children count: ", game_scene.get_child_count())
	for child in game_scene.get_children():
		print("  - ", child.name)
	print("current level: ", PlayerData.level)    # is level 0? 
	print("current exp: ", PlayerData.experience) # what's the state?
	
	
func setting_open(_origin: String) -> void:
	#
	pass


func about_open(_origin: String) -> void:
	#
	pass


func exit_game(_origin: String) -> void:
	get_tree().quit()


func resume_game(_origin: String) -> void:
	# 1. Show the gameplay HUD again
	get_tree().get_first_node_in_group("hud").visible = true
