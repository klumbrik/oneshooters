extends CharacterBody2D
var enemy = preload("res://enemy.tscn")
var shooting_enemy = preload("res://shooting_enemy.tscn")
var shielded_enemy = preload("res://shielded_enemy.tscn")
@export var enabled: bool #disable when tesitng
@onready var target = $target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(1, 1.5)
	$Break_Window.wait_time = randf_range(3, 6)
	$WaveEnd.wait_time = 5#randf_range(15,25)
	
	if enabled:
		$Timer.start()
		$WaveEnd.start()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(G.enemiesonscreen)
	
	
	if !G.wave_going: #when wave stops we stop spawning
		$Timer.stop()
		
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
	var chance = randf()
	var current_enemy
	if chance <= 0.8: #0.8:
		current_enemy = enemy
	else:
		#current_enemy = shooting_enemy
		if chance >= 0.95:
			current_enemy = shooting_enemy
		else:
			current_enemy = shielded_enemy #for testing change later (other types of enemies)

	var new_enemy = current_enemy.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.position = position #spawn position = spawner position
	$Timer.wait_time = randf_range(1, 1.5) #random time between spawns
	
	
	
	
	

		
func wave_end():
	$WaveEnd.wait_time = randf_range(15,25) #we redefine time for a new wave15, 25
	G.wave_going = false
	#print("wave has ended. wavetime changed")
	start_break()
	
func new_wave():
	G.wave_going = true #once break timer is out we start a new wave 
	$Timer.start() #start randomly spawning again
	$WaveEnd.start()
	
func start_break():
	$Break_Window.wait_time = randf_range(3, 6) #define new break time in range
	$Break_Window.start() #then we start a new timer for break time
