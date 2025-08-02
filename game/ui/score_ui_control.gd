extends Control

@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel
@onready var high_score_label = $HighScoreLabel
@onready var score_manager = get_node("/root/Game/ScoreManager")

var fade_tween: Tween

func _ready():
	update_high_score_label(score_manager.high_score)
	score_manager.score_changed.connect(update_score_label, score_manager.score)
	score_manager.combo_changed.connect(update_combo_label, score_manager.combo)

func update_score_label(new_score: int):
	score_label.text = "Score: %d" % new_score
	
func update_high_score_label(new_score: int):
	high_score_label.text = "High Score: %d" % new_score
	
func update_combo_label(new_combo: int):
	if new_combo <= 1:
		combo_label.text = ""
	else:
		combo_label.text = "Combo %d" % new_combo
		combo_label.modulate.a = 1.0

		if fade_tween and fade_tween.is_running():
			fade_tween.kill()

		fade_tween = create_tween()
		fade_tween.EASE_IN_OUT
		fade_tween.tween_property(combo_label, "modulate:a", 0.0, score_manager.combo_interval)
