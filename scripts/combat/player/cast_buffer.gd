extends Node
class_name CastBuffer

signal buffer_changed(active: int, max_active: int)
signal spell_started(spell: SpellResource, cast_time: float)
signal spell_ready(spell: SpellResource)

@onready var run_state = get_parent().get_node_or_null("RunState")

var _active: Array[Dictionary] = []

func max_size() -> int:
	if run_state != null and "stats" in run_state and run_state.stats != null:
		return max(1, int(run_state.stats.buffer_size))
	return 2

func add_spell(spell: SpellResource) -> bool:
	if _active.size() >= max_size():
		emit_signal("buffer_changed", _active.size(), max_size())
		return false

	var ct : float = max(0.0, float(spell.cast_time))
	_active.append({"spell": spell, "remaining": ct, "total": ct})

	emit_signal("buffer_changed", _active.size(), max_size())
	emit_signal("spell_started", spell, ct)
	return true

func _process(delta: float) -> void:
	if _active.is_empty():
		return

	for i in range(_active.size() - 1, -1, -1):
		_active[i]["remaining"] -= delta
		if _active[i]["remaining"] <= 0.0:
			var spell: SpellResource = _active[i]["spell"]
			_active.remove_at(i)
			emit_signal("buffer_changed", _active.size(), max_size())
			emit_signal("spell_ready", spell)
			
func get_active_casts() -> Array[Dictionary]:
	return _active
