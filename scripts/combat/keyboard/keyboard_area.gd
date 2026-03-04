extends Node2D

@onready var keyboard: TileMapLayer = $Keyboard
@onready var player = $Player

@export var player_offset: Vector2 = Vector2.ZERO
@export var pressed_atlas_texture: Texture2D
@export var key_block_size: Vector2i = Vector2i(4, 4)
@export var letter_cell_offset: Vector2i = Vector2i(1, 0) 
@export var pressed_source_id: int = 1

var letter_to_cell: Dictionary = {}

var _has_last := false
var _last_saved: Array = []
# var _last_cell: Vector2i
# var _last_source_id: int
# var _last_atlas_coords: Vector2i
# var _last_alt: int
# var _last_anchor: Vector2i

func _ready():
	var ts := keyboard.tile_set
	for i in ts.get_source_count():
		var id := ts.get_source_id(i)
	_build_mapping()
	position.x = get_viewport_rect().size.x / 2 - 8

func _build_mapping():
	letter_to_cell.clear()
	for cell in keyboard.get_used_cells():
		var data = keyboard.get_cell_tile_data(cell)
		if data == null:
			continue

		var letter = data.get_custom_data("letter")
		if letter != null:
			letter_to_cell[str(letter).to_lower()] = cell

func handle_letter(letter: String):
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

	var center_cell := anchor + Vector2i(key_block_size.x / 2, key_block_size.y / 2) #nötig i guess, hab vergessen für was :D
	var pos := keyboard.map_to_local(center_cell)
	player.global_position = keyboard.to_global(pos) + player_offset

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
