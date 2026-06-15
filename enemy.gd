extends CharacterBody2D

@export_category("Stats")
@export var hitpoints:int = 180
@export_category("Related Scenes")
@export var death_packed: PackedScene


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()


func death() -> void:
	queue_free()
