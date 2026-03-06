@tool
extends Node

var spells: Dictionary = {}
var enemies: Dictionary = {}

func _ready() -> void:
	_load_spells()
	_load_enemies()

	print("ContentDB loaded:")
	print("Spells: ", spells.keys())
	print("Enemies: ", enemies.keys())

# LOADERS
func _load_spells() -> void:
	var path := "res://resources/spells/"
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Failed to open spells directory")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = path + file_name
			var res = load(full_path)

			if res != null and res.has_method("get"):
				if res.id != "":
					spells[res.id] = res
				else:
					push_warning("Spell missing id: " + full_path)

		file_name = dir.get_next()

	dir.list_dir_end()

func _load_enemies() -> void:
	var path := "res://resources/enemies/"
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Failed to open enemies directory")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = path + file_name
			var res = load(full_path)

			if res != null:
				if res.id != "":
					enemies[res.id] = res
				else:
					push_warning("Enemy missing id: " + full_path)

		file_name = dir.get_next()

	dir.list_dir_end()

# GETTERS
func get_spell(id: String):
	return spells.get(id, null)

func get_enemy(id: String):
	return enemies.get(id, null)

func get_all_spells() -> Array:
	return spells.values()

func get_all_enemies() -> Array:
	return enemies.values()
