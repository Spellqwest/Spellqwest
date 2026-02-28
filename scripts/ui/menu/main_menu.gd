extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Menu loaded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass # Replace with function body.
	
func _on_play_button_pressed() -> void:
	print("Play pressed!") # <- test
	get_tree().change_scene_to_file("res://scenes/game/combat/CombatScreen.tscn")
	
func _on_menu_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()
