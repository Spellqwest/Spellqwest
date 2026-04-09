extends Node2D

##############################################
#Global Variables
##############################################
signal enemy_entity_died(gold: int)

@export var enemy_scene:= preload("res://scenes/game/combat/enemies/Enemy.tscn") 

var spawnPoints: Array[Marker2D] = []
var rng = RandomNumberGenerator.new()
var spawnTimer: Timer

##############################################
#Functions
##############################################
func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			spawnPoints.append(child)
	spawnTimer = $SpawnTimer
	_on_enemy_spawn_timer_timeout()

func _on_enemy_spawn_timer_timeout() -> void:
	var free_spawns: Array[Marker2D] = []

	for spawn in spawnPoints:
		var area: Area2D = spawn.get_node("SpawnArea")
		if not area.has_overlapping_areas():
			free_spawns.append(spawn)
	
	if free_spawns.is_empty():
		return
	
	var spawn_point = free_spawns[rng.randi_range(0, free_spawns.size() - 1)]
	var enemy: Enemy = enemy_scene.instantiate()
	
	enemy.global_position = spawn_point.global_position
	enemy.enemy_died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_died(gold: int) -> void:
	emit_signal("enemy_entity_died", gold)
	
func combat_end() -> void:
		spawnTimer.stop()
		for child in get_children():
			if child.is_in_group("enemy"):
				child.queue_free()

func combat_start() -> void:
		spawnTimer.start()
