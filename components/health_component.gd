extends Node2D
class_name HealthComponent

signal die
@export var health: int = 1
	
func take_damage(damage: int):
	health -= damage 
	
	if health <= 0:
		emit_signal("die")
	
