extends CharacterBody2D
const ENUMS = preload("res://autoloads/enums.gd")

@export var speed: float = 300.0
@export var rps_list: Array[ENUMS.RPSType] = []

var player: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var rps_container = $RPSContainer

func generate_rps_list():
	rps_list.clear()
	var rps_length = randi() % 3 + 1
	var keys = ENUMS.RPSType.keys()
	
	for i in range(rps_length):
		var random_key = keys[randi() % keys.size()]
		var random_rps: ENUMS.RPSType = ENUMS.RPSType[random_key]
		rps_list.append(random_rps)
		
const RPS_TEXTURES = {
	ENUMS.RPSType.ROCK: preload("res://assets/rps/rock.png"),
	ENUMS.RPSType.PAPER: preload("res://assets/rps/paper.png"),
	ENUMS.RPSType.SCISSOR: preload("res://assets/rps/scissor.png"),
}

func update_rps_icons():
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

func _physics_process(delta):
	if player:
		agent.target_position = player.global_position
	
	# TODO: replace with checking collider once the Player is combined
	if agent.is_navigation_finished():
		return

	var next_path_position = agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
