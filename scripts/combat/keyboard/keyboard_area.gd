@tool
extends Node2D

const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")
const EQUIPPED_ITEM_VIEW_SCENE: PackedScene = preload("res://scenes/game/combat/board/EquippedItemView.tscn")

@onready var keyboard: TileMapLayer = $Keyboard
@onready var player = $Player
@onready var equipped_items_root: Node2D = $EquippedItems

@export var player_offset: Vector2 = Vector2.ZERO
@export var pressed_atlas_texture: Texture2D
@export var key_block_size: Vector2i = Vector2i(4, 4)
@export var letter_cell_offset: Vector2i = Vector2i(1, 0)
@export var pressed_source_id: int = 1

@export var equipped_item_offset: Vector2 = Vector2(0, 42)

var letter_to_cell: Dictionary = {}
var _slot_views: Dictionary = {} # "consumable" / "weapon" -> node

var _has_last := false
var _last_saved: Array = []

func _ready() -> void:
	_build_mapping()
	position.x = get_viewport_rect().size.x / 2 - 8

func _build_mapping() -> void:
	letter_to_cell.clear()
	for cell in keyboard.get_used_cells():
		var data = keyboard.get_cell_tile_data(cell)
		if data == null:
			continue

		var letter = data.get_custom_data("letter")
		if letter != null:
			letter_to_cell[str(letter).to_lower()] = cell

func handle_letter(letter: String) -> void:
	letter = letter.to_lower()
	if not letter_to_cell.has(letter):
		return

	var label_cell: Vector2i = letter_to_cell[letter]
	var anchor: Vector2i = label_cell - letter_cell_offset

	if _has_last:
		for entry in _last_saved:
			keyboard.set_cell(entry.cell, entry.source_id, entry.atlas, entry.alt)
		_last_saved.clear()

	_last_saved = _save_block(anchor)
	_set_block_pressed(anchor)
	_has_last = true

	var center_cell := anchor + Vector2i(key_block_size.x / 2, key_block_size.y / 2)
	var pos := keyboard.map_to_local(center_cell)
	player.global_position = keyboard.to_global(pos) + player_offset

func get_slot_global_position(slot_name: String) -> Vector2:
	var token := ""
	match slot_name:
		"consumable":
			token = ","
		"weapon":
			token = "."
		_:
			return global_position

	if not letter_to_cell.has(token):
		return global_position

	var cell: Vector2i = letter_to_cell[token]
	var local_pos: Vector2 = keyboard.map_to_local(cell) + equipped_item_offset
	return keyboard.to_global(local_pos)

func set_equipped_item(slot_name: String, item: ItemResource) -> void:
	_clear_slot_view(slot_name)

	if item == null:
		return

	var view = EQUIPPED_ITEM_VIEW_SCENE.instantiate()
	equipped_items_root.add_child(view)
	view.global_position = get_slot_global_position(slot_name)
	view.setup(item, slot_name)

	_slot_views[slot_name] = view

func clear_equipped_item(slot_name: String) -> void:
	_clear_slot_view(slot_name)

func refresh_equipped_items(consumable_item: ItemResource, weapon_item: ItemResource) -> void:
	set_equipped_item("consumable", consumable_item)
	set_equipped_item("weapon", weapon_item)

func _clear_slot_view(slot_name: String) -> void:
	if _slot_views.has(slot_name):
		var node = _slot_views[slot_name]
		if is_instance_valid(node):
			node.queue_free()
		_slot_views.erase(slot_name)

func _find_atlas_source_id_by_texture(tex: Texture2D) -> int:
	if tex == null:
		return -1
	var ts := keyboard.tile_set
	if ts == null:
		return -1

	for i in ts.get_source_count():
		var source_id := ts.get_source_id(i)
		var src := ts.get_source(source_id)
		if src is TileSetAtlasSource and src.texture == tex:
			return source_id
	return -1

func _save_block(anchor: Vector2i) -> Array:
	var saved: Array = []
	for y in range(key_block_size.y):
		for x in range(key_block_size.x):
			var cell := anchor + Vector2i(x, y)
			var src_id := keyboard.get_cell_source_id(cell)
			if src_id == -1:
				continue
			saved.append({
				"cell": cell,
				"source_id": src_id,
				"atlas": keyboard.get_cell_atlas_coords(cell),
				"alt": keyboard.get_cell_alternative_tile(cell),
			})
	return saved

func _set_block_pressed(anchor: Vector2i) -> void:
	for y in range(key_block_size.y):
		for x in range(key_block_size.x):
			var cell := anchor + Vector2i(x, y)
			var src_id := keyboard.get_cell_source_id(cell)
			if src_id == -1:
				continue
			var atlas := keyboard.get_cell_atlas_coords(cell)
			keyboard.set_cell(cell, pressed_source_id, atlas, 0)

func player_damaged(damage: int) -> void:
	player.take_damage(damage)
