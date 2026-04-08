extends Node

const GUEST_ID_PATH = "user://talo_guest_id"

var _current_run_id: String = ""

func _ready() -> void:
	# Wait for Talo to initialize
	if not Talo.is_node_ready():
		await Talo.ready

	var guest_id = _load_guest_id()
	if guest_id == "":
		guest_id = Talo.players.generate_identifier()
		_save_guest_id(guest_id)
	
	print("[TaloTracker] Identifying player as guest:", guest_id)
	Talo.players.identify("guest", guest_id)

func _load_guest_id() -> String:
	if FileAccess.file_exists(GUEST_ID_PATH):
		var file = FileAccess.open(GUEST_ID_PATH, FileAccess.READ)
		var content = file.get_as_text().strip_edges()
		file.close()
		return content
	return ""

func _save_guest_id(guest_id: String) -> void:
	var file = FileAccess.open(GUEST_ID_PATH, FileAccess.WRITE)
	file.store_string(guest_id)
	file.close()

func _generate_run_id() -> String:
	# Generate a v4-style UUID using random bytes
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var hex := ""
	for i in range(16):
		hex += "%02x" % rng.randi_range(0, 255)
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12)
	]

func get_run_id() -> String:
	return _current_run_id

# -- Tracking helpers --

func _base_props() -> Dictionary[String, String]:
	var props: Dictionary[String, String] = {}
	props["run_id"] = _current_run_id
	return props

func _merge(extra: Dictionary[String, String]) -> Dictionary[String, String]:
	var props := _base_props()
	props.merge(extra)
	return props

# -- Events --

func track_run_started() -> void:
	_current_run_id = _generate_run_id()
	print("[TaloTracker] Tracking run_started (run_id=%s)" % _current_run_id)
	Talo.events.track("run_started", _base_props())

func track_combat_end(player_won: bool, stage_index: int) -> void:
	print("[TaloTracker] Tracking combat_end")
	var extra: Dictionary[String, String] = {}
	extra["stage_index"] = str(stage_index)
	extra["player_won"] = str(player_won)
	Talo.events.track("combat_end", _merge(extra))

func track_run_end(player_won: bool, stage_index: int) -> void:
	print("[TaloTracker] Tracking run_end")
	var extra: Dictionary[String, String] = {}
	extra["stage_index"] = str(stage_index)
	extra["player_won"] = str(player_won)
	Talo.events.track("run_end", _merge(extra))

func track_visit_map_node(node_type: String, node_index: int) -> void:
	print("[TaloTracker] Tracking visit_map_node")
	var extra: Dictionary[String, String] = {}
	extra["node_type"] = node_type
	extra["node_index"] = str(node_index)
	Talo.events.track("visit_map_node", _merge(extra))

func track_spell_use(spell_name: String) -> void:
	print("[TaloTracker] Tracking spell_use")
	var extra: Dictionary[String, String] = {}
	extra["spell_name"] = spell_name
	Talo.events.track("spell_use", _merge(extra))

func track_item_buy(item_name: String) -> void:
	print("[TaloTracker] Tracking item_buy")
	var extra: Dictionary[String, String] = {}
	extra["item_name"] = item_name
	Talo.events.track("item_buy", _merge(extra))

func track_item_use(item_name: String) -> void:
	print("[TaloTracker] Tracking item_use")
	var extra: Dictionary[String, String] = {}
	extra["item_name"] = item_name
	Talo.events.track("item_use", _merge(extra))
