@tool
extends Node
class_name RunState

const MapStageData = preload("res://data/map/map_stage_data.gd")

@export var stats: PlayerStats
var learned_spell_ids: Dictionary = {}  # id -> true
@export var current_coins: int = 0

var current_map_stage: MapStageData
var current_stage_index: int = 1

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
