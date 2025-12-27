extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("appear")
	$CenterContainer/RichTextLabel.text = "Game Over. Score: " + str(G.score)


func _on_again_button_button_up() -> void:
	$AnimationPlayer.play_backwards("appear")
	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var direct_order = $AnimationPlayer.current_animation_length == $AnimationPlayer.current_animation_position
	if anim_name == "appear" and !direct_order:
		$Transition.play("fade")
		print("deleted")
	
	

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		G.emit_signal("reload_game")
		queue_free()
