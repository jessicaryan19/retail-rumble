extends Node2D

signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal new_high_score()

const SAVE_PATH := "user://high_score.save"

var score: int = 0
var combo: int = 0
var high_score: int = 0
var is_new_high_score_notified = false

@export var combo_interval: float = 6.0
@onready var combo_timer = $ComboTimer

func _ready():
	load_high_score()
	combo_timer.wait_time = combo_interval
	combo_timer.timeout.connect(reset_combo)
	combo_timer.one_shot = true

func reset_combo():
	combo = 0
	emit_signal("combo_changed", combo)
	
func add_combo():
	combo += 1
	emit_signal("combo_changed", combo)
	combo_timer.stop()
	combo_timer.start()

func add_score(points: int):
	score += points * combo
	emit_signal("score_changed", score)
	
	if score > high_score and high_score != 0 and not is_new_high_score_notified:
		is_new_high_score_notified = true
		emit_signal("new_high_score")

func reset_score():
	score = 0
	emit_signal("score_changed", score)
	
func save_high_score():
	if score > high_score:
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		var data = { "high_score": score }
		file.store_string(JSON.stringify(data))
		file.close()

func load_high_score():
	if not FileAccess.file_exists(SAVE_PATH):
		save_high_score()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = {}
	if content != "":
		data = JSON.parse_string(content)
		high_score = int(data.get("high_score", 0))

func _on_enemy_took_damage():
	add_combo()
	add_score(10)
