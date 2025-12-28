extends StaticBody2D

var appeared
var ducked = false
var dodging = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print("appeared: ", appeared, " shield_enabled: ", G.shield_enabled)
	#print("collision disabled:", $CollisionShape2D.disabled)
	if G.shield_enabled and !appeared:
		$CollisionShape2D.disabled = false
		visible = true
		$Sprite2D/AnimationPlayer.play("appear")
	elif G.shield_enabled == false:
		$CollisionShape2D.disabled = true
		visible = false
		appeared = false
		
	if G.shield_enabled and !dodging:
		for area in $Area2D.get_overlapping_areas():
			var is_enemy = area.is_in_group("enemies")
			var is_bullet = area.is_in_group("enemy_damage")
		
			if is_bullet and ducked:
				break  # shield doesn't get destroyed
			if is_enemy or is_bullet:
				$Sprite2D/AnimationPlayer.play("destroyed")
				break
	
	if dodging:
		collision_mask = 0
		collision_layer = 0
		print("dont collide")
	else: 
		collision_mask = 1
		collision_layer = 1
		print("collide")
		
func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "appear":
		appeared = true
		$energy.play()
		
	if anim_name == "destroyed":
		$shield_crash.play()
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroyed":
		queue_free()
		G.shield_enabled = false
		
