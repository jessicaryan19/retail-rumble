extends CanvasLayer

@export var score_manager: NodePath
@onready var score_label = $ScoreLabel

func _ready():
	var score_manager = get_node(score_manager)
	score_manager.score_changed.connect(update_score_label, score_manager.score)

func update_score_label(new_score: int):
	score_label.text = "Score: %d" % new_score
