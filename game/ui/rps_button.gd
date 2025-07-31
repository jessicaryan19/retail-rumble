extends TextureRect

@onready var button_sprite: AnimatedSprite2D = $Button
@onready var jkl_sprite: AnimatedSprite2D = $JKL
@onready var rps_sprite: AnimatedSprite2D = $RPS

func set_button_state(is_active: bool) -> void:
	if is_active:
		button_sprite.frame = 1
	else:
		button_sprite.frame = 0

func show_key_hint(key: String) -> void:
	jkl_sprite.visible = true
	jkl_sprite.frame = Enums.KeyType.get(key)

func show_rps(rps: String) -> void:
	rps_sprite.visible = true
	rps_sprite.frame = Enums.RPSType.get(rps)
	
func configure(key: String, rps: String):
	show_key_hint(key)
	show_rps(rps)
