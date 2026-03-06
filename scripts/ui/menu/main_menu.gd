@tool
extends Control

@onready var settings_window: Window = $SettingsWindow
@onready var volume_slider: HSlider = $SettingsWindow/VBoxContainer/HBoxContainer/VolumeSlider

func _ready() -> void:
	settings_window.hide()
	var bus_index = AudioServer.get_bus_index("Master")
	var db = AudioServer.get_bus_volume_db(bus_index)

	var linear = db_to_linear(db)
	volume_slider.value = linear * 100

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/RunRoot.tscn")

func _on_menu_button_pressed() -> void:
	settings_window.popup_centered()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_close_button_pressed() -> void:
	settings_window.hide()

func _on_volume_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	if value == 0:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		var linear = value / 100.0
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))
