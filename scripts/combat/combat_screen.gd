extends Node

@onready var keyboard = $Keyboard
@onready var hud = $CanvasLayer/CombatHud 

var can_type: bool = true

@export var typing_delay: float = 0.1  # 0.1 = 100ms between inputs
var typed: String = ""

func _unhandled_input(event: InputEvent) -> void:
	if not can_type:
		return
	
	if event.keycode == KEY_ENTER:
			typed = ""
			hud.set_typed_text(typed)
			return

	if event is InputEventKey and event.pressed and not event.echo:
		var token := _key_to_token(event)
		if token == "":
			return

		can_type = false  # block input

		$Keyboard.handle_letter(token)

		if token != "shift":
			typed += token
			hud.set_typed_text(typed)

		_start_typing_cooldown()

func _key_to_letter(event):
	if event.unicode == 0:
		return ""
	var s = char(event.unicode).to_lower()
	if s >= "a" and s <= "z":
		print(s)
		return s
	return ""


func _key_to_token(event: InputEventKey) -> String:
	if event.keycode == KEY_SHIFT:
		return "shift_r"

	match event.keycode:
		KEY_MINUS:
			return "-"
		KEY_PERIOD:
			return "."
		KEY_COMMA:
			return ","

	if event.unicode != 0:
		var s := char(event.unicode).to_lower()
		if s.length() == 1 and s[0] >= "a" and s[0] <= "z":
			return s

	return ""
	
func _start_typing_cooldown():
	await get_tree().create_timer(typing_delay).timeout
	can_type = true
