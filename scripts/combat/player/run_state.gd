extends Node

var learned_spell_ids: Dictionary = {} # StringName -> true

func learn_spell(id: StringName) -> void:
	learned_spell_ids[id] = true

func knows_spell(id: StringName) -> bool:
	return learned_spell_ids.has(id)

func learn_all_spells(spells: Array) -> void:
	learned_spell_ids.clear()
	for s in spells:
		if s == null:
			continue
		learn_spell(s.id)
