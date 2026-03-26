@tool
extends Node2D
class_name Player

signal hp_changed(current: int, max: int)
signal mana_changed(current: float, max: float)
signal mana_regen_changed(current: float)
signal hp_empty
signal coins_changed(coins: int)

@export var stats: PlayerStats

var current_hp: int
var coins: int
var current_mana: float
var mana_regen: float

var _regen_interval: float = 1.0
var _regen_timer: float = 0.0
var _regen_cooldown: float = 0.0

func _ready() -> void:
	if stats != null:
		current_hp = stats.current_hp
		coins = stats.starting_coins
		current_mana = stats.current_mana
		mana_regen = stats.mana_regen
	_emit_all()

func apply_run_stats(run_stats: PlayerStats) -> void:
	if run_stats == null:
		return

	stats = run_stats
	current_hp = stats.current_hp
	current_mana = stats.current_mana
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
		emit_signal("mana_changed", current_mana, stats.max_mana)
	emit_signal("coins_changed", coins)

func use_mana(amount: float) -> bool:
	if current_mana - amount >= 0:
		current_mana = max(0, current_mana - amount)
		stats.current_mana = current_mana
		emit_signal("mana_changed", current_mana, stats.max_mana)
		return true
	else:
		return false

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or stats == null:
		return

	if _regen_cooldown > 0:
		_regen_cooldown -= delta
		return

	_regen_timer += delta
	if _regen_timer >= _regen_interval:
		_regen_timer = 0.0
		_tick_mana_regen()

func pause_mana_regen(duration: float = 1.0) -> void:
	_regen_cooldown = duration
	_regen_timer = 0.0

func change_mana_regen(amount: float):
	stats.mana_regen = amount
	emit_signal("mana_regen_changed", amount)

func _tick_mana_regen():
	if !(current_mana + mana_regen > stats.max_mana):
		current_mana += mana_regen
	else:
		current_mana = stats.max_mana
	stats.current_mana = current_mana
	emit_signal("mana_changed", current_mana, stats.max_mana)