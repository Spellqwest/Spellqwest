@tool
extends Area2D
class_name EnemyProjectile

signal impacted(world_pos: Vector2, hit_area: Area2D)

@export var lifetime: float = 2.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 0

func setup(v: Vector2, dmg: int, frames: SpriteFrames, anim_name: StringName, projectile_scale: Vector2 = Vector2.ONE) -> void:
	velocity = v
	damage = dmg
	scale = projectile_scale

	if frames != null:
		anim.sprite_frames = frames
	if anim.sprite_frames != null and anim.sprite_frames.has_animation(String(anim_name)):
		anim.play(String(anim_name))
	else:
		anim.play()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.call("take_damage", damage)

	emit_signal("impacted", global_position, area)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()