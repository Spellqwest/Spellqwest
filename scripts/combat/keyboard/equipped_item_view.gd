extends Node2D
class_name EquippedItemView

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@onready var icon: Sprite2D = $Icon
@onready var name_label: Label = $NameLabel

var item: ItemResource
var slot_name: String = ""

func setup(p_item: ItemResource, p_slot_name: String) -> void:
	item = p_item
	slot_name = p_slot_name
	_refresh()

func _refresh() -> void:
	if item == null:
		if icon != null:
			icon.visible = false
		name_label.text = ""
		return

	if icon != null:
		if item.icon != null:
			icon.texture = item.icon
			icon.visible = true
		else:
			icon.visible = false

	name_label.text = item.display_name
	name_label.position = Vector2(-20, 18)
