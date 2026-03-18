@tool
extends Area2D
class_name Projectile

signal impacted(world_pos: Vector2, hit_area: Area2D)

@export var lifetime: float = 2.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 0

func setup(v: Vector2, dmg: int, frames: SpriteFrames, anim_name: StringName) -> void:
	velocity = v
	damage = dmg
	if frames != null:
		anim.sprite_frames = frames
	if anim.sprite_frames != null and anim.sprite_frames.has_animation(String(anim_name)):
		anim.play(String(anim_name))
	else:
		anim.play()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	area_entered.connect(_on_area_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.call("take_damage", damage)

	emit_signal("impacted", global_position, area)
	queue_free()
