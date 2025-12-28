extends Node2D

var current_id := "intro_1"

var drone_ref

signal tapped
signal full_ammo
signal tap_enemy

var dialogue := {
	"intro_1": {
		"speaker": "Jed",
		"text": "Привет, добро пожаловать в oneshooters! Потому что один выстрел решает всё.",
		"next": "intro_2"
	},
	"intro_2": {
		"speaker": "Jed",
		"text": "Сейчас быстро введу в курс дела",
		"next": "intro_3"
	},
	"intro_3": {
		"speaker": "Jed",
		"text": "Я стреляю автоматически",
		"action": "enable_shooting",
		"next": "intro_4"
	},
	"intro_4": {
		"speaker": "Jed",
		"text": "Патроны закончились. зажми и держи, чтобы перезарядиться до 6",
		"action": "enable_reloading",
		"next": "intro_5"
	},
	"intro_5": {
		"speaker": "Jed",
		"text": "Видишь, враг идёт к огоньку? Нажми на него, чтобы переключить цель",
		"action": "await_fire_tap",
		"next": "intro_6"
	},
	"intro_6": {
		"speaker": "Jed",
		"text": "Отлично, убив врага в огоньке ты получаешь пак. Смотри.",
		"action": "await_pack_use",
		"next": "intro_7"
	},
	"intro_7": {
		"speaker": "Jed",
		"text": "Видишь? Патроны закончились, но пак меня выручил",
		"action": "spawn_shooting_enemy",
		"next": "intro_8",
	},
	"intro_8": {
		"speaker": "Jed",
		"text": "Это парень опасный, пригнись",
		"action": "only_duck",
		"next": "intro_9",
	},
	"intro_9": {
		"speaker": "Jed",
		"text": "Время бежать. Свайпни вправо.",
		"action": "run",
		"next": "intro_10",
	},
	"intro_10": {
		"speaker": "Jed",
		"text": "Ой-ой, перекат!(Снова свайпни вправо)",
		"action": "dodge",
		"next": "intro_11",
	},
	"intro_11": {
		"speaker": "Jed",
		"text": "Перекатиться между укрытиями можно лишь раз! А теперь возьми этого дрона",
		"action": "drone_and_watch",
		"next": "intro_12",
	},
	"intro_12": {
		"speaker": "Jed",
		"text": "Хорошо, свайпни влево, чтобы вернутся назад",
		"action": "back",
		"next": "intro_13",
	},
	"intro_13": {
		"speaker": "Jed",
		"text": "Так держать!",
		"action": "done"
	}
}

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
	G.tutorial_mode = true
	$room/Hot_Target_Spawner.disabled = true
	$character.dontduck = true
	$character.dontshoot = true
	$character.dontrun = true
	$character.dontdodge = true
	
	G.player_died.connect(self._on_player_died)
	
	show_next_dialogue()
	
	#$CanvasLayer/TapToStartLabel.visible = true
	$enemyspawn.enabled = false
	$CanvasLayer/CenterContainer.visible = true
	$CanvasLayer/DodgeBar.visible = true
	
	#$character.dontshoot = false
	
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



func _unhandled_input(event: InputEvent) -> void: #add swipe detection for fixing tutorial swipe bugs
	if Input.is_action_pressed("press"):
		emit_signal("tapped")
		print("✅ tapped emitted")
		if G.enemiesonscreen.size() > 0:
			if G.enemiesonscreen[0].mouse_onself:
				emit_signal("tap_enemy")
func _input(event):
	if G.game_started:
		return
	if G.ammo == 6:
		emit_signal("full_ammo")
	#if $CanvasLayer/WardrobeButton.get_global_rect().has_point(get_viewport().get_mouse_position()):
		#return
		
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



func show_next_dialogue():
	
	
	var entry = dialogue.get(current_id)
	
	
	
	if entry == null:
		return
	
	$CanvasLayer/Label.text = (entry["text"])
	
	$CanvasLayer/Jedbigres/AnimationPlayer.play("popup")
	await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished
	
	
	if entry.has("action"):
		handle_action(entry["action"])
	else:
		await tapped
		$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
		await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished

		current_id = entry.get("next", "")
		show_next_dialogue()
		
		
		
