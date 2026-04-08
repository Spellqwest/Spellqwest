@tool
extends Node2D
class_name MapScreen

signal node_chosen(node_data)
signal combat_requested(node_data)
signal shop_requested(node_data)
signal treasure_requested(node_data)
signal special_requested(node_data)
signal boss_requested(node_data)

const MapFloorData = preload("res://data/map/map_stage_data.gd")
const MapNodeData = preload("res://data/map/map_node_data.gd")
const MapGenerator = preload("res://data/map/map_generator.gd")

@export var map_node_scene: PackedScene

@export var mouse_follow_strength: float = 220.0
@export var edge_scroll_zone: float = 120.0
@export var edge_scroll_speed: float = 520.0
@export var edge_scroll_curve: float = 2.0
@export var wheel_scroll_amount: float = 80.0
@export var drag_enabled: bool = true
@export var move_speed: float = 300.0

@export_enum(
	"None:-1",
	"Combat:1",
	"Hard Combat:2",
	"Boss:3",
	"Shop:4",
	"Treasure:5",
	"Special:6"
) var debug_force_first_layer_node_type: int = -1

@onready var paths: Node2D = $Paths
@onready var nodes_root: Node2D = $Nodes
@onready var camera: Camera2D = $Camera2D
@onready var map_avatar: AnimatedSprite2D = $MapAvatar

var _is_moving_to_node: bool = false
var _pending_node: MapNodeData

var _dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO
var _base_camera_y: float = 0.0

var run_state: RunState
var floor_data: MapFloorData
var _node_views: Dictionary = {}

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()
	
	if camera != null:
		camera.enabled = true

	if map_avatar != null and map_avatar.sprite_frames != null:
		map_avatar.play("default")

func _process(delta: float) -> void:
	if camera == null or floor_data == null:
		return

	if _is_moving_to_node:
		_update_avatar_movement(delta)
		return

	if _dragging:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.y <= 0.0:
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

	var edge_velocity: float = 0.0

	if mouse_pos.y < edge_scroll_zone:
		var edge_t: float = 1.0 - (mouse_pos.y / edge_scroll_zone)
		edge_t = pow(edge_t, edge_scroll_curve)
		edge_velocity = -edge_t * edge_scroll_speed
	elif mouse_pos.y > viewport_size.y - edge_scroll_zone:
		var dist_from_bottom: float = viewport_size.y - mouse_pos.y
		var edge_t: float = 1.0 - (dist_from_bottom / edge_scroll_zone)
		edge_t = pow(edge_t, edge_scroll_curve)
		edge_velocity = edge_t * edge_scroll_speed

	_base_camera_y += edge_velocity * delta
	camera.position.y = _base_camera_y
	_clamp_camera()
	_base_camera_y = camera.position.y

func setup(p_run_state: RunState) -> void:
	run_state = p_run_state

func _on_visibility_changed() -> void:
	if camera == null:
		return

	camera.enabled = visible

func generate_new_floor(stage_index: int, seed: int = 0) -> void:
	var generator := MapGenerator.new()
	floor_data = generator.generate_floor(
		stage_index,
		seed,
		debug_force_first_layer_node_type
	)
	_rebuild_view()

func _rebuild_view() -> void:
	if floor_data == null:
		push_error("MapScreen: floor_data is null.")
		return

	if map_node_scene == null:
		push_error("MapScreen: map_node_scene is not assigned.")
		return

	_layout_map_roots()

	for child in nodes_root.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	_node_views.clear()

	for node: MapNodeData in floor_data.nodes:
		var view = map_node_scene.instantiate() as MapNodeView
		if view == null:
			push_error("MapScreen: failed to instantiate MapNodeView scene.")
			return

		nodes_root.add_child(view)
		view.setup(node)
		view.pressed.connect(_on_node_pressed)
		_node_views[node.id] = view

	if paths.has_method("set_floor_data"):
		paths.set_floor_data(floor_data)

	_focus_on_current_node()
	_position_avatar_on_current_node()

func _refresh_view() -> void:
	for node_id in _node_views.keys():
		var view: MapNodeView = _node_views[node_id] as MapNodeView
		if view != null:
			view.refresh()

	if paths.has_method("set_floor_data"):
		paths.set_floor_data(floor_data)

func _on_node_pressed(node_id: int) -> void:
	if _is_moving_to_node:
		return

	var node := floor_data.get_node_by_id(node_id)
	if node == null or not node.available:
		return

	_pending_node = node
	_is_moving_to_node = true

	if map_avatar != null and map_avatar.sprite_frames != null:
		map_avatar.play("default")

	var local_avatar_x: float = map_avatar.position.x - nodes_root.position.x
	map_avatar.flip_h = node.position.x < local_avatar_x

