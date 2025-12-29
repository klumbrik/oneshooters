extends Node2D

var room = preload("res://scenes/room.tscn")
@onready var sprite = $CanvasLayer/CenterContainer/ui_weapon


@onready var camera := $character/Camera2D

var sprite_angle = 0.0
var body_in_area
var current_bullet
var bullet_ui = preload("res://scenes/jebulletui.tscn")

var bonus_weights := {
	"ammo": 0.6,
	"shield": 0.3,
	"drone": 0.1
}

var bonus_scenes := {
	"ammo": preload("res://scenes/ammo_bonus1.tscn"),
	"shield": preload("res://scenes/shield_bonus.tscn"),
	"drone": preload("res://scenes/drone_bonus.tscn")
}

var ShieldScene =  preload("res://scenes/shield_visual.tscn")
var DroneScene = preload("res://scenes/drone.tscn")

@onready var spawner_distance = $enemyspawn.global_position - $character.global_position

var reload_tween: Tween
var reload_in_progress
var reload_cycle_active = false
var reload_start_time = 0.0
var reload_duration = 0.4 #whole rotation sequence duration. don't mix up with rotation duration
var reload_origin_angle = 0.0
var bullet_node: Node = null
var rotation_pending = false
var rotation_completed = false

var bullet_removal_in_progress = false


@onready var slot1 = $CanvasLayer/CenterContainer/ui_weapon/slot1
@onready var slot2 = $CanvasLayer/CenterContainer/ui_weapon/slot2
@onready var slot3 = $CanvasLayer/CenterContainer/ui_weapon/slot3
@onready var slot4 = $CanvasLayer/CenterContainer/ui_weapon/slot4
@onready var slot5 = $CanvasLayer/CenterContainer/ui_weapon/slot5
@onready var slot6 = $CanvasLayer/CenterContainer/ui_weapon/slot6

var revolver

func _ready() -> void:
	G.tutorial_mode = false
	$room/Hot_Target_Spawner.disabled = false
	$character.controls_blocked = true
	$CanvasLayer/BestContainer.show()
	
	G.player_died.connect(self._on_player_died)
	camera.zoom = Vector2(3, 3) # zoomed start
	camera.position = Vector2(-60, -110)
	#$CanvasLayer/TapToStartLabel.visible = true
	$enemyspawn.enabled = false
	$CanvasLayer/CenterContainer.visible = false
	$CanvasLayer/DodgeBar.visible = false
	
	$CanvasLayer/BestContainer/BestLabel.text = "Your best: " + str(G.best_score)
	
	revolver = {
	1:slot1,
	2:slot2,
	3:slot3,
	4:slot4,
	5:slot5,
	6:slot6
} #slots indexes match their positions


	await get_tree().process_frame #to not get null when adding the first room to array
	G.rooms.clear()
	G.rooms.append($room) #adding the first room to array
	G.swipe_room.connect(self._create_room_on_swipe)
	
	G.rotate_ui.connect(self._on_ui_rotate)
	G.cancel_reload_rotation.connect(self.cancel_reload_sequence)
	G.shot.connect(self._on_shot)
	
	G.enemy_died_in_zone.connect(self._on_enemy_died_in_zone)
	G.out_of_ammo.connect(self._used_stash)
	G.drop_bonus.connect(self._on_drop_bonus)
	G.bonus_stash.connect(self._stash_bonus_collected)
	
func _input(event):
	if G.game_started:
		return
	#if $CanvasLayer/WardrobeButton.get_global_rect().has_point(get_viewport().get_mouse_position()):
		#return
	if event.is_action_pressed("space"):
		start_game()
		
func _process(delta: float) -> void: #for testing only, comment later
	
	#print(G.game_started)
	
	
	$CanvasLayer/spawner_metrics.text = """new_enemy_in: %.2f\nwave ends in: %.2f\nbreak ends in: %.2f""" % [$enemyspawn/Timer.time_left, $enemyspawn/WaveEnd.time_left, $enemyspawn/Break_Window.time_left]
	if $enemyspawn/Timer.time_left == 0 and not $CanvasLayer/spawner_metrics.get("modulate").r == 1.0:
		$CanvasLayer/spawner_metrics.modulate = Color(1, 0, 0) # red
		$CanvasLayer/spawner_metrics.call_deferred("reset_color")
		
	#print(G.drone_active)	
	#shield tracking
	shield_tracking()
	drone_tracking()
	spawn_tracking()		
			
			
func reset_color(): #testing only!
	await get_tree().create_timer(1.0).timeout
	$CanvasLayer/spawner_metrics.modulate = Color(1, 1, 1) #white or default
	
	
	
	
	
	
