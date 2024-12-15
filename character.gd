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

var character_state_machine: LimboHSM
#var right_swipe_detected = false I decided to make this global in G to change it in the cover scene


func _ready() -> void:
	initiate_state_machine()
	G.moving = false
	$Sprite2D/AnimationPlayer.play("shoot")
	$Timer.start()
	

func _input(event: InputEvent) -> void:
	pass #moved shoot controls into states
			
			
func _physics_process(_delta: float) -> void: #main function
	print(character_state_machine.get_active_state())
	G.ammo = ammo
	if !is_shooting:
		$Timer.paused = true
	else:
		$Timer.paused = false
	swipe_detection() #we need to detect swipes each frame
	if G.right_swipe_detected:
		G.moving = true
		
	
			
	
	

func _on_timer_timeout() -> void:
	if ammo > 0:
		$Sprite2D/AnimationPlayer.seek(0)
		$Sprite2D/AnimationPlayer.play("shoot")
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = Vector2(23, -5) #bullet position for jed
		add_child(new_bullet)
		ammo -= 1


func _on_reload_timer_timeout() -> void:
	if ammo < 6:
		ammo += 1


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass
	#if area.is_in_group('enemies'):
		#get_tree().paused = true


func _on_shootingrange_body_exited(body: Node2D) -> void: #bullet range restriction
	if body.is_in_group("damage"):
		print("bullet is out")
		body.queue_free()















func shoot_controls():
	if !G.moving:
		if swipe_start_pos.distance_to(swipe_cur_pos) == 0: #if finger is not moving
			if Input.is_action_pressed("press"): 
				if swipe_cur_pos == swipe_start_pos:
					ducking = true #ducking_state()
		if Input.is_action_just_released("press"): #were on one level 
				ducking = false #shooting state
		
			


func _on_swipe_timer_timeout() -> void:
	swiping = false



func initiate_state_machine():
	character_state_machine = LimboHSM.new()
	add_child(character_state_machine)
	
	var shooting_state = LimboState.new().named("shooting").call_on_enter(shooting_enter).call_on_update(shooting_update)
	var ducking_state = LimboState.new().named("ducking").call_on_enter(ducking_enter).call_on_update(ducking_update)
	var running_state = LimboState.new().named("running").call_on_enter(running_enter).call_on_update(running_update)
	
	character_state_machine.add_child(shooting_state)
	character_state_machine.add_child(ducking_state)
	character_state_machine.add_child(running_state)
	
	
	character_state_machine.initial_state = shooting_state
	
	character_state_machine.add_transition(shooting_state, ducking_state, &"to duck")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, shooting_state, &"state ended")
	character_state_machine.add_transition(character_state_machine.ANYSTATE, running_state, &"to run")
	
	character_state_machine.initialize(self)
	character_state_machine.set_active(true)
func shooting_enter():
	
	is_shooting = true
	$ReloadTimer.stop()
	
func shooting_update(delta: float):
	shoot_controls()
	if ducking == true:
		character_state_machine.dispatch(&"to duck")
	if G.moving == true:
		character_state_machine.dispatch(&"to run")
func ducking_enter(): #state machine funcs
	$Sprite2D/AnimationPlayer.play("duck")
	is_shooting = false
	$ReloadTimer.start()
func ducking_update(delta: float):
	shoot_controls()
	if ducking == false:
		$Sprite2D/AnimationPlayer.play_backwards("duck") #remove if needed 
		character_state_machine.dispatch(&"state ended")
	if G.moving == true:
		character_state_machine.dispatch(&"to run")
func running_enter():
	ducking = false
	is_shooting = false
	$Sprite2D/AnimationPlayer.play("run") #play run here
	velocity.x = G.moving_speed
func running_update(delta: float):
	move_and_slide()
	if G.moving == false:
		character_state_machine.dispatch(&"state ended")


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
					print("horizontal swipe!")
					if swipe_start_pos.x < swipe_cur_pos.x:
						print("right swipe!")
						G.right_swipe_detected = true
				swiping = false
	else:
		swiping = false
		
	
	#considering adding a timer to this detection so that the player doesn't swipe to long. added
