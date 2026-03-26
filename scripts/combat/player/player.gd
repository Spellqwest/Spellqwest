@tool
extends Node2D
class_name Player

signal hp_changed(current: int, max: int)
signal hp_empty
signal coins_changed(coins: int)

@export var stats: PlayerStats

var current_hp: int
var coins: int

func _ready() -> void:
	if stats != null:
		current_hp = stats.current_hp
		coins = stats.starting_coins
	_emit_all()

func apply_run_stats(run_stats: PlayerStats) -> void:
	if run_stats == null:
		return

	stats = run_stats
	current_hp = stats.current_hp
	_emit_all()

func take_damage(amount: int) -> void:
	if stats == null:
		return

	current_hp = max(0, current_hp - amount)
	#print(str(current_hp))
	stats.current_hp = current_hp
	
	emit_signal("hp_changed", current_hp, stats.max_hp)
	
	if(current_hp <= 0):
		emit_signal("hp_empty")
	
	#if(current_hp > 0):
		#emit_signal("hp_changed", current_hp, stats.max_hp)
	#else:
		#emit_signal("hp_empty")
		#without hp_changed being active, the hud won't update the players health

func heal(amount: int) -> void:
	if stats == null:
		return

	current_hp = min(stats.max_hp, current_hp + amount)
	stats.current_hp = current_hp
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
	if stats != null:
		emit_signal("hp_changed", current_hp, stats.max_hp)
	emit_signal("coins_changed", coins)
