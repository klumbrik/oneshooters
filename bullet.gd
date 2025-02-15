extends RigidBody2D
signal range
#пока что character но потом будет rigid
#var speed = 1000#
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$BulletTexture/AnimationPlayer.play("thrown")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies'):
		$BulletTexture/AnimationPlayer.play("collided")
		$CollisionShape2D.set_deferred("disabled", true)
		linear_velocity = Vector2.ZERO
		constant_force = Vector2.ZERO
		$Area2D.set_deferred("monitorable", false)
		
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "collided":
		print("bullet collided")
		queue_free()


func _on_range() -> void:
	if $BulletTexture/AnimationPlayer.current_animation != "collided":
		queue_free()
		print("bullet is out of range")
