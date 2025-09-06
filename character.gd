extends CharacterBody2D
#IF YOU CHANGE ANIMATION TIMINGS, CHANGE ALL THE LINES ABOUT THE ANIM POSITION
#var is_shooting = true
@export var dontshoot: bool #testing

#var ammo = G.ammo
var bullet = preload("res://bullet.tscn")
var time_to_die = false
var swipe_length = 25  #Swipe variables. They should be declared here globally.
var swiping = false
var swipe_cur_pos: Vector2
var swipe_start_pos: Vector2
var swipe_threshold = 30
var ducking = false
var shoot_cooldown_passed = false
var anim_pos := 0.0
var left_swipe_blocked = true
var left_swipe_block_duration = 0.1

var invincible = false #can't die and collide (for tests)
var dodge_speed = 200

var dodge_old_pos_x = position.x
var character_state_machine: LimboHSM

var dodge_finished = false
var death_finished = false

var reload_anim_played = false
#var right_swipe_detected = false I decided to make this global in G to change it in the cover scene


func _ready() -> void:
	G.character_ref = self
	G.character_position = global_position
	$Timer.wait_time = 0.8 / G.pacedif_modifier
	#$ReloadTimer.wait_time = 0.6 / G.pacedif_modifier
	initiate_state_machine()
	character_state_machine.dispatch(&"to shoot") #entering the Sshooting state
	$Timer.start() #INITIAL SHOOT timer start

func _input(event: InputEvent) -> void: #for pc controls
	if Input.is_action_just_pressed("right"):
		G.right_swipe_detected = true
		G.left_swipe_detected = false
		G.number_of_right_swipes += 1
		if !G.moving and G.current_cover_number > G.last_cover_number:
			G.emit_signal("swipe_room") #to create a new room
			G.last_cover_number = G.current_cover_number
	elif Input.is_action_just_pressed("left"):
		if !left_swipe_blocked:
			G.left_swipe_detected = true	
			G.right_swipe_detected = false
	elif Input.is_action_pressed("space"):
		ducking = true
	else:
		ducking = false
			
func _physics_process(_delta: float) -> void: #main function
	#print($Sprite2D/AnimationPlayer.current_animation)
	#print("left swipe:", G.left_swipe_detected, " ", "right swipe:", G.right_swipe_detected, "number_of_rights: ", number_of_right_swipes)
	#print(character_state_machine.get_active_state().name)
	#print(ducking)
	#print(shoot_cooldown_passed)
	#print($Timer.time_left, $Timer.paused)
	#print($Sprite2D/AnimationPlayer.current_animation, $Sprite2D/AnimationPlayer.current_animation_position)
	#print("dodge_finished: " + str(dodge_finished))
	#G.ammo = ammo
	#if !is_shooting:
		#$Timer.paused = true #not needeed anymore. Ruins being in the process.So paused parameter is changed in the states
	#else:
	#$Timer.paused = false
	swipe_detection() #we need to detect swipes each frame
	
	if G.shield_enabled:
		invincible = true
	else:
		if character_state_machine.get_active_state().name != "dodging":
			invincible = false
		
	if G.right_swipe_detected:
		G.moving = true
		
	use_stash()
	
	$debugger.text = str(G.number_of_right_swipes)
	
	print("running update — swipes:", G.number_of_right_swipes, " dodges:", G.number_of_dodges)	
	
	

func _on_timer_timeout() -> void: #when the shooting timer expires
	if !dontshoot:
		shot()


#func _on_reload_timer_timeout() -> void:
	#if ammo < 6 and !G.reload_cooldown_active:
		#$Sprite2D/AnimationPlayer.play("reload")
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies') or area.is_in_group('enemy_damage'):
		if !invincible: #are you sure?
			$DeathTimer.start()
			time_to_die = true #probably the character will die if not escapes

func _on_area_2d_area_exited(area: Area2D) -> void: #bugs may arise when working with enemy bullets. Might be solved by adding a new group for it
	if area.is_in_group('enemies') or area.is_in_group('enemy_damage'):
		time_to_die = false
		

