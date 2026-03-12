extends ItemEffect
class_name ShieldNextHitEffect

func apply(run_state: RunState, _context: int) -> void:
	if run_state == null:
		return

	run_state.has_next_hit_shield = true
