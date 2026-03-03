extends Node
class_name TypingInput

signal token_typed(token: String)
signal buffer_changed(buffer: String)
signal buffer_submitted(buffer: String)

@export var typing_delay: float = 0.1
var buffer: String = ""
var _can_type: bool = true

# Right shift only: set this to your right shift physical keycode
@export var right_shift_physical: int = -1

func _unhandled_input(event: InputEvent) -> void:
	if not _can_type:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var e := event as InputEventKey

	# Enter submits (and clears)
	if e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER:
		emit_signal("buffer_submitted", buffer)
		buffer = ""
		emit_signal("buffer_changed", buffer)
		_start_cooldown()
		return

	# Backspace deletes
	if e.keycode == KEY_BACKSPACE:
		if buffer.length() > 0:
			buffer = buffer.substr(0, buffer.length() - 1)
			emit_signal("buffer_changed", buffer)
		_start_cooldown()
		return

	var token := _key_to_token(e)
	if token == "":
		return

	emit_signal("token_typed", token)

	# shift should move/press but not enter buffer
	if token != "shift":
		buffer += token
		emit_signal("buffer_changed", buffer)

	_start_cooldown()

func _key_to_token(e: InputEventKey) -> String:
	# Right shift only -> "shift"
	if e.keycode == KEY_SHIFT:
		if right_shift_physical != -1 and e.physical_keycode == right_shift_physical:
			return "shift"
		return ""  # ignore left shift

	match e.keycode:
		KEY_MINUS:  return "-"
		KEY_PERIOD: return "."
		KEY_COMMA:  return ","

	if e.unicode != 0:
		var s := char(e.unicode).to_lower()
		if s.length() == 1 and s[0] >= "a" and s[0] <= "z":
			return s

	return ""

func _start_cooldown() -> void:
	_can_type = false
	await get_tree().create_timer(typing_delay).timeout
	_can_type = true
