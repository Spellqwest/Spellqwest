extends Node

@onready var keyboard = $Keyboard
@onready var hud = $CanvasLayer/CombatHud
@onready var typing: TypingInput = $TypingInput

func _ready() -> void:
	typing.token_typed.connect(_on_token_typed)
	typing.buffer_changed.connect(_on_buffer_changed)
	typing.buffer_submitted.connect(_on_buffer_submitted)

func _on_token_typed(token: String) -> void:
	keyboard.handle_letter(token)

func _on_buffer_changed(buf: String) -> void:
	hud.set_typed_text(buf)

func _on_buffer_submitted(buf: String) -> void:
	print("SUBMIT:", buf) 
