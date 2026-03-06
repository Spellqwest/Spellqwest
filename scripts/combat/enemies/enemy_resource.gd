@tool
extends Resource
class_name EnemyResource

enum EnemyType { GRUNT, TANK, RANGED, ELITE, BOSS }

@export var id: String
@export var display_name: String
@export var type: EnemyType

# Core stats
@export var max_hp: int = 10
@export var speed: float = 90.0
@export var contact_damage: int = 1

# Visuals
@export var enemy_frames: SpriteFrames
@export var enemy_anim: StringName = &"enemy_idle"

# Optional: rewards (für die demo)
@export var gold_reward: int 
