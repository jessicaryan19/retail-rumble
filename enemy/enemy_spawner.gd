extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var map_rect: Rect2 = Rect2(0, 0, 3000, 3000)
@export var min_distance_from_player: float = 300.0
@export var max_attempts: int = 20

var player: Node2D

func start_spawning():
	spawn_enemy()
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy():
	var screen_size = get_viewport().get_visible_rect().size
	print(screen_size)
	if not enemy_scene or not player:
		return
	var spawn_pos: Vector2 = get_valid_spawn_position()
	if spawn_pos == null:
		return

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child.call_deferred(enemy)
	print("Spawning enemy", enemy.global_position, enemy.rps_list)

func get_valid_spawn_position():
	
	var attempt := 0
	while attempt < max_attempts:
		var x = randf_range(map_rect.position.x, map_rect.end.x)
		var y = randf_range(map_rect.position.y, map_rect.end.y)
		var candidate = Vector2(x, y)

		if candidate.distance_to(player.global_position) >= min_distance_from_player:
			return candidate
		attempt += 1
	return null
	
func _ready():
	
	player = get_tree().get_first_node_in_group("player")
	start_spawning()
