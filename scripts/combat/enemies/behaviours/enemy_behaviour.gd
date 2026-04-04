extends Resource
class_name EnemyBehaviour

func should_move(_enemy) -> bool:
	return true

func get_action_interval() -> float:
	return 0.0

func perform_action(_enemy, _delta: float) -> void:
	pass