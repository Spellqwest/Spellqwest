extends Resource
class_name MapNodeData

enum NodeType {
	START,
	COMBAT,
	HARD_COMBAT,
	BOSS,
	SHOP,
	TREASURE,
	SPECIAL
}

@export var id: int = -1
@export var type: NodeType = NodeType.COMBAT
@export var layer_index: int = 0
@export var lane_index: int = 0
@export var position: Vector2 = Vector2.ZERO

@export var outgoing_ids: Array[int] = []
@export var incoming_ids: Array[int] = []

var visited: bool = false
var revealed: bool = false
var available: bool = false
