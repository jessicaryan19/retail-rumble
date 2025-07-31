extends Control

@onready var button_container = $ButtonContainer
@onready var player = get_tree().get_first_node_in_group("player")

var rock_button
var paper_button
var scissor_button
var rps_component

func _ready():
	rps_component = player.rps_component
	rock_button = button_container.get_node("RockButton")
	paper_button = button_container.get_node("PaperButton")
	scissor_button = button_container.get_node("ScissorButton")
	
	rock_button.configure("J", "ROCK")
	paper_button.configure("K", "PAPER")
	scissor_button.configure("L", "SCISSOR")
	
func _process(_delta):
	update_active_rps_button()

func update_active_rps_button():
	var current = rps_component.current_rps_type
	rock_button.set_button_state(current == Enums.RPSType.ROCK)
	paper_button.set_button_state(current == Enums.RPSType.PAPER)
	scissor_button.set_button_state(current == Enums.RPSType.SCISSOR)
