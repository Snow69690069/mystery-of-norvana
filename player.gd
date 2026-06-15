extends CharacterBody2D

signal game_over(victorious: bool)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_damage: int= 60
@export var hitpoints: int = 150


var state: State = State.IDLE
var move_direction: Vector2 = Vector2(0,0)
var attack_speed: float

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]


func _ready() -> void:
	animation_tree.set_active(true)
	calculate_stats()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack()
		

func _physics_process(_delta: float) -> void:
	if not state == State.ATTACK:
		movment_loop()
		
		

func calculate_stats() -> void:
	attack_speed = Equations.calculate_attack_speed()
	var time_factor: float = Equations.BASE_ATTACK_SPEED / attack_speed
	animation_tree.set("parameters/attack/TimeScale/scale", time_factor)
	print("my new attack speed: ", attack_speed)

func movment_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	
	if state == State.IDLE or State.RUN:
		if move_direction.x < -0.01:
			$sprite2D.flip_h = true
		elif move_direction.x > 0.1:
			$sprite2D.flip_h = false

	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")


func attack() -> void:
	#
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	#
	var attack_dir: Vector2
	if move_direction != Vector2.ZERO:
		attack_dir = move_direction.normalized()
	else:
		attack_dir = Vector2(-1,0) if $sprite2D.flip_h else Vector2(1,0)
	$sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	#
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	update_animation()

func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()


func death() -> void:
	print("I died")
	game_over.emit(false)
	

func _on_hitbox_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)
	print("Entered")
