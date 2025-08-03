extends Control

@onready var new_high_score_label = $NewHighScoreLabel
@onready var score_manager = get_node("/root/Game/ScoreManager")

func _ready() -> void:
	new_high_score_label.scale = Vector2(0.6, 0.6)
	new_high_score_label.modulate.a = 0.0
	
	score_manager.new_high_score.connect(show_high_score_notice)

func show_high_score_notice():
	var tween = create_tween()
	tween.parallel().tween_property(new_high_score_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(new_high_score_label, "modulate:a", 1.0, 0.3)
	
	# Sequential operations happen automatically after parallel block
	tween.tween_interval(3.0)
	tween.tween_property(new_high_score_label, "modulate:a", 0.0, 0.4)
