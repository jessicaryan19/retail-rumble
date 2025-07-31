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
		do_stretch_tween()
		
		match (value):
			PlayerState.NORMAL:
				body.animation = "normal"
			
			PlayerState.POSE:
				pose_timer.start()
				body.animation = "pose"
				do_closeup_tween(1.2)
				body.frame = randi() % body.sprite_frames.get_frame_count("pose")
				hitbox_component.invincible = true
				hitbox_component.target = null
				
			PlayerState.INVINCIBLE:
				invincible_timer.start()
				body.animation = "hurt"
				do_closeup_tween(1.2)
				hitbox_component.invincible = true
				hitbox_component.target = null
				
			PlayerState.DIE:
				body.animation = "hurt"
				do_die_tween()
				hitbox_collision.set_deferred("disabled", true)
				hitbox_component.target = null
		

@export var MAX_SPEED: float = 600.0
@export var ACCELERATION: float = 800.0
@export var DECCELERATION: float = 1200.0

var accel_time: float= 0.0
var deccel_time: float= 0.0

@export var ACCEL_TIME_TO_MAX := 0.3
@export var DECCEL_TIME_TO_STOP := 0.3

@export var ACCELERATION_CURVE: Curve
@export var DECCELERATION_CURVE: Curve

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var rps_component: RPSComponent = $RPSComponent
#@onready var knockback_component: Node2D = $KnockbackComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var head: AnimatedSprite2D = $Sprite/Head
@onready var body: AnimatedSprite2D = $Sprite/Body
@onready var check_close_entity: Area2D = $CheckCloseEntity
@onready var sprite: Node2D = $Sprite
@onready var camera: Camera2D = $Camera

@onready var score_manager = get_tree().get_root().get_node("Game/ScoreManager")

var die_tween: Tween
var closeup_tween: Tween
var stretch_tween: Tween

func do_die_tween() -> void:
	if die_tween:
		die_tween.kill()
		
	die_tween = create_tween()
	
	Engine.time_scale = 1
	
	die_tween.tween_property(camera, "zoom", Vector2(2, 2), 0.5)
	

func do_closeup_tween(duration: float) -> void:
	
	if closeup_tween:
		closeup_tween.kill()
	
	closeup_tween = create_tween()
	
	var duration_each_segment: float = duration/2
	
	closeup_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	closeup_tween.set_parallel(true)
	closeup_tween.tween_property(camera, "zoom", Vector2(1.3, 1.3), duration_each_segment)
	closeup_tween.tween_property(Engine, "time_scale", 0.5, duration_each_segment)
	
	closeup_tween.chain().tween_interval(0)
	closeup_tween.parallel().set_ease(Tween.EASE_IN).tween_property(Engine, "time_scale", 1, duration_each_segment)
	closeup_tween.parallel().tween_property(camera, "zoom", Vector2(1.0, 1.0), duration_each_segment)
	
func do_stretch_tween() -> void:
	if stretch_tween:
		stretch_tween.kill()
	
	stretch_tween = create_tween()
	
	stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
	
func _process(delta: float) -> void:
	handle_anim()
	
	if state == PlayerState.NORMAL:
		handle_rps()
		set_closest_hitbox_target()
	elif state == PlayerState.POSE or state == PlayerState.INVINCIBLE:
		handle_rps()
	elif state == PlayerState.DIE:
		pass

func _physics_process(delta: float) -> void:
	
	if state == PlayerState.NORMAL or state == PlayerState.POSE or state == PlayerState.INVINCIBLE:
		handle_movement(delta)
	
func set_closest_hitbox_target():
	var closest = null
	var closest_dist_sq = INF
	
	for entity in check_close_entity.get_overlapping_bodies():
		if entity.is_in_group("enemy"):
			entity.get_node("HitboxComponent").reset_target()
			var dsq = global_position.distance_squared_to(entity.global_position)
			if dsq < closest_dist_sq:
				closest_dist_sq = dsq
				closest = entity
			
	
	if closest:
		closest.get_node("HitboxComponent").target = hitbox_component
		hitbox_component.target = closest.get_node("HitboxComponent")
	else:
		hitbox_component.reset_target()
   
		
func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func handle_rps():
	
	if Input.is_action_just_pressed("equip_rock"):
		rps_component.current_rps_type = Enums.RPSType.ROCK
		
	if Input.is_action_just_pressed("equip_paper"):
		rps_component.current_rps_type = Enums.RPSType.PAPER
	
	if Input.is_action_just_pressed("equip_scissor"):
		rps_component.current_rps_type = Enums.RPSType.SCISSOR
	
	if head.frame != rps_component.current_rps_type:
		#retoggle_hitbox_monitoring()
		do_stretch_tween()
		head.frame = rps_component.current_rps_type

#func retoggle_hitbox_monitoring():
	#hitbox_component.monitoring = false
	#await get_tree().process_frame
	#hitbox_component.monitoring = true

func handle_movement(delta: float):
	
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


func _on_health_component_die() -> void:
	print("die")
	state = PlayerState.DIE


func _on_pose_timer_timeout() -> void:
	if state == PlayerState.DIE: return
	
	print("end of pose")
	
	hitbox_component.invincible = false
	state = PlayerState.NORMAL
	

func _on_invincible_timer_timeout() -> void:
	if state == PlayerState.DIE: return
	
	print("end of invincible")
	
	hitbox_component.invincible = false
	state = PlayerState.NORMAL
	

func _on_hitbox_component_duel(win: bool, opponent: HitboxComponent) -> void:
	
	if (win):
		print("win")
		camera.apply_screen_shake(8, 0.2)
		if state == PlayerState.NORMAL:
			state = PlayerState.POSE
	else:
		print("lose")
		camera.apply_screen_shake(20, 0.3)
		health_component.take_damage(1)
		#apply_hit_shader_effect()
		
		if health_component.health > 0:
			state = PlayerState.INVINCIBLE
	
		# apply knockback
		#var knockback_dir = -(opponent.global_position - hitbox_component.global_position).normalized()
		#knockback_component.apply_knockback(knockback_dir)

# Ini shader yg buat jadi merah
func apply_hit_shader_effect():
	var mat := body.material as ShaderMaterial
	if mat == null:
		return
	
	mat.set("shader_parameter/r", 1.0)
	mat.set("shader_parameter/g", 0.0)
	mat.set("shader_parameter/b", 0.0)
	mat.set("shader_parameter/mix_color", 1.0)
	mat.set("shader_parameter/opacity", 1.0)

	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/mix_color", 0.0, 0.2)


func _on_took_damage():
	apply_hit_shader_effect()
	score_manager.reset_combo()

func _ready():
	health_component.took_damage.connect(_on_took_damage);
