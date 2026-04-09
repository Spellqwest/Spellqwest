extends RefCounted
class_name ItemRewardRuntime

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

var item: ItemResource

func _init(p_item: ItemResource) -> void:
	item = p_item

func get_display_name() -> String:
	if item == null:
		return "Unknown"
	return item.display_name

func get_description() -> String:
	if item == null:
		return ""
	return item.description

func get_icon() -> Texture2D:
	if item == null:
		return null
	return item.icon

func get_shop_value() -> int:
	if item == null:
		return 0
	return item.shop_value

func can_grant(run_state: RunState) -> bool:
	return run_state != null and item != null

func grant(run_state: RunState) -> bool:
	if run_state == null or item == null:
		return false

	run_state.add_item(item)
	return true
