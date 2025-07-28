extends Area2D
class_name HitboxComponent

signal win(opponent: HitboxComponent)
signal lose(opponent: HitboxComponent)

@export var rps_component: RPSComponent
@export var target: HitboxComponent = null

func reset_target() -> void:
	target = null

func _on_area_entered(area: Area2D) -> void:
	
	if area is not HitboxComponent: return 
	
	if area != target: return
	
	var my_rps_type = rps_component.current_rps_type
		
	# if draw
	if area.rps_component.current_rps_type == my_rps_type:
		if area.rps_component.priority < rps_component.priority:
			emit_signal("lose", area)
		else:
			emit_signal("win", area)
			
		return # make sure to return
	
	# check wether win or lose
	match area.rps_component.current_rps_type:
		Enums.RPSType.ROCK:
			if my_rps_type == Enums.RPSType.SCISSOR:
				emit_signal("lose", area)
			else:
				emit_signal("win", area)
					
		Enums.RPSType.PAPER:
			if my_rps_type == Enums.RPSType.ROCK:
				emit_signal("lose", area)
			else:
				emit_signal("win", area)
					
		Enums.RPSType.SCISSOR:
			if my_rps_type == Enums.RPSType.PAPER:
				emit_signal("lose", area)
			else:
				emit_signal("win", area)
				
	
