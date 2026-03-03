extends Node

@onready var keyboard = $Keyboard
@onready var hud = $CanvasLayer/CombatHud
@onready var typing = $TypingInput
@onready var spell_book = $SpellBook
@onready var run_state = $Keyboard/Player/RunState
@onready var caster = $CombatCaster

func _ready() -> void:
	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)
	run_state.learn_all_spells(spell_book.get_all_spells())

func _on_token_typed(token: String) -> void:
	keyboard.handle_letter(token)

func _on_buffer_changed(buf: String) -> void:
	hud.set_typed_text(buf)

func _on_buffer_submitted(buf: String) -> void:
	var spell = spell_book.get_by_word(buf)
	if spell == null:
		print("No spell:", buf)
		return

	if not run_state.knows_spell(spell.id):
		print("Spell not learned:", spell.id)
		return

	var origin: Vector2 = keyboard.player.global_position
	caster.cast(spell, origin)
