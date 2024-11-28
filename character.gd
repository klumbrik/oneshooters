extends CharacterBody2D

var is_shooting = true
var ammo = 6
var bullet = preload("res://bullet.tscn")


var swipe_length = 30  #Swipe variables. They should be declared here globally.
var swiping = false
var swipe_cur_pos: Vector2
var swipe_start_pos: Vector2
var swipe_threshold = 30
#var right_swipe_detected = false I decided to make this global in G to change it in the cover scene


func _ready() -> void:
	G.moving = false
	$Sprite2D/AnimationPlayer.play("shoot")
	$Timer.start()
	

func _input(event: InputEvent) -> void:
	shoot_controls()
			
	#if event is InputEventScreenTouch: #the same but using other approach
		#if event.pressed:
			#$Sprite2D/AnimationPlayer.play("duck")
			#is_shooting = false
			#$ReloadTimer.start()
		#else:
			#$Sprite2D/AnimationPlayer.play("shoot")
			#is_shooting = true
			#$ReloadTimer.stop()
			

func _physics_process(_delta: float) -> void: #main function
	G.ammo = ammo
	if !is_shooting:
		$Timer.paused = true
	else:
		$Timer.paused = false
	swipe_detection() #we need to detect swipes each frame
	if G.right_swipe_detected:
		G.moving = true
		move_to_cover()
		
			
	
	

func _on_timer_timeout() -> void:
	if ammo > 0:
		var new_bullet = bullet.instantiate()
		add_child(new_bullet)
		ammo -= 1


func _on_reload_timer_timeout() -> void:
	if ammo < 6:
		ammo += 1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies'):
		get_tree().paused = true


func _on_shootingrange_body_exited(body: Node2D) -> void: #bullet range restriction
	if body.is_in_group("damage"):
		body.queue_free()















func shoot_controls():
	if !G.moving:
		if swipe_start_pos.distance_to(swipe_cur_pos) == 0: #if finger is not moving
			if Input.is_action_pressed("press"): 
				if swipe_cur_pos == swipe_start_pos:
					$Sprite2D/AnimationPlayer.play("duck")
					is_shooting = false
					$ReloadTimer.start()
		if Input.is_action_just_released("press"): #were on one level 
				$Sprite2D/AnimationPlayer.play("shoot")
				is_shooting = true
				$ReloadTimer.stop()
		
		
		
func swipe_detection():
	if Input.is_action_just_pressed("press"):
		if !swiping:
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
		
	
	#considering adding a timer to this detection so that the player doesn't swipe to long

func move_to_cover():
	if !G.moving:
		print("Stop!")
		velocity.x = 0
	else:
		is_shooting = false
		$Sprite2D/AnimationPlayer.play("shoot") #play run here
		velocity.x = G.moving_speed
		move_and_slide()
		
	
