extends Control

@onready var page1 = $Page1
@onready var page2 = $Page2
@onready var prev_button = $ButtonContainer/PrevButton
@onready var next_button = $ButtonContainer/NextButton
@onready var button_close = $ButtonClose

var current_page: int = 1

func _ready():
	prev_button.set_text("Prev")
	next_button.set_text("Next")
	next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	page1.visible = false
	page2.visible = false
	prev_button.visible = false
	
func _animate_page(page: Node):
	for i in page.get_children():
		stop_beating_animation(i)
		i.scale = Vector2(0.0, 0.0)
		
		var tween = create_tween()
		var delay = 0.1 * page.get_children().find(i)
		
		tween.set_parallel(true)
		tween.tween_property(i, "scale", Vector2.ONE, 0.25).set_delay(delay)
		tween.tween_callback(Callable(self, "start_beating_animation").bind(i)).set_delay(delay)
		
func start_beating_animation(item: Node):
	var animation_player := item.get_node("AnimationPlayer")
	if animation_player and not animation_player.is_playing():
		animation_player.play("beating")
		
func stop_beating_animation(item: Node):
	var animation_player := item.get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.stop()

func _on_next_pressed():
	page1.visible = false
	page2.visible = true
	current_page = 2
	_animate_page(page2)
	next_button.visible = false
	prev_button.visible = true

func _on_prev_pressed():
	page2.visible = false
	page1.visible = true
	current_page = 1
	_animate_page(page1)
	next_button.visible = true
	prev_button.visible = false
	
func _on_close():
	page2.visible = false
	page1.visible = false
	current_page = 1
	next_button.visible = true
	prev_button.visible = false
