extends CharacterBody2D

@export var MAX_SPEED: float = 600.0
@export var ACCELERATION: float = 800.0
@export var DECCELERATION: float = 1200.0

var accel_time := 0.0
var deccel_time := 0.0
@export var ACCEL_TIME_TO_MAX := 0.3
@export var DECCEL_TIME_TO_STOP := 0.3

@export var ACCELERATION_CURVE: Curve
@export var DECCELERATION_CURVE: Curve

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent

func _process(delta: float) -> void:
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		change_animation("move")
	else:
		change_animation("idle")
		
func _physics_process(delta: float) -> void:
	var input_direction = get_input_direction()
	var target_vel = input_direction * MAX_SPEED
	
	if input_direction != Vector2.ZERO:
		accel_time = min(accel_time + delta, ACCEL_TIME_TO_MAX)
		deccel_time = 0.0
		var t = accel_time / ACCEL_TIME_TO_MAX
		var curve_factor = ACCELERATION_CURVE.sample( clamp(t, 0.0, 1.0) )
		velocity = velocity.move_toward(target_vel, curve_factor * ACCELERATION * delta)
	else:
		deccel_time = min(deccel_time + delta, DECCEL_TIME_TO_STOP)
		accel_time = 0.0
		var t = deccel_time / DECCEL_TIME_TO_STOP
		var curve_factor = DECCELERATION_CURVE.sample( clamp(t, 0.0, 1.0) )
		velocity = velocity.move_toward(Vector2.ZERO, curve_factor * DECCELERATION * delta)
		
	move_and_slide()
		
func get_input_direction():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func change_animation(animation_name: String):
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func _on_hitbox_component_lose() -> void:
	print("lose")
	health_component.take_damage(1)


func _on_hitbox_component_win() -> void:
	print("win")
	
	
func _on_health_component_die() -> void:
	print("die")
