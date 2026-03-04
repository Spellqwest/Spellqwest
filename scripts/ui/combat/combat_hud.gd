extends Node

@export var slot_scene: PackedScene

@onready var typed_label = $TypedPanel/TypedLabel
@onready var grid: GridContainer = $CastPanel/CastGrid

var _slots: Array[CastSlot] = []
var cast_buffer: CastBuffer = null

func _process(_delta: float) -> void:
	if cast_buffer == null:
		return

	var casts: Array = cast_buffer.get_active_casts()
	_ensure_slot_count(casts.size())

	for i in range(casts.size()):
		var entry: Dictionary = casts[i]
		var spell: SpellResource = entry["spell"]
		var remaining: float = float(entry["remaining"])
		var total: float = float(entry["total"])

		if _slots[i].name_label.text == "" or _slots[i].name_label.text != spell.display_name:
			_slots[i].setup(spell, total)
		else:
			_slots[i].set_remaining(remaining)

func _ensure_slot_count(n: int) -> void:
	while _slots.size() > n:
		var s: CastSlot = _slots.pop_back() as CastSlot
		if s != null:
			s.queue_free()

	while _slots.size() < n:
		var slot := slot_scene.instantiate() as CastSlot
		grid.add_child(slot)
		_slots.append(slot)

func set_typed_text(text: String) -> void:
	typed_label.text = text

func set_cast_buffer(cb: CastBuffer) -> void:
	cast_buffer = cb
