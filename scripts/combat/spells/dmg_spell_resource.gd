extends Resource
class_name SpellResource

enum SpellType { PROJECTILE, AOE, BEAM }

@export var id: StringName
@export var display_name: String
@export var word: String
@export var damage: int
@export var type: SpellType
