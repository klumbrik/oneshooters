extends "res://enemy.gd"



func _ready() -> void:
	super._ready() #call base parent's ready
	# change hp
	hp = 2

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	super._on_animation_player_animation_finished(anim_name)
	# delete shield if it exists
	if anim_name == "damage_taken":
		$Sprite2D/AnimationPlayer.play("run")
		if is_instance_valid($ShieldMask):
			$ShieldMask.queue_free()


#remove enemies from the game (NOT from the array) when player reaches a new cover to keep memory clean












#func _unhandled_input(event: InputEvent) -> void: old solution
	#if event is InputEventMouseButton and event.pressed:
		#var topleft = get_corners_in_global()[0]
		#var botright = get_corners_in_global()[3]
		#var rect = Rect2(topleft, abs(botright - topleft)) #rect params are position (top left corner) and size
		#if rect.has_point(event.global_position):
			#G.emit_signal("enemy_tap",self) #handing over self link as a parameter along with emitting a signal
#func get_corners_in_global():
	#var shape = $Area2D/CollisionShape2D.shape
	#var extents = shape.extents #distance from the center of the collision
	#var local_corners = [
		#Vector2(-extents.x, -extents.y), #top left
		#Vector2(extents.x, -extents.y),#top right
		#Vector2(-extents.x, extents.y),#bottom left
		#Vector2(extents.x, extents.y)#bottom right
	#]
	#var global_corners = []
	#for corner in local_corners:
		#global_corners.append($Area2D/CollisionShape2D.get_global_transform() * corner) #apply global transform to every local point
	#return global_corners
	#
