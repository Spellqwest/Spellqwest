@tool
extends Area2D
class_name DamageZone

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var tick_timer: Timer = $TickTimer if has_node("TickTimer") else null

var mode: AOESpellResource.AoEMode
var radius: float
var delay: float

# ONCE
var damage_once: int
var _hit := {}

# DOT
var duration: float
var tick_damage: int
var tick_rate: float
var _inside: Array[Area2D] = []

var _active := false

func setup_from_spell(spell: AOESpellResource) -> void:
	mode = spell.aoe_mode
	radius = spell.aoe_radius
	delay = max(0.0, spell.aoe_delay)

	damage_once = spell.aoe_damage_once

	duration = spell.aoe_duration
	tick_damage = spell.aoe_tick_damage
	tick_rate = max(0.01, spell.aoe_tick_rate)

	_set_radius(radius)

	# visuals
	if anim != null:
		if spell.aoe_frames != null:
			anim.sprite_frames = spell.aoe_frames
		if anim.sprite_frames != null and anim.sprite_frames.has_animation(String(spell.aoe_anim)):
			anim.play(String(spell.aoe_anim))
		else:
			anim.play()

	monitoring = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	_activate_after_delay()

func _set_radius(r: float) -> void:
	var circle := shape_node.shape as CircleShape2D
	if circle == null:
		circle = CircleShape2D.new()
		shape_node.shape = circle
	circle.radius = max(0.0, r)

func _activate_after_delay() -> void:
	call_deferred("_activate_after_delay_async")

func _activate_after_delay_async() -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	_active = true

	await get_tree().process_frame

	if mode == AOESpellResource.AoEMode.ONCE:
		_damage_once_now()
		queue_free()
		return

	# DOT
	_start_dot()
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		queue_free()

func _damage_once_now() -> void:
	for a in get_overlapping_areas():
		var id := a.get_instance_id()
		if _hit.has(id):
			continue
		_hit[id] = true
		_deal_damage(a, damage_once)

func _start_dot() -> void:
	if tick_timer == null:
		tick_timer = Timer.new()
		add_child(tick_timer)
	tick_timer.one_shot = false
	tick_timer.wait_time = tick_rate
	if not tick_timer.timeout.is_connected(_on_tick):
		tick_timer.timeout.connect(_on_tick)

	_on_tick()
	tick_timer.start()

func _on_area_entered(a: Area2D) -> void:
	if mode == AOESpellResource.AoEMode.DOT:
		if not _inside.has(a):
			_inside.append(a)

func _on_area_exited(a: Area2D) -> void:
	if mode == AOESpellResource.AoEMode.DOT:
		_inside.erase(a)

func _on_tick() -> void:
	if not _active:
		return

	for a in _inside.duplicate():
		if not is_instance_valid(a):
			_inside.erase(a)
			continue
		_deal_damage(a, tick_damage)

func _deal_damage(target: Area2D, amount: int) -> void:
	if target.is_in_group("enemy"):
		target.call("take_damage", amount)
