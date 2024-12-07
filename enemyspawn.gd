extends CharacterBody2D
var enemy = preload("res://enemy.tscn")
var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enabled:
		$Timer.start()
		$WaveEnd.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$Timer.wait_time = randf_range(1, 3) #random time between spawns
	
	if !G.wave_going: #when wave stops we stop spawning
		$Timer.stop()
		
	if G.moving:
		velocity.x = G.moving_speed
		move_and_slide()
	

func _on_timer_timeout() -> void:
	spawn()


func _on_wave_end_timeout() -> void: #once the timer is timed out the wave stops
	wave_end()


func _on_break_window_timeout() -> void:
	new_wave()
	


func spawn():
	var new_enemy = enemy.instantiate()
	new_enemy.position = position
	get_parent().add_child(new_enemy)
	
func wave_end():
	$WaveEnd.wait_time = randf_range(20, 50) #we redefine time for a new wave
	G.wave_going = false
	print("wave has ended. wavetime changed")
	$Break_Window.wait_time = randf_range(3, 5) #define new break time in range
	$Break_Window.start() #then we start a new timer for break time
	
func new_wave():
	G.wave_going = true #once break timer is out we start a new wave 
	$Timer.start() #start randomly spawning again
