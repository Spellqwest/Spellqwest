extends Resource
class_name RewardResource

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var shop_value: int = 0

func can_grant(_run_state: RunState) -> bool:
	return true

func grant(_run_state: RunState) -> bool:
	return false
