extends Node
class_name SpellBook

@export var spells: Array[Resource] = []  
var _by_word: Dictionary = {} # word -> spell

func _ready() -> void:
	_by_word.clear()
	for s in spells:
		if s == null:
			continue
		_by_word[str(s.word).to_lower()] = s

func get_by_word(word: String) -> Resource:
	return _by_word.get(word.to_lower(), null)

func get_all_spells() -> Array[Resource]:
	return spells
