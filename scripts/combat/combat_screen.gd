@tool
extends Node2D
class_name CombatScreen

@onready var keyboard = $Keyboard
@onready var player = $Keyboard/Player
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var hud = $CanvasLayer/CombatHud
@onready var typing = $TypingInput
@onready var cast_buffer = $Keyboard/Player/CastBuffer
@onready var caster = $CombatCaster
@onready var inventory_popup: InventoryPopup = $"../../RunUI/InventoryPopup"

var spell_book: SpellBook
var run_state: RunState

func setup(_run_state: RunState, _spell_book: SpellBook) -> void:
	run_state = _run_state
	spell_book = _spell_book

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)
	cast_buffer.spell_ready.connect(_on_spell_ready)
	
	if run_state != null and run_state.stats != null:
		player.apply_run_stats(run_state.stats)
	
	inventory_popup.item_used.connect(_on_inventory_item_used)
	inventory_popup.item_equipped.connect(_on_inventory_item_equipped)
	
	hud.set_player(player)
	hud.set_cast_buffer(cast_buffer)
	
	_on_visibility_changed()

	if run_state != null and spell_book != null:
		_init_run_spells()

func _on_visibility_changed() -> void:
	var combat_camera: Camera2D = get_node_or_null("Camera2D")
	var canvas_layer: CanvasLayer = $CanvasLayer
	canvas_layer.visible = visible
	if combat_camera != null:
		combat_camera.enabled = visible

func _init_run_spells() -> void:
	run_state.learn_all_spells(spell_book.get_all_spells())

func _on_token_typed(token: String) -> void:
	keyboard.handle_letter(token)

	match token:
		",":
			_try_use_equipped_consumable()
		".":
			_try_use_equipped_weapon()

func _on_buffer_changed(buf: String) -> void:
	hud.set_typed_text(buf)

func _on_buffer_submitted(buf: String) -> void:
	if spell_book == null or run_state == null:
		return

	var spell: SpellResource = spell_book.get_by_word(buf)
	if spell == null:
		return

	if not run_state.knows_spell(spell.id):
		return

	cast_buffer.add_spell(spell)

func _on_spell_ready(spell: SpellResource) -> void:
	var origin: Vector2 = keyboard.player.global_position
	caster.cast(spell, origin)
	
func _refresh_equipped_item_display() -> void:
	if run_state == null or run_state.inventory == null:
		keyboard.refresh_equipped_items(null, null)
		return

	keyboard.refresh_equipped_items(
		run_state.inventory.equipped_consumable,
		run_state.inventory.equipped_weapon
	)
	
func _try_use_equipped_consumable() -> void:
	if run_state == null or run_state.inventory == null:
		return

	var item = run_state.inventory.equipped_consumable
	if item == null:
		return

	if run_state.can_use_item(item):
		run_state.use_item(item)
		_sync_player_from_run_state()
		_refresh_equipped_item_display()

func _try_use_equipped_weapon() -> void:
	if run_state == null or run_state.inventory == null:
		return

	var item = run_state.inventory.equipped_weapon
	if item == null:
		return

	if run_state.can_use_item(item):
		run_state.use_item(item)
		_refresh_equipped_item_display()
		
func _sync_player_from_run_state() -> void:
	if run_state == null or run_state.stats == null:
		return

	player.apply_run_stats(run_state.stats)

func _on_inventory_item_used(_item: ItemResource) -> void:
	_sync_player_from_run_state()
	_refresh_equipped_item_display()

func _on_inventory_item_equipped(_item: ItemResource) -> void:
	_refresh_equipped_item_display()
