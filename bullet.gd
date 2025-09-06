extends RigidBody2D
signal range
var hit = false
#var speed = 1000#
# Called when the node enters the scene tree for the first time.

#НАГОВНОКОДИЛ! ИСПРАВЬ и инглиш
func _ready() -> void:
	#$BulletTexture/AnimationPlayer.play("thrown")
	$RayCast2D.enabled = true
	$RayCast2D.force_raycast_update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not hit:
		# Настраиваем луч в направлении движения
		$RayCast2D.force_raycast_update()
		
		# Если луч пересекает врага
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider() # returns node link
			if collider.is_in_group("enemies") and collider == G.current_target_enemy:
				freeze = true
				#linear_velocity = Vector2.ZERO
				#constant_force = Vector2.ZERO
				_on_hit()
				
	else:
		$Area2D.set_deferred("monitorable", false)
func _on_hit():
		$BulletTexture/AnimationPlayer.play("collided")
		$CollisionShape2D.set_deferred("disabled", true)
		
		hit = true
		
		
		
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "collided":
		queue_free()
	if anim_name == "dissolve":
		queue_free()

func _on_range() -> void:
	set_deferred("freeze", true)
	if $BulletTexture/AnimationPlayer.current_animation != "collided":
		$BulletTexture/AnimationPlayer.play("dissolve")
