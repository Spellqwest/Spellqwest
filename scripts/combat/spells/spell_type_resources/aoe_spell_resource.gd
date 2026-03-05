extends ProjectileSpellResource
class_name AOESpellResource

enum AoEMode { ONCE, DOT }

@export var aoe_mode: AoEMode
@export var aoe_radius: float
@export var aoe_delay: float = 0.0

# For ONCE
@export var aoe_damage_once: int

# For DOT
@export var aoe_duration: float
@export var aoe_tick_damage: int
@export var aoe_tick_rate: float

@export var aoe_frames: SpriteFrames
@export var aoe_anim: StringName = &"default"
