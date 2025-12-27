extends CharacterBody2D
var enemy = preload("res://enemy.tscn")
var shooting_enemy = preload("res://shooting_enemy.tscn")
var shielded_enemy = preload("res://shielded_enemy.tscn")
@export var enabled: bool #disable when tesitng
@onready var target = $target
var shielded_streak := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(1, 1.5)
	$Break_Window.wait_time = randf_range(3, 6)
	$WaveEnd.wait_time = randf_range(10,15) #set to 1 for break testing
	
	if enabled:
		$Timer.start()
		$WaveEnd.start()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(G.enemiesonscreen)
	
	
	if !G.wave_going: #when wave stops we stop spawning
		$Timer.stop()
		$WaveEnd.stop()
	#if G.moving:
		#if G.left_swipe_detected:
			#velocity.x = -G.moving_speed
		#else:
			#velocity.x = G.moving_speed
		#move_and_slide()
		#
	if $Break_Window.is_stopped():
		G.break_bar_progress = 0.0
	else:
		var time_left = $Break_Window.time_left
		var total_time = $Break_Window.wait_time
		G.break_bar_progress = 1 - clamp(1.0 - time_left / total_time, 0.0, 1.0) #percentage left
		
	#print("break percent: " + str(G.break_bar_progress))
	

func _on_timer_timeout() -> void:
	spawn_and_register()


func _on_wave_end_timeout() -> void: #once the timer is timed out the wave stops
	wave_end()
	print("wave ended")


func _on_break_window_timeout() -> void:
	new_wave()
	print("wave started")
	$Break_Window.stop()
	

func spawn_and_register():
	var current_enemy
	var difficulty = G.difficulty_level
	var chance = randf()

	# Вероятности
	var base_enemy_chance = clamp(0.8 - difficulty * 0.05, 0.5, 0.8)
	var shielded_chance = clamp(0.1 + difficulty * 0.02, 0.05, 0.3)
	var shooting_chance = clamp(0.1 + difficulty * 0.02, 0.05, 0.2)
	
	var total = base_enemy_chance + shielded_chance + shooting_chance
	var norm_base = base_enemy_chance / total
	var norm_shielded = shielded_chance / total
	var norm_shooting = shooting_chance / total

	# Ограничение на shielded подряд
	if shielded_streak >= 2:
		if chance < norm_base + norm_shooting:
			current_enemy = shooting_enemy
			shielded_streak = 0
		else:
			current_enemy = enemy
			shielded_streak = 0
	else:
		if chance < norm_base:
			current_enemy = enemy
			shielded_streak = 0
		elif chance < norm_base + norm_shielded:
			current_enemy = shielded_enemy
			shielded_streak += 1
		else:
			current_enemy = shooting_enemy
			shielded_streak = 0
			
	var new_enemy = current_enemy.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.position = position
	
	var base = 1.5 - difficulty * 0.1
	$Timer.wait_time = clamp(randf_range(base * 0.8, base), 0.4, 2.0)
	
#func spawn_and_register():
	#
	#var current_enemy
	#var difficulty = G.difficulty_level
	#var chance = randf()
	#
	## Базовые вероятности
	#var base_enemy_chance = clamp(0.7 - difficulty * 0.05, 0.3, 0.7)
	#var shielded_chance = clamp(0.2 + difficulty * 0.03, 0.2, 0.5)
	#var shooting_chance = clamp(0.1 + difficulty * 0.02, 0.1, 0.3)
	#
	#if chance < base_enemy_chance:
		#current_enemy = enemy
	#elif chance < base_enemy_chance + shielded_chance:
		#current_enemy = shielded_enemy
	#else:
		#current_enemy = shooting_enemy
#
	#var new_enemy = current_enemy.instantiate()
	#get_parent().add_child(new_enemy)
	#new_enemy.position = position #spawn position = spawner position
	#var base = 1.5 - G.difficulty_level * 0.1
	#$Timer.wait_time = clamp(randf_range(base * 0.8, base), 0.3, 2.0)

	
	
	
	
	

		
func wave_end():
	$WaveEnd.wait_time = randf_range(15,25) #we redefine time for a new wave15, 25
	G.wave_going = false
	#print("wave has ended. wavetime changed")
	start_break()
	
func new_wave():
	$WaveEnd.wait_time = randf_range(15, 25)
	G.wave_going = true #once break timer is out we start a new wave 
	$Timer.start() #start randomly spawning again
	$WaveEnd.start()
	
func start_break():
	$Break_Window.wait_time = randf_range(3, 6) #define new break time in range
	$Break_Window.start() #then we start a new timer for break time
