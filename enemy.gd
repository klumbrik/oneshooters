extends CharacterBody2D


const SPEED = 105.0
var hp
var chance
var disabled_damage = false
#const JUMP_VELOCITY = -400.0

func _ready() -> void: #when spawns randomly defines hp
	$Sprite2D/AnimationPlayer.play("run")
	chance = randf() 
	if chance < 0.7:
		hp = 1
	else: 
		hp = 2
	#hp = randi_range(1,2) 
func _physics_process(delta: float) -> void:
	#velocity.limit_length(SPEED)
	velocity.x = -SPEED
	$RichTextLabel.text = str(hp)
	#print(velocity.length())
	if hp <= 0:
			die()
	if !G.wave_going: #we stop if the wave stops
		velocity.x = 0
		disable_damage()
	else:
		enable_damage()
		
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
	if area.is_in_group('character'):
		if !disabled_damage:
			get_tree().paused = true
			G.game_over = true
		
		
		
		




func die():
	$Sprite2D/AnimationPlayer.play("beaten")
	
	
func disable_damage():
	$CollisionShape2D.disabled = true
	disabled_damage = true
	
func enable_damage():
	$CollisionShape2D.disabled = false
	disabled_damage = false

	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "beaten":
		queue_free()
		G.score += 10 #adding 10 points for each enemy defeated
