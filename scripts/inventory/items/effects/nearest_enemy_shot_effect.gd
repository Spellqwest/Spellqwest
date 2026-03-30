extends WeaponEffect
class_name ShootNearestEnemyEffect

const Projectile = preload("res://scenes/game/combat/entities/damageEntitiy/PlayerProjectile.tscn")

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var damage: int = 1
@export var projectile_frames: SpriteFrames
@export var projectile_animation: StringName = &"default"
@export var projectile_scale: Vector2 = Vector2.ONE

func apply_weapon(run_state: RunState, combat_screen: CombatScreen) -> void:
	if run_state == null or combat_screen == null:
		return

	if projectile_scene == null:
		return

	var target: Node2D = combat_screen.get_nearest_enemy_to_player()
	if target == null:
		return

	var start_pos: Vector2 = combat_screen.player.global_position
	var direction: Vector2 = (target.global_position - start_pos).normalized()
	var velocity: Vector2 = direction * projectile_speed

	combat_screen.spawn_weapon_projectile(
		velocity,
		damage,
		projectile_scene,
		projectile_frames,
		projectile_animation,
		projectile_scale
	)
