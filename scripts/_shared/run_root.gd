extends Node
class_name RunRoot

@onready var run_state: RunState = $RunState
@onready var spell_book: SpellBook = $SpellBook
@onready var run_ui: RunUI = $RunUI
@onready var combat_screen: CombatScreen = $Screens/CombatScreen

func _ready() -> void:
	spell_book.set_spells(ContentDB.get_all_spells())

	run_state.learn_all_spells(spell_book.get_all_spells())

	combat_screen.setup(run_state, spell_book)
