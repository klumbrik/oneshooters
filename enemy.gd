extends CharacterBody2D


var mouse_onself = false
var target = preload("res://target.tscn")
var SPEED = 80.0 * G.pacedif_modifier
var hp
var chance
var disabled_damage = false
var is_in_zone = false
#const JUMP_VELOCITY = -400.0

func _ready() -> void: #when spawns randomly defines hp
	$Sprite2D/AnimationPlayer.play("run")
	chance = randf() 
	if chance < 0.9:
		hp = 1
		$ShieldMask.visible = false
	else: 
		hp = 2
		$ShieldMask.visible = true
	#hp = randi_range(1,2) 
func _physics_process(delta: float) -> void:
	#velocity.limit_length(SPEED)
	velocity.x = -SPEED
	$RichTextLabel.text = str(hp)
	#print(velocity.length())
	if hp <= 0:
			$CollisionShape2D.disabled = true
			$Area2D/CollisionShape2D.disabled = true
			die()
	if !G.wave_going: #we stop if the wave stops
		velocity.x = 0
		disable_damage()
	else:
		enable_damage()
		
	add_target()
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('damage'):
		hp -= 1 #damage
		get_damage()
	if area.is_in_group('character'):
		#if !disabled_damage:
			#get_tree().paused = true
			#G.game_over = true removed it because it worked in a stupid way
		pass
	if area.is_in_group('target_zone'):
		is_in_zone = true
		#print("Entered zone ", is_in_zone)
		
		
		
		


func add_target():
	if mouse_onself:
		if Input.is_action_just_pressed("press"):
			var new_target = target.instantiate()
			add_child(new_target)

func die():
	$Sprite2D/AnimationPlayer.play("beaten")
	if is_in_zone and G.stash < 6: #before disabling collision we track if it is in zone to add stash ammo. The limit can be tweaked.
		G.stash += 3
		G.emit_signal("enemy_died")
	disable_damage()
func get_damage():
	velocity.x = 0
	$Sprite2D/AnimationPlayer.play("damage_taken")
	
func disable_damage():
	$CollisionShape2D.disabled = true
	$Area2D.monitorable = false
	disabled_damage = true
	
	
func enable_damage():
	$CollisionShape2D.disabled = false
	$Area2D.monitorable = true
	disabled_damage = false
	

	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "beaten":
		#print("before removal, is in zone: ", is_in_zone)
		is_in_zone = false
		queue_free()
		G.score += 10 #adding 10 points for each enemy defeated
	if anim_name == "damage_taken":
		$Sprite2D/AnimationPlayer.play("run")


		


func _on_area_2d_mouse_entered() -> void:
	mouse_onself = true


func _on_area_2d_mouse_exited() -> void:
	mouse_onself = false


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group('target_zone'):
		is_in_zone = false
		#print(is_in_zone)
