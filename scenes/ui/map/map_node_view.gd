@tool
extends Node2D
class_name MapNodeView

signal pressed(node_id: int)

const MapNodeData = preload("res://data/map/map_node_data.gd")

@onready var button_area: Area2D = $ButtonArea
@onready var icon: CanvasItem = $Sprite2D
@onready var state_label: Label = $StateLabel

var data: MapNodeData

func setup(node_data: MapNodeData) -> void:
	data = node_data
	position = data.position
	_update_visuals()

func refresh() -> void:
	_update_visuals()

func _ready() -> void:
	button_area.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if data == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if data.available:
			pressed.emit(data.id)

func _update_visuals() -> void:
	if data == null:
		return

	state_label.text = _type_to_text(data.type)

	modulate = Color.WHITE
	scale = Vector2.ONE

	if data.visited:
		modulate = Color(0.7, 1.0, 0.7)
		scale = Vector2(1.15, 1.15)
	elif data.available:
		modulate = Color(1.0, 1.0, 1.0)
		scale = Vector2(1.0, 1.0)
	elif data.revealed:
		modulate = Color(0.75, 0.75, 0.75)
	else:
		modulate = Color(0.35, 0.35, 0.35)

func _type_to_text(type: int) -> String:
	match type:
		MapNodeData.NodeType.START:
			return "Start"
		MapNodeData.NodeType.COMBAT:
			return "Combat"
		MapNodeData.NodeType.HARD_COMBAT:
			return "Hard"
		MapNodeData.NodeType.BOSS:
			return "Boss"
		MapNodeData.NodeType.SHOP:
			return "Shop"
		MapNodeData.NodeType.TREASURE:
			return "Treasure"
		MapNodeData.NodeType.SPECIAL:
			return "Special"
		_:
			return "?"
