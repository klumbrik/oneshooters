extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("appear")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		G.is_enemy_in_zone = true
		#print(G.is_enemy_in_zone)
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		G.is_enemy_in_zone = false
		#print(G.is_enemy_in_zone)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		$AnimationPlayer.play("burn")
