extends Node
class_name CombatCaster

func cast(spell: Resource, origin: Vector2) -> void:
	print("CAST:", spell.display_name, " word:", spell.word, " type:", spell.type, " from:", origin)
