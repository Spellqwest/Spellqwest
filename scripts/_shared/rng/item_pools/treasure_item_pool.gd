extends Resource
class_name TreasureItemPool

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@export var items: Array[ItemResource] = []

func roll_random_item(rng: RandomNumberGenerator) -> ItemResource:
	if items.is_empty():
		return null
	var index: int = rng.randi_range(0, items.size() - 1)
	return items[index]
