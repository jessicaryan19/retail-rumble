extends Node2D

@export var enemy_scene: PackedScene
@export var min_distance_from_player: float = 300.0
@export var max_attempts: int = 20
@export var initial_max_enemies: int = 5
@export var initial_spawn_interval: float = 8.0
@export var path_node: NodePath
@export var spawn_timer_node: NodePath

@onready var difficulty_timer_node = $DifficultyTimer
var current_difficulty: float = 1.0

var player: Node2D
@onready var score_manager = get_parent().get_node("ScoreManager")
@onready var spawn_timer = get_node(spawn_timer_node) as Timer

func _ready():
	player = get_tree().get_first_node_in_group("player")
		
	spawn_timer.wait_time = initial_spawn_interval
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start()
	
	difficulty_timer_node.timeout.connect(_on_difficulty_timer_timeout)


func _on_difficulty_timer_timeout():
	current_difficulty += 0.5
	print("New difficulty level: ", current_difficulty)
	
#	Kalau mau ubah max enemies per difficulty point(level) itu disini
#	Ini gw set Multiply by 2 Jadi bakal ngasih 2 extra enemies buat tiap 1 point difficulty.
	var new_max_enemies = initial_max_enemies + floori(current_difficulty * 2.0) # Bisa lu ganti jadi 1.5 atau 1.0
	
#	Kalau mau ubah spawn interval disini, tinggal kali aja current_difficulty nya
	var new_spawn_interval = max(1.0, initial_spawn_interval / current_difficulty * 1.5) # Jangan biarin intervalnya kurang dari 1s

	spawn_timer.wait_time = new_spawn_interval
	
	print("Updated spawner: Max Enemies = %d, Spawn Interval = %.2f" % [new_max_enemies, new_spawn_interval])
	
	
func spawn_enemy():
	if not enemy_scene or not player:
		return
	#var current_max_enemies = initial_max_enemies + floori(current_difficulty)
	var current_max_enemies = initial_max_enemies + floori(current_difficulty * 2.0)
	if get_tree().get_nodes_in_group("enemy").size() >= current_max_enemies:
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