func _on_shootingrange_body_exited(body: Node2D) -> void: #bullet range restriction
	if body.is_in_group("damage"):
		body.emit_signal("range")















func shoot_controls():
		if swipe_start_pos.distance_to(swipe_cur_pos) == 0: #if finger is not moving
			if Input.is_action_pressed("press"): 
				if swipe_cur_pos == swipe_start_pos:
					ducking = true
		if Input.is_action_just_released("press"): #were on one level 
				ducking = false
		
func shot():
	if G.ammo > 0:
		$Sprite2D/AnimationPlayer.seek(0)
		$Sprite2D/AnimationPlayer.play("shoot")
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = Vector2(5, -5) #bullet position for jed in space of the character scene (25, -5)
		add_child(new_bullet)
		#ammo -= 1
		G.emit_signal("shot")
		if G.sound_on == true:
			$BlasterMetallic01.play()


func _on_swipe_timer_timeout() -> void:
	swiping = false



func initiate_state_machine():
	character_state_machine = LimboHSM.new()
	add_child(character_state_machine)
	
	var shooting_state = LimboState.new().named("shooting").call_on_enter(shooting_enter).call_on_update(shooting_update)
	var reloading_state = LimboState.new().named("reloading").call_on_enter(reloading_enter).call_on_update(reloading_update)
	var running_state = LimboState.new().named("running").call_on_enter(running_enter).call_on_update(running_update)
	var duckingdown_state = LimboState.new().named("duckingdown").call_on_enter(duckingdown_enter).call_on_update(duckingdown_update)
	var duckingup_state = LimboState.new().named("duckingup").call_on_enter(duckingup_enter).call_on_update(duckingup_update)
	var dodging_state = LimboState.new().named("dodging").call_on_enter(dodging_enter).call_on_update(dodging_update)
	var null_state = LimboState.new().named("null")
	
	character_state_machine.add_child(shooting_state)
	character_state_machine.add_child(reloading_state)
	character_state_machine.add_child(running_state)
	character_state_machine.add_child(duckingdown_state)
	character_state_machine.add_child(duckingup_state)
	character_state_machine.add_child(dodging_state)
	character_state_machine.add_child(null_state)
	
	character_state_machine.initial_state = shooting_state
	
	character_state_machine.add_transition(character_state_machine.ANYSTATE, duckingdown_state, &"to downduck")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, duckingup_state, &"to upduck")
	character_state_machine.add_transition(duckingdown_state, reloading_state, &"to reload")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, shooting_state, &"to shoot")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, running_state, &"to run")
	character_state_machine.add_transition(running_state, dodging_state, &"to dodge")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, null_state, &"to null")
	
	character_state_machine.initialize(self)
	character_state_machine.set_active(true)
	
#state machine funcs on enter and update
func shooting_enter():
	dodge_finished = false
	#G.number_of_right_swipes = 0
	$Sprite2D.flip_h = false
	$Sprite2D/AnimationPlayer.play("RESET")
	G.moving = false
	$Timer.paused = false #starting Timer from the same time where it was paused
	if shoot_cooldown_passed and !G.moving:
		#print("shot?!") #if the character reaches the cooldown he shoots immediately (when stands up after frame threshhold)
		$Timer.stop() #stopping timer so that bullets don't stack more than 1 at a time
		shot()
		$Timer.start() #starting again to not stop shooting
		shoot_cooldown_passed = false
	
func shooting_update(delta: float):
	shoot_controls() #to detect input #it's important to repeat here to not have tap bugs
	if $Sprite2D/AnimationPlayer.current_animation == "shoot":
		if $Sprite2D/AnimationPlayer.current_animation_position >= 0.2: #we need to let the shoot animation play a bit so it looks coherent
			if ducking:
				character_state_machine.dispatch(&"to downduck")
	elif $Sprite2D/AnimationPlayer.current_animation_position == 1 or $Sprite2D/AnimationPlayer.current_animation == "":	
		if ducking:
				character_state_machine.dispatch(&"to downduck")
	
	if G.moving: #the same condition added on every state update
		character_state_machine.dispatch(&"to run")

