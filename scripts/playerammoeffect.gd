extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	G.out_of_ammo.connect(self._on_out_of_ammo)


func _on_out_of_ammo():
	visible = true
	$position_anim/AnimationPlayer.play("+ammo")
