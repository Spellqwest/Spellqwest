@tool
extends Area2D
class_name Beam

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var damage: int = 0
var lifetime: float = 0.0
var hit_interval: float = 0.1

var length: float = 300.0
var width: float = 24.0
var direction: Vector2 = Vector2.UP

var _started := false
var _tick_timer: Timer

func setup(
	_damage: int,
	_lifetime: float,
	_hit_delay: float, 
	frames: SpriteFrames,
	anim_name: StringName,
	_direction: Vector2,
	_length: float,
	_width: float
) -> void:
	damage = _damage
	lifetime = _lifetime
	hit_interval = max(0.01, _hit_delay)

	direction = _direction.normalized()
	length = _length
	width = _width

	monitoring = true
	monitorable = true

	# visuals
	if anim != null:
		if frames != null:
			anim.sprite_frames = frames
		if anim.sprite_frames != null and anim.sprite_frames.has_animation(String(anim_name)):
			anim.play(String(anim_name))
		else:
			anim.play()

	_configure_hitbox()

func start() -> void:
	if _started:
		return
	_started = true

	_tick_timer = Timer.new()
	_tick_timer.one_shot = false
	_tick_timer.wait_time = hit_interval
	add_child(_tick_timer)
	_tick_timer.timeout.connect(_on_tick)

	call_deferred("_start_ticks_async")

	_end_after(lifetime)

func _start_ticks_async() -> void:
	await get_tree().physics_frame
	_on_tick()
	_tick_timer.start()

func _configure_hitbox() -> void:
	rotation = direction.angle()

	var rect := RectangleShape2D.new()
	rect.size = Vector2(length, width)
	shape_node.shape = rect

	shape_node.position = Vector2(length * 0.5, 0)
	if anim != null:
		anim.position = Vector2(length * 0.5, 0)

func _on_tick() -> void:
	for a in get_overlapping_areas():
		if a.has_method("take_damage"):
			a.call("take_damage", damage)

func _end_after(t: float) -> void:
	if t <= 0.0:
		queue_free()
		return
	await get_tree().create_timer(t).timeout
	queue_free()
