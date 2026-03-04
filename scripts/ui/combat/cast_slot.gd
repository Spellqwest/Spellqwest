extends PanelContainer
class_name CastSlot

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var bar: ProgressBar = $VBoxContainer/Progress

var total: float = 1.0
var remaining: float = 0.0

func setup(spell: SpellResource, cast_time: float) -> void:
	name_label.text = spell.display_name
	total = max(0.001, cast_time)
	remaining = cast_time
	_update_bar()

func set_remaining(time_left: float) -> void:
	remaining = max(0.0, time_left)
	_update_bar()

func _update_bar() -> void:
	bar.value = 1.0 - (remaining / total)
