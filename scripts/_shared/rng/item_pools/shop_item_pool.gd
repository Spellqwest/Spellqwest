extends Resource
class_name ShopItemPool

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@export var items: Array[ItemResource] = []

func get_all_items() -> Array[ItemResource]:
	return items

func get_items_by_type(item_type: int) -> Array[ItemResource]:
	var out: Array[ItemResource] = []
	for item: ItemResource in items:
		if item != null and item.item_type == item_type:
			out.append(item)
	return out
