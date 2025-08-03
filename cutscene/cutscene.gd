extends Control

@onready var frames: Node = $Frames
@onready var narration = $Narration

var beating_items: Array = []
var narration_list: Array = [
	"In a world where people speak through rock, paper, and scissors... a new shop quietly opens its doors.",
	"But it doesn’t take long for the complaints to start piling up.",
	"In this world, arguments aren’t solved with words—they're settled with a single throw.",
	"To survive angry customers, the shopkeeper must play and win, or be chased out of his own store."
]
var current_item: int = 0
var can_proceed: bool = false
var sfx = preload("res://sfx/woosh2.mp3")

func _ready():
	initialize_items()
	show_item(0)
	
func initialize_items():
	beating_items = frames.get_children()
	for item in beating_items:
		item.modulate.a = 0.0

func show_item(index: int) -> void:
	if index >= beating_items.size():
		return
		
	narration.text = narration_list[index]
	
		
	current_item = index
	var item = beating_items[index]
	var original_pos = item.position
	item.position = original_pos + Vector2(-400, 0)

	AudioHandler.play_sfx(sfx, 3, randf_range(0.5, 0.8))
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "position", original_pos, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(item, "modulate:a", 1.0, 0.4)
	tween.tween_callback(func():
		var anim_player: AnimationPlayer = item.get_node("AnimationPlayer")
		anim_player.play("beating")
		can_proceed = true
		if index == 3:
			show_remaining_items(index + 1)
	)

func show_remaining_items(start_index: int) -> void:
	for i in range(start_index, beating_items.size()):
		show_item_pop(i)
		await get_tree().create_timer(0.2).timeout

func show_item_pop(index: int) -> void:
	var item = beating_items[index]
	item.scale = Vector2(0.0, 0.0)
	item.rotation_degrees = -30
	item.modulate.a = 0.0
	
	AudioHandler.play_sfx(sfx, 3, randf_range(0.5, 0.8))
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "modulate:a", 1.0, 0.2)
	tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(item, "rotation_degrees", 0.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		item.get_node("AnimationPlayer").play("beating")
		can_proceed = true
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and can_proceed:
		can_proceed = false
		current_item += 1
		if current_item < beating_items.size() and current_item <= 3:
			show_item(current_item)
		else:
			get_tree().change_scene_to_file("res://game/game.tscn")
