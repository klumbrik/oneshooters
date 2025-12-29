extends "res://scripts/bullet.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bullet_owner = "drone"
	add_to_group("drone_bullet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
