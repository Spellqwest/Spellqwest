extends Resource
class_name SpellResource

enum SpellType { PROJECTILE, AOE, BEAM }

@export var id: String
@export var display_name: String
@export var cast: String
@export var damage: int
@export var type: SpellType
