extends Control
class_name ShopScreen

signal proceed_requested

const ShopItemPool = preload("res://scripts/_shared/rng/item_pools/shop_item_pool.gd")
const ItemResource = preload("res://scripts/inventory/items/item_resource.gd")

enum Step {
	SHOPPING,
	PROCEED
}

@export var shop_pool: ShopItemPool
@export var guaranteed_health_potion: ItemResource
@export var guaranteed_mana_potion: ItemResource

@onready var title_label: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var coins_label: Label = $Panel/Margin/VBox/Header/CoinsLabel
@onready var items_label: Label = $Panel/Margin/VBox/ItemsLabel
@onready var shop_items_root: VBoxContainer = $Panel/Margin/VBox/ShopItems
@onready var prompt_label: Label = $Panel/Margin/VBox/PromptLabel
@onready var base_word_label: Label = $Panel/Margin/VBox/WordHolder/BaseWordLabel
@onready var typed_word_label: Label = $Panel/Margin/VBox/WordHolder/TypedWordLabel
@onready var result_label: Label = $Panel/Margin/VBox/ResultLabel

var run_state: RunState
var _rng := RandomNumberGenerator.new()
var _step: int = Step.SHOPPING
var _target_word: String = "PROCEED"
var _typed_count: int = 0

var _current_shop_items: Array[ItemResource] = []

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

func setup(p_run_state: RunState) -> void:
	run_state = p_run_state

func begin_shop() -> void:
	_step = Step.SHOPPING
	_target_word = "PROCEED"
	_typed_count = 0
	result_label.text = ""

	title_label.text = "Shop"
	items_label.text = "Click an item to buy it."
	prompt_label.text = "Type PROCEED to leave the shop."

	_generate_shop_inventory()
	_refresh_all()
	show()

func _generate_shop_inventory() -> void:
	_current_shop_items.clear()

	if guaranteed_health_potion != null:
		_current_shop_items.append(guaranteed_health_potion)

	if guaranteed_mana_potion != null:
		_current_shop_items.append(guaranteed_mana_potion)

	if shop_pool == null:
		return

	var pool_items: Array[ItemResource] = shop_pool.get_all_items().duplicate()
	var extra_count: int = _rng.randi_range(1, 4)

	var consumables: Array[ItemResource] = []
	var non_consumables: Array[ItemResource] = []

	for item: ItemResource in pool_items:
		if item == null:
			continue
		if item.item_type == ItemResource.ItemType.CONSUMABLE:
			consumables.append(item)
		else:
			non_consumables.append(item)

	# Always min. 1 random consumable
	if not consumables.is_empty() and extra_count > 0:
		var forced_consumable := consumables[_rng.randi_range(0, consumables.size() - 1)]
		_current_shop_items.append(forced_consumable)
		_remove_first_item_from_array(pool_items, forced_consumable)
		extra_count -= 1

	while extra_count > 0 and not pool_items.is_empty():
		var idx: int = _rng.randi_range(0, pool_items.size() - 1)
		var picked: ItemResource = pool_items[idx]
		_current_shop_items.append(picked)
		pool_items.remove_at(idx)
		extra_count -= 1

func _remove_first_item_from_array(array: Array[ItemResource], item: ItemResource) -> void:
	var idx: int = array.find(item)
	if idx != -1:
		array.remove_at(idx)

func _refresh_all() -> void:
	_refresh_coins()
	_refresh_shop_items()
	_refresh_word_display()

func _refresh_coins() -> void:
	var coins: int = 0
	if run_state != null:
		coins = run_state.current_coins
	coins_label.text = "Coins: %d" % coins

func _refresh_shop_items() -> void:
	for child in shop_items_root.get_children():
		child.queue_free()

	for item: ItemResource in _current_shop_items:
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var name := "Unknown"
		var price := 0
		if item != null:
			name = item.display_name
			price = item.shop_value

		button.text = "%s - %d coins" % [name, price]
		button.disabled = not _can_afford(item)

		button.pressed.connect(func() -> void:
			_try_buy_item(item)
		)

		shop_items_root.add_child(button)

func _can_afford(item: ItemResource) -> bool:
	if run_state == null or item == null:
		return false
	return run_state.current_coins >= item.shop_value

func _try_buy_item(item: ItemResource) -> void:
	if run_state == null or item == null:
		return

	if not _current_shop_items.has(item):
		return

	if not _can_afford(item):
		result_label.text = "Not enough coins."
		return

	run_state.current_coins -= item.shop_value
	run_state.add_item(item)
	_current_shop_items.erase(item)

	TaloTracker.track_item_buy(item.display_name)
	result_label.text = "Bought: %s" % item.display_name
	_refresh_all()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if _step != Step.SHOPPING:
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
		hide()
		proceed_requested.emit()

func _refresh_word_display() -> void:
	base_word_label.text = _target_word
	typed_word_label.text = _target_word.substr(0, _typed_count)
