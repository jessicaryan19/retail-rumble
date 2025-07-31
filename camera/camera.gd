extends Camera2D

var original_offset: Vector2 = offset

var shake_intensity: float = 0.0
var active_shake_duration: float = 0.0

@export var SHAKE_DECAY: float = 5.0

var shake_duration: float = 0.0
@export var SHAKE_DURATION_SPEED: float = 20.0

var noise = FastNoiseLite.new()

@export var ZERO_OFFSET_LERP_AMMOUNT = 10.5

func _physics_process(delta: float) -> void:
	if active_shake_duration > 0:
		shake_duration += delta * SHAKE_DURATION_SPEED
		active_shake_duration -= delta
		
		offset = original_offset + Vector2(
			noise.get_noise_2d(shake_duration, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_duration) * shake_intensity
		)
		
		shake_intensity = max(shake_intensity - SHAKE_DECAY * delta, 0)
	else:
		offset = lerp(offset, original_offset, ZERO_OFFSET_LERP_AMMOUNT * delta)

func apply_screen_shake(intensity: int, duration: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_duration = duration
	shake_duration = 0.0
