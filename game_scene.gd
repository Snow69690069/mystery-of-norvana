extends Node2D

signal levelup

@export var end_game_screen_packed: PackedScene
@export var pause_menu_packed: PackedScene
@export var buttons_packed: PackedScene

var total_enemies: int
var killed_enemies: int = 0
var active_buttons_ui: CanvasLayer = null # Add this line at the top!
var active_pause_menu: Control = null

func _ready() -> void:
	var enemy_array: Array = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemy_array.size()
	print("works total number of enemy: ", total_enemies)
	if total_enemies == 0:
		print("enemies not found")
		return
	for i in enemy_array:
		i.died.connect(enemy_died)
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	levelup.connect(player.calculate_stats)
	player.game_over.connect(display_end_game_screen)
	if buttons_packed:
		active_buttons_ui = buttons_packed.instantiate()
		add_child(active_buttons_ui)
		active_buttons_ui.menu.connect(_on_menu_button_pressed)


# === PASTE THIS AS ITS OWN SEPARATE FUNCTION AT THE BOTTOM OF THE SCRIPT ===
func _on_menu_button_pressed(origin: String) -> void:
	if origin == "pause_menu":
		display_pause_menu()


func enemy_died(exp_reward: int) -> void:
	killed_enemies += 1
	experience_gained(exp_reward)
	if killed_enemies == total_enemies:
		display_end_game_screen(true)
		
	



func experience_gained(exp_gain: int) -> void:
	print("exp gained called: ", exp_gain)        # is this firing?
	print("current level: ", PlayerData.level)    # is level 0? 
	print("current exp: ", PlayerData.experience) # what's the state?

	if PlayerData.level == LevelData.MAX_LEVEL:
		return
	var new_experience: int = PlayerData.experience + exp_gain
	if new_experience >= LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]:
		level_up(new_experience)
	else:
		PlayerData.experience = new_experience


func level_up(new_experience: int) -> void:
	print("yay, I got more powerful")
	new_experience -= LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]
	PlayerData.level += 1
	PlayerData.experience = new_experience
	levelup.emit()


func display_end_game_screen(victorious: bool) -> void:
	get_tree().get_first_node_in_group("hud").visible = false
	if active_buttons_ui:
		active_buttons_ui.visible = false
	var end_game_screen_scene: Control = end_game_screen_packed.instantiate()
	end_game_screen_scene.victorious = victorious
	
	var scene_handler: Node = get_node("/root/SceneHandler")
	end_game_screen_scene.repeat_level.connect(scene_handler.new_game)
	end_game_screen_scene.main_menu.connect(scene_handler.load_main_menu)
	$UI.add_child(end_game_screen_scene)
	
	await get_tree().create_timer(0.9).timeout
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	player.set_process_mode(PROCESS_MODE_DISABLED)
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	for i: CharacterBody2D in enemies:
		i.set_process_mode(PROCESS_MODE_DISABLED)
	
	
	
	
	
func display_pause_menu() -> void:
	get_tree().get_first_node_in_group("hud").visible = false
	if active_buttons_ui:
		active_buttons_ui.visible = false
	active_pause_menu = pause_menu_packed.instantiate()
	#var buttons_scene: Control = buttons_packed.instantiate()
	$UI.add_child(active_pause_menu)
	
	var scene_handler: Node = get_node("/root/SceneHandler")
	
	active_pause_menu.resume.connect(_on_resume_pressed)
	active_pause_menu.main_menu.connect(scene_handler.load_main_menu)
	active_pause_menu.settings.connect(scene_handler.setting_open)
	active_pause_menu.exit.connect(scene_handler.exit_game)
	
	get_tree().paused = true
	
	
	
func _on_resume_pressed(origin: String) -> void:
	if origin == "pause_menu" :
		get_tree().paused = false
		
		
		if active_pause_menu:
			active_pause_menu.queue_free()
			active_pause_menu = null
			
			
		
		get_tree().get_first_node_in_group("hud").visible = true
		if active_buttons_ui:
			active_buttons_ui.visible = true
