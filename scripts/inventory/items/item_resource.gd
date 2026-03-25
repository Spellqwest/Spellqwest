extends Resource
class_name ItemResource

enum ItemType {
	CONSUMABLE,
	WEAPON,
	PASSIVE
}

enum UseContext {
	MAP,
	COMBAT
}

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var icon: Texture2D
@export var shop_value: int = 100

@export var can_use_on_map: bool = false
@export var can_use_in_combat: bool = false
@export var requires_equip_to_use: bool = false

@export var effect: ItemEffect
