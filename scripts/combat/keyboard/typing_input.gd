extends Node
class_name TypingInput

signal token_typed(token: String)
signal buffer_changed(buffer: String)
signal buffer_submitted(buffer: String)

@export var typing_delay: float = 0.1 #100ms delay
var buffer: String = ""
var _can_type: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if not _can_type:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var e := event as InputEventKey

	# Space submits (and clears)
	if e.keycode == KEY_SPACE:
		emit_signal("buffer_submitted", buffer)
		buffer = ""
		emit_signal("buffer_changed", buffer)
		_start_cooldown()
		return

	# Backspace deletes DEBUG
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

	var non_typing_tokens := {"shift": true, ".": true, ",": true}

	if not non_typing_tokens.has(token):
		buffer += token
		emit_signal("buffer_changed", buffer)

	_start_cooldown()

func _key_to_token(e: InputEventKey) -> String:
	if e.keycode == KEY_SHIFT:
		return "shift"

	match e.keycode:
		KEY_PERIOD: return "."
		KEY_COMMA:  return ","
		KEY_MINUS:  return "-"

	if e.unicode != 0:
		var s := char(e.unicode).to_lower()
		if s.length() == 1 and s[0] >= "a" and s[0] <= "z":
			return s

	return ""

func _start_cooldown() -> void:
	_can_type = false
	await get_tree().create_timer(typing_delay).timeout
	_can_type = true
