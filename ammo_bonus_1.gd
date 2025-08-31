extends RigidBody2D
#this bonus is like stash piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.visible = true
	$Pick_Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pick_timer_timeout() -> void:
	$AnimationPlayer.play("dissappear")





func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("character"):
		queue_free()
		if G.stash_pieces < 2:
			G.stash_pieces += 1
			G.stash += 3
		G.emit_signal("bonus_stash")
			
