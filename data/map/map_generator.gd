extends RefCounted
class_name MapGenerator

const MapNodeData = preload("res://data/map/map_node_data.gd")
const MapFloorData = preload("res://data/map/map_stage_data.gd")

var _rng := RandomNumberGenerator.new()
var _next_id: int = 0

func generate_floor(stage_index: int, seed: int = 0) -> MapFloorData:
	_next_id = 0

	if seed == 0:
		_rng.randomize()
		seed = _rng.randi()
	_rng.seed = seed

	var floor := MapFloorData.new()
	floor.stage_index = stage_index
	floor.seed = seed

	var regular_layers := 4
	var lane_count := 4
	
	var layer_spacing := 220.0
	var lane_spacing := 220.0
	
	var center_x := 0.0
	var start_y := 300.0

	var start := _make_node(
		MapNodeData.NodeType.START,
		0,
		int(lane_count / 2),
		Vector2(center_x, start_y)
	)
	floor.nodes.append(start)
	floor.current_node_id = start.id

	var layers: Array[Array] = []
	layers.append([start])

	for layer_idx in range(1, regular_layers + 1):
		var layer_nodes: Array[MapNodeData] = []
		for lane in range(lane_count):
			if _rng.randf() < _spawn_chance_for_layer(layer_idx, regular_layers):
				var node_type := _roll_node_type(layer_idx, regular_layers)
				var pos := Vector2(
					center_x + (lane - (lane_count - 1) * 0.5) * lane_spacing,
					start_y - layer_idx * layer_spacing
				)
				var node := _make_node(node_type, layer_idx, lane, pos)
				layer_nodes.append(node)
				floor.nodes.append(node)

		while layer_nodes.size() < 2:
			var lane := _rng.randi_range(0, lane_count - 1)
			if not _layer_has_lane(layer_nodes, lane):
				var pos := Vector2(
					center_x + (lane - (lane_count - 1) * 0.5) * lane_spacing,
					start_y - layer_idx * layer_spacing
				)
				var node := _make_node(_roll_node_type(layer_idx, regular_layers), layer_idx, lane, pos)
				layer_nodes.append(node)
				floor.nodes.append(node)

		layers.append(layer_nodes)

	var boss_layer := regular_layers + 1
	var boss := _make_node(
		MapNodeData.NodeType.BOSS,
		boss_layer,
		int(lane_count / 2),
		Vector2(center_x, start_y - boss_layer * layer_spacing)
	)
	floor.nodes.append(boss)
	floor.boss_node_id = boss.id
	layers.append([boss])

	for i in range(layers.size() - 1):
		_connect_layers(layers[i], layers[i + 1])

	_prune_unreachable_from_start(floor)

	_rebuild_incoming_links(floor)

	_refresh_availability(floor)

	return floor


func _make_node(type: int, layer_index: int, lane_index: int, pos: Vector2) -> MapNodeData:
	var node := MapNodeData.new()
	node.id = _next_id
	_next_id += 1
	node.type = type
	node.layer_index = layer_index
	node.lane_index = lane_index
	node.position = pos
	return node


func _spawn_chance_for_layer(layer_idx: int, regular_layers: int) -> float:
	if layer_idx == regular_layers:
		return 0.65
	return 0.75


func _roll_node_type(layer_idx: int, regular_layers: int) -> int:
	if layer_idx <= 1:
		return MapNodeData.NodeType.COMBAT

	var roll := _rng.randf()

	if roll < 0.45:
		return MapNodeData.NodeType.COMBAT
	elif roll < 0.65:
		return MapNodeData.NodeType.HARD_COMBAT
	elif roll < 0.78:
		return MapNodeData.NodeType.SPECIAL
	elif roll < 0.88:
		return MapNodeData.NodeType.TREASURE
	else:
		return MapNodeData.NodeType.SHOP


func _layer_has_lane(layer_nodes: Array[MapNodeData], lane: int) -> bool:
	for node in layer_nodes:
		if node.lane_index == lane:
			return true
	return false


func _connect_layers(from_layer: Array, to_layer: Array) -> void:
	if from_layer.is_empty() or to_layer.is_empty():
		return

	for from_node: MapNodeData in from_layer:
		var candidates := _sorted_by_lane_distance(from_node, to_layer)

		var connection_count := 1
		if candidates.size() >= 2 and _rng.randf() < 0.45:
			connection_count = 2

		for i in range(min(connection_count, candidates.size())):
			_link_nodes(from_node, candidates[i])

	for to_node: MapNodeData in to_layer:
		if to_node.incoming_ids.is_empty():
			var nearest_from := _nearest_node_by_lane(to_node, from_layer)
			if nearest_from != null:
				_link_nodes(nearest_from, to_node)


func _sorted_by_lane_distance(from_node: MapNodeData, nodes: Array) -> Array[MapNodeData]:
	var copy: Array[MapNodeData] = []
	for n in nodes:
		copy.append(n)

	copy.sort_custom(func(a: MapNodeData, b: MapNodeData) -> bool:
		var da : int = abs(a.lane_index - from_node.lane_index)
		var db : int = abs(b.lane_index - from_node.lane_index)
		if da == db:
			return a.lane_index < b.lane_index
		return da < db
	)

	return copy


func _nearest_node_by_lane(target: MapNodeData, nodes: Array) -> MapNodeData:
	var best: MapNodeData = null
	var best_dist := 999999
	for node: MapNodeData in nodes:
		var d : int = abs(node.lane_index - target.lane_index)
		if d < best_dist:
			best_dist = d
			best = node
	return best


func _link_nodes(a: MapNodeData, b: MapNodeData) -> void:
	if not a.outgoing_ids.has(b.id):
		a.outgoing_ids.append(b.id)
	if not b.incoming_ids.has(a.id):
		b.incoming_ids.append(a.id)


func _prune_unreachable_from_start(floor: MapFloorData) -> void:
	var reachable := {}
	var queue: Array[int] = [floor.current_node_id]

	while not queue.is_empty():
		var id : int = queue.pop_front()
		if reachable.has(id):
			continue
		reachable[id] = true

		var node := floor.get_node_by_id(id)
		if node == null:
			continue

		for child_id in node.outgoing_ids:
			queue.append(child_id)

	var kept: Array[MapNodeData] = []
	for node in floor.nodes:
		if reachable.has(node.id):
			kept.append(node)

	floor.nodes = kept

	for node in floor.nodes:
		var filtered: Array[int] = []
		for out_id in node.outgoing_ids:
			if reachable.has(out_id):
				filtered.append(out_id)
		node.outgoing_ids = filtered


func _rebuild_incoming_links(floor: MapFloorData) -> void:
	for node in floor.nodes:
		node.incoming_ids.clear()

	for node in floor.nodes:
		for child_id in node.outgoing_ids:
			var child := floor.get_node_by_id(child_id)
			if child != null and not child.incoming_ids.has(node.id):
				child.incoming_ids.append(node.id)


func _refresh_availability(floor: MapFloorData) -> void:
	for node in floor.nodes:
		node.available = false
		node.revealed = false

	var current := floor.get_node_by_id(floor.current_node_id)
	if current == null:
		return

	current.visited = true
	current.revealed = true

	for child in floor.get_children_of(current.id):
		child.available = true
		child.revealed = true
