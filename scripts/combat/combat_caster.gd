@tool
extends Node
class_name CombatCaster

@export var projectile_scene: PackedScene
@export var projectile_parent_path: NodePath
@onready var projectile_parent: Node = get_node_or_null(projectile_parent_path)

@export var damage_zone_scene: PackedScene
@export var damage_zone_parent_path: NodePath
@onready var damage_zone_parent: Node = get_node_or_null(damage_zone_parent_path)

@export var beam_scene: PackedScene
@export var beam_parent_path: NodePath
@onready var beam_parent: Node = get_node_or_null(beam_parent_path)

func cast(spell: SpellResource, origin: Vector2) -> void:
	if spell is AOESpellResource:
		_cast_aoe_projectile(spell as AOESpellResource, origin)
	elif spell is ProjectileSpellResource:
		_cast_projectile(spell as ProjectileSpellResource, origin)
	elif spell is BeamSpellResource:
		_cast_beam(spell as BeamSpellResource, origin)

func _cast_projectile(spell: ProjectileSpellResource, origin: Vector2) -> void:
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

func _cast_aoe_projectile(spell: AOESpellResource, origin: Vector2) -> void:
	if projectile_scene == null:
		push_error("CombatCaster: projectile_scene not assigned")
		return

	var p := projectile_scene.instantiate() as Projectile
	var parent: Node = projectile_parent if projectile_parent != null else get_tree().current_scene
	parent.add_child(p)

	p.global_position = origin
	p.z_index = 50

	var vel := Vector2(0, -spell.projectile_speed)

	p.setup(vel, spell.damage, spell.spell_frames, spell.spell_anim)

	p.impacted.connect(_on_projectile_impacted_spawn_zone.bind(spell), CONNECT_ONE_SHOT)

func _on_projectile_impacted_spawn_zone(world_pos: Vector2, _hit_area: Area2D, spell: AOESpellResource) -> void:
	call_deferred("_spawn_damage_zone", spell, world_pos)

func _spawn_damage_zone(spell: AOESpellResource, world_pos: Vector2) -> void:
	if damage_zone_scene == null:
		push_error("CombatCaster: damage_zone_scene not assigned")
		return

	var dz := damage_zone_scene.instantiate() as DamageZone
	var parent: Node = damage_zone_parent if damage_zone_parent != null else get_tree().current_scene

	parent.add_child(dz)
	dz.global_position = world_pos
	dz.z_index = 40
	dz.setup_from_spell(spell)

func _cast_beam(spell: BeamSpellResource, origin: Vector2) -> void:
	if beam_scene == null:
		push_error("CombatCaster: beam_scene not assigned")
		return

	var b := beam_scene.instantiate() as Beam
	var parent: Node = beam_parent if beam_parent != null else get_tree().current_scene
	parent.add_child(b)

	b.global_position = origin
	b.z_index = 50

	var dir := Vector2.UP
	var beam_length := 920.0
	var beam_width := 24.0

	b.setup(
		spell.damage,
		spell.lifetime,
		spell.hit_delay,
		spell.spell_frames,
		spell.spell_anim,
		dir,
		beam_length,
		beam_width
	)
	b.start()
