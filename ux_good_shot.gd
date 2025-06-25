extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	G.enemy_died.connect(self._on_enemy_died)


func _on_enemy_died():
	visible = true
	$position_anim/AnimationPlayerShot.play("perfect")
