extends Node2D

signal score_changed
signal combo_changed

var score: int = 0
var combo: int = 1
@export var combo_interval: float = 10.0
@onready var combo_timer = $ComboTimer

func _ready():
	combo_timer.wait_time = combo_interval
	combo_timer.timeout.connect(reset_combo)
	combo_timer.one_shot = true

func reset_combo():
	combo = 1
	print("reset combo: ", combo)
	emit_signal("combo_changed")
	
func add_combo():
	combo += 1
	emit_signal("combo_changed")
	combo_timer.stop()
	combo_timer.start()

func add_score(points: int):
	score += points * combo
	print("combo: ", combo)
	print("current score: ", score)
	emit_signal("score_changed")

func reset_score():
	score = 0
	emit_signal("score_changed")

func _on_enemy_took_damage():
	add_score(10)
	add_combo()
