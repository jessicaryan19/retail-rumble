extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D

@onready var collide_sfx: AudioStream = preload("res://sfx/dieThrow1.mp3")

func _ready() -> void:
	animated_sprite_2d.frame = randi() % animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation)

var squash_stretch_tween: Tween

func do_squash_stretch_tween() -> void:
	if squash_stretch_tween:
		squash_stretch_tween.kill()
	
	squash_stretch_tween = create_tween()
	
	squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	squash_stretch_tween.tween_property(animated_sprite_2d, "scale", Vector2(1.1, 0.9), 0.1)
	squash_stretch_tween.tween_property(animated_sprite_2d, "scale", Vector2(0.9, 1.1), 0.1)
	squash_stretch_tween.tween_property(animated_sprite_2d, "scale", Vector2(1, 1), 0.1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	do_squash_stretch_tween()
	AudioHandler.play_sfx(collide_sfx, -2, randf_range(0.9, 1.1))
