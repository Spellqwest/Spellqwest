extends EnemyBehaviour
class_name RangedBehaviour

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 200.0
@export var projectile_damage: int = 5

func should_move(enemy) -> bool:
	return not enemy.is_acting

func get_action_interval() -> float:
	return 3.0

func perform_action(enemy, _delta: float) -> void:
	if projectile_scene == null:
		return

	var x_offset = [-30.0, 30.0].pick_random()

	var projectile = projectile_scene.instantiate()
	enemy.get_tree().current_scene.add_child(projectile)
	projectile.global_position = enemy.global_position + Vector2(x_offset, 0)
	projectile.setup(Vector2(0, 1) * projectile_speed, projectile_damage, null, &"")
