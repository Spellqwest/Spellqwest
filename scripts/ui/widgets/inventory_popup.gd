extends Control
class_name InventoryPopup

const InventoryState = preload("res://scripts/inventory/inventory_state.gd")
const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@onready var panel: PanelContainer = $Panel
@onready var coins_label: Label = $Panel/Margin/VBox/Header/Coins
@onready var consumable_slot_label: Label = $Panel/Margin/VBox/EquipRow/ConsumableSlot/ConsumableSlotMargin/ConsumableSlotLabel
@onready var weapon_slot_label: Label = $Panel/Margin/VBox/EquipRow/WeaponSlot/WeaponSlotMargin/WeaponSlotLabel
@onready var items_scroll: ScrollContainer = $Panel/Margin/VBox/ItemsPanel/ItemsMargin/ItemsScroll
@onready var items_grid: GridContainer = $Panel/Margin/VBox/ItemsPanel/ItemsMargin/ItemsScroll/ItemsGrid

var _run_state: RunState
var _inventory: InventoryState

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if items_grid != null:
		items_grid.columns = 4
	
	_set_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if not is_node_ready():
			return
		_set_layout()

func show_popup(run_state: RunState) -> void:
	_run_state = run_state

	if _run_state != null:
		if _run_state.inventory == null:
			_run_state.ensure_inventory()

		if _inventory != null and _inventory.changed.is_connected(_on_inventory_changed):
			_inventory.changed.disconnect(_on_inventory_changed)

		_inventory = _run_state.inventory

		if _inventory != null and not _inventory.changed.is_connected(_on_inventory_changed):
			_inventory.changed.connect(_on_inventory_changed)

	_refresh()
	show()

func hide_popup() -> void:
	hide()

func _on_inventory_changed() -> void:
	_refresh()

func _set_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size := Vector2(viewport_size.x * 0.7, viewport_size.y * 0.7)
	var margin := 48.0

	panel.size = panel_size
	panel.position = (viewport_size - panel_size) * 0.5

	if panel.position.x < margin:
		panel.position.x = margin
	if panel.position.y < margin:
		panel.position.y = margin

	if panel.position.x + panel.size.x > viewport_size.x - margin:
		panel.size.x = max(200.0, viewport_size.x - margin * 2.0)
		panel.position.x = margin

	if panel.position.y + panel.size.y > viewport_size.y - margin:
		panel.size.y = max(200.0, viewport_size.y - margin * 2.0)
		panel.position.y = margin

func _refresh() -> void:
	_refresh_coins()
	_refresh_equipment_slots()
	_refresh_items_grid()

func _refresh_coins() -> void:
	var coins: int = 0
	if _run_state != null:
		coins = _run_state.current_coins
	coins_label.text = "Coins: %d" % coins

func _refresh_equipment_slots() -> void:
	if _inventory == null:
		consumable_slot_label.text = "Consumable\n[Empty]"
		weapon_slot_label.text = "Weapon\n[Empty]"
		return

	if _inventory.equipped_consumable != null:
		consumable_slot_label.text = "Consumable\n%s" % _inventory.equipped_consumable.display_name
	else:
		consumable_slot_label.text = "Consumable\n[Empty]"

	if _inventory.equipped_weapon != null:
		weapon_slot_label.text = "Weapon\n%s" % _inventory.equipped_weapon.display_name
	else:
		weapon_slot_label.text = "Weapon\n[Empty]"

func _refresh_items_grid() -> void:
	if items_grid == null:
		push_error("InventoryPopup: items_grid is null.")
		return

	for child in items_grid.get_children():
		child.queue_free()

	if _inventory == null:
		print("InventoryPopup: _inventory is null")
		return

	var items: Array[ItemResource] = _inventory.get_all_items()
	print("InventoryPopup: refreshing items, count = ", items.size())

	for item: ItemResource in items:
		var slot: Button = _make_item_slot(item)
		items_grid.add_child(slot)

	items_grid.queue_sort()

func _make_item_slot(item: ItemResource) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(140, 90)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if item == null:
		button.text = "Unknown"
	else:
		button.text = item.display_name

	button.pressed.connect(func() -> void:
		_on_item_pressed(item)
	)

	return button

func _on_item_pressed(item: ItemResource) -> void:
	if _inventory == null or item == null:
		return

	match item.item_type:
		ItemResource.ItemType.CONSUMABLE, ItemResource.ItemType.WEAPON:
			_inventory.equip(item)
		ItemResource.ItemType.PASSIVE:
			pass
