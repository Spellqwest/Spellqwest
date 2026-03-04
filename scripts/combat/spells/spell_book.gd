extends Node
class_name SpellBook

@export var spells: Array[Resource] = []
var _by_word: Dictionary = {}
var _by_id: Dictionary = {}

func _ready() -> void:
	_rebuild_indexes()

func set_spells(new_spells: Array) -> void:
	var typed: Array[Resource] = []
	for s in new_spells:
		if s != null:
			typed.append(s)

	spells = typed
	_rebuild_indexes()

func _rebuild_indexes() -> void:
	_by_word.clear()
	_by_id.clear()

	for s in spells:
		if s == null:
			continue
		_by_word[str(s.word).to_lower()] = s
		_by_id[s.id] = s

func get_by_word(word: String) -> Resource:
	return _by_word.get(word.to_lower(), null)

func get_by_id(id: StringName) -> Resource:
	return _by_id.get(id, null)

func get_all_spells() -> Array[Resource]:
	return spells
