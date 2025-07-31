extends Control

@onready var die_label: Label = $VBoxContainer/DieLabel
@onready var draw_info_label: Label = $VBoxContainer/DrawInfoLabel

@export var die_string: String = "rock beats rock?":
	get:
		return die_string
	set(value):
		die_string = value
		die_label.text = die_string
		
@export var show_draw_info: bool = false:
	get:
		return show_draw_info
	set(value):
		show_draw_info = value
		draw_info_label.visible = show_draw_info
		
