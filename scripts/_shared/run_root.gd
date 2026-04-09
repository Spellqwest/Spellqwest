@tool
extends Node
class_name RunRoot

@onready var run_state: RunState = $RunState
@onready var spell_book: SpellBook = $SpellBook
@onready var run_ui: RunUI = $RunUI
@onready var map_screen: MapScreen = $Screens/MapScreen
@onready var combat_screen: CombatScreen = $Screens/CombatScreen
@onready var treasure_screen: TreasureScreen = $Screens/TreasureScreen
@onready var shop_screen: ShopScreen = $Screens/ShopScreen

func _ready() -> void:
	TaloTracker.track_run_started()
	run_state.initialize_run_state()
	spell_book.set_spells(ContentDB.get_all_spells())
	_grant_starting_spells()

	combat_screen.setup(run_state, spell_book)
	combat_screen.proceed_requested.connect(_on_combat_proceed_requested)
	combat_screen.game_over.connect(_on_game_over)
	
	map_screen.setup(run_state)
	map_screen.combat_requested.connect(_on_combat_requested)
	map_screen.boss_requested.connect(_on_boss_requested)
	map_screen.shop_requested.connect(_on_shop_requested)
	map_screen.treasure_requested.connect(_on_treasure_requested)
	map_screen.special_requested.connect(_on_special_requested)
	
	treasure_screen.setup(run_state, spell_book)
	treasure_screen.proceed_requested.connect(_on_treasure_proceed_requested)
	
	shop_screen.setup(run_state, spell_book)
	shop_screen.proceed_requested.connect(_on_shop_proceed_requested)
	
	run_state.add_test_items()

	_activate_screen(map_screen)

	if run_state.current_map_stage == null:
		map_screen.generate_new_floor(run_state.current_stage_index)
		run_state.current_map_stage = map_screen.floor_data
	else:
		map_screen.floor_data = run_state.current_map_stage
		map_screen.call_deferred("_rebuild_view")

func _activate_screen(active_screen: Node) -> void:
	var screens: Array[Node] = [map_screen, combat_screen]

	for screen in screens:
		if screen == active_screen:
			if screen is CanvasItem:
				(screen as CanvasItem).show()
			screen.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			if screen is CanvasItem:
				(screen as CanvasItem).hide()
			screen.process_mode = Node.PROCESS_MODE_DISABLED

func _show_map() -> void:
	_activate_screen(map_screen)

	if run_state.current_map_stage == null:
		map_screen.generate_new_floor(run_state.current_stage_index)
		run_state.current_map_stage = map_screen.floor_data
	else:
		map_screen.floor_data = run_state.current_map_stage
		map_screen.call_deferred("_rebuild_view")

func _show_combat() -> void:
	_activate_screen(combat_screen)
	combat_screen.start_combat()

func _on_combat_requested(node_data) -> void:
	_show_combat()

func _on_boss_requested(node_data) -> void:
	_show_combat()

func _on_shop_requested(_node_data) -> void:
	_show_shop()
	shop_screen.begin_shop()

func _on_treasure_requested(_node_data) -> void:
	_show_treasure()
	treasure_screen.begin_treasure()

func _on_special_requested(node_data) -> void:
	print("Open special event for node: ", node_data.id)
	
func _show_treasure() -> void:
	map_screen.hide()
	combat_screen.hide()
	treasure_screen.show()

func _show_shop() -> void:
	map_screen.hide()
	combat_screen.hide()
	treasure_screen.hide()
	shop_screen.show()

func _on_treasure_proceed_requested() -> void:
	_show_map()

func _on_shop_proceed_requested() -> void:
	_show_map()

func _on_combat_proceed_requested() -> void:
	_show_map()

func _on_game_over() -> void:
	TaloTracker.track_run_end(false, run_state.current_stage_index)
	run_state.current_map_stage = null
	run_state.game_over_reset() #Redundant. But needed for later working with playerstats
	combat_screen.player.heal(run_state.stats.current_hp)
	TaloTracker.track_run_started()
	_show_map()

func _grant_starting_spells() -> void:
	run_state.learned_spell_ids.clear()

	var starter_spell_ids: Array[StringName] = [
		&"spell_fire",
		&"spell_acid",
		&"spell_boom",
		&"spell_laser"
	]

	for spell_id: StringName in starter_spell_ids:
		var spell = ContentDB.get_spell(String(spell_id))
		if spell != null:
			run_state.learn_spell(spell.id)
