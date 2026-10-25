extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		var player = get_parent()
		if player.has_method("take_damage"):
			player.take_damage(10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
