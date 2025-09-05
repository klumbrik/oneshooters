extends Node2D

var room = preload("res://room.tscn")
@onready var sprite = $CanvasLayer/CenterContainer/ui_weapon

var sprite_angle = 0.0
var body_in_area
var current_bullet
var bullet_ui = preload("res://jebulletui.tscn")
var bonuses = [preload("res://ammo_bonus1.tscn"), preload("res://shield_bonus.tscn")]
var ShieldScene =  preload("res://shield_visual.tscn")

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
	
	
func _process(delta: float) -> void: #for testing only, comment later
	$CanvasLayer/spawner_metrics.text = """new_enemy_in: %.2f\nwave ends in: %.2f\nbreak ends in: %.2f""" % [$enemyspawn/Timer.time_left, $enemyspawn/WaveEnd.time_left, $enemyspawn/Break_Window.time_left]
	if $enemyspawn/Timer.time_left == 0 and not $CanvasLayer/spawner_metrics.get("modulate").r == 1.0:
		$CanvasLayer/spawner_metrics.modulate = Color(1, 0, 0) # red
		$CanvasLayer/spawner_metrics.call_deferred("reset_color")
		
		
	#shield tracking
	shield_tracking()
			
			
			
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
	reload_tween.tween_property(sprite, "rotation_degrees", new_rotation, reload_duration)
	
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
	reload_tween.tween_property(sprite, "rotation_degrees", reload_origin_angle, duration)
	sprite_angle = reload_origin_angle
	
	

func shot_back_rotate_60_tween(): #shot tween
	var new_rotation = sprite_angle - 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.1)
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
	var bonus_chance = randi_range(0, 1)
	var bonus = bonuses[bonus_chance].instantiate()
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

func ui_add_bullet():
	bullet_node = bullet_ui.instantiate()
	if $CanvasLayer/CenterContainer/ui_weapon.get_children().size() <= 12: #6 slots (markers) + 6 bullets
		$CanvasLayer/CenterContainer/ui_weapon.call_deferred("add_child", bullet_node)#$CanvasLayer/CenterContainer/ui_weapon.add_child(bullet)
		bullet_node.call_deferred("set_global_position", revolver[6].global_position)
		#call_deferred("revolver_reverse_update_indicies")
	else:
		print("NOT ADDED")
