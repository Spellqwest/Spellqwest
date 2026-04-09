@tool
extends Node
class_name RunState

const MapStageData = preload("res://data/map/map_stage_data.gd")
const InventoryState = preload("res://scripts/inventory/inventory_state.gd")
const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")
const WeaponEffect = preload("res://scripts/inventory/items/weapon_effect.gd")

const USE_CONTEXT_MAP := 0
const USE_CONTEXT_COMBAT := 1

@export var current_coins: int = 0
@export var stats: PlayerStats

var inventory: InventoryState
var current_use_context: int = USE_CONTEXT_MAP
var current_map_stage: MapStageData
var current_combat_screen: CombatScreen
var current_stage_index: int = 1
var has_next_hit_shield: bool = false
var learned_spell_ids: Dictionary = {}  # id -> true

func _ready() -> void:
	ensure_inventory()

func initialize_run_state() -> void:
	if stats != null:
		current_coins = stats.starting_coins
	else:
		current_coins = 0

	learned_spell_ids.clear()
	ensure_inventory()

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

func ensure_inventory() -> void:
	if inventory == null:
		inventory = InventoryState.new()

func add_item(item: ItemResource) -> void:
	ensure_inventory()
	inventory.add_item(item)

func remove_item(item: ItemResource) -> bool:
	ensure_inventory()
	return inventory.remove_item(item)

func equip_item(item: ItemResource) -> bool:
	ensure_inventory()
	return inventory.equip(item)

func can_use_item(item: ItemResource) -> bool:
	if item == null:
		return false

	ensure_inventory()

	if not inventory.has_item(item):
		return false

	match item.item_type:
		ItemResource.ItemType.CONSUMABLE:
			return _can_use_consumable(item)
		ItemResource.ItemType.WEAPON:
			return _can_use_weapon(item)
		ItemResource.ItemType.PASSIVE:
			return false
		_:
			return false

func _can_use_consumable(item: ItemResource) -> bool:
	if current_use_context == USE_CONTEXT_MAP and not item.can_use_on_map:
		return false

	if current_use_context == USE_CONTEXT_COMBAT and not item.can_use_in_combat:
		return false

	if item.requires_equip_to_use and inventory.equipped_consumable != item:
		return false

	return true

func _can_use_weapon(item: ItemResource) -> bool:
	if current_use_context != USE_CONTEXT_COMBAT:
		return false

	if not item.can_use_in_combat:
		return false

	if inventory.equipped_weapon != item:
		return false

	return true

func use_item(item: ItemResource) -> bool:
	if not can_use_item(item):
		return false

	if item == null or item.effect == null:
		return false

	match item.item_type:
		ItemResource.ItemType.CONSUMABLE:
			item.effect.apply(self, current_use_context)
			inventory.remove_item(item)
			TaloTracker.track_item_use(item.display_name)
			return true

		ItemResource.ItemType.WEAPON:
			if item.effect is WeaponEffect:
				var weapon_effect := item.effect as WeaponEffect
				weapon_effect.apply_weapon(self, current_combat_screen)
				TaloTracker.track_item_use(item.display_name)
				return true
			return false

		ItemResource.ItemType.PASSIVE:
			return false

	return false

func get_owned_passives() -> Array[ItemResource]:
	ensure_inventory()
	return inventory.get_passives()

func set_current_combat_screen(screen: CombatScreen) -> void:
	current_combat_screen = screen

func clear_current_combat_screen() -> void:
	current_combat_screen = null

#DEBUG
func add_test_items() -> void:
	add_item(preload("res://resources/items/health_potion.tres"))
	add_item(preload("res://resources/items/ink_flask.tres"))
	add_item(preload("res://resources/items/crossbow.tres"))

func game_over_reset() -> void:
	stats.current_hp = stats.max_hp
