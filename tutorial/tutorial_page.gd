extends Control

@onready var page1 = $Page1
@onready var page2 = $Page2
@onready var prev_button = $ButtonContainer/PrevButton
@onready var next_button = $ButtonContainer/NextButton
@onready var button_close = $ButtonClose

var current_page := 1
var can_switch_page := false

func _ready() -> void:
	page1.visible = false
	page2.visible = false
	prev_button.visible = false
	next_button.set_text("Next")
	prev_button.set_text("Prev")
	
	next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)

func _animate_page(page: Control) -> void:
	can_switch_page = false
	
	for item in page.get_children():
		_stop_animation(item)
		item.scale = Vector2.ZERO
	
	for i in page.get_children().size():
		var item = page.get_child(i)
		var delay = 0.1 * i
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(item, "scale", Vector2.ONE, 0.25).set_delay(delay)
		tween.tween_callback(func(): _start_animation(item)).set_delay(delay)
		if i == page.get_children().size() - 1:
			await tween.finished
		
	can_switch_page = true

func _start_animation(item: Node) -> void:
	var anim := item.get_node_or_null("AnimationPlayer")
	if anim and not anim.is_playing():
		anim.play("beating")

func _stop_animation(item: Node) -> void:
	var anim := item.get_node_or_null("AnimationPlayer")
	if anim:
		anim.stop()

func _on_next_pressed() -> void:
	if not can_switch_page:
		return
	_switch_page(2)

func _on_prev_pressed() -> void:
	if not can_switch_page:
		return
	_switch_page(1)

func _switch_page(page_number: int) -> void:
	page1.visible = (page_number == 1)
	page2.visible = (page_number == 2)
	current_page = page_number

	prev_button.visible = (page_number == 2)
	next_button.visible = (page_number == 1)

	var page = page1 if page_number == 1 else page2
	await _animate_page(page)

func _on_close() -> void:
	page1.visible = false
	page2.visible = false
	current_page = 1
	next_button.visible = true
	prev_button.visible = false
