extends Control
class_name ItemInspectPopup

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

@onready var panel: PanelContainer = $Panel
@onready var name_label: Label = $Panel/Margin/VBox/Title
@onready var description_label: Label = $Panel/Margin/VBox/Description
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

	panel.custom_minimum_size = Vector2(360, 220)

	close_button.pressed.connect(hide_popup)
	_center_panel()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_center_panel()

func show_for_item(item: ItemResource) -> void:
	if item == null:
		return

	name_label.text = item.display_name
	description_label.text = item.description
	show()
	await get_tree().process_frame
	_center_panel()

func hide_popup() -> void:
	hide()

func _center_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = panel.size

	if panel_size == Vector2.ZERO:
		panel_size = panel.custom_minimum_size

	panel.position = (viewport_size - panel_size) * 0.5


func _on_close_button_pressed() -> void:
	hide_popup()
