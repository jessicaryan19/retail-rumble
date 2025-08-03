extends Control

@onready var back_button = $VBoxContainer/ButtonMenu
@onready var score = $VBoxContainer/Score/Point
@onready var high_score = $VBoxContainer/HighScore/Point
@onready var vbox= $VBoxContainer

var score_manager: Node

func _ready() -> void:
	back_button.disabled = true
	back_button.set_text("back")
	
	vbox.modulate.a = 0.0
	score.text = str(score_manager.score)
	high_score.text = str(score_manager.high_score)
	
	var tween := create_tween()
	await tween.tween_property(vbox, "modulate:a", 1.0, 0.5).finished
	back_button.disabled = false
	back_button.pressed.connect(_on_back_to_menu)

func _on_back_to_menu() -> void:
	back_button.disabled = true
	var tween := create_tween()
	await tween.tween_property(vbox, "modulate:a", 0.0, 0.5).finished
	#get_tree().change_scene_to_file("res://menu/main_menu.tscn")
	SceneManager.change_scene("res://game/game.tscn", {
				"pattern": "squares",
				"speed": 2.5,               
				"invert_on_leave": true,   
				"ease": 4.5,
				"color" : Color("#FFD23C")
			})