func duckingdown_enter():
	#print("error?")
	#$Sprite2D/AnimationPlayer.play("duck")
	#$Timer.paused = true #We pause the timer to stop shooting
	anim_pos = 0.0
	if $Sprite2D/AnimationPlayer.current_animation == "duck":
		anim_pos = $Sprite2D/AnimationPlayer.current_animation_position
	#print(anim_pos)
	$Sprite2D/AnimationPlayer.play("duck")
	$Sprite2D/AnimationPlayer.seek(anim_pos, true) # Continue from current pos
	$Timer.paused = true #We pause the timer to stop shooting
func duckingdown_update(delta: float):
	shoot_controls() #to detect input
	if !ducking:
		character_state_machine.dispatch(&"to upduck")
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.26: #shooting cooldown
		shoot_cooldown_passed = true
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.3:
		#print("relod")
		character_state_machine.dispatch(&"to reload")
		
	if G.moving: #the same condition added on every state update
		character_state_machine.dispatch(&"to run")

func duckingup_enter():
	$Sprite2D/AnimationPlayer.play_backwards("duck")
func duckingup_update(delta: float):
	shoot_controls() #to detect input
	if ducking:
		#$Sprite2D/AnimationPlayer.seek($Sprite2D/AnimationPlayer.current_animation_position)
		character_state_machine.dispatch(&"to downduck")
	elif $Sprite2D/AnimationPlayer.current_animation_position == 0.0 and $Sprite2D/AnimationPlayer.current_animation == "": #empty animation string is default stand pose
		character_state_machine.dispatch(&"to shoot")
	
	
	#elif $Sprite2D/AnimationPlayer.current_animation_position >= 0: #changing to the shooting state if we're currently on the 0 sec of the duck animation
		##print("mistake", $Sprite2D/AnimationPlayer.current_animation, $Sprite2D/AnimationPlayer.current_animation_position)
		#character_state_machine.dispatch(&"to shoot")
		
	if G.moving: #the same condition added on every state update
		character_state_machine.dispatch(&"to run")

func reloading_enter(): 
	try_reload()
	
func reloading_update(delta: float):
	try_reload()
	shoot_controls() #to detect input
	if !ducking:
		#$ReloadTimer.stop()
		character_state_machine.dispatch(&"to upduck")

	if G.moving: #the same condition added on every state update
			character_state_machine.dispatch(&"to run")

func running_enter():
	if G.sound_on:
		$Run.play()
	$Timer.paused = true
	shoot_cooldown_passed = false
	$Sprite2D/AnimationPlayer.play("run")
	
	left_swipe_blocked = true
	await get_tree().create_timer(left_swipe_block_duration).timeout
	left_swipe_blocked = false

func running_update(delta: float):
	shoot_controls() #to detect input
	
	if !G.moving:
		 #change if you want the character to duck automatically after running
		velocity.x = 0
		character_state_machine.dispatch(&"to shoot")
		$Run.stop()
	else:
		if G.right_swipe_detected:
			velocity.x = G.moving_speed
			$Sprite2D.flip_h = false
			if G.number_of_right_swipes > 1 and G.number_of_dodges > 0:
				G.number_of_dodges -= 1
				character_state_machine.dispatch(&"to dodge")
				$Run.stop()
		elif G.left_swipe_detected:
			
			if !G.last_cover_moved: #move if running back to last cover
				G.emit_signal("move_last_cover")
				G.last_cover_moved = true
				#print("cover moved")
				
			velocity.x = -G.moving_speed
			$Sprite2D.flip_h = true
			G.number_of_right_swipes = 0 #to avoid superflous dodge bug
			G.emit_signal("make_cover_unused")
		move_and_slide()

func dodging_enter():
	G.emit_signal("dodge_bar_empty")
	time_to_die = false
	$DeathTimer.stop()
	if G.sound_on:
		$Roll.play()
	invincible = true
	$Sprite2D/AnimationPlayer.play("dodge")
	dodge_old_pos_x = position.x #remembering the old position to calculate dodge distance
	
	