func handle_action(action: String):
	match action:
		"enable_shooting":
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished
			
			
			$character.dontshoot = false
			
			var old_pos = $character.global_position.x + 100
			for i in range(6):
				var enemy = preload("res://scenes/enemy.tscn").instantiate()
				enemy.bonus_dropped = true #so that bonus doesn't drop
				enemy.disable_damage()
				enemy.untapable = true
				enemy.global_position.y = $character.global_position.y
				enemy.global_position.x = old_pos + 30
				old_pos = enemy.global_position.x
				add_child(enemy)
				
			var timer = get_tree().create_timer(6)
			await timer.timeout
			print("timeout")
			if G.enemiesonscreen.size() <= 0:
				current_id = dialogue.get(current_id).get("next", "")
				show_next_dialogue()
		"enable_reloading":
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			
			$character.dontduck = false
			
			await full_ammo
			
			current_id = dialogue.get(current_id).get("next", "")
			
			var enemy = preload("res://scenes/enemy.tscn").instantiate()
			var fire = preload("res://scenes/Fire_Target_Visual.tscn").instantiate()
			
			enemy.bonus_dropped = true #so that bonus doesn't drop
			enemy.disable_damage()
			enemy.untapable = true
			enemy.global_position.y = $character.global_position.y
			enemy.global_position.x = $character.global_position.x + 250
			enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
			$enemyspawn/target.process_mode = Node.PROCESS_MODE_PAUSABLE
			add_child(enemy)
			fire.global_position.y = $character.global_position.y + 33
			fire.global_position.x = enemy.global_position.x - 40
			fire.process_mode = Node.PROCESS_MODE_PAUSABLE
			add_child(fire)
			
			
			get_tree().paused = true
			show_next_dialogue()
		"await_fire_tap":
			var enemy = G.enemiesonscreen[0]
			var timer = get_tree().create_timer(0.3)
			await timer.timeout
			
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			
			enemy.area.process_mode = Node.PROCESS_MODE_ALWAYS
			
			print("🟡 waiting for tap_enemy")
			await tap_enemy
			print("✅ tap_enemy received")
			
			print(enemy.SPEED)
			$enemyspawn/target.process_mode = Node.PROCESS_MODE_ALWAYS
			$character.dontshoot = false
			get_tree().paused = false
			$character.dontduck = true
			await enemy.died
			
			var timer1 = get_tree().create_timer(0.2)
			await timer1.timeout
			$character.dontshoot = true
			
			
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
		"await_pack_use":
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			$character.dontshoot = false
			
			await G.out_of_ammo
			$character.dontshoot = true
			
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
		"spawn_shooting_enemy":
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			
			var enemy = preload("res://scenes/shooting_enemy.tscn").instantiate()
			
			enemy.bonus_dropped = true #so that bonus doesn't drop
			enemy.disable_damage()
			enemy.untapable = true
			enemy.global_position.y = $character.global_position.y - 10
			enemy.global_position.x = $character.global_position.x + 250
			enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
			
			add_child(enemy)
			
			await enemy.shot_start
			
			get_tree().paused = true
			
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
		"only_duck":
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			$character.dontduck = false
			$character.process_mode = Node.PROCESS_MODE_ALWAYS
			
			await $character.tut_ducked
			
			$character.dontduck = true
			$character.dontshoot = false
			Input.action_release("press")
			get_tree().paused = false
			
			var timer = get_tree().create_timer(0.2)
			await timer.timeout
			
			
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
			
		"run":
			$character.dontshoot = true
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			$character.dontrun = false
			$character.dontleft = true
			$character.dontdodge = true
			$character.process_mode = Node.PROCESS_MODE_PAUSABLE
			
			await $character.tut_run
			
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			print("DONE")
			
			var enemy = preload("res://scenes/enemy.tscn").instantiate()
			
			enemy.bonus_dropped = true #so that bonus doesn't drop
			enemy.disable_damage()
			enemy.untapable = true
			enemy.global_position.y = $character.global_position.y - 10
			enemy.global_position.x = $character.global_position.x + 30
			enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
			add_child(enemy)
			
			
			get_tree().paused = true
			
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
			
		"dodge":
			$character.dontdodge = false
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			G.number_of_right_swipes = 2
			get_tree().paused = false
			$character.controls_blocked = true
			#print(G.number_of_right_swipes)
			await G.delete_enemies_out_of_screen
			
			var drone = preload("res://scenes/drone_bonus.tscn").instantiate()
			drone.global_position = $character.global_position + Vector2(100, 0)
			call_deferred("add_child", drone)
			drone_ref = drone
			$character.dontrun = true
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
			
		"drone_and_watch":
			$character.dontrun = false
			$character.dontdodge = true
			$character.controls_blocked = true
			get_tree().paused = true
			if is_instance_valid(drone_ref):
				drone_ref.timer.stop()
				
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			
			
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			$character.controls_blocked = false
			
			get_tree().paused = false
			
			print("🟡 waiting for picked")
			await drone_ref.picked
			print("✅ picked received")
			
			$character.process_mode = Node.PROCESS_MODE_PAUSABLE
			
			get_tree().paused = true
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
			
		"back":
			$character.dontleft = false
			$character.controls_blocked = true
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			G.left_swipe_detected = true
			G.right_swipe_detected = false
			get_tree().paused = false
			
			var timer = get_tree().create_timer(1)
			await timer.timeout
			
			var old_pos = $character.global_position.x + 100
			for i in range(6):
				var enemy = preload("res://scenes/enemy.tscn").instantiate()
				enemy.bonus_dropped = true #so that bonus doesn't drop
				enemy.disable_damage()
				enemy.untapable = true
				enemy.global_position.y = $character.global_position.y
				enemy.global_position.x = old_pos + 30
				old_pos = enemy.global_position.x
				add_child(enemy)
				
			current_id = dialogue.get(current_id).get("next", "")
			show_next_dialogue()
		"done":
			await tapped
			$CanvasLayer/Jedbigres/AnimationPlayer.play_backwards("popup")
			await $CanvasLayer/Jedbigres/AnimationPlayer.animation_finished	
			#$CanvasLayer/TranisitionPlayer.play("start_fade")
			#
			#await $CanvasLayer/TranisitionPlayer.animation_finished
			G.score = 0
			G.tutorial_finished = true
			G.tutorial_mode = false
			G.save_json_file()
			G.emit_signal("menu_play")
		

		
