extends Node2D

@onready var background = $Background
@onready var button_container = $ButtonContainer
@onready var game_logo = $GameLogo
@onready var animation_player = $AnimationPlayer

@onready var play_btn = button_container.get_node("Play")
@onready var tutorial_btn = button_container.get_node("Tutorial")
@onready var credit_btn = button_container.get_node("Credit")
@onready var exit_btn = button_container.get_node("Exit")


func _ready():
	play_btn.set_text("Play")
	tutorial_btn.set_text("Tutorial")
	credit_btn.set_text("Credits")
	exit_btn.set_text("Exit")
	animation_player.play("rotation")

	play_btn.pressed.connect(_on_play_pressed)
	tutorial_btn.pressed.connect(_on_tutorial_pressed)
	credit_btn.pressed.connect(_on_credit_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	animation_player.play("open_rolling_door")
	animation_player.animation_finished.connect(_on_transition_finished)
	
func _on_transition_finished():
	get_tree().change_scene_to_file("res://game/game.tscn")

func _on_tutorial_pressed():
	print("Show tutorial")

func _on_credit_pressed():
	print("Show credits")

func _on_exit_pressed():
	get_tree().quit()
