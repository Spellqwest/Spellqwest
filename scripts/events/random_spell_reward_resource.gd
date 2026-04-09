extends RewardResource
class_name RandomSpellRewardResource

func can_grant(run_state: RunState, spell_book: SpellBook = null) -> bool:
	if run_state == null or spell_book == null:
		return false

	var all_spells: Array = spell_book.get_all_spells()
	for spell in all_spells:
		if spell == null:
			continue
		if not run_state.knows_spell(spell.id):
			return true

	return false

func grant(run_state: RunState, spell_book: SpellBook = null) -> bool:
	if run_state == null or spell_book == null:
		return false

	var all_spells: Array = spell_book.get_all_spells()
	var candidates: Array = []

	for spell in all_spells:
		if spell == null:
			continue
		if not run_state.knows_spell(spell.id):
			candidates.append(spell)

	if candidates.is_empty():
		return false

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var index: int = rng.randi_range(0, candidates.size() - 1)
	var chosen_spell = candidates[index]

	run_state.learn_spell(chosen_spell.id)
	return true
