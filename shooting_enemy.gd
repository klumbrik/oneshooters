#extends CharacterBody2D
extends "res://enemy.gd"

var is_shooting = false
var enemy_moving = true
var target = preload("res://target.tscn")
var bullet = preload("res://enemy_bullet.tscn")


func _ready() -> void:
	await super._ready()
	extend_state_machine()
	SPEED = randf_range(30.0, 35.0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var anim = $Sprite2D/AnimationPlayer.current_animation
	velocity.x = -SPEED if $Sprite2D/AnimationPlayer.current_animation == "run" else 0
	move_and_slide()
	#print("Anim:", $Sprite2D/AnimationPlayer.current_animation, "Playing:", $Sprite2D/AnimationPlayer.is_playing())
	print(SPEED)
func _on_shoot_timer_timeout() -> void:
	enemy_moving = false
	$Shoot_Timer.wait_time = 4
	is_shooting = true

func shot():
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = Vector2(3, 1)
	add_child(new_bullet)
	

func _on_delay_timeout() -> void:
	enemy_moving = true

func extend_state_machine():
	
	var rtransition_state = LimboState.new().named("recharging-transition").call_on_enter(rtransition_enter).call_on_update(rtransition_update)
	var recharging_state = LimboState.new().named("recharging").call_on_enter(recharging_enter).call_on_update(recharging_update)
	var shooting_state = LimboState.new().named("shooting").call_on_enter(shooting_enter).call_on_update(shooting_update)
	

	
	enemy_state_machine.add_child(rtransition_state)
	enemy_state_machine.add_child(recharging_state)
	enemy_state_machine.add_child(shooting_state)
	



	
	enemy_state_machine.add_transition(rtransition_state, recharging_state, &"to recharge")
	enemy_state_machine.add_transition(recharging_state, shooting_state, &"to shoot")
	enemy_state_machine.add_transition(moving_state, rtransition_state, &"to recharge transition")

	

func moving_enter():
	$Sprite2D/AnimationPlayer.play("run")
	$Shoot_Timer.wait_time = randf_range(0.5, 2)
	$Shoot_Timer.start()

func moving_update(delta: float):
	is_dead()
	add_target()
	if is_shooting:
		enemy_state_machine.dispatch(&"to recharge transition")
	is_reset_recharging()

func rtransition_enter():
	$Sprite2D/AnimationPlayer.play("recharge_transition")
	G.emit_signal("enemy_shoots", self)
func rtransition_update(delta: float):
	is_dead()
	add_target()
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.5:
		enemy_state_machine.dispatch(&"to recharge")
	is_reset_recharging()

func recharging_enter():
	$Sprite2D/AnimationPlayer.play("recharge")

func recharging_update(delta: float):
	is_dead()
	add_target()
	if $UX_EnemyShot.go_bullet:
		shot()
		$UX_EnemyShot.go_bullet = false
		$delay.start()
		enemy_state_machine.dispatch(&"to shoot")
	is_reset_recharging()

func shooting_enter():
	$Sprite2D/AnimationPlayer.play("shoot")

func shooting_update(delta: float):
	is_dead()
	add_target()
	if $Sprite2D/AnimationPlayer.current_animation_position >= 0.33:
		is_shooting = false
		enemy_state_machine.dispatch(&"to move")
	is_reset_recharging()
	
func beaten_enter():
	die()
	
func is_dead():
	if hp <= 0:
		$CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D.disabled = true
		enemy_state_machine.dispatch(&"to beaten")
		
func should_move() -> bool:
	var anim = $Sprite2D/AnimationPlayer
	return anim.current_animation == "run" and anim.is_playing()
	

	
#var is_shooting = false
#var enemy_moving = true
#var mouse_onself = false
#var target = preload("res://target.tscn")
#var bullet = preload("res://enemy_bullet.tscn")
#var SPEED = 80.0 * G.pacedif_modifier
#var hp
#var chance
#var disabled_damage = false
#var is_in_zone = false
#var enemy_state_machine: LimboHSM
#
#func _ready() -> void: #when spawns randomly defines hp
	#initiate_state_machine()
	##chance = randf() 
	#hp = 1
	##hp = randi_range(1,2) 
	#
	#G.enemiesonscreen.append(self)
	#
#func _physics_process(delta: float) -> void:
	##velocity.limit_length(SPEED)
	#if enemy_moving:
		#velocity.x = -SPEED
		#$RichTextLabel.text = str(hp)
	#else:
		#velocity.x = 0
	##print(velocity.length())
	#
	#if !G.wave_going: #we stop if the wave stops
		#velocity.x = 0
		#disable_damage()
	#else:
		#enable_damage()
		#
	#add_target()
	#
	#
	#
	#
	#move_and_slide()
#
#
#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if area.is_in_group('damage'):
		#hp -= 1 #damage
		#get_damage()
	#if area.is_in_group('character'):
		##if !disabled_damage:
			##get_tree().paused = true
			##G.game_over = true removed it because it worked in a stupid way
		#pass
	#if area.is_in_group('target_zone'):
		#is_in_zone = true
		##print("Entered zone ", is_in_zone)
		#
		#
		#
		#
#
#
#func add_target():
	#if mouse_onself:
		#if Input.is_action_just_pressed("press"):
			#var new_target = target.instantiate()
			#add_child(new_target)
#
#func die():
	#$Sprite2D/AnimationPlayer.play("beaten")
	#if is_in_zone and G.stash < 6: #before disabling collision we track if it is in zone to add stash ammo. The limit can be tweaked.
		#G.stash += 3
		#G.emit_signal("enemy_died_in_zone")
	#disable_damage()
#func get_damage():
	#velocity.x = 0
	#$Sprite2D/AnimationPlayer.play("damage_taken")
	#
#func disable_damage():
	#$CollisionShape2D.disabled = true
	#$Area2D.monitorable = false
	#disabled_damage = true
	#
	#
#func enable_damage():
	#$CollisionShape2D.disabled = false
	#$Area2D.monitorable = true
	#disabled_damage = false
	#
#
	#
#
#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "beaten":
		##print("before removal, is in zone: ", is_in_zone)
		#is_in_zone = false
		#queue_free()
		#G.score += 10 #adding 10 points for each enemy defeated
	#if anim_name == "damage_taken":
		#$Sprite2D/AnimationPlayer.play("run")
#
#
		#
#
#
#func _on_area_2d_mouse_entered() -> void:
	#mouse_onself = true
#
#
#func _on_area_2d_mouse_exited() -> void:
	#mouse_onself = false
#
#
#func _on_area_2d_area_exited(area: Area2D) -> void:
	#if area.is_in_group('target_zone'):
		#is_in_zone = false
		##print(is_in_zone)
#
#
#
#func _on_shoot_timer_timeout() -> void:
	#enemy_moving = false # to stop
	#G.emit_signal("enemy_shoots")
	##print("shot happend timer lox") #literally enemy shoots
	#$Shoot_Timer.wait_time = 4 #so called cooldown. Consider carefully knowing that we need time for ux animation (also remember bout timer after the shot)
	#is_shooting = true
#func shot():
	#var new_bullet = bullet.instantiate()
	#new_bullet.global_position = Vector2(3, 1) #bullet position for enemy in space of the shooting_enemy scene
	#add_child(new_bullet)
#
#
#func _on_delay_timeout() -> void: #a delay after the shot
	#enemy_moving = true
	#
	#
#func initiate_state_machine():
	#enemy_state_machine = LimboHSM.new()
	#add_child(enemy_state_machine)
	#
	##declaring states
	#var moving_state = LimboState.new().named("moving").call_on_enter(moving_enter).call_on_update(moving_update)
	#var recharging_state =  LimboState.new().named("recharging").call_on_enter(recharging_enter).call_on_update(recharging_update)
	#var shooting_state =  LimboState.new().named("shooting").call_on_enter(shooting_enter).call_on_update(shooting_update)
	#var rtransition_state = LimboState.new().named("recharging-transition").call_on_enter(rtransition_enter).call_on_update(rtransition_update)
	#var beaten_state =  LimboState.new().named("beaten").call_on_enter(beaten_enter)
	#
	#enemy_state_machine.add_child(moving_state)
	#enemy_state_machine.add_child(recharging_state)
	#enemy_state_machine.add_child(shooting_state)
	#enemy_state_machine.add_child(rtransition_state)
	#enemy_state_machine.add_child(beaten_state)
	#
	#enemy_state_machine.initial_state = moving_state
	#
	#enemy_state_machine.add_transition(moving_state, rtransition_state, &"to recharge transition")
	#enemy_state_machine.add_transition(rtransition_state, recharging_state, &"to recharge")
	#enemy_state_machine.add_transition(recharging_state, shooting_state, &"to shoot")
	#enemy_state_machine.add_transition(enemy_state_machine.ANYSTATE, moving_state, &"to move")
	#enemy_state_machine.add_transition(enemy_state_machine.ANYSTATE, beaten_state, &"to beaten")
	#
	#enemy_state_machine.initialize(self)
	#enemy_state_machine.set_active(true)
	#
#func moving_enter():
	#$Sprite2D/AnimationPlayer.play("run")
	#$Shoot_Timer.wait_time = randf_range(0.5, 2) #starts shooting after ... to ... seconds
	#$Shoot_Timer.start()
#func moving_update(delta: float):
	#if is_shooting == true:
			#enemy_state_machine.dispatch(&"to recharge transition")
	#is_dead()
#func rtransition_enter():
	#$Sprite2D/AnimationPlayer.play("recharge_transition")
#func rtransition_update(delta: float):
	#if $Sprite2D/AnimationPlayer.current_animation_position >= 0.5:
		##print("allo")
		#enemy_state_machine.dispatch(&"to recharge")
	#is_dead()
#func recharging_enter():
	#$Sprite2D/AnimationPlayer.play("recharge")
#func recharging_update(delta: float):
	#if $UX_EnemyShot.go_bullet == true: #there may be a bug or problem with this when there are many instance on the screen because they are all referencing the same animation
		#shot()
		#$UX_EnemyShot.go_bullet = false
		#$delay.start()
		#enemy_state_machine.dispatch(&"to shoot")
	#is_dead()
#func shooting_enter():
	#$Sprite2D/AnimationPlayer.play("shoot")
#func shooting_update(delta: float):
	#if $Sprite2D/AnimationPlayer.current_animation_position >= 0.33:
		#is_shooting = false
		#enemy_state_machine.dispatch(&"to move")
	#is_dead()
#
#func beaten_enter():
	#die()
#
#
#
#func is_dead():
	#if hp <= 0:
			#$CollisionShape2D.disabled = true
			#$Area2D/CollisionShape2D.disabled = true
			#enemy_state_machine.dispatch(&"to beaten")
