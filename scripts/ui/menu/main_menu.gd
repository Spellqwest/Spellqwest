extends Control

@onready var settings_window: Window = $SettingsWindow

func _ready() -> void:
	settings_window.hide()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/RunRoot.tscn")

func _on_menu_button_pressed() -> void:
	settings_window.popup_centered()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_close_button_pressed() -> void:
	settings_window.hide()
