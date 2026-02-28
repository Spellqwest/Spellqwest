extends CharacterBody2D

@onready var label: Label = get_parent().get_node("Label") #Ändern für neue Poition von TypingLabel

# Dictionary mapping each letter key to a unique position
var key_positions: Dictionary = {
	KEY_Q: Vector2(100, 100),
	KEY_W: Vector2(200, 100),
	KEY_E: Vector2(300, 100),
	KEY_R: Vector2(400, 100),
	KEY_T: Vector2(500, 100),
	KEY_Z: Vector2(600, 100),
	KEY_U: Vector2(700, 100),
	KEY_I: Vector2(800, 100),
	KEY_O: Vector2(900, 100),
	
	KEY_P: Vector2(100, 300),
	KEY_A: Vector2(200, 300),
	KEY_S: Vector2(300, 300),
	KEY_D: Vector2(400, 300),
	KEY_F: Vector2(500, 300),
	KEY_G: Vector2(600, 300),
	KEY_H: Vector2(700, 300),
	KEY_J: Vector2(800, 300),
	KEY_K: Vector2(900, 300),
	
	KEY_SHIFT: Vector2(100, 500),
	KEY_L: Vector2(200, 500),
	KEY_Y: Vector2(300, 500),
	KEY_X: Vector2(400, 500),
	KEY_C: Vector2(500, 500),
	KEY_V: Vector2(600, 500),
	KEY_B: Vector2(700, 500),
	KEY_N: Vector2(800, 500),
	KEY_M: Vector2(900, 500),
}

var cooldown_time: float = 0.08
var next_allowed_time: float = 0.0


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		
		var now: float = Time.get_ticks_msec() / 1000.0
		if now < next_allowed_time:
			return

		var key_event := event as InputEventKey
		var k: int = key_event.keycode

		if not key_positions.has(k):
			return

		position = key_positions[k]

		if key_event.unicode > 0:
			var character: String = char(key_event.unicode)
			label.text += character

		next_allowed_time = now + cooldown_time
