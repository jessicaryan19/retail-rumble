extends Node2D

@export var enemy_scene: PackedScene
@export var min_distance_from_player: float = 300.0
@export var max_attempts: int = 20
@export var max_enemies: int = 5
@export var spawn_interval: float = 5.0
@export var path_node: NodePath
@export var timer_node: NodePath

var player: Node2D
@onready var score_manager = get_parent().get_node("ScoreManager")

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var timer = get_node(timer_node) as Timer
	timer.wait_time = spawn_interval
	timer.timeout.connect(spawn_enemy)
	timer.start()

func spawn_enemy():
	if not enemy_scene or not player:
		return

	if get_tree().get_nodes_in_group("enemy").size() >= max_enemies:
		return

	var spawn_pos = get_valid_spawn_position()
	if spawn_pos == null:
		return

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.add_to_group("enemies")
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
