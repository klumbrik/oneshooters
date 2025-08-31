extends CharacterBody2D


var mouse_onself = false
var SPEED: float 
@onready var hp = 1
var chance
var disabled_damage = false
var is_in_zone = false
var killed = false
var index = null
var for_deletion
var bonus_dropped
var bonus_chance
var enemy_state_machine: LimboHSM

#const JUMP_VELOCITY = -400.0

func _ready() -> void: #when spawns randomly defines hp
	$Sprite2D/AnimationPlayer.play("run")
	G.connect("delete_enemies_out_of_screen", _delete_enemies_out_of_screen)
	SPEED = randf_range(30.0, 60.0) * G.pacedif_modifier
	initiate_state_machine()
	

func initiate_state_machine():
	pass
	
	

func _physics_process(delta: float) -> void:
	
	#test
	var test_myindex = G.enemiesonscreen.find(self)
	
	if self == G.current_target_enemy:
		$test.text = "I'm target [" + str(test_myindex) + "]"
	else:
		$test.text = "I'm normis [" + str(test_myindex) + "]"
		
	#test
		
		
		
	#print(is_in_zone)
	#velocity.limit_length(SPEED)
	$RichTextLabel.text = str(hp)
	#print(velocity.length())
	if hp <= 0 and self == G.current_target_enemy:
	
			$Area2D/CollisionShape2D.disabled = true
			die()
			
	if !G.wave_going:
		velocity.x = 0
		disable_damage()
	else:
		enable_damage()
		velocity.x = -SPEED if should_move() else 0
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
	if area.is_in_group('damage') and self == G.current_target_enemy:
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
			#var new_target = target.instantiate()
			#add_child(new_target)
			G.emit_signal("enemy_tap",self) #handing over self link as a parameter along with emitting a signal

func die():
	$Sprite2D/AnimationPlayer.play("beaten")
	if !bonus_dropped:
		bonus_chance = randf()
		if bonus_chance <= 0.01: #chance of bonus
			print(bonus_chance)
			G.emit_signal("drop_bonus", global_position)
			bonus_dropped = true
	
	if is_in_zone and G.stash < 6: #before disabling collision we track if it is in zone to add stash ammo. The limit can be tweaked.
		G.stash += 3
		G.stash_pieces += 1
		G.emit_signal("enemy_died_in_zone", self) #passing self as an arguement
		killed = true
	disable_damage()
func get_damage():
	velocity.x = 0
	$Sprite2D/AnimationPlayer.play("damage_taken")
	
func disable_damage():

	$Area2D.monitorable = false
	disabled_damage = true
	
	
func enable_damage():

	$Area2D.monitorable = true
	disabled_damage = false
	

	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "beaten":
		#print("before removal, is in zone: ", is_in_zone)
		is_in_zone = false
		
		
		
		
		var children = get_children()
		remove_child(children[-1])
		get_parent().add_child(children[-1])
		unregister()
		queue_free()
		
		G.score += 10 #adding 10 points for each enemy defeated
	if anim_name == "damage_taken":
		$Sprite2D/AnimationPlayer.play("run")
		
	

		


func _on_area_2d_mouse_entered() -> void: #not needed now
	mouse_onself = true


func _on_area_2d_mouse_exited() -> void:
	mouse_onself = false


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group('target_zone'):
		is_in_zone = false
		#print(is_in_zone)

func unregister():
	G.enemiesonscreen.erase(self) #erase self from the allenemies array before dying







#old solution
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#var topleft = get_corners_in_global()[0]
		#var botright = get_corners_in_global()[3]
		#var rect = Rect2(topleft, abs(botright - topleft))
		#print(get_corners_in_global())
		#print(event.global_position + )
		#if rect.has_point(event.global_position):
			#G.emit_signal("enemy_tap",self) #handing over self link as a parameter along with emitting a signal
#func get_corners_in_global():
	#var shape = $Area2D/CollisionShape2D.shape
	#var extents = shape.extents
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


func _on_visible_on_screen_notifier_2d_screen_entered() -> void: #add to the array when entered the sreen
	for_deletion = false
	if index != null and index >= 0 and index <= G.enemiesonscreen.size():
		G.enemiesonscreen.insert(index, self)
		#print("INSERTED")
		G.current_target_enemy = null #to make space for a new [0] target
	else:
		G.enemiesonscreen.append(self)
	print("entered")
	#if 
	#insert at old_pos
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#remember index in case the enemy is not killed and we stored its index and the player returns
	if !killed: 
		index = G.enemiesonscreen.find(self)
		#print("remembered index: ", index)
	G.enemiesonscreen.erase(self)  #remove from the array when exited the sreen
	for_deletion = true
	
	if self == G.current_target_enemy: #clear a variable if the enemy is the target enemy and leaves the screen or dies
		G.current_target_enemy = null

func _delete_enemies_out_of_screen(): #remove this instance from the game if it's marked for deletion
	if for_deletion:
		#print("ENEMY DELETED")
		queue_free()
#remove enemies from the game (NOT from the array) when player reaches a new cover to keep memory clean

func should_move() -> bool:
	return true  # by default the base enemy always moves when the wave is going
