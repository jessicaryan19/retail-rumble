extends Control

@onready var health_container = $HealthContainer
@onready var player = get_tree().get_first_node_in_group("player")

const HEART_SCENE := preload("res://game/ui/heart.tscn")
var heart_sprites: Array[AnimatedSprite2D] = []
var max_health: int

func _ready():
	max_health = player.health_component.MAX_HEALTH
	player.health_component.took_damage.connect(update_health_ui)
	setup_hearts()

func setup_hearts():
	for child in health_container.get_children():
		child.queue_free()
	heart_sprites.clear()

	for i in max_health:
		var heart_container = HEART_SCENE.instantiate()
		var heart_sprite = heart_container.get_node("HeartSprite")
		heart_sprite.animation = "full"
		health_container.add_child(heart_container)
		heart_sprites.append(heart_sprite)

func update_health_ui():
	var current_health = player.health_component.health
	if current_health >= 0:
		var heart_sprite = heart_sprites[current_health]
		heart_sprite.play("fade_to_empty")
