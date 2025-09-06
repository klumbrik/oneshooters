extends RigidBody2D
#this bonus is like stash piece
var tag
var converted_to_coin = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.visible = true
	$Pick_Timer.start()
	tag = "ammo3"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tag == "ammo3":
		if G.stash_pieces == 2:
			tag = "coin"
			convert_to_coin()
	elif tag == "shield":
		if G.shield_enabled:
			tag = "coin"
			convert_to_coin()

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
		elif tag == "coin":
			G.coins += 1
		queue_free()

func convert_to_coin():
	if !converted_to_coin:
		$AnimationPlayer.play("to_coin")
		converted_to_coin = true
