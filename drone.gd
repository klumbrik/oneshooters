extends CharacterBody2D

@export var dontshoot: bool
var appeared = false
var current_target: Node2D = null
var just_shot = false
var font = load("res://demo/assets/fonts/8bitOperatorPlusSC-Bold.ttf")
var bullet = preload("res://drone_bullet.tscn")
@onready var shoot_from = $Marker2D.global_position
@onready var shoot_to = Vector2.ZERO
var direction
		
var wiggle_amplitude := Vector2(5.0, 3.0)
var wiggle_speed := Vector2(3.0, 2.4)
var base_position : Vector2

var phase := Vector2(randf() * TAU, randf() * TAU)
var phase_shift_speed := Vector2(0.1, 0.12)

var target_direction := Vector2.ZERO # ← для рисования
var distance_to_player = Vector2(0, -100)
func _ready():
	visible = false

func _physics_process(delta: float) -> void:
	
	if G.character_ref != null: #base point around which should wiggle
		base_position = G.character_ref.global_position + distance_to_player
		appear()
		
	#wiggle phase
	phase.x += delta * phase_shift_speed.x
	phase.y += delta * phase_shift_speed.y
	
	var time = Time.get_ticks_msec() / 1000.0
	
	var wiggle_offset := Vector2(
		sin(time * wiggle_speed.x + phase.x) * wiggle_amplitude.x,
		cos(time * wiggle_speed.y + phase.y) * wiggle_amplitude.y
		)
	
	global_position = base_position + wiggle_offset
	
	#queue_redraw()
	#if G.enemiesonscreen.size() > 0:
		#shoot_to = G.enemiesonscreen[0].global_position
	
	




	
	


func shot():
	if just_shot:
		return
	just_shot = true
	
	if current_target == null or !is_instance_valid(current_target):
		if current_target == null:
			return
			
	 # Проверка на живую цель
	if current_target.has_method("get_hp") and current_target.get_hp() <= 0:
		return
	# Стреляем только по текущей цели
	var new_bullet = bullet.instantiate()
	var shoot_from = $Marker2D.global_position
	var shoot_to = current_target.global_position
	
	new_bullet.global_position = shoot_from

	var direction = (shoot_to - shoot_from).normalized()
	new_bullet.rotation = direction.angle()
	new_bullet.linear_velocity = 700 * direction
	new_bullet.constant_force = 3000 * direction
	
	get_parent().add_child(new_bullet)
	
	$BlasterMetallic01.play()
	
func _on_shoot_timer_timeout() -> void:
	if dontshoot:
		return
	
	just_shot = false
	if current_target == null:
		find_new_target()
		
	if current_target != null:
		shot()


func appear():	
	if !appeared:
			visible = true
			$AnimationPlayer.play("appear")
			await $AnimationPlayer.animation_finished
			appeared = true
			$fly.play()
			
func find_new_target():
	var valid_enemies := G.enemiesonscreen.filter(func(e):
		return is_instance_valid(e) and e.has_method("get_hp") and e.get_hp() > 0
	)
	if valid_enemies.size() == 0:
		current_target = null
		return
	
	valid_enemies.sort_custom(func(a, b):
		return a.global_position.x < b.global_position.x
		)
		
	# first_enemy
	current_target = valid_enemies[0]

	# Подписываемся на сигнал смерти
	if current_target.has_signal("died") and not current_target.is_connected("died", Callable(self, "_on_target_died")):
		current_target.connect("died", Callable(self, "_on_target_died"))
		
		
func _on_target_died():
	current_target = null
	find_new_target()
	if current_target != null:
		just_shot = false
		shot()
#func _draw() -> void: #draws in LOCAL COORDINATES
	#if G.enemiesonscreen.size() > 0:
		#var shoot_from = to_local($Marker2D.global_position)
		#var shoot_to = to_local(G.enemiesonscreen[0].global_position)	
		
		
		#var direction = (shoot_from - shoot_to).normalized()
		#
		#draw_line(shoot_from, shoot_to, Color.RED, 3.0)
		#
		## Базовая ось X (вправо)
		#var base_axis = Vector2.RIGHT * 50
		#draw_line(shoot_from, shoot_from + base_axis, Color.GRAY, 2.0)
#
		## Вектор направления
		#var aim_vector = direction * 50
		#draw_line(shoot_from, shoot_from + aim_vector, Color.YELLOW, 2.0)
#
		## Угол между базовой осью и направлением
		#var angle_rad = Vector2.RIGHT.angle_to(direction)
		#var angle_deg = angle_rad * 180.0 / PI
#
		## Нарисуем дугу угла
		#draw_arc(shoot_from, 30.0, 0.0, angle_rad, 16, Color.CYAN)
#
		## Подпись угла
		#draw_string(font , shoot_from + Vector2(0, -20), str(round(angle_deg)) + "°")
		
		
		
func _on_life_timer_timeout() -> void:
	$AnimationPlayer.play_backwards("appear")
	$fly.play()
	await $AnimationPlayer.animation_finished
	queue_free()
	G.drone_active = false
