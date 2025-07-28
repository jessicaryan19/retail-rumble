extends Node2D
class_name HealthComponent

signal die


@export var MAX_HEALTH: int = 3
@export var health: int = 1:
	get:
		return health
	set(value):
		health = value
		handle_die()
		
func _ready() -> void:
	health = MAX_HEALTH
	
func take_damage(damage: int):
	health -= damage 
	
	handle_die()
	
func handle_die():
	if health <= 0:
		emit_signal("die")
