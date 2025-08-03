extends CharacterBody2D

enum EnemyState {
	CHASE = 0,
	STUNNED = 1,
	DIE = 2
}

@onready var hurt_sfx: AudioStream = preload("res://sfx/ua.mp3")
@onready var die_sfx: AudioStream = preload("res://sfx/yey.mp3")

@export var initial_speed: float = 300.0
var speed: float

@export var rps_list: Array[Enums.RPSType] = []
var player: Node2D
var difficulty_level: float = 1.0

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var rps_container = $RPSContainer

@onready var stunned_timer: Timer = $StunnedTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: AnimatedSprite2D = $Sprite/Body
@onready var head: AnimatedSprite2D = $Sprite/Head
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var rps_component: RPSComponent = $RPSComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var score_manager = get_tree().get_root().get_node("Game/ScoreManager")

#@onready var outline_material: ShaderMaterial = preload("res://enemy/outline_material.tres")
@onready var enemy_shader := preload("res://shader/white_outline.gdshader")

#@onready var knockback_component: KnockbackComponent = $KnockbackComponent
var rps_sprite_scene = preload("res://enemy/rps_sprite.tscn")

var state: EnemyState = EnemyState.CHASE:
	get: 
		return state
	set(value):
		
		if state==value: return
		if state==EnemyState.DIE: return
		
		state = value
		body.frame = state
		do_squash_stretch_tween()
		
		match (value):
			EnemyState.CHASE:
				stop_blink()
				head.animation = "rps"
				
			
			EnemyState.STUNNED:
				flash_red()
				start_blink()
				stunned_timer.start()
				head.animation = "rps"
				AudioHandler.play_sfx(hurt_sfx, 0, randf_range(0.8, 1.4))
				hitbox_collision.set_deferred("disabled", true)
				collision_shape_2d.set_deferred("disabled", true)
				
				
			EnemyState.DIE:
				flash_red()
				stop_blink()
				head.animation = "die"
				AudioHandler.play_sfx(die_sfx, 0, randf_range(0.8, 1.4))
				hitbox_collision.set_deferred("disabled", true)
				collision_shape_2d.set_deferred("disabled", true)
				do_die_tween()
				await die_tween.finished

var die_tween: Tween
var squash_stretch_tween: Tween


func initialize(p_difficulty_level: float):
	await ready

	difficulty_level = p_difficulty_level

	speed = initial_speed * (1 + (difficulty_level - 1.0) * 0.05)
	
	randomize_variant()
	generate_rps_list() 
	
	if score_manager:
		health_component.took_damage.connect(score_manager._on_enemy_took_damage)
	

func do_die_tween() -> void:
	if die_tween:
		die_tween.kill()
	
	die_tween = create_tween()
	
	die_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	die_tween.tween_property(self, "modulate:a", 0.0, 2.0)
	die_tween.tween_callback(self.queue_free)
	
func do_squash_stretch_tween() -> void:
	if squash_stretch_tween:
		squash_stretch_tween.kill()
	
	squash_stretch_tween = create_tween()
	
	squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)

	
func generate_rps_list():
	rps_list.clear()
	
	var min_rps_length = 1
	var max_rps_length = min(5, 1 + floori(difficulty_level / 2.0))
	var rps_length = randi_range(min_rps_length, max_rps_length)
	
	var keys = Enums.RPSType.keys()
	
	for i in range(rps_length):
		var random_key = keys[randi() % keys.size()]
		var random_rps: Enums.RPSType = Enums.RPSType[random_key]
		rps_list.append(random_rps)
	
	update_current_rps()
	update_health()
	update_rps_visual()
	
	
const RPS_TEXTURES = {
	Enums.RPSType.ROCK: preload("res://assets/rps/rock.png"),
	Enums.RPSType.PAPER: preload("res://assets/rps/paper.png"),
	Enums.RPSType.SCISSOR: preload("res://assets/rps/scissor.png"),
}

func randomize_variant():
	var animation_names = body.sprite_frames.get_animation_names()
	body.animation = animation_names[randi() % animation_names.size()]

func update_rps_visual():
	if rps_list.size() > 0:
		head.frame = rps_list.front()
	
	for child in rps_container.get_children():
		child.queue_free()

	var icon_spacing = 80
	var start_x = -(rps_list.size() - 1) * icon_spacing / 2.0

	for i in rps_list.size():
		var rps_sprite = rps_sprite_scene.instantiate()
		print("rps", rps_list[i])
		rps_sprite.frame = rps_list[i]
		rps_sprite.position = Vector2(start_x + i * icon_spacing, 0)
		rps_container.add_child(rps_sprite)
		
		if i == 0:
			var frame = Sprite2D.new()
			frame.texture = preload("res://assets/ui/frame_indicator.png")
			frame.z_index = 1
			frame.position = Vector2.ZERO
			rps_sprite.add_child(frame)
	
	

func _ready():
	var mat := ShaderMaterial.new()
	mat.shader = enemy_shader
	sprite.material = mat.duplicate()
	player = get_tree().get_first_node_in_group("player")
	agent.target_position = player.global_position
	
	if speed == 0:
		speed = initial_speed
		randomize_variant()
		generate_rps_list()
	
	
func _process(delta: float) -> void:
	handle_anim()
	
func _physics_process(delta: float):
	
	if state == EnemyState.CHASE:
		chase_player(delta)

func handle_anim():
	if state==EnemyState.CHASE:
		change_animation("move")
	else:
		change_animation("idle")
		
	if player.global_position.x >= global_position.x:
		body.flip_h = true
	else:
		body.flip_h = false


func change_animation(animation_name: String):
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

	
func chase_player(delta: float):
	if player:
		agent.target_position = player.global_position
	
	# TODO: replace with checking collider once the Player is combined
	if agent.is_navigation_finished():
		return

	var next_path_position = agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	velocity = direction * speed # TODO: tambahin delta
	
	move_and_slide()

func update_current_rps() -> void:
	if rps_list.size() > 0:
		rps_component.current_rps_type = rps_list.front()
	
func update_health() -> void:
	health_component.health = rps_list.size()
	health_component.take_damage(0)
	
func _on_stunned_timer_timeout() -> void:
	if state == EnemyState.DIE: return
	
	collision_shape_2d.set_deferred("disabled", false)
	hitbox_collision.set_deferred("disabled", false)	
	state = EnemyState.CHASE
	
	
	update_current_rps()
	
	#print("enemy end of stunned")
	
func _on_health_component_die() -> void:
	state = EnemyState.DIE
	
	#print("enemy die")
	
func _on_hitbox_component_duel(win: bool, opponent: HitboxComponent) -> void:
	
	if win:
		print("enemy win")
		do_squash_stretch_tween()
		pass
	else:
		#print("enemy lose")
		
		rps_list.pop_front()
		update_rps_visual()
		update_health()
		
		if health_component.health > 0:
			state = EnemyState.STUNNED
			
			
#func set_outline(is_active: bool) -> void:
	#if not is_node_ready():
		#await ready
	#
	#var material_to_set = outline_material if is_active else null
	#stop_blink()
	#if sprite:
		#sprite.material = material_to_set
	##if body:
		##body.material = material_to_set
	##if head:
		##head.material = material_to_set

func flash_red():
	var mat := sprite.material as ShaderMaterial
	if mat:
		mat.set("shader_parameter/flash_active", true)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_active", false, 0.3)

func start_blink():
	var mat := sprite.material as ShaderMaterial
	if mat:
		mat.set("shader_parameter/blink_active", true)

func stop_blink():
	var mat := sprite.material as ShaderMaterial
	if mat:
		mat.set("shader_parameter/blink_active", false)
