extends ItemEffect
class_name HealEffect

@export var heal_amount: int = 5

func apply(run_state: RunState, _context: int) -> void:
	if run_state == null or run_state.stats == null:
		return
	run_state.stats.current_hp = min(
		run_state.stats.current_hp + heal_amount,
		run_state.stats.max_hp
	)
