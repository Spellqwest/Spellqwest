extends Resource
class_name SpellResource

enum SpellType { PROJECTILE, AOE, BEAM, MELEE }

@export var id: StringName
@export var display_name: String
@export var word: String
@export var damage: int
@export var type: SpellType
@export var cast_time: float
@export var projectile_scale: Vector2 = Vector2.ONE

@export var spell_frames: SpriteFrames
@export var spell_anim: StringName = &"default"
