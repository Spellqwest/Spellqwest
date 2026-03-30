@tool
extends Node2D
class_name CombatScreen

signal proceed_requested
signal game_over

@export var victory_texture: Texture2D
@export var game_over_texture: Texture2D

@onready var result_image: TextureRect = $CanvasLayer/CombatResult

@onready var keyboard = $Keyboard
@onready var player = $Keyboard/Player
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var hud = $CanvasLayer/CombatHud
@onready var typing = $TypingInput
@onready var cast_buffer = $Keyboard/Player/CastBuffer
@onready var caster = $CombatCaster
@onready var inventory_popup: InventoryPopup = $"../../RunUI/InventoryPopup"
@onready var enemy_field = $EnemyField

@onready var player_attacks = $PlayerAttacks
@onready var projectiles_root: Node = $PlayerAttacks/Projectiles
@onready var beams_root: Node = $PlayerAttacks/Beams
@onready var damage_zones_root: Node = $PlayerAttacks/DamageZones

var spell_book: SpellBook
var run_state: RunState

var enemies_to_defeat: int = 2
var defeated_enemies: int

var combat_finished: bool
var player_won: bool

func setup(_run_state: RunState, _spell_book: SpellBook) -> void:
	run_state = _run_state
	spell_book = _spell_book
	defeated_enemies = 0
	combat_finished = false

	if run_state != null:
		run_state.current_use_context = RunState.USE_CONTEXT_COMBAT
		run_state.set_current_combat_screen(self)

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)
	cast_buffer.spell_ready.connect(_on_spell_ready)
	
	if run_state != null and run_state.stats != null:
		player.apply_run_stats(run_state.stats)
	
	inventory_popup.item_used.connect(_on_inventory_item_used)
	inventory_popup.item_equipped.connect(_on_inventory_item_equipped)
	
	enemy_field.enemy_entity_died.connect(_on_enemy_died)
	player.hp_empty.connect(_on_player_died)
	
	hud.set_player(player)
	hud.set_cast_buffer(cast_buffer)
	
	result_image.hide()
	
	_on_visibility_changed()

	if run_state != null and spell_book != null:
		_init_run_spells()

func _on_visibility_changed() -> void:
	var combat_camera: Camera2D = get_node_or_null("Camera2D")
	var canvas_layer: CanvasLayer = $CanvasLayer
	canvas_layer.visible = visible
	if combat_camera != null:
		combat_camera.enabled = visible

func _init_run_spells() -> void:
	run_state.learn_all_spells(spell_book.get_all_spells())

func _on_token_typed(token: String) -> void:
	if not player.use_mana(2.0):
		return

	keyboard.handle_letter(token)

	match token:
		",":
			_try_use_equipped_consumable()
		".":
			_try_use_equipped_weapon()

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
	player.pause_mana_regen(1.0)
	
func _refresh_equipped_item_display() -> void:
	if run_state == null or run_state.inventory == null:
		keyboard.refresh_equipped_items(null, null)
		return

	keyboard.refresh_equipped_items(
		run_state.inventory.equipped_consumable,
		run_state.inventory.equipped_weapon
	)
	
func _try_use_equipped_consumable() -> void:
	if run_state == null or run_state.inventory == null:
		return

	var item = run_state.inventory.equipped_consumable
	if item == null:
		return

	if run_state.can_use_item(item):
		run_state.use_item(item)
		_sync_player_from_run_state()
		_refresh_equipped_item_display()

func _try_use_equipped_weapon() -> void:
	if run_state == null or run_state.inventory == null:
		print("weapon use: no run_state or inventory")
		return

	var item = run_state.inventory.equipped_weapon
	if item == null:
		print("weapon use: no equipped weapon")
		return

	print("weapon use: trying ", item.display_name)
	print("weapon use: can_use_item = ", run_state.can_use_item(item))

	if run_state.can_use_item(item):
		run_state.use_item(item)
		_refresh_equipped_item_display()
		
func _sync_player_from_run_state() -> void:
	if run_state == null or run_state.stats == null:
		return

	player.apply_run_stats(run_state.stats)

func _on_inventory_item_used(_item: ItemResource) -> void:
	_sync_player_from_run_state()
	_refresh_equipped_item_display()

func _on_inventory_item_equipped(_item: ItemResource) -> void:
	_refresh_equipped_item_display()

func _on_enemy_died() -> void:
	if (combat_finished):
		return
		
	defeated_enemies += 1
	
	if (defeated_enemies >= enemies_to_defeat):
		combat_finished = true
		player_won = true
		end_combat()

func _on_player_died() -> void:
	if (combat_finished):
		return
	
	combat_finished = true
	end_combat()

func _clear_player_attacks() -> void:
	_clear_children(projectiles_root)
	_clear_children(beams_root)
	_clear_children(damage_zones_root)

func _clear_children(root: Node) -> void:
	if root == null:
		return

	for child in root.get_children():
		child.queue_free()

func end_combat() -> void:
	if run_state != null:
		run_state.current_use_context = RunState.USE_CONTEXT_MAP
		run_state.clear_current_combat_screen()
	
	enemy_field.combat_end()
	_clear_player_attacks()
	
	_show_result()
	
	await get_tree().create_timer(2.0).timeout
	#TODO
	#Implement that based on win/lose there is a visualization of it to see
	
	if (player_won):
		proceed_requested.emit()
	else:
		game_over.emit()

func start_combat():
	defeated_enemies = 0
	combat_finished = false
	player_won = false
	
	set_process(true)
	typing.set_process(true)
	
	hud.show()
	result_image.hide()
	
	enemy_field.combat_start()
	_sync_player_from_run_state()
	
func _show_result() -> void:
	print("SHOW RESULT CALLED")
	print(result_image)
	print("SIZE :" + str(result_image.size))
	print("Texture:", victory_texture)
	set_process(false)
	typing.set_process(false)
	
	hud.hide()
	
	if player_won:
		TaloTracker.track_combat_end(true, run_state.current_stage_index)
		result_image.texture = victory_texture
	else:
		TaloTracker.track_combat_end(false, run_state.current_stage_index)
		result_image.texture = game_over_texture
	result_image.show()

func get_nearest_enemy_to_player() -> Node2D:
	if player == null:
		return null

	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var best_enemy: Node2D = null
	var best_dist_sq: float = INF

	for enemy_node in enemies:
		if enemy_node == null:
			continue
		if not enemy_node is Node2D:
			continue

		var enemy := enemy_node as Node2D
		if not is_instance_valid(enemy):
			continue

		var dist_sq: float = player.global_position.distance_squared_to(enemy.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_enemy = enemy

	return best_enemy

func spawn_weapon_projectile(
	velocity: Vector2,
	damage: int,
	projectile_scene: PackedScene,
	frames: SpriteFrames,
	anim_name: StringName,
	projectile_scale: Vector2 = Vector2.ONE
) -> void:
	if projectiles_root == null or projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	if projectile == null:
		return

	projectiles_root.add_child(projectile)

	if projectile is Projectile:
		var p := projectile as Projectile
		p.global_position = player.global_position
		p.setup(velocity, damage, frames, anim_name, projectile_scale)
