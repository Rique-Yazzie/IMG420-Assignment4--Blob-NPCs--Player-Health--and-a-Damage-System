
class_name Hitbox
extends Area2D

@export var damage: int = 10
@export var knockback_force: float = 300.0

func _init() -> void:
	monitoring = true
	monitorable = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	print("Hitbox detected area: ", area.name)

	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		hurtbox.damage_received.emit(self)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
