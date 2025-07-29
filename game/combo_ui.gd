extends CanvasLayer

@export var score_manager: NodePath
@onready var combo_label = $ComboLabel

func _ready():
	var score_manager = get_node(score_manager)
	score_manager.combo_changed.connect(update_combo_label, score_manager.combo)

func update_combo_label(new_combo: int):
	if new_combo <= 1:
		combo_label.text = ""
	else:
		combo_label.text = "Combo %d" % new_combo
