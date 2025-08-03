extends Control

signal transition_finished()
@onready var animation_player = $AnimationPlayer

func roll_up():
	animation_player.play("roll_up")
	await animation_player.animation_finished
	emit_signal("transition_finished")

func roll_down():
	print("in roll dwn")
	animation_player.play("roll_down")
	await animation_player.animation_finished
	emit_signal("transition_finished")
