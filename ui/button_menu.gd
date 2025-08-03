extends TextureButton

@onready var button_label = $Label

func set_text(label: String):
	button_label.text = label
