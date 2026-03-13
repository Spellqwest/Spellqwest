extends Node2D

##############################################
#Global Variables
##############################################
@export var enemy_scene:= preload("res://scenes/game/combat/entities/Enemy.tscn") 

const baseYPos = 100

var enemy_spawnpoints: Array[Vector2] = [
	Vector2(314.0, baseYPos),
	Vector2(446.0, baseYPos),
	Vector2(574.0, baseYPos),
	Vector2(698.0, baseYPos),
	Vector2(826.0, baseYPos)
]

var rng = RandomNumberGenerator.new()
var randomPos: int
var blocked_enemy_positions: Array[int] = []

##############################################
#Functions
##############################################
func _on_enemy_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	randomPos = rng.randi_range(0, 4)
	
	if(!blocked_enemy_positions.has(randomPos)):
		enemy.position = enemy_spawnpoints[randomPos]
		blocked_enemy_positions.append(randomPos)
		print("used enemy positions: " + str(blocked_enemy_positions))
		print("spawning enemy on: " + str(enemy.position))
		add_child(enemy)
	print("in timer method mit rng: " + str(randomPos))
	if(blocked_enemy_positions.size() == 5): 
		blocked_enemy_positions = Array([], TYPE_INT, "", null)
