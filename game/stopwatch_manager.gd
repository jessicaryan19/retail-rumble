extends Node2D

@onready var stopwatch: Stopwatch = $Stopwatch

@export var stopwatch_label: Label

func _process(delta: float) -> void:
	if stopwatch_label is Label:
		stopwatch_label.text = stopwatch.get_elapsed_time_as_formatted_string("{MM}:{ss}")
