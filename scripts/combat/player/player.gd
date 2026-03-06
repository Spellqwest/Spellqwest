@tool
extends Node2D
class_name Player

signal hp_changed(current: int, max: int)
signal coins_changed(coins: int)

@export var stats: PlayerStats

var current_hp: int
var coins: int

func _ready() -> void:
	current_hp = stats.max_hp
	coins = stats.starting_coins

	_emit_all()

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	emit_signal("hp_changed", current_hp, stats.max_hp)

func heal(amount: int) -> void:
	current_hp = min(stats.max_hp, current_hp + amount)
	emit_signal("hp_changed", current_hp, stats.max_hp)

func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	emit_signal("coins_changed", coins)
	return true

func _emit_all() -> void:
	emit_signal("hp_changed", current_hp, stats.max_hp)
	emit_signal("coins_changed", coins)
