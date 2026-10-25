
extends Node2D

@export var blob_scene: PackedScene
@export var spawn_cooldown: float = 4.0
@export var max_blobs_alive: int = 5

var spawn_points: Array[Marker2D] = []
var active_blobs: Array[CharacterBody2D] = []

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		var default_marker = Marker2D.new()
		add_child(default_marker)
		spawn_points.append(default_marker)

	spawn_timer.wait_time = spawn_cooldown
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	active_blobs = active_blobs.filter(
		func(blob): return is_instance_valid(blob)
	)

	if active_blobs.size() >= max_blobs_alive:
		return

	if blob_scene:
		spawn_new_blob()

func spawn_new_blob() -> void:
	var random_marker = spawn_points.pick_random()
	var new_blob = blob_scene.instantiate() as CharacterBody2D

	new_blob.global_position = random_marker.global_position
	active_blobs.append(new_blob)
	get_parent().add_child.call_deferred(new_blob)

	trigger_spawn_juice(new_blob)

func trigger_spawn_juice(target_blob: CharacterBody2D) -> void:
	var blob_sprite = target_blob.get_node_or_null("BlobSprite")
	if blob_sprite:
		var spawn_tween = create_tween()
		blob_sprite.scale = Vector2.ZERO
		spawn_tween.tween_property(
			blob_sprite, "scale", Vector2(1.3, 1.3), 0.15
		)
		spawn_tween.tween_property(
			blob_sprite, "scale", Vector2(1.0, 1.0), 0.1
		)