func _move_to_node(node: MapNodeData) -> void:
	var previous := floor_data.get_node_by_id(floor_data.current_node_id)
	if previous != null:
		previous.available = false

	floor_data.current_node_id = node.id
	node.visited = true
	node.revealed = true

	for n: MapNodeData in floor_data.nodes:
		n.available = false

	for child: MapNodeData in floor_data.get_children_of(node.id):
		child.available = true
		child.revealed = true

	_refresh_view()
	_focus_on_current_node()

func _emit_event_signal(node: MapNodeData) -> void:
	match node.type:
		MapNodeData.NodeType.COMBAT, MapNodeData.NodeType.HARD_COMBAT:
			combat_requested.emit(node)
		MapNodeData.NodeType.BOSS:
			boss_requested.emit(node)
		MapNodeData.NodeType.SHOP:
			shop_requested.emit(node)
		MapNodeData.NodeType.TREASURE:
			treasure_requested.emit(node)
		MapNodeData.NodeType.SPECIAL:
			special_requested.emit(node)
		MapNodeData.NodeType.START:
			pass

func _layout_map_roots() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var anchor := Vector2(viewport_size.x * 0.5, viewport_size.y - 140.0)

	nodes_root.position = anchor
	paths.position = anchor

func _unhandled_input(event: InputEvent) -> void:
	if camera == null:
		return

	if event is InputEventMouseButton:
		if drag_enabled and event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
			_last_mouse_pos = event.position
			if _dragging:
				_base_camera_y = camera.position.y

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.position.y -= wheel_scroll_amount
			_clamp_camera()
			_base_camera_y = camera.position.y

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.position.y += wheel_scroll_amount
			_clamp_camera()
			_base_camera_y = camera.position.y

	elif event is InputEventMouseMotion and _dragging:
		var delta_pos: Vector2 = event.position - _last_mouse_pos
		camera.position.y -= delta_pos.y
		_last_mouse_pos = event.position
		_clamp_camera()
		_base_camera_y = camera.position.y

func _clamp_camera() -> void:
	if floor_data == null or camera == null:
		return

	var top_y: float = 999999.0
	var bottom_y: float = -999999.0

	for node: MapNodeData in floor_data.nodes:
		top_y = min(top_y, node.position.y)
		bottom_y = max(bottom_y, node.position.y)

	var viewport_size: Vector2 = get_viewport_rect().size
	var half_h: float = viewport_size.y * 0.5

	var min_y: float = top_y + nodes_root.position.y + half_h - 120.0
	var max_y: float = bottom_y + nodes_root.position.y - half_h + 120.0

	if min_y > max_y:
		var mid: float = (min_y + max_y) * 0.5
		min_y = mid
		max_y = mid

	camera.position.x = viewport_size.x * 0.5
	camera.position.y = clamp(camera.position.y, min_y, max_y)

func _focus_on_current_node() -> void:
	if floor_data == null or camera == null:
		return

	var current := floor_data.get_node_by_id(floor_data.current_node_id)
	if current == null:
		return

	camera.position = nodes_root.position + current.position
	_clamp_camera()
	_base_camera_y = camera.position.y

func _position_avatar_on_current_node() -> void:
	if floor_data == null or map_avatar == null:
		return

	var current := floor_data.get_node_by_id(floor_data.current_node_id)
	if current == null:
		return

	map_avatar.position = nodes_root.position + current.position

func _update_avatar_movement(delta: float) -> void:
	if _pending_node == null or map_avatar == null:
		_is_moving_to_node = false
		return

	var target_pos: Vector2 = nodes_root.position + _pending_node.position
	var to_target: Vector2 = target_pos - map_avatar.position
	var distance: float = to_target.length()

	if distance <= move_speed * delta:
		map_avatar.position = target_pos
		_on_avatar_reached_pending_node()
		return

	map_avatar.position += to_target.normalized() * move_speed * delta
	
func _on_avatar_reached_pending_node() -> void:
	if map_avatar != null and map_avatar.sprite_frames != null:
		map_avatar.play("default")

	var node := _pending_node
	_pending_node = null
	_is_moving_to_node = false

	if node == null:
		return

	_move_to_node(node)
	node_chosen.emit(node)

	var type_name := _node_type_to_string(node.type)
	TaloTracker.track_visit_map_node(type_name, node.id)

	_emit_event_signal(node)

func _node_type_to_string(type: int) -> String:
	match type:
		MapNodeData.NodeType.START:
			return "start"
		MapNodeData.NodeType.COMBAT:
			return "combat"
		MapNodeData.NodeType.HARD_COMBAT:
			return "hard_combat"
		MapNodeData.NodeType.BOSS:
			return "boss"
		MapNodeData.NodeType.SHOP:
			return "shop"
		MapNodeData.NodeType.TREASURE:
			return "treasure"
		MapNodeData.NodeType.SPECIAL:
			return "special"
		_:
			return "unknown"
