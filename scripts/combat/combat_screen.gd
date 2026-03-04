extends Node

@onready var keyboard = $Keyboard
@onready var hud = $CanvasLayer/CombatHud
@onready var typing = $TypingInput
@onready var spell_book = $SpellBook
@onready var run_state = $Keyboard/Player/RunState
@onready var cast_buffer = $Keyboard/Player/CastBuffer
@onready var caster = $CombatCaster

func _ready() -> void:
	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)
	cast_buffer.spell_ready.connect(_on_spell_ready)
	
	hud.set_cast_buffer($Keyboard/Player/CastBuffer)
	
	run_state.learn_all_spells(spell_book.get_all_spells())

func _on_token_typed(token: String) -> void:
	keyboard.handle_letter(token)

func _on_buffer_changed(buf: String) -> void:
	hud.set_typed_text(buf)

func _on_buffer_submitted(buf: String) -> void:
	var spell: SpellResource = spell_book.get_by_word(buf)
	if spell == null:
		return

	if not keyboard.player.get_node("RunState").knows_spell(spell.id):
		return

	cast_buffer.add_spell(spell)

func _on_spell_ready(spell: SpellResource) -> void:
	var origin: Vector2 = keyboard.player.global_position
	caster.cast(spell, origin)
