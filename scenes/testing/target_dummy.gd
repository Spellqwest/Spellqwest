extends Area2D
class_name TargetDummy

@export var max_hp: int = 999
var hp: int

func _ready() -> void:
	hp = max_hp
	add_to_group("targets") 

func take_damage(amount: int) -> void:
	hp -= amount
	print("DUMMY HIT for", amount, "HP left:", hp)
