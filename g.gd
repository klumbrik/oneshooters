extends Node
#Contains global vars
var game_over = false
var score = 0
var ammo = 6
var wave_going = true
var moving = false #activated when we run to the next cover
var moving_speed = 500
var right_swipe_detected = false
var covers_to_spawn =  1 # how many covers we need to spawn (or don't)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
