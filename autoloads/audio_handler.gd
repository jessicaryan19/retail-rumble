extends AudioStreamPlayer

func play_music(music: AudioStream, volume = 0.0) -> void:
	bus = 'Music'
	if stream == music:
		return
	
	stream = music	
	volume_db = volume
	
	play()

func play_sfx(stream: AudioStream, volume = 0.0, pitch_scale = 1.0):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = 'SFX'
	sfx_player.name = 'AudioStreamPlayerSFX'
	sfx_player.volume_db = volume
	sfx_player.pitch_scale = pitch_scale
	add_child(sfx_player)
	sfx_player.play()
	await sfx_player.finished
	sfx_player.queue_free()

func _ready() -> void:
	pass
