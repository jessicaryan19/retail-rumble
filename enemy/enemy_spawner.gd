extends Node2D

@export var enemy_scene: PackedScene
@export var min_distance_from_player: float = 300.0
@export var max_attempts: int = 20
@export var initial_max_enemies: int = 5
@export var initial_spawn_interval: float = 8.0
@export var path_node: NodePath
@export var spawn_timer_node: NodePath

@export_group("Testing & Debugging")
@export var initial_difficulty_override: float = 1.0
@export var disable_difficulty_increase: bool = false
@export_group("")

@onready var difficulty_timer_node = $DifficultyTimer 
var current_difficulty: float = 1.0

var player: Node2D
@onready var score_manager = get_parent().get_node("ScoreManager")
@onready var spawn_timer = get_node(spawn_timer_node) as Timer

func _ready():	
	if not spawn_timer:
		printerr("EnemySpawner: The 'Spawn Timer Node' has not been assigned in the Inspector!")
		set_process(false)
		return
	
	current_difficulty = initial_difficulty_override
	print("Starting game with difficulty level: ", current_difficulty)
	player = get_tree().get_first_node_in_group("player")
	
	spawn_timer.wait_time = initial_spawn_interval
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start()
	
	if not disable_difficulty_increase:
		difficulty_timer_node.timeout.connect(_on_difficulty_timer_timeout)		
	else:
		print("Difficulty increase is DISABLED for this test session.")
	
	call_deferred("spawn_burst", 2)


func _on_difficulty_timer_timeout():
	var old_difficulty = current_difficulty
	
	current_difficulty += 0.25
	print("New difficulty level: ", current_difficulty)
	
	var new_spawn_interval = max(1.0, initial_spawn_interval / current_difficulty)
	spawn_timer.wait_time = new_spawn_interval
	
	var current_max_enemies_cap = initial_max_enemies + floori(current_difficulty)
	print("Updated spawner: Max Enemies = %d, Spawn Interval = %.2f" % [current_max_enemies_cap, new_spawn_interval])
	
	
	if floor(current_difficulty / 3.0) > floor(old_difficulty / 3.0):
		print("Spawning a burst of enemies")
		spawn_burst(3) 
		
	
func spawn_burst(count: int):
	print("Spawning a burst of %d enemies." % count)
	for i in range(count):
		spawn_enemy()
	
	
func spawn_enemy():
	if not enemy_scene or not player:
		return
		
	var current_max_enemies = initial_max_enemies + floori(current_difficulty)
	if get_tree().get_nodes_in_group("enemy").size() >= current_max_enemies:
		print("Max enemies (%d) reached, skipping spawn." % current_max_enemies)
		return
		
	var spawn_pos = get_valid_spawn_position()
	if spawn_pos == null:
		return

	var enemy = enemy_scene.instantiate()
	
	if enemy.has_method("initialize"):
		enemy.initialize(current_difficulty)
	
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.add_to_group("enemy")
	print("Spawning enemy at", spawn_pos)


func get_valid_spawn_position():
	var path = get_node(path_node) as Path2D
	var curve = path.curve
	if not curve or curve.get_point_count() < 2:
		return null
		
	var attempt = 0
	while attempt < max_attempts:
		var length = curve.get_baked_length()
		var offset = randf_range(0, length)
		var local_pos = curve.sample_baked(offset)
		var global_pos = path.to_global(local_pos)
		
		if global_pos.distance_to(player.global_position) >= min_distance_from_player:
			return global_pos
		attempt += 1
	return null
