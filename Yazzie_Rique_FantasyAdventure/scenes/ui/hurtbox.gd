
class_name Hurtbox
extends Area2D

signal damage_received(hitbox: Hitbox)

var is_invincible: bool = false
var iframe_timer: Timer

func _init() -> void:
	monitoring = false
	monitorable = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_setup_iframe_timer()

func _setup_iframe_timer() -> void:
	iframe_timer = Timer.new()
	iframe_timer.one_shot = true
	add_child(iframe_timer)
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)

func _on_area_entered(incoming_area: Area2D) -> void:
	if is_invincible:
		return

	if incoming_area is Hitbox:
		var hitbox = incoming_area as Hitbox
		damage_received.emit(hitbox)

func start_invincibility(duration: float) -> void:
	if duration <= 0.0:
		return

	is_invincible = true
	set_deferred("monitorable", false)
	iframe_timer.start(duration)

func _on_iframe_timer_timeout() -> void:
	is_invincible = false
	set_deferred("monitorable", true)
