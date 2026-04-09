extends Control
class_name TreasureScreen

signal proceed_requested

const TreasureItemPool = preload("res://scripts/_shared/rng/item_pools/treasure_item_pool.gd")
const RewardResource = preload("res://scripts/events/reward_resource.gd")
const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

enum Step {
	OPEN_CHEST,
	PROCEED
}

@export var treasure_pool: TreasureItemPool

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var prompt_label: Label = $Panel/Margin/VBox/PromptLabel
@onready var base_word_label: Label = $Panel/Margin/VBox/WordHolder/BaseWordLabel
@onready var typed_word_label: Label = $Panel/Margin/VBox/WordHolder/TypedWordLabel
@onready var reward_label: Label = $Panel/Margin/VBox/RewardLabel

var spell_book: SpellBook
var run_state: RunState
var _rng := RandomNumberGenerator.new()
var _step: int = Step.OPEN_CHEST
var _target_word: String = "OPEN"
var _typed_count: int = 0

var _granted_item: ItemResource
var _granted_special_reward: RewardResource

func _ready() -> void:
	hide()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rng.randomize()

	base_word_label.modulate = Color(1, 1, 1, 0.35)
	typed_word_label.modulate = Color(1, 1, 1, 1.0)

func setup(p_run_state: RunState, p_spell_book: SpellBook) -> void:
	run_state = p_run_state
	spell_book = p_spell_book

func begin_treasure() -> void:
	_step = Step.OPEN_CHEST
	_target_word = "OPEN"
	_typed_count = 0
	_granted_item = null
	_granted_special_reward = null

	title_label.text = "Treasure"
	prompt_label.text = "Type OPEN to open the chest."
	reward_label.text = ""
	_refresh_word_display()
	show()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is not InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	var key_event: InputEventKey = event
	var typed: String = char(key_event.unicode).to_upper()

	if typed.is_empty():
		return

	_try_advance_word(typed)
	get_viewport().set_input_as_handled()

func _try_advance_word(typed: String) -> void:
	if _typed_count >= _target_word.length():
		return

	var expected: String = _target_word.substr(_typed_count, 1)
	if typed != expected:
		return

	_typed_count += 1
	_refresh_word_display()

	if _typed_count >= _target_word.length():
		_on_word_completed()

func _on_word_completed() -> void:
	match _step:
		Step.OPEN_CHEST:
			_open_chest()
		Step.PROCEED:
			hide()
			proceed_requested.emit()

func _open_chest() -> void:
	if treasure_pool == null:
		reward_label.text = "No treasure pool assigned."
	else:
		var rolled: Dictionary = treasure_pool.roll_random_entry(_rng, run_state, spell_book)

		if rolled.is_empty():
			reward_label.text = "The chest was empty."
		else:
			var entry_type: String = str(rolled.get("type", ""))
			var value = rolled.get("value", null)

			match entry_type:
				"item":
					_granted_item = value as ItemResource
					if _granted_item == null:
						reward_label.text = "The chest was empty."
					else:
						if run_state != null:
							run_state.add_item(_granted_item)
						reward_label.text = "You found: %s" % _granted_item.display_name

				"reward":
					_granted_special_reward = value as RewardResource
					if _granted_special_reward == null:
						reward_label.text = "The chest was empty."
					else:
						var granted: bool = _granted_special_reward.grant(run_state, spell_book)
						if granted:
							reward_label.text = "You found: %s" % _granted_special_reward.display_name
						else:
							reward_label.text = "The chest was empty."

				_:
					reward_label.text = "The chest was empty."

	_step = Step.PROCEED
	_target_word = "PROCEED"
	_typed_count = 0
	prompt_label.text = "Type PROCEED to return to the map."
	_refresh_word_display()

func _refresh_word_display() -> void:
	base_word_label.text = _target_word
	typed_word_label.text = _target_word.substr(0, _typed_count)
