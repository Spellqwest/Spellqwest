extends Label

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		
		var k: int = event.keycode
		
		# 🔹 ENTER → clear text
		if k == KEY_ENTER or k == KEY_KP_ENTER:
			text = ""
			return
		
		# 🔹 BACKSPACE → remove last character
		if k == KEY_BACKSPACE:
			if text.length() > 0:
				text = text.substr(0, text.length() - 1)
