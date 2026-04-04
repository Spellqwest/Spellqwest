extends Node2D

class_name Enemy

signal enemy_died

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var enemy_choices: Array[EnemyResource]
var enemy_stats: EnemyResource
var current_hp: int 
var currentSpeed: float 
var randomEnemy: int
var affectedArea: Area2D
var rng = RandomNumberGenerator.new()
var action_timer: float = 0.0
var is_acting: bool = false
var is_contact_attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomEnemy = rng.randi_range(0, enemy_choices.size()-1)
	enemy_stats = enemy_choices[randomEnemy]
	current_hp = enemy_stats.max_hp
	currentSpeed = enemy_stats.speed
	anim.sprite_frames = enemy_stats.enemy_frames
	action_timer = enemy_stats.behaviour.get_action_interval()
	add_to_group("enemy")
	anim.play("enemy_idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemy_stats.behaviour.should_move(self):
		global_position.y += currentSpeed * delta
	if not is_acting:
		if enemy_stats.behaviour.get_action_interval() > 0:
			action_timer -= delta
			if action_timer <= 0:
				is_acting = true
				anim.play("enemy_attack")

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if(current_hp <= 0):
		emit_signal("enemy_died") 
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("player_damaged"):
		affectedArea = area
		is_contact_attacking = true
		anim.play("enemy_attack")
		currentSpeed = 0

func _on_animation_looped() -> void:
	if anim.animation == "enemy_attack":
		if is_contact_attacking:
			affectedArea.call("player_damaged", enemy_stats.contact_damage)
			queue_free()
		else:
			enemy_stats.behaviour.perform_action(self, 0.0)
			is_acting = false
			action_timer = enemy_stats.behaviour.get_action_interval()
			anim.play("enemy_idle")
