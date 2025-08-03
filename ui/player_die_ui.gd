extends Control
@onready var die_label: Label = $VBoxContainer/VBoxContainer/DieLabel
@onready var draw_info_label: Label = $VBoxContainer/VBoxContainer/DrawInfoLabel
@onready var player = get_tree().get_first_node_in_group("player")
@onready var rolling_door_bg = $RollingDoorBG
var score_manager

@export var die_string: String = "rock beats rock?":
	get:
		return die_string
	set(value):
		die_string = value
		if die_label:
			die_label.text = die_string
		
@export var show_draw_info: bool = false:
	get:
		return show_draw_info
	set(value):
		show_draw_info = value
		if draw_info_label:
			draw_info_label.visible = show_draw_info

func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	score_manager = get_tree().get_current_scene().get_node("ScoreManager")

func _input(event: InputEvent) -> void:
	if player.state == player.PlayerState.DIE:
		if event is InputEventMouseButton and event.pressed:
			_on_continue()

func _on_continue():
	await rolling_door_bg.roll_down()
	var next_scene = load("res://game/game_over.tscn").instantiate()
	next_scene.score_manager = score_manager
	get_tree().get_current_scene().queue_free()
	get_tree().root.add_child(next_scene)
	get_tree().set_current_scene(next_scene)
