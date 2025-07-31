extends CanvasLayer

@export var player: NodePath
@onready var player_die_ui: Control = $PlayerDieUI

@export var show_die_ui: bool = false:
	get:
		return show_die_ui
	set(value):
		show_die_ui = value
		player_die_ui.visible = show_die_ui

func _ready() -> void:
	var player = get_node(player)
	player.get_node("HitboxComponent").connect("duel", change_die_string)
	player.get_node("HealthComponent").connect("die", player_die)

func player_die() -> void:
	show_die_ui = true
	
func change_die_string(win: bool, opponent: HitboxComponent) -> void:
	if win: return
	
	var player_rps_string = ""
	var opponent_rps_string = ""
	var question_mark_if_draw = ""
	
	var player = get_node(player)
	match(player.get_node("HitboxComponent").rps_component.current_rps_type):
		Enums.RPSType.ROCK:
			player_rps_string = "rock"
		Enums.RPSType.PAPER:
			player_rps_string = "paper"
		Enums.RPSType.SCISSOR:
			player_rps_string = "scissor"
	
	match(opponent.rps_component.current_rps_type):
		Enums.RPSType.ROCK:
			opponent_rps_string = "rock"
		Enums.RPSType.PAPER:
			opponent_rps_string = "paper"
		Enums.RPSType.SCISSOR:
			opponent_rps_string = "scissor"
	
	question_mark_if_draw = "?" if player_rps_string == opponent_rps_string else "" 
	
	player_die_ui.show_draw_info = (player_rps_string == opponent_rps_string)
	player_die_ui.die_string = opponent_rps_string + " beats " + player_rps_string + question_mark_if_draw
	
	
