extends CharacterBody2D

enum PlayerState {
	NORMAL,
	POSE,
	INVINCIBLE,
	DIE
}

@onready var click_sfx: AudioStream = preload("res://sfx/click3.mp3")
@onready var hurt_sfx: AudioStream = preload("res://sfx/ua.mp3")
@onready var pose_sfx: AudioStream = preload("res://sfx/woosh2.mp3")

@onready var pose_timer: Timer = $PoseTimer
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var retoggle_hitbox_timer: Timer = $RetoggleHitboxTimer

var state: PlayerState = PlayerState.NORMAL:
	get: 
		return state
	set(value):
		
		if state==value: return
		if state==PlayerState.DIE: return
		
		state = value

		var mat := sprite.material as ShaderMaterial
		do_squash_stretch_tween()
		
		match (value):
			PlayerState.NORMAL:
				body.animation = "normal"
				body_silhouette.animation = "normal"
				mat.set("shader_parameter/blink_active", false)
				retoggle_hitbox_timer.start()
			
			PlayerState.POSE:
				pose_timer.start()
				body.animation = "pose"
				body_silhouette.animation = "pose"
				AudioHandler.play_sfx(pose_sfx, 6, randf_range(0.9, 1.1))
				do_closeup_tween(1.2)
				body.frame = randi() % body.sprite_frames.get_frame_count("pose")
				body_silhouette.frame = body.frame
				hitbox_component.invincible = true
				hitbox_component.target = null
				mat.set("shader_parameter/blink_active", true)
				retoggle_hitbox_timer.stop()
				
			PlayerState.INVINCIBLE:
				invincible_timer.start()
				body.animation = "hurt"
				body_silhouette.animation = "hurt"
				AudioHandler.play_sfx(hurt_sfx, 0, randf_range(0.8, 1.4))
				do_closeup_tween(1.2)
				hitbox_component.invincible = true
				hitbox_component.target = null
				mat.set("shader_parameter/blink_active", true)
				retoggle_hitbox_timer.stop()
				
			PlayerState.DIE:
				body.animation = "hurt"
				body_silhouette.animation = "hurt"
				AudioHandler.play_sfx(hurt_sfx, 0, randf_range(0.8, 1.4))
				do_die_tween()
				hitbox_collision.set_deferred("disabled", true)
				hitbox_component.target = null
				mat.set("shader_parameter/blink_active", false)
				retoggle_hitbox_timer.stop()
		

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
@onready var body_silhouette: AnimatedSprite2D = $Sprite/BodySilhouette
@onready var head_silhouette: AnimatedSprite2D = $Sprite/HeadSilhouette
@onready var check_close_entity: Area2D = $CheckCloseEntity
@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera

@onready var score_manager = get_tree().get_root().get_node("Game/ScoreManager")

var current_target_enemy: CharacterBody2D = null

var die_tween: Tween
var closeup_tween: Tween
var squash_stretch_tween: Tween

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
	
func do_squash_stretch_tween() -> void:
	if squash_stretch_tween:
		squash_stretch_tween.kill()
	
	squash_stretch_tween = create_tween()
	
	squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
	
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
	var potential_enemies = check_close_entity.get_overlapping_bodies()
	var new_closest_enemy: CharacterBody2D = null
	var closest_dist_sq = INF
	
	for entity in potential_enemies:
		if entity.is_in_group("enemy"):
			var dsq = global_position.distance_squared_to(entity.global_position)
			if dsq < closest_dist_sq:
				closest_dist_sq = dsq
				new_closest_enemy = entity
	
	if new_closest_enemy != current_target_enemy:
	
		if is_instance_valid(current_target_enemy):
			current_target_enemy.get_node("RPSContainer").visible = false
			current_target_enemy.get_node("ClosestIndicator").visible = false
			#current_target_enemy.set_outline(false)
			
		if is_instance_valid(new_closest_enemy):
			new_closest_enemy.get_node("RPSContainer").visible = true
			new_closest_enemy.get_node("ClosestIndicator").visible = true
			#new_closest_enemy.set_outline(true)
			new_closest_enemy.get_node("HitboxComponent").target = hitbox_component
		else:
			hitbox_component.reset_target()
		
		current_target_enemy = new_closest_enemy
		
	if is_instance_valid(current_target_enemy) and current_target_enemy.is_in_group("enemy"):
		if hitbox_component.target == current_target_enemy.get_node("HitboxComponent"): return
		
		hitbox_component.target = current_target_enemy.get_node("HitboxComponent")
   
		
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
		do_squash_stretch_tween()
		AudioHandler.play_sfx(click_sfx, 6, randf_range(0.9, 1.1))
		head.frame = rps_component.current_rps_type
		head_silhouette.frame = head.frame

func retoggle_hitbox_monitoring():
	hitbox_component.monitoring = false
	await get_tree().process_frame
	hitbox_component.monitoring = true

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
		
	body_silhouette.flip_h = body.flip_h
func change_animation(animation_name: String):
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)


func _on_health_component_die() -> void:
	print("die")
	state = PlayerState.DIE
	score_manager.save_high_score()


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
	print("Flash triggered")
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		print("No material!")
		return
	mat.set("shader_parameter/flash_active", true)
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/flash_active", false, 0.2)

func _on_took_damage():
	apply_hit_shader_effect()
	score_manager.reset_combo()

func _ready():
	health_component.took_damage.connect(_on_took_damage);


func _on_retoggle_hitbox_timer_timeout() -> void:
	print("Retoggle Timer Timeout")
	retoggle_hitbox_monitoring()
	
	retoggle_hitbox_timer.start()
	
		
