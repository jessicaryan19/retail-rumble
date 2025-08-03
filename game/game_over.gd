extends Control

@onready var back_button = $VBoxContainer/ButtonMenu
@onready var score = $VBoxContainer/Score/Point
@onready var high_score = $VBoxContainer/HighScore/Point
@onready var time = $VBoxContainer/Time/Point
@onready var new_score_notice = $NewScore
@onready var rolling_door_bg = $RollingDoorBG

var score_manager
var stopwatch_manager

func _ready() -> void:
	rolling_door_bg.roll_up()
	
	score.text = str(score_manager.score)
	high_score.text = str(score_manager.high_score)
	time.text = str(stopwatch_manager.stopwatch_label.text)
	
	back_button.set_text("Back")
	back_button.pressed.connect(_on_back_to_menu)
	back_button.disabled = false
	
	if int(score.text) == int(high_score.text):
		new_score_notice.visible = true
		new_score_notice.animation_player.play("beating")
	else:
		new_score_notice.visible = false

func _on_back_to_menu() -> void:
	back_button.disabled = true
	SceneManager.change_scene("res://menu/main_menu.tscn", {
				"pattern": "squares",
				"speed": 2.5,               
				"invert_on_leave": true,   
				"ease": 4.5,
				"color" : Color("#D1370B")
			})
