extends CharacterBody2D

var font = load("res://demo/assets/fonts/8bitOperatorPlusSC-Bold.ttf")
var bullet = preload("res://bullet.tscn")
@onready var shoot_from = $Marker2D.global_position
@onready var shoot_to = Vector2.ZERO
var direction
		
var wiggle_amplitude := Vector2(5.0, 3.0)
var wiggle_speed := Vector2(3.0, 2.4)
var base_position : Vector2

var phase := Vector2(randf() * TAU, randf() * TAU)
var phase_shift_speed := Vector2(0.1, 0.12)

var target_direction := Vector2.ZERO # ← для рисования

func _ready():
	base_position = global_position

func _physics_process(delta: float) -> void:
	
	if G.moving:
		if G.left_swipe_detected:
			velocity.x = -G.moving_speed
		else:
			velocity.x = G.moving_speed
		move_and_slide()
	
	queue_redraw()
	if G.enemiesonscreen.size() > 0:
		shoot_to = G.enemiesonscreen[0].global_position
	var time = Time.get_ticks_msec() / 1000.0
	


	# Медленно меняем фазу, чтобы траектория эволюционировала
	phase.x += delta * phase_shift_speed.x
	phase.y += delta * phase_shift_speed.y

	var wiggle_offset = Vector2(
		sin(time * wiggle_speed.x + phase.x) * wiggle_amplitude.x,
		cos(time * wiggle_speed.y + phase.y) * wiggle_amplitude.y
	)

	global_position = base_position + wiggle_offset
	
	


func shot():
	if G.enemiesonscreen.size() > 0: #if there are enemies
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = $Marker2D.global_position #bullet position for drone in space of the character scene (25, -5)
		direction = (to_global(shoot_to) - to_global(shoot_from)).normalized()
		new_bullet.rotation = atan2(direction.y, direction.x)
		new_bullet.linear_velocity = 700 * direction
		new_bullet.constant_force = 3000 * direction
		print(new_bullet.rotation_degrees)
		get_parent().add_child(new_bullet)

func _on_shoot_timer_timeout() -> void:
	shot()

#func _draw() -> void: #draws in LOCAL COORDINATES
	#if G.enemiesonscreen.size() > 0:
		#var shoot_from = to_local($Marker2D.global_position)
		#var shoot_to = to_local(G.enemiesonscreen[0].global_position)	
		#
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
