extends Node2D

##############################################
#Global Variables
##############################################
@export var enemy_scene:= preload("res://scenes/game/combat/enemies/Enemy.tscn") 

var baseYPos = 100

var enemy_spawnpoints: Array[Vector2] = [
	Vector2(314.0, baseYPos),
	Vector2(446.0, baseYPos),
	Vector2(574.0, baseYPos),
	Vector2(698.0, baseYPos),
	Vector2(826.0, baseYPos)
]
var blocked_enemy_spawns: Array[int] = []

var randomPos: int
var rng = RandomNumberGenerator.new()


##############################################
#Functions
##############################################
func _on_enemy_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	randomPos = rng.randi_range(0, 4)
	
	if(!blocked_enemy_spawns.has(randomPos)):
		enemy.position = enemy_spawnpoints[randomPos]
		blocked_enemy_spawns.append(randomPos)
		print("used enemy positions: " + str(blocked_enemy_spawns))
		print("spawning enemy on: " + str(enemy.position))
		add_child(enemy)
	print("in timer method mit rng: " + str(randomPos))
	if(blocked_enemy_spawns.size() == 5): 
		blocked_enemy_spawns = Array([], TYPE_INT, "", null)
