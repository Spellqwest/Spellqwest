extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var enemy_stats: EnemyResource
var current_hp: int 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_hp = enemy_stats.max_hp
	anim.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += enemy_stats.speed * delta

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if(current_hp <= 0): 
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if(area.has_method("player_damaged")):
		area.call("player_damaged", enemy_stats.contact_damage)
		queue_free()
