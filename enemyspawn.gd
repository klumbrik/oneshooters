extends CharacterBody2D
var enemy = preload("res://enemy.tscn")
var shooting_enemy = preload("res://shooting_enemy.tscn")
var shielded_enemy = preload("res://shielded_enemy.tscn")
var enabled = true #disable when tesitng
@onready var target = $target
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(1, 1.5)
	#$Break_Window.wait_time = randf_range(3, 6)
	$WaveEnd.wait_time = 5
	
	if enabled:
		$Timer.start()
		$WaveEnd.start()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(G.enemiesonscreen)
	$Timer.wait_time = randf_range(1, 1.5) #random time between spawns
	
	if !G.wave_going: #when wave stops we stop spawning
		$Timer.stop()
		
	if G.moving:
		velocity.x = G.moving_speed
		move_and_slide()


func _on_timer_timeout() -> void:
	spawn_and_register()


func _on_wave_end_timeout() -> void: #once the timer is timed out the wave stops
	wave_end()
	print("wave ended")


func _on_break_window_timeout() -> void:
	new_wave()
	print("wave started")
	


func spawn_and_register():
	var chance = randf()
	var current_enemy
	if chance <= 0.8: #0.8:
		current_enemy = enemy
	else:
		current_enemy = shielded_enemy #for testing change later (other types of enemies)
		#current_enemy = shooting_enemy
	var new_enemy = current_enemy.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.position = position #spawn position = spawner position
	
	
	
	
	

		
func wave_end():
	$WaveEnd.wait_time = randf_range(1,2) #we redefine time for a new wave15, 25
	G.wave_going = false
	#print("wave has ended. wavetime changed")
	$Break_Window.wait_time = randf_range(3, 6) #define new break time in range
	$Break_Window.start() #then we start a new timer for break time
	
func new_wave():
	G.wave_going = true #once break timer is out we start a new wave 
	$Timer.start() #start randomly spawning again
	

	
