extends Control

func _ready() -> void:
	print("Menu loaded")

func _on_play_button_pressed() -> void:
	print("Play pressed!")
	get_tree().change_scene_to_file("res://scenes/game/RunRoot.tscn")
	
func _on_menu_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
