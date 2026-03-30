extends PassiveEffect
class_name RegenEffect

@export var heal_per_tick: int = 1
@export var tick_interval: float = 1.0

var _timer: Timer

func on_combat_started(run_state: RunState, combat_screen: CombatScreen) -> void:
	if run_state == null or run_state.stats == null or combat_screen == null:
		return

	if _timer != null and is_instance_valid(_timer):
		return

	_timer = Timer.new()
	_timer.wait_time = tick_interval
	_timer.one_shot = false
	_timer.autostart = false
	_timer.timeout.connect(_on_tick.bind(run_state, combat_screen))
	combat_screen.add_child(_timer)
	_timer.start()

func on_combat_ended(_run_state: RunState, _combat_screen: CombatScreen) -> void:
	if _timer != null and is_instance_valid(_timer):
		_timer.stop()
		_timer.queue_free()
	_timer = null

func _on_tick(run_state: RunState, combat_screen: CombatScreen) -> void:
	if run_state == null or run_state.stats == null:
		return

	run_state.stats.current_hp = min(
		run_state.stats.current_hp + heal_per_tick,
		run_state.stats.max_hp
	)

	if combat_screen != null:
		combat_screen.sync_player_and_hud_from_run_state()
