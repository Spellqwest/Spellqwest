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

# Optional: visuals
@export var icon: Texture2D

# Optional: rewards (für die demo)
@export var gold_reward: int 