func start_reload_sequence(): #reload tween
	if reload_in_progress or reload_cycle_active or bullet_removal_in_progress:
		return
		
	if reload_tween and reload_tween.is_running():
		reload_tween.kill()
		
	reload_in_progress = true
	reload_cycle_active = true
	reload_start_time = Time.get_ticks_msec() / 1000.0 #tween start time
	rotation_pending = true
	rotation_completed = false
	
	
	
		
	
	
	ui_add_bullet()
	
	
	reload_origin_angle = sprite.rotation_degrees
	var new_rotation = reload_origin_angle + 60.0
	sprite_angle = new_rotation
	reload_tween = create_tween()
	reload_tween.tween_property(sprite, "rotation_degrees", new_rotation, reload_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	reload_tween.finished.connect(self._on_reload_rotation_finished)
	#print(sprite.rotation_degrees)
	
	
func cancel_reload_sequence():
	if not reload_in_progress:
		return
	if reload_tween and reload_tween.is_running():
		reload_tween.kill()
		
	var now = Time.get_ticks_msec() / 1000.0
	var elapsed = clamp(now - reload_start_time, 0.0, reload_duration)
	
	var current_angle = sprite.rotation_degrees
	var duration = elapsed
	
	reload_tween = create_tween()
	reload_tween.finished.connect(self._on_reload_cancelled)
	var offset = fmod(current_angle, 60.0)
	reload_tween.tween_property(sprite, "rotation_degrees", reload_origin_angle, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sprite_angle = reload_origin_angle
	
	

func shot_back_rotate_60_tween(): #shot tween
	var new_rotation = sprite_angle - 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#print(sprite.rotation_degrees)
	if body_in_area:
		if is_instance_valid(current_bullet):
			current_bullet.unload()
			G.ammo -= 1
	
func _on_ui_rotate():
	start_reload_sequence()

func _on_shot():
	if reload_in_progress or rotation_pending:
		return  # can't shoot while rotating
	shot_back_rotate_60_tween()
	revolver_update_indicies()
	#print(revolver)



func _on_area_2d_body_entered(body: Node2D) -> void:
	#print(body)
	body_in_area = true
	current_bullet = body
	#print(current_bullet)


func _on_area_2d_body_exited(body: Node2D) -> void:
	body_in_area = false




func _create_room_on_swipe():
	var previous_room = G.rooms[-1]
	#print("room created")
	var next_room = room.instantiate()
	add_child(next_room)
	next_room.global_position.x = previous_room.position.x + 360
		
	#adding the new room
	G.rooms.append(next_room) 

	#removing rooms
	if G.rooms.size() > 2: #2 for safety but can be 1
		var old_room = G.rooms[0]
		if is_instance_valid(old_room):
			old_room.queue_free()
		G.rooms.remove_at(0)
		
	#print(G.rooms)
	
func stash_visibility():
	if G.stash_pieces == 1:
		$CanvasLayer/CenterContainer/stash2.visible = true
	if G.stash_pieces > 1:
		$CanvasLayer/CenterContainer/stash1.visible = true
		
	
func _on_enemy_died_in_zone(enemy):
	stash_visibility()

func _used_stash(): #&&&&&&&&??????????????
	if G.stash_pieces == 1:
		$CanvasLayer/CenterContainer/stash1.visible = false
	if G.stash_pieces == 0:
		$CanvasLayer/CenterContainer/stash2.visible = false
		
	#add 3 bullets stash
	var markers = [revolver[1], revolver[2], revolver[3]]
	for marker in markers:
		var bullet = bullet_ui.instantiate()
		$CanvasLayer/CenterContainer/ui_weapon.add_child(bullet)
		bullet.global_position = marker.global_position
	$'character/Reload'.play()
		
func revolver_update_indicies():
	var new_slots = {}
	for i in range(1,7):
		var next_index = i % 6 + 1
		new_slots[i] = revolver[next_index] #get link to a slot from revolver + 1
	revolver = new_slots
		
	
func revolver_reverse_update_indicies():
	var new_slots = {}
	for i in range(1, 7):
		var prev_index = (i - 2 + 6) % 6 + 1
		new_slots[i] = revolver[prev_index]
	revolver = new_slots

func _on_reload_rotation_finished():
	print("ROTATION FINISHED, ammo = ", G.ammo)
	G.ammo += 1
	rotation_pending = false
	rotation_completed = true
	reload_in_progress = false
	reload_cycle_active = false
	call_deferred("revolver_reverse_update_indicies")
	G.reload_cooldown_active = true
	await get_tree().create_timer(G.reload_cooldown_duration).timeout
	G.reload_cooldown_active = false
	
	
func _on_reload_cancelled():
	if bullet_node and is_instance_valid(bullet_node):
		bullet_removal_in_progress = true
		bullet_node.play_load_backwards()  # method inside bullet_ui
		
		bullet_node.get_animation_player().animation_finished.connect(func(anim_name):
			if is_instance_valid(bullet_node):
				bullet_node.queue_free()
				bullet_removal_in_progress = false
				)
	rotation_pending = false
	reload_in_progress = false
	reload_cycle_active = false
	G.reload_cooldown_active = false
func _on_drop_bonus(position: Vector2):
	print("DROP BONUS CALLED at", position)
	var spawn_chance = clamp(0.3 + G.difficulty_level * 0.05, 0.3, 0.8)
	if randf() > spawn_chance:
		return # не спавним бонус
		
	var bonus_type := choose_bonus_type()
	var bonus = bonus_scenes[bonus_type].instantiate()
	bonus.global_position = position
	add_child(bonus)
	
func _stash_bonus_collected():
	stash_visibility()

func shield_tracking():
		var shield_node := get_node_or_null("Shield_Visual")
		if shield_node:
			
			shield_node.global_position = $character/ShieldMarker.global_position
			
			if $character/ShieldMarker.position == Vector2(6,5):
				shield_node.ducked = true
				print("ducked")
			else:
				shield_node.ducked = false
				print("unducked")
				
			if $character/Sprite2D/AnimationPlayer.current_animation == "dodge":
				shield_node.dodging = true
			else:
				shield_node.dodging = false
			
		elif G.shield_enabled:
			var new_shield := ShieldScene.instantiate()
			new_shield.name = "Shield_Visual"
			add_child(new_shield)

func drone_tracking():
	var drone_node := get_node_or_null("Drone_Visual")
	
	if drone_node == null and G.drone_active:
		
		var new_drone := DroneScene.instantiate()
		new_drone.name = "Drone_Visual"
		add_child(new_drone)

func spawn_tracking():
	$enemyspawn.global_position = $character.global_position + spawner_distance
	
	
func ui_add_bullet():
	bullet_node = bullet_ui.instantiate()
	if $CanvasLayer/CenterContainer/ui_weapon.get_children().size() <= 12: #6 slots (markers) + 6 bullets
		$CanvasLayer/CenterContainer/ui_weapon.call_deferred("add_child", bullet_node)#$CanvasLayer/CenterContainer/ui_weapon.add_child(bullet)
		bullet_node.call_deferred("set_global_position", revolver[6].global_position)
		#call_deferred("revolver_reverse_update_indicies")
	else:
		print("NOT ADDED")


func choose_bonus_type() -> String:
	var total_weight := 0.0
	for weight in bonus_weights.values():
		total_weight += weight
		
	var roll := randf() * total_weight
	var cumulative := 0.0
	
	for bonus_type in bonus_weights.keys():
		cumulative += bonus_weights[bonus_type]
		if roll <= cumulative:
			return bonus_type
		
	return "ammo" # fallback


func start_game():
	
	G.game_started = true
	G.wave_going = true
	# UI и камера
	#$CanvasLayer/TapToStartLabel.visible = false
	$CanvasLayer/CenterContainer.visible = true
	$CanvasLayer/DodgeBar.visible = true
	$CanvasLayer/BestContainer.hide()
	
	var tween := create_tween()
	
	tween.set_parallel()
	
	tween.tween_property(camera, "zoom", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", Vector2(-53, -306), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#camera.base_position = camera.position

	# Запуск спавна
	$enemyspawn.enabled = true
	$enemyspawn/Timer.start()
	$enemyspawn/WaveEnd.start()
	
	$character.controls_blocked = false
	$character.dontshoot = false
	# Можно добавить звук, вспышку, анимацию
	
	$CanvasLayer/WardrobeButton.visible = false
	
	
	
	


func _on_start_game_button_button_down() -> void:
	var tween = create_tween()
	var button = $CanvasLayer/StartGameButton
	tween.tween_property(button, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	start_game()


func _on_wardrobe_button_button_down() -> void:
	G.emit_signal("to_wardrobe")


func _on_player_died():
	G.game_started = false
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(camera, "zoom", Vector2(3, 3), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", Vector2(-60, -110), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	#$CanvasLayer/TapToStartLabel.visible = true
	$enemyspawn.enabled = false
	$CanvasLayer/CenterContainer.visible = false
	$CanvasLayer/DodgeBar.visible = false
