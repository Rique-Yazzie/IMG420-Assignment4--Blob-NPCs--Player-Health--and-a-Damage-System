
extends CharacterBody2D

enum State { IDLE, PATROL, CHASE }

@export var patrol_speed = 40.0
@export var chase_speed = 90.0
@export var idle_time = 1.5

@onready var detection_area = $DetectionArea

var current_state = State.IDLE
var player = null
var idle_timer = 1.5
var start_position: Vector2
var patrol_points = []
var patrol_index = 0

func _ready():
	start_position = global_position
	patrol_points = [
		start_position + Vector2(-100, 0),
		start_position + Vector2(100, 0)
	]
	idle_timer = idle_time

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			idle_timer -= delta
			if idle_timer <= 0:
				current_state = State.PATROL

		State.PATROL:
			var target = patrol_points[patrol_index]
			velocity = global_position.direction_to(target) * patrol_speed

			if global_position.distance_to(target) < 5:
				patrol_index = (patrol_index + 1) % patrol_points.size()
				current_state = State.IDLE
				idle_timer = idle_time

		State.CHASE:
			if is_instance_valid(player):
				velocity = global_position.direction_to(player.global_position) * chase_speed
			else:
				player = null
				current_state = State.PATROL

	move_and_slide()



func _on_body_entered(body):
	print("Blob detected: ", body.name)
	print("Player node name is: ", body.name)

	if body.name == "Player":
		print("Chasing Player!")
		player = body
		current_state = State.CHASE
		print("Current state is now CHASE")

func _on_body_exited(body):
	if body == player:
		player = null
		current_state = State.PATROL




func _on_detection_area_body_entered(body: Node2D) -> void:
	print("DETECTED BODY: ", body.name)

	if body == self:
		return

	if body.name == "Player":
		player = body
		current_state = State.CHASE
		print("CHASE STARTED!")
