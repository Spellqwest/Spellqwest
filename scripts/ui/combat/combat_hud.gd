extends Node

@onready var typed_label = $TypedPanel/TypedLabel

func set_typed_text(text: String) -> void:
	typed_label.text = text
