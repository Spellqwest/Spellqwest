extends Control
class_name ItemActionPopup

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

signal equip_requested(item)
signal use_requested(item)
signal inspect_requested(item)

@onready var panel: PanelContainer = $Panel
@onready var vbox: VBoxContainer = $Panel/Margin/VBox
@onready var equip_button: Button = $Panel/Margin/VBox/EquipButton
@onready var use_button: Button = $Panel/Margin/VBox/UseButton
@onready var inspect_button: Button = $Panel/Margin/VBox/InspectButton


var _item: ItemResource

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

	equip_button.pressed.connect(_on_equip_pressed)
	use_button.pressed.connect(_on_use_pressed)
	inspect_button.pressed.connect(_on_inspect_pressed)

func show_for_item(item: ItemResource, screen_position: Vector2) -> void:
	_item = item
	_update_buttons()

	vbox.queue_sort()
	panel.reset_size()

	show()
	await get_tree().process_frame
	panel.reset_size()
	_position_panel(screen_position)

func hide_popup() -> void:
	_item = null
	hide()

func _update_buttons() -> void:
	if _item == null:
		equip_button.visible = false
		use_button.visible = false
		inspect_button.visible = false
	else:
		equip_button.visible = (
			_item.item_type == ItemResource.ItemType.CONSUMABLE
			or _item.item_type == ItemResource.ItemType.WEAPON
		)

		use_button.visible = (
			_item.item_type == ItemResource.ItemType.CONSUMABLE
			and _item.can_use_on_map
		)

		inspect_button.visible = true

	vbox.queue_sort()
	panel.reset_size()

func _position_panel(screen_position: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = panel.size

	if panel_size == Vector2.ZERO:
		panel_size = panel.get_combined_minimum_size()

	var pos: Vector2 = screen_position

	if pos.x + panel_size.x > viewport_size.x - 8.0:
		pos.x = viewport_size.x - panel_size.x - 8.0
	if pos.y + panel_size.y > viewport_size.y - 8.0:
		pos.y = viewport_size.y - panel_size.y - 8.0

	if pos.x < 8.0:
		pos.x = 8.0
	if pos.y < 8.0:
		pos.y = 8.0

	panel.position = pos

func _on_equip_pressed() -> void:
	if _item != null:
		equip_requested.emit(_item)
	hide_popup()

func _on_use_pressed() -> void:
	if _item != null:
		use_requested.emit(_item)
	hide_popup()

func _on_inspect_pressed() -> void:
	if _item != null:
		inspect_requested.emit(_item)
	hide_popup()
