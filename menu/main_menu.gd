extends Node2D

@onready var rolling_door_bg = $RollingDoorBG
@onready var button_container = $ButtonContainer
@onready var game_logo = $GameLogo
@onready var tutorial_page = $TutorialPage
#@onready var tutorial_panel = $TutorialPanel

@onready var play_btn = button_container.get_node("Play")
@onready var tutorial_btn = button_container.get_node("Tutorial")
@onready var credit_btn = button_container.get_node("Credit")
@onready var exit_btn = button_container.get_node("Exit")

enum ActionType { NONE, PLAY, TUTORIAL, CREDITS }
var pending_action: ActionType = ActionType.NONE

func _ready():
	play_btn.set_text("Play")
	tutorial_btn.set_text("Tutorial")
	credit_btn.set_text("Credits")
	exit_btn.set_text("Exit")

	play_btn.pressed.connect(_on_play_pressed)
	tutorial_btn.pressed.connect(_on_tutorial_pressed)
	credit_btn.pressed.connect(_on_credit_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	rolling_door_bg.transition_finished.connect(_on_transition_finished)
	await transition_into_menu()

func _on_play_pressed():
	tutorial_page.visible = false
	pending_action = ActionType.PLAY
	transition_out_from_menu()

func _on_tutorial_pressed():
	pending_action = ActionType.TUTORIAL
	transition_out_from_menu()

func _on_credit_pressed():
	pending_action = ActionType.CREDITS
	transition_out_from_menu()

func _on_exit_pressed():
	get_tree().quit()

func transition_out_from_menu():
	button_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_logo.modulate.a = 1.0
	button_container.modulate.a = 1.0

	var tween = create_tween()
	tween.parallel().tween_property(game_logo, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(button_container, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(rolling_door_bg.roll_up)
	
func transition_into_menu():
	button_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_logo.modulate.a = 0.0
	button_container.modulate.a = 0.0

	var tween = create_tween()
	tween.parallel().tween_property(game_logo, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(button_container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		button_container.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func _on_transition_finished():
	match pending_action:
		ActionType.PLAY:
			#get_tree().change_scene_to_file("res://game/game.tscn")
			SceneManager.change_scene("res://game/game.tscn", {
				"pattern": "circle",
				"speed": 1.0,               
				"invert_on_leave": true,
				"ease": 5.0,
				"color" : Color("#FFD23C")
			})
			
		ActionType.TUTORIAL:
			show_tutorial()
		ActionType.CREDITS:
			show_credits()
		_:
			pass

func show_tutorial():
	tutorial_page.close_button.pressed.connect(_on_tutorial_closed)
	tutorial_page.page1.visible = true
	tutorial_page._animate_page(tutorial_page.page1)
	
func _on_tutorial_closed():
	await rolling_door_bg.roll_down()
	transition_into_menu()
	tutorial_page._on_close()
	
func show_credits():
	pass
