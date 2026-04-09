extends RewardResource
class_name ItemRewardResource

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@export var item: ItemResource

func can_grant(run_state: RunState, _spell_book: SpellBook = null) -> bool:
	return run_state != null and item != null

func grant(run_state: RunState, _spell_book: SpellBook = null) -> bool:
	if run_state == null or item == null:
		return false

	run_state.add_item(item)
	return true
