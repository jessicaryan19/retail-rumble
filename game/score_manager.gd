extends Node2D

signal score_changed

var score: int = 0

func add_score(points: int):
	score += points
	print("add score:", score)
	emit_signal("score_changed", score)

func reset_score():
	score = 0
	emit_signal("score_changed", score)

func _on_enemy_took_damage():
	add_score(10)
