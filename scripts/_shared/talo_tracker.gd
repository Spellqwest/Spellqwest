extends Node

const GUEST_ID_PATH = "user://talo_guest_id"

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

func track_run_started() -> void:
	print("[TaloTracker] Tracking run_started")
	Talo.events.track("run_started")

func track_combat_end(player_won: bool, stage_index: int) -> void:
	print("[TaloTracker] Tracking combat_end")
	Talo.events.track("combat_end", {
		"stage_index": str(stage_index),
		"player_won": str(player_won)
	})

# TODO: Call when we add a run end scene
func track_run_end(player_won: bool, stage_index: int) -> void:
	print("[TaloTracker] Tracking run_end")
	Talo.events.track("run_end", {
		"stage_index": str(stage_index),
		"player_won": str(player_won)
	})
