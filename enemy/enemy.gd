extends CharacterBody2D

enum EnemyState {
	CHASE = 0,
	STUNNED = 1,
	DIE = 2
}

@export var speed: float = 300.0
@export var rps_list: Array[Enums.RPSType] = []

var player: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var rps_container = $RPSContainer

@onready var stunned_timer: Timer = $StunnedTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: AnimatedSprite2D = $Sprite/Body
@onready var head: AnimatedSprite2D = $Sprite/Head
@onready var sprite: Node2D = $Sprite

@onready var rps_component: RPSComponent = $RPSComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var score_manager = get_tree().get_root().get_node("Game/ScoreManager")
#@onready var knockback_component: KnockbackComponent = $KnockbackComponent

var state: EnemyState = EnemyState.CHASE:
	get: 
		return state
	set(value):
		
		if state==value: return
		if state==EnemyState.DIE: return
		
		state = value
		body.frame = state
		frightened_tween()
		
		match (value):
			EnemyState.CHASE:
				head.animation = "rps"
				pass
			
			EnemyState.STUNNED:
				stunned_timer.start()
				head.animation = "rps"
				
			EnemyState.DIE:
				head.animation = "die"
				hitbox_collision.set_deferred("disabled", true)
				
				reset_die_tween()
				die_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				die_tween.tween_property(self, "modulate:a", 0.0, 2.0)
				die_tween.tween_callback(self.queue_free)
				await die_tween.finished

var die_tween: Tween
var scale_tween: Tween

func reset_die_tween() -> void:
	if die_tween:
		die_tween.kill()
	
	die_tween = create_tween()
	
func reset_scale_tween() -> void:
	if scale_tween:
		scale_tween.kill()
	
	scale_tween = create_tween()
	
func generate_rps_list():
	rps_list.clear()
	var rps_length = randi() % 3 + 1
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
	# update head
	if rps_list.size() > 0:
		head.frame = rps_list.front()
	
	for child in rps_container.get_children():
		child.queue_free()

	var icon_spacing = 32
	var start_x = -(rps_list.size() - 1) * icon_spacing / 2.0

	for i in rps_list.size():
		var icon = Sprite2D.new()
		icon.texture = RPS_TEXTURES[rps_list[i]]
		icon.position = Vector2(start_x + i * icon_spacing, 0)
		icon.scale = Vector2(0.05, 0.05)
		rps_container.add_child(icon)
	
func _ready():
	player = get_tree().get_first_node_in_group("player")
	agent.target_position = player.global_position
	randomize_variant()
	generate_rps_list()
	if score_manager:
		health_component.took_damage.connect(score_manager._on_enemy_took_damage)
	
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
	
	state = EnemyState.CHASE
	
	update_current_rps()
	
	print("enemy end of stunned")
	
func _on_health_component_die() -> void:
	state = EnemyState.DIE
	
	print("enemy die")

func frightened_tween() -> void:
	reset_scale_tween()
	scale_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	scale_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
	
func _on_hitbox_component_duel(win: bool, opponent: HitboxComponent) -> void:
	frightened_tween()
	
	if win:
		print("enemy win")
		frightened_tween()
	else:
		print("enemy lose")
		
		rps_list.pop_front()
		update_rps_visual()
		update_health()
		
		if health_component.health > 0:
			state = EnemyState.STUNNED
			
