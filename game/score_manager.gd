extends Node2D

signal score_changed(new_score: int)
signal combo_changed(new_combo: int)

@onready var score_sfx1: AudioStream = preload("res://sfx/UI_Quirky7.mp3")
@onready var score_sfx2: AudioStream = preload("res://sfx/UI_Quirky18.mp3")

var score: int = 0
var combo: int = 0
@export var combo_interval: float = 3.0
@onready var combo_timer = $ComboTimer

@export var sfx_variant_every_n_combo: int = 10

func _ready():
	combo_timer.wait_time = combo_interval
	combo_timer.timeout.connect(reset_combo)
	combo_timer.one_shot = true

func reset_combo():
	combo = 0
	print("reset combo: ", combo)
	emit_signal("combo_changed", combo)
	
func add_combo():
	combo += 1
	emit_signal("combo_changed", combo)
	combo_timer.stop()
	combo_timer.start()

func add_score(points: int):
	if combo % sfx_variant_every_n_combo == 0:
		AudioHandler.play_sfx(score_sfx2, 10, randf_range(0.8, 1.0))
	else:
		AudioHandler.play_sfx(score_sfx1, 10, randf_range(0.8, 1.0))
	
	score += points * combo
	print("combo: ", combo)
	print("current score: ", score)
	emit_signal("score_changed", score)

func reset_score():
	score = 0
	emit_signal("score_changed", score)

func _on_enemy_took_damage():
	add_combo()
	add_score(10)
