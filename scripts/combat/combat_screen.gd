extends Node

@onready var keyboard = $Keyboard
@onready var hud = $CanvasLayer/CombatHud 

var can_type: bool = true

@export var typing_delay: float = 0.1  # 0.1 = 100ms between inputs
var typed: String = ""

@export var enemy_scene:= preload("res://scenes/game/combat/entities/Enemy.tscn") 
var column_enemy_positions: Dictionary = {
	1: Vector2(100, 0),
	2: Vector2(200, 0),
	3: Vector2(300, 0),
	4: Vector2(400, 0),
	5: Vector2(500, 0),
	6: Vector2(600, 0)
}
var rng = RandomNumberGenerator.new()
var used_positions = Array([], TYPE_INT, "", null)

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

func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var randomPos = rng.randi_range(1, 6)
	
	print("Timer method running...")
	
	if(!used_positions.has(randomPos)):
		enemy.position = column_enemy_positions[randomPos]
		used_positions.append(randomPos)
		print("used enemy positions: " + str(used_positions))
		add_child(enemy)
