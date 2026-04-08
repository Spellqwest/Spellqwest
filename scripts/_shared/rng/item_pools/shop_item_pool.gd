extends Resource
class_name ShopItemPool

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")
const RewardResource = preload("res://scripts/events/reward_resource.gd")

@export var items: Array[ItemResource] = []
@export var special_rewards: Array[RewardResource] = []

func get_all_valid_items() -> Array[ItemResource]:
	var out: Array[ItemResource] = []
	for item: ItemResource in items:
		if item != null:
			out.append(item)
	return out

func get_all_valid_special_rewards(run_state: RunState) -> Array[RewardResource]:
	var out: Array[RewardResource] = []
	for reward: RewardResource in special_rewards:
		if reward == null:
			continue
		if run_state != null and not reward.can_grant(run_state):
			continue
		out.append(reward)
	return out
