extends TextureButton

@onready var click_sfx = preload("res://sfx/click3.mp3")

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	
func _on_button_pressed():
	AudioHandler.play_sfx(click_sfx, 6, randf_range(0.9, 1.1))
