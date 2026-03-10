extends Resource
class_name MapStageData

@export var nodes: Array[MapNodeData] = []
@export var current_node_id: int = -1
@export var boss_node_id: int = -1
@export var stage_index: int = 0
@export var seed: int = 0

func get_node_by_id(node_id: int) -> MapNodeData:
	for node in nodes:
		if node.id == node_id:
			return node
	return null

func get_children_of(node_id: int) -> Array[MapNodeData]:
	var result: Array[MapNodeData] = []
	var node := get_node_by_id(node_id)
	if node == null:
		return result

	for child_id in node.outgoing_ids:
		var child := get_node_by_id(child_id)
		if child != null:
			result.append(child)

	return result

func get_parents_of(node_id: int) -> Array[MapNodeData]:
	var result: Array[MapNodeData] = []
	var node := get_node_by_id(node_id)
	if node == null:
		return result

	for parent_id in node.incoming_ids:
		var parent := get_node_by_id(parent_id)
		if parent != null:
			result.append(parent)

	return result
