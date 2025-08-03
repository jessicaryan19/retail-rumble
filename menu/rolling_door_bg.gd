extends Control

signal transition_finished(direction: String)
@onready var animation_player = $AnimationPlayer

func roll_up():
	animation_player.play("roll_up")

func roll_down():
	animation_player.play("roll_down")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "roll_up":
		emit_signal("transition_finished", "up")
	elif anim_name == "roll_down":
		emit_signal("transition_finished", "down")
