extends Control

@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel
@onready var score_manager = get_node("/root/Game/ScoreManager")

var score_label_text: int = 0

var fade_tween: Tween
var score_tween: Tween

func do_fade_tween() -> void:
	if fade_tween and fade_tween.is_running(): fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(combo_label, "modulate:a", 0.0, score_manager.combo_interval)

func do_score_tween(target_value: int) -> void:
	if score_tween and score_tween.is_running(): score_tween.kill()
	score_tween = create_tween()
	score_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	score_tween.tween_property(self, "score_label_text", target_value, 1)
	

func _ready():
	score_manager.score_changed.connect(update_score_label, score_manager.score)
	score_manager.combo_changed.connect(update_combo_label, score_manager.combo)

func _process(delta: float) -> void:
	score_label.text = "Score: %d" % score_label_text
	
func update_score_label(new_score: int):
	do_score_tween(new_score)
	
func update_combo_label(new_combo: int):
	if new_combo <= 1:
		combo_label.text = ""
	else:
		combo_label.text = "Combo %d" % new_combo
		combo_label.modulate.a = 1.0

		if fade_tween and fade_tween.is_running():
			fade_tween.kill()

		do_fade_tween()
		
