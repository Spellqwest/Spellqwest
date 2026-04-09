extends Resource
class_name TreasureItemPool

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")
const RewardResource = preload("res://scripts/events/reward_resource.gd")

@export var items: Array[ItemResource] = []
@export var special_rewards: Array[RewardResource] = []

func roll_random_entry(rng: RandomNumberGenerator, run_state: RunState, spell_book: SpellBook = null) -> Dictionary:
	var entries: Array = []

	for item: ItemResource in items:
		if item != null:
			entries.append({
				"type": "item",
				"value": item
			})

	for reward: RewardResource in special_rewards:
		if reward == null:
			continue
		if run_state != null and not reward.can_grant(run_state, spell_book):
			continue
		entries.append({
			"type": "reward",
			"value": reward
		})

	if entries.is_empty():
		return {}

	var idx: int = rng.randi_range(0, entries.size() - 1)
	return entries[idx]
