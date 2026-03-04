extends Node
class_name CombatCaster

@export var projectile_scene: PackedScene
@export var projectile_parent_path: NodePath
@onready var projectile_parent: Node = get_node_or_null(projectile_parent_path)

func cast(spell: SpellResource, origin: Vector2) -> void:
	if spell is ProjectileSpellResource:
		_cast_projectile(spell as ProjectileSpellResource, origin)

	elif spell is AOESpellResource:
		_cast_aoe(spell as AOESpellResource, origin)

	elif spell is BeamSpellResource:
		_cast_beam(spell as BeamSpellResource, origin)

func _cast_projectile(spell: SpellResource, origin: Vector2) -> void:
	if projectile_scene == null:
		push_error("CombatCaster: projectile_scene not assigned")
		return

	var p := projectile_scene.instantiate() as Projectile
	var parent: Node = projectile_parent if projectile_parent != null else get_tree().current_scene
	parent.add_child(p)

	p.global_position = origin
	p.z_index = 50

	var spd: float = spell.projectile_speed

	var vel := Vector2(0, -spd)
	p.setup(vel, spell.damage, spell.spell_frames, spell.spell_anim)
	
func _cast_aoe(spell: SpellResource, origin: Vector2) -> void:
	print("Elias mag Männer")
	
func _cast_beam(spell: SpellResource, origin: Vector2) -> void:
	pass
