extends RigidBody2D
#this bonus is like stash piece
var tag
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.visible = true
	$Pick_Timer.start()
	tag = "ammo3"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pick_timer_timeout() -> void:
	$AnimationPlayer.play("dissappear")





func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("character"):
		$AnimationPlayer.play("pick")
		
		
			


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pick":
		if tag == "shield":
			G.shield_enabled = true
		elif tag == "ammo3":
			if G.stash_pieces < 2:
				G.stash_pieces += 1
				G.stash += 3
			G.emit_signal("bonus_stash")
		queue_free()
