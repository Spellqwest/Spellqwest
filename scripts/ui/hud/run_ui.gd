@tool
extends CanvasLayer
class_name RunUI

@onready var run_state: RunState = $"../RunState"
@onready var spell_book: SpellBook = $"../SpellBook"
@onready var spell_popup: SpellPopup = $SpellPopup

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_spellbook"):
		if spell_popup.visible:
			spell_popup.hide_popup()
		else:
			spell_popup.show_popup(run_state, spell_book)

	if event.is_action_pressed("ui_cancel"):
		spell_popup.hide_popup()
