extends Control
class_name SpellPopup

@onready var list: VBoxContainer = %SpellList
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var run_state: RunState
var spell_book: SpellBook

func _ready() -> void:
	visible = false
	close_button.pressed.connect(hide_popup)

func show_popup(_run_state: RunState, _spell_book: SpellBook) -> void:
	run_state = _run_state
	spell_book = _spell_book
	_refresh()
	visible = true

func hide_popup() -> void:
	visible = false

func _refresh() -> void:
	print("List node path:", list.get_path())

	for c in list.get_children():
		c.queue_free()

	var test := Label.new()
	test.text = "TEST ROW (if you see this, list wiring is correct)"
	test.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_child(test)

	for id in run_state.get_learned_spell_ids():
		var spell := spell_book.get_by_id(id)
		if spell == null:
			continue
		var row := Label.new()
		row.text = spell.display_name
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		list.add_child(row)

	print("List children after refresh:", list.get_child_count())
	list.queue_sort()
