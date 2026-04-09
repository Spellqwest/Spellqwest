extends Node2D

class_name Enemy

signal enemy_died(gold: int)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var enemy_choices: Array[EnemyResource]
var enemy_stats: EnemyResource
var current_hp: int 
var currentSpeed: float 
var randomEnemy: int
var affectedArea: Area2D
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomEnemy = rng.randi_range(0, enemy_choices.size()-1)
	enemy_stats = enemy_choices[randomEnemy]
	current_hp = enemy_stats.max_hp
	currentSpeed = enemy_stats.speed
	anim.sprite_frames = enemy_stats.enemy_frames
	add_to_group("combat_enemy")
	anim.play("enemy_idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += currentSpeed * delta

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if(current_hp <= 0):
		emit_signal("enemy_died", enemy_stats.gold_reward)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if(area.has_method("player_damaged")):
		affectedArea = area
		anim.play("enemy_attack")
		currentSpeed = 0

func _on_animation_looped() -> void:
	if(anim.animation == "enemy_attack"):
		affectedArea.call("player_damaged", enemy_stats.contact_damage)
		queue_free()
