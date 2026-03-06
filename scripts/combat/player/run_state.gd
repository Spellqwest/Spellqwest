@tool
extends Node
class_name RunState

@export var stats: PlayerStats
var learned_spell_ids: Dictionary = {}  # id -> true

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

func get_learned_spell_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for k in learned_spell_ids.keys():
		out.append(k as StringName)
	return out
