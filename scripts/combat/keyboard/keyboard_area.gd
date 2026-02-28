extends Node2D

@onready var keyboard: TileMapLayer = $Keyboard
@onready var player = $Player

@export var player_offset: Vector2 = Vector2.ZERO

var letter_to_cell: Dictionary = {}

func _ready():
	_build_mapping()

func _build_mapping():
	for cell in keyboard.get_used_cells():
		var data = keyboard.get_cell_tile_data(cell)
		if data == null:
			continue

		var letter = data.get_custom_data("letter")
		if letter != null:
			letter_to_cell[str(letter).to_lower()] = cell

	print("Mapped keys:", letter_to_cell)

func handle_letter(letter: String):
	letter = letter.to_lower()
	if not letter_to_cell.has(letter):
		return

	var cell = letter_to_cell[letter]

	var pos = keyboard.map_to_local(cell)
	player.global_position = keyboard.to_global(pos) + player_offset
