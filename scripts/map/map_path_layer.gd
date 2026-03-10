@tool
extends Node2D
class_name MapPathLayer

const MapStageData = preload("res://data/map/map_stage_data.gd")

var floor_data: MapStageData

func set_floor_data(value: MapStageData) -> void:
	floor_data = value
	queue_redraw()

func _draw() -> void:
	if floor_data == null:
		return

	for node in floor_data.nodes:
		for child_id in node.outgoing_ids:
			var child = floor_data.get_node_by_id(child_id)
			if child == null:
				continue

			var color := Color(0.6, 0.6, 0.6)
			if node.visited and child.available:
				color = Color(1.0, 0.9, 0.5)
			elif node.visited and child.visited:
				color = Color(0.7, 1.0, 0.7)

			draw_line(node.position, child.position, color, 4.0, true)
