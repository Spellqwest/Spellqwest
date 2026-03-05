extends Node
class_name CombatScreen

@onready var keyboard = $Keyboard
@onready var player = $Keyboard/Player
@onready var hud = $CanvasLayer/CombatHud
@onready var typing = $TypingInput
@onready var cast_buffer = $Keyboard/Player/CastBuffer
@onready var caster = $CombatCaster

var spell_book: SpellBook
var run_state: RunState

func setup(_run_state: RunState, _spell_book: SpellBook) -> void:
	run_state = _run_state
	spell_book = _spell_book

func _ready() -> void:
	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)
	cast_buffer.spell_ready.connect(_on_spell_ready)

	hud.set_player(player)
	hud.set_cast_buffer(cast_buffer)

	if run_state != null and spell_book != null:
		_init_run_spells()

func _init_run_spells() -> void:
	run_state.learn_all_spells(spell_book.get_all_spells())

func _on_token_typed(token: String) -> void:
	keyboard.handle_letter(token)

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
