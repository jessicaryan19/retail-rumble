extends CharacterBody2D

enum PlayerState {
	NORMAL,
	POSE,
	INVINCIBLE,
	DIE
}

@onready var pose_timer: Timer = $PoseTimer
@onready var invincible_timer: Timer = $InvincibleTimer

var state: PlayerState = PlayerState.NORMAL:
	get: 
		return state
	set(value):
		
		if state==value: return
		if state==PlayerState.DIE: return
		
		state = value
		
		match (value):
			PlayerState.NORMAL:
				body.animation = "normal"
			
			PlayerState.POSE:
				pose_timer.start()
				body.animation = "pose"
				body.frame = randi() % body.sprite_frames.get_frame_count("pose")
				hitbox_component.get_node("CollisionShape2D").disabled = true
				
			PlayerState.INVINCIBLE:
				invincible_timer.start()
				body.animation = "hurt"
				hitbox_component.get_node("CollisionShape2D").disabled = true
			
			PlayerState.DIE:
				body.animation = "hurt"
				hitbox_component.get_node("CollisionShape2D").disabled = true
		
		

@export var MAX_SPEED: float = 600.0
@export var ACCELERATION: float = 800.0
@export var DECCELERATION: float = 1200.0

var accel_time := 0.0
var deccel_time := 0.0

@export var ACCEL_TIME_TO_MAX := 0.3
@export var DECCEL_TIME_TO_STOP := 0.3

@export var ACCELERATION_CURVE: Curve
@export var DECCELERATION_CURVE: Curve

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var rps_component: RPSComponent = $RPSComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var head: AnimatedSprite2D = $Sprite/Head
@onready var body: AnimatedSprite2D = $Sprite/Body
	
func _process(delta: float) -> void:
	handle_anim()
	
	if state == PlayerState.NORMAL:
		handle_rps()
		set_hitbox_component_target()
	elif state == PlayerState.POSE or state == PlayerState.INVINCIBLE:
		handle_rps()
	elif state == PlayerState.DIE:
		pass
	
		
func _physics_process(delta: float) -> void:
	
	if state == PlayerState.NORMAL or state == PlayerState.POSE or state == PlayerState.INVINCIBLE:
		handle_movement(delta)
		
	elif state == PlayerState.DIE:
		pass

func set_hitbox_component_target():
	
	var closest: HitboxComponent = null
	var min_distsq: float = INF
	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		
		var d2 = hitbox_component.global_position.distance_squared_to(e.get_node("HitboxComponent").global_position)
		if d2 < min_distsq:
			min_distsq = d2
			closest = e.get_node("HitboxComponent")
	
	if closest:
		hitbox_component.target = closest
		if is_instance_valid(closest):
			closest.target = hitbox_component
   
		
func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func handle_rps():
	
	if Input.is_action_just_pressed("equip_rock"):
		rps_component.current_rps_type = Enums.RPSType.ROCK
		
	if Input.is_action_just_pressed("equip_paper"):
		rps_component.current_rps_type = Enums.RPSType.PAPER
	
	if Input.is_action_just_pressed("equip_scissor"):
		rps_component.current_rps_type = Enums.RPSType.SCISSOR
	
	head.frame = rps_component.current_rps_type
	
	

func handle_movement(delta: float):
	
	if state == PlayerState.DIE: return
	
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

func handle_anim():
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO and state != PlayerState.DIE:
		change_animation("move")
	else:
		change_animation("idle")
		
	if input_direction.x > 0:
		body.flip_h = true
	elif input_direction.x < 0:
		body.flip_h = false

func change_animation(animation_name: String):
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func _on_hitbox_component_lose() -> void:
	print("lose")
	health_component.take_damage(1)
	state = PlayerState.INVINCIBLE


func _on_hitbox_component_win() -> void:
	print("win")
	state = PlayerState.POSE
	
	
func _on_health_component_die() -> void:
	print("die")
	state = PlayerState.DIE


func _on_pose_timer_timeout() -> void:
	if state == PlayerState.DIE: return
	
	state = PlayerState.NORMAL
	hitbox_component.get_node("CollisionShape2D").disabled = false


func _on_invincible_timer_timeout() -> void:
	if state == PlayerState.DIE: return
	
	state = PlayerState.NORMAL
	hitbox_component.get_node("CollisionShape2D").disabled = false
			
