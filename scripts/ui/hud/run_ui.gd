@tool
extends CanvasLayer
class_name RunUI

@onready var run_state: RunState = $"../RunState"
@onready var spell_book: SpellBook = $"../SpellBook"
@onready var spell_popup: SpellPopup = $SpellPopup
@onready var inventory_popup: InventoryPopup = $InventoryPopup

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_spellbook"):
		if inventory_popup.visible:
			inventory_popup.hide_popup()

		if spell_popup.visible:
			spell_popup.hide_popup()
		else:
			spell_popup.show_popup(run_state, spell_book)

		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_inventory"):
		if spell_popup.visible:
			spell_popup.hide_popup()

		if inventory_popup.visible:
			inventory_popup.hide_popup()
		else:
			inventory_popup.show_popup(run_state)

		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		spell_popup.hide_popup()
		inventory_popup.hide_popup()
		get_viewport().set_input_as_handled()
