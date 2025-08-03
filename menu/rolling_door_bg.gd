extends Control

signal transition_finished()
@onready var animation_player = $AnimationPlayer
@onready var sfx_roll_up: AudioStream = preload("res://sfx/Blinds_Opening.mp3")
@onready var sfx_roll_down: AudioStream = preload("res://sfx/Kitchen-Drawer-4-Open_with_Silverware.mp3")

func roll_up():
	animation_player.play("roll_up")
	AudioHandler.play_sfx(sfx_roll_up)
	await animation_player.animation_finished
	emit_signal("transition_finished")

func roll_down():
	animation_player.play("roll_down")
	AudioHandler.play_sfx(sfx_roll_down)
	await animation_player.animation_finished
	emit_signal("transition_finished")
