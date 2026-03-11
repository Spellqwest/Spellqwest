extends Control
class_name InventoryPopup

@onready var panel: PanelContainer = $Panel
@onready var coins_label: Label = $Panel/Margin/VBox/Header/Coins
@onready var consumable_slot_label: Label = $Panel/Margin/VBox/EquipRow/ConsumableSlot/ConsumableSlotMargin/ConsumableSlotLabel
@onready var weapon_slot_label: Label = $Panel/Margin/VBox/EquipRow/WeaponSlot/WeaponSlotMargin/WeaponSlotLabel
@onready var items_grid: GridContainer = $Panel/Margin/VBox/ItemsPanel/ItemsMargin/ItemsScroll/ItemsGrid

var _run_state: RunState

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_layout()

func show_popup(run_state: RunState) -> void:
	_run_state = run_state
	_set_layout()
	_refresh()
	show()

func hide_popup() -> void:
	hide()

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

	if panel.position.x + panel_size.x > viewport_size.x - margin:
		panel.size.x = max(200.0, viewport_size.x - margin * 2.0)
		panel.position.x = margin

	if panel.position.y + panel_size.y > viewport_size.y - margin:
		panel.size.y = max(200.0, viewport_size.y - margin * 2.0)
		panel.position.y = margin

func _refresh() -> void:
	_refresh_coins()
	_refresh_equipment_slots()
	_refresh_items_grid()

func _refresh_coins() -> void:
	var coins: int = 0

	if _run_state != null:
		if "current_coins" in _run_state:
			coins = _run_state.current_coins
		elif "Current_coins" in _run_state:
			coins = _run_state.Current_coins

	coins_label.text = "Coins: %d" % coins

func _refresh_equipment_slots() -> void:
	consumable_slot_label.text = "Consumable\n[Empty]"
	weapon_slot_label.text = "Weapon\n[Empty]"

func _refresh_items_grid() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	# Placeholder items until item system exists.
	for i in range(20):
		var slot := _make_placeholder_item_slot("Item %02d" % (i + 1))
		items_grid.add_child(slot)

func _make_placeholder_item_slot(item_name: String) -> Control:
	var panel_container := PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(120, 80)
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 8)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_right", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)
	panel_container.add_child(margin_container)

	var label := Label.new()
	label.text = item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin_container.add_child(label)

	return panel_container
