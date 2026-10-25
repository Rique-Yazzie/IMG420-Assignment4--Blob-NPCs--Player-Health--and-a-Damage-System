# Inside your HealthBar or UI script
extends TextureProgressBar
@export var player: CharacterBody2D
func _ready() -> void:
	if player:
		# 1. Connect the signal for future changes
		player.health_changed.connect(_on_player_health_changed)
		# 2. Set the initial value explicitly right now
		max_value = player.max_health
		value = player.current_health
func _on_player_health_changed(current: int, max_hp: int) -> void:
	max_value = max_hp
	value = current
