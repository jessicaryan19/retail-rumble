extends Area2D
class_name HitboxComponent

signal duel(win: bool, opponent: HitboxComponent)

@export var rps_component: RPSComponent
@export var target: HitboxComponent = null
@export var invincible: bool = false

func reset_target() -> void:
	target = null

func _on_area_entered(area: Area2D) -> void:
	
	if area is not HitboxComponent: return
	
	if not area.invincible and not invincible:
		if area != target:
			print("Area is not target")
			return
	
	#reset_target()
	
	var my_rps_type = rps_component.current_rps_type
		
	# if draw
	if area.rps_component.current_rps_type == my_rps_type:
		if area.rps_component.priority < rps_component.priority:
			if not invincible: emit_signal("duel", false, area)
		else:
			emit_signal("duel", true, area)
			
		return # make sure to return
	
	# check wether win or lose
	match area.rps_component.current_rps_type:
		Enums.RPSType.ROCK:
			if my_rps_type == Enums.RPSType.SCISSOR:
				if not invincible: emit_signal("duel", false, area)
			else:
				emit_signal("duel", true, area)
					
		Enums.RPSType.PAPER:
			if my_rps_type == Enums.RPSType.ROCK:
				if not invincible: emit_signal("duel", false, area)
			else:
				emit_signal("duel", true, area)
					
		Enums.RPSType.SCISSOR:
			if my_rps_type == Enums.RPSType.PAPER:
				if not invincible: emit_signal("duel", false, area)
			else:
				emit_signal("duel", true, area)
				
	