func dodging_update(delta: float):
	shoot_controls() 

	var target_distance = 80
	if !G.moving:
		 #change if you want the character to duck automatically after running
		velocity.x = 0
		invincible = false
		if dodge_finished:
			character_state_machine.dispatch("to shoot")
	else:
		#print(position.x - dodge_old_pos_x)
		velocity.x = dodge_speed
		if position.x - dodge_old_pos_x >= target_distance and dodge_finished: #more or equals because we can't calculate it precisely 
			print('yes')
			#G.number_of_right_swipes = 0 #need to reset to avoid bugs
			invincible = false
			dodge_finished = false
			character_state_machine.dispatch("to run")
		
		
	
	move_and_slide()
	
	
	
func swipe_detection():
	if Input.is_action_just_pressed("press"):
		if !swiping:
			$Swipe_Timer.start()
			swiping = true
			swipe_start_pos = get_viewport().get_mouse_position()
	if Input.is_action_pressed("press"):
		if swiping:
			swipe_cur_pos = get_viewport().get_mouse_position()
			if swipe_start_pos.distance_to(swipe_cur_pos) >= swipe_length:
				if abs(swipe_start_pos.y - swipe_cur_pos.y) <= swipe_threshold:
					#print("horizontal swipe!")
					if swipe_start_pos.x < swipe_cur_pos.x:
						#print("right swipe!")
						G.right_swipe_detected = true
						G.left_swipe_detected = false
						G.number_of_right_swipes += 1
						if !G.moving and G.current_cover_number > G.last_cover_number:
							G.emit_signal("swipe_room") #to create a new room
							G.last_cover_number = G.current_cover_number
					elif swipe_start_pos.x > swipe_cur_pos.x:
						#print("left swipe!")
						if !left_swipe_blocked:
							G.left_swipe_detected = true
							G.right_swipe_detected = false
				swiping = false
	else:
		swiping = false
		
	
	#considering adding a timer to this detection so that the player doesn't swipe to long. added (done)


func use_stash():
	if G.ammo == 0 and G.stash > 0:
		G.ammo += 3
		G.stash -= 3
		G.stash_pieces -= 1
		G.emit_signal("out_of_ammo")

	

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "reload" and G.ammo < 6:
		G.emit_signal("rotate_ui")
	else:
		G.emit_signal("cancel_reload_rotation")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "reload":
		reload_anim_played = false
		if G.sound_on:
			$Reload.play()
		#print("done")
		#if ammo < 6 and !G.reload_cooldown_active:
			#ammo += 1
			#$ReloadTimer.start()
			#$Sprite2D/AnimationPlayer.play("reload")
			#if G.sound_on:
				#$Reload.play()
		
		
	if anim_name == "dodge":
		dodge_finished = true
	
	if anim_name == "death":
		death_finished = true
		if G.score >= G.best_score:
			G.best_score = G.score #saving new best
		game_over()

func try_reload():
	if (!G.reload_cooldown_active and !reload_anim_played) or (character_state_machine.get_active_state().name == "reloading" and $Sprite2D/AnimationPlayer.current_animation == ""):
		if G.ammo < 6:
			$Sprite2D/AnimationPlayer.play("reload")
			reload_anim_played = true		

func _on_death_timer_timeout() -> void:
	if time_to_die:
		print("this is the end")
		
		character_state_machine.dispatch(&"to null")
		$Timer.stop() #need to stop timer to avoid state bugs
		G.moving = false
		if G.sound_on == true:
			$RobloxOof.play()
		$Sprite2D/AnimationPlayer.play("death")
		

		
func game_over():
	freeze_script()
	print("oKKK")
	set_process(false) #what?
	G.game_over = true
	G.save_json_file()



func freeze_script():
	invincible = true
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	$Timer.stop()
	#$ReloadTimer.stop()
	$DeathTimer.stop()
	G.moving = false
	$Run.stop()
