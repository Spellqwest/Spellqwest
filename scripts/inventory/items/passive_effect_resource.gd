extends ItemEffect
class_name PassiveEffect

func on_pickup(_run_state: RunState) -> void:
	pass

func on_combat_started(_run_state: RunState, _combat_screen: CombatScreen) -> void:
	pass

func on_player_damaged(_run_state: RunState, amount: int) -> int:
	return amount

func on_combat_ended(_run_state: RunState, _combat_screen: CombatScreen) -> void:
	pass
