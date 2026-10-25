
extends TextureProgressBar

@export var animation_duration: float = 0.25

var health_tween: Tween

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		push_error("GameUI: Could not find Player in the Player group.")
		return

	# Set the initial display immediately.
	max_value = player.max_health
	value = player.current_health

	# Listen for future health changes.
	player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(
	current_health: int,
	new_max_health: int
) -> void:
	max_value = new_max_health

	if health_tween and health_tween.is_running():
		health_tween.kill()

	health_tween = create_tween()
	health_tween.tween_property(
		self,
		"value",
		current_health,
		animation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
