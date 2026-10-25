
extends CharacterBody2D

# Movement
@export var speed: float = 200.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $PlayerHurtbox

var last_direction: String = "down"
var is_action_playing: bool = false
var attack_active: bool = false
@export var iframe_duration: float = 0.6

# Health
signal health_changed(current_health, max_health)

@export var max_health: int = 100
var current_health: int = 100

@export var knockback_friction: float = 10.0

var knockback_velocity: Vector2 = Vector2.ZERO
var is_in_knockback: bool = false

func flash_sprite() -> void:
	var flash_tween = create_tween()

	flash_tween.tween_property(animated_sprite, "modulate:a", 0.4, iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 1.0, iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 0.4, iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 1.0, iframe_duration / 4.0)


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	hurtbox.damage_received.connect(_on_damage_received)


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)

	hurtbox.start_invincibility(iframe_duration)
	flash_sprite()

	if current_health <= 0:
		die()



# Restore health
func heal(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)


# Player death
func die() -> void:
	print("Player died!")


# Update facing direction
func update_direction(input_direction: Vector2) -> void:
	if input_direction.y < 0:
		last_direction = "up"
	elif input_direction.y > 0:
		last_direction = "down"
	elif input_direction.x < 0:
		last_direction = "left"
	elif input_direction.x > 0:
		last_direction = "right"


# Play idle or running animation
func update_movement_animation(input_direction: Vector2) -> void:
	if input_direction == Vector2.ZERO:
		animated_sprite.play("idle_" + last_direction)
	else:
		animated_sprite.play("run_" + last_direction)


# Play attack, hit, or death animation
func play_action_animation(action_name: String) -> void:
	is_action_playing = true
	animated_sprite.play(action_name + "_" + last_direction)

	if action_name == "attack":
		attack_active = true
		await get_tree().create_timer(0.25).timeout
		attack_active = false


# Test actions
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		play_action_animation("attack")
	elif event.is_action_pressed("test_hit"):
		take_damage(10)
		play_action_animation("hit")
	elif event.is_action_pressed("test_die"):
		play_action_animation("die")


# Player movement

func _physics_process(delta: float) -> void:
	if is_in_knockback:
		velocity = knockback_velocity
		move_and_slide()

		knockback_velocity = knockback_velocity.move_toward(
			Vector2.ZERO,
			knockback_friction * speed * delta
		)

		if knockback_velocity.length() < 10.0:
			is_in_knockback = false

		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)

	velocity = input_direction * speed

	update_direction(input_direction)

	if not is_action_playing:
		update_movement_animation(input_direction)

	move_and_slide()



# Allow action animations to finish
func _on_animated_sprite_2d_animation_finished() -> void:
	is_action_playing = false


func _on_damage_received(hitbox: Hitbox) -> void:
	take_damage(hitbox.damage)
	apply_knockback(hitbox.global_position, hitbox.knockback_force)


func apply_knockback(source_position: Vector2, force: float) -> void:
	var knockback_direction = (global_position - source_position).normalized()

	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.DOWN

	knockback_velocity = knockback_direction * force
	is_in_knockback = true


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
