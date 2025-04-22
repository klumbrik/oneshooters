extends CharacterBody2D

var is_shooting = true
var ammo = 6
var bullet = preload("res://bullet.tscn")


var swipe_length = 25  #Swipe variables. They should be declared here globally.
var swiping = false
var swipe_cur_pos: Vector2
var swipe_start_pos: Vector2
var swipe_threshold = 30
var ducking = false
var shoot_cooldown_passed = false

var character_state_machine: LimboHSM
#var right_swipe_detected = false I decided to make this global in G to change it in the cover scene


func _ready() -> void:
	$Timer.wait_time = 0.8 / G.pacedif_modifier
	$ReloadTimer.wait_time = 0.6 / G.pacedif_modifier
	initiate_state_machine()
	character_state_machine.dispatch(&"to shoot") #entering the shooting state
	

func _input(event: InputEvent) -> void:
	pass #moved shoot controls into states
			
			
func _physics_process(_delta: float) -> void: #main function
	#print(character_state_machine.get_active_state())
	#print(ducking)
	G.ammo = ammo
	if !is_shooting:
		$Timer.paused = true
	else:
		$Timer.paused = false
	swipe_detection() #we need to detect swipes each frame
	if G.right_swipe_detected:
		G.moving = true
		
	use_stash()
	
			
	
	

func _on_timer_timeout() -> void: #when the shooting timer expires
	shot()


func _on_reload_timer_timeout() -> void:
	if ammo < 6:
		ammo += 1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies') or area.is_in_group('enemy_damage'):
		get_tree().paused = true
		G.game_over = true

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
	if ammo > 0:
		$Sprite2D/AnimationPlayer.seek(0)
		$Sprite2D/AnimationPlayer.play("shoot")
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = Vector2(25, -5) #bullet position for jed in space of the character scene
		add_child(new_bullet)
		ammo -= 1


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
	character_state_machine.add_child(shooting_state)
	character_state_machine.add_child(reloading_state)
	character_state_machine.add_child(running_state)
	character_state_machine.add_child(duckingdown_state)
	character_state_machine.add_child(duckingup_state)
	
	character_state_machine.initial_state = shooting_state
	
	character_state_machine.add_transition(character_state_machine.ANYSTATE, duckingdown_state, &"to downduck")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, duckingup_state, &"to upduck")
	character_state_machine.add_transition(duckingdown_state, reloading_state, &"to reload")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, shooting_state, &"to shoot")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, running_state, &"to run")
	
	character_state_machine.initialize(self)
	character_state_machine.set_active(true)
	
#state machine funcs on enter and update
func shooting_enter():
	$Sprite2D/AnimationPlayer.play("RESET")
	G.moving = false
	$Timer.start()	
	if shoot_cooldown_passed and !G.moving: #if the character reaches the cooldown he shoots immediately
		shot()
		shoot_cooldown_passed = false
func shooting_update(delta: float):
	shoot_controls() #to detect input
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
	$Timer.stop() #We stop the timer to stop shooting
	$Sprite2D/AnimationPlayer.play("duck")
func duckingdown_update(delta: float):
	shoot_controls() #to detect input
	if !ducking:
		character_state_machine.dispatch(&"to upduck")
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.26: #shooting cooldown
		shoot_cooldown_passed = true
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.4:
		character_state_machine.dispatch(&"to reload")
	
	if G.moving: #the same condition added on every state update
		character_state_machine.dispatch(&"to run")

func duckingup_enter():
	$Sprite2D/AnimationPlayer.play_backwards("duck")
func duckingup_update(delta: float):
	shoot_controls() #to detect input
	if ducking:
		character_state_machine.dispatch(&"to downduck")
	if $Sprite2D/AnimationPlayer.current_animation_position == 0: #changing to the shooting state if we're currently on the 0 sec of the duck animation
		character_state_machine.dispatch(&"to shoot")
		
	if G.moving: #the same condition added on every state update
		character_state_machine.dispatch(&"to run")

func reloading_enter(): 
	$ReloadTimer.start()
func reloading_update(delta: float):
	shoot_controls() #to detect input
	if !ducking:
		$ReloadTimer.stop()
		character_state_machine.dispatch(&"to upduck")

	if G.moving: #the same condition added on every state update
			character_state_machine.dispatch(&"to run")

func running_enter():
	$Timer.stop()
	shoot_cooldown_passed = false
	$Sprite2D/AnimationPlayer.play("run")
func running_update(delta: float):
	shoot_controls() #to detect input
	if !G.moving:
		 #change if you want the character to duck automatically after running
		velocity.x = 0
		character_state_machine.dispatch("to shoot")
	else:
		velocity.x = G.moving_speed
		move_and_slide()


	
	
	
	
func swipe_detection():
	if Input.is_action_just_pressed("press"):
		if !swiping:
			$Swipe_Timer.start()
			swiping = true
			swipe_start_pos = get_global_mouse_position()
	if Input.is_action_pressed("press"):
		if swiping:
			swipe_cur_pos = get_global_mouse_position()
			if swipe_start_pos.distance_to(swipe_cur_pos) >= swipe_length:
				if abs(swipe_start_pos.y - swipe_cur_pos.y) <= swipe_threshold:
					#print("horizontal swipe!")
					if swipe_start_pos.x < swipe_cur_pos.x:
						#print("right swipe!")
						G.right_swipe_detected = true
				swiping = false
	else:
		swiping = false
		
	
	#considering adding a timer to this detection so that the player doesn't swipe to long. added (done)


func use_stash():
	if ammo == 0 and G.stash > 0:
		ammo += 3
		G.stash -= 3
		G.emit_signal("out_of_ammo")
