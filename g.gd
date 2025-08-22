extends Node

#signals - mostly for the ux player

signal enemy_tap(enemy)
signal enemy_died_in_zone
signal out_of_ammo
signal enemy_shoots
signal swipe_room
signal make_cover_unused
signal rotate_ui
signal shot
signal delete_enemies_out_of_screen
signal reload_game
signal menu_play
signal pause_menu

var pacedif_modifier = 1 #Set to 1 to revert to play with original values. modifier for speed in terms of difficulty (testing). 
#Contains global vars
var game_over = false
var sound_on = true
var is_enemy_in_zone: bool
var score = 0
var ammo = 6
var stash = 0
var stash_pieces = 2
var wave_going = true
var moving = false #activated when we run to the next cover
var moving_speed = 250
var right_swipe_detected = false
var left_swipe_detected = false
var area_res #?
var character_position: Vector2
var enemiesonscreen = [] #an array containing all the enemies in the screen
var current_target_enemy
var rooms = [] #an array containing rooms
var current_cover_number = 0 #counts covers
var last_cover_number = -1
var number_of_dodges = 1
var best_score = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_cover_number, last_cover_number)
	#print(enemiesonscreen)
	pass

func reset():
	G.stash = 0
	G.score = 0
	G.game_over = false
	G.current_cover_number = 0
	G.last_cover_number = -1
	G.number_of_dodges = 1
	get_tree().paused = false
	G.enemiesonscreen.clear()
	G.rooms.clear()
