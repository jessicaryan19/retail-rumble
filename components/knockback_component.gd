extends Node2D
class_name KnockbackComponent

@export var KNOCKBACK_DURATION: float = 0.2
@export var KNOCKBACK_FORCE: float = 800.0

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0 

var parent_node: CharacterBody2D

func _ready() -> void:
	parent_node = get_parent()

func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		parent_node.velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO

func apply_knockback(direction: Vector2) -> void:
	knockback = direction * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_DURATION
