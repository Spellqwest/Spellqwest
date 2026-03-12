extends Resource
class_name InventoryState

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@export var items: Array[ItemResource] = []
@export var equipped_consumable: ItemResource
@export var equipped_weapon: ItemResource

func add_item(item: ItemResource) -> void:
	if item == null:
		return
	items.append(item)
	changed.emit()

func remove_item(item: ItemResource) -> bool:
	if item == null:
		return false

	var idx := items.find(item)
	if idx == -1:
		return false

	items.remove_at(idx)

	if equipped_consumable == item:
		equipped_consumable = null
	if equipped_weapon == item:
		equipped_weapon = null

	changed.emit()
	return true

func get_all_items() -> Array[ItemResource]:
	return items

func get_passives() -> Array[ItemResource]:
	var out: Array[ItemResource] = []
	for item: ItemResource in items:
		if item != null and item.item_type == ItemResource.ItemType.PASSIVE:
			out.append(item)
	return out

func has_item(item: ItemResource) -> bool:
	return items.has(item)

func can_equip(item: ItemResource) -> bool:
	if item == null:
		return false

	return item.item_type == ItemResource.ItemType.CONSUMABLE \
		or item.item_type == ItemResource.ItemType.WEAPON

func equip(item: ItemResource) -> bool:
	if item == null or not has_item(item):
		return false

	match item.item_type:
		ItemResource.ItemType.CONSUMABLE:
			equipped_consumable = item
			changed.emit()
			return true
		ItemResource.ItemType.WEAPON:
			equipped_weapon = item
			changed.emit()
			return true
		_:
			return false

func unequip_consumable() -> void:
	equipped_consumable = null
	changed.emit()

func unequip_weapon() -> void:
	equipped_weapon = null
	changed.emit()
