extends Node

#signals - mostly for the ux player

signal enemy_tap(enemy)
signal enemy_died_in_zone(enemy)
signal out_of_ammo
signal enemy_shoots(enemy)
signal swipe_room
signal make_cover_unused
signal rotate_ui
signal cancel_reload_rotation
signal shot
signal delete_enemies_out_of_screen
signal reload_game
signal menu_play
signal to_wardrobe
signal pause_menu
signal drop_bonus(position)
signal move_last_cover
signal dodge_bar_empty
signal dodge_bar_fill
signal bonus_stash
signal player_died
signal score_changed(score)

var json_path = "user://essential_data.json"

var e_data: Dictionary = {}
var coins = 0
var skin2bought = false
var break_bar_progress = 0.0
var pacedif_modifier = 1 #Set to 1 to revert to play with original values. modifier for speed in terms of difficulty (testing). 
#Contains global vars

var difficulty_level = 1.0
var difficulty_growth_rate = 0.05 # increases each n secs
var difficulty_timer = 0.0

var tutorial_mode = true
var tutorial_finished = false
var character_ref: Node2D
var game_over = false
var last_sound_state
var sound_on = true
var is_enemy_in_zone: bool
var score = 0
var ammo = 6
var stash = 0
var stash_pieces = 0
var wave_going = true
var moving = false #activated when we run to the next cover
var moving_speed = 250
var right_swipe_detected = false
var left_swipe_detected = false
var number_of_right_swipes = 0

var reload_cooldown_active = false
var reload_cooldown_duration = 0.1 #change carefully

var area_res #?
var shield_enabled = false
var drone_active = false


var character_position: Vector2 #INITIAL CHARACTER POSITION (NOT UPDATING)
var enemiesonscreen = [] #an array containing all the enemies in the screen
var current_target_enemy
var rooms = [] #an array containing rooms
var current_cover_number = 0 #counts covers
var last_cover_number = -1
var number_of_dodges = 1
var pause_added = false

var last_cover_area_ref = null
var last_cover_moved = false
var best_score = 0

var game_started := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS #always processes even if paused
	connect("move_last_cover", self._move_last_cover)
	print(load_json_file())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(last_cover_area_ref)
	#print(current_cover_number, last_cover_number)
	#print(enemiesonscreen)
	if last_sound_state != sound_on:
		last_sound_state = sound_on
		if sound_on:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
			#print("ON")
		else:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			#print("OFF")
			
	difficulty_timer += delta
	if difficulty_timer >= 30.0: # каждые 30 секунд
		G.difficulty_level += 0.25
		difficulty_timer = 0.0
		

func reset(): #reset essential variables
	G.stash_pieces = 0
	G.stash = 0
	G.score = 0
	G.game_over = false
	G.current_cover_number = 0
	G.last_cover_number = -1
	G.number_of_dodges = 1
	get_tree().paused = false
	G.enemiesonscreen.clear()
	G.rooms.clear()
	G.pause_added = false
	G.ammo = 6
	G.number_of_right_swipes = 0
	G.number_of_dodges = 1
	G.shield_enabled = false
	G.drone_active = false
	
	difficulty_level = 1.0
	difficulty_growth_rate = 0.05 # increases each n secs
	difficulty_timer = 0.0
	game_started = false

func _move_last_cover():
	G.last_cover_area_ref.position.x -= 30
	#print("cover pos changed")

func load_json_file():
	var file = FileAccess.open(json_path, FileAccess.READ)
	
	if !FileAccess.file_exists(json_path):
		print("JSON file not found, creating default")
		e_data = {
			"best_score": 0,
			"coins": 0,
			"skin2bought": false,
			"tutorial_finished": false
			}
		save_json_file()
		return e_data
		
	if file == null:
		print("Failed to open file")
		e_data = {}
		return e_data
	
	var json = file.get_as_text()
	var json_object = JSON.new()
	json_object.parse(json)
	
	
	
	if typeof(json_object.data) != TYPE_DICTIONARY:
		print("Parsed JSON is not a dictionary")
		e_data = {}
		return e_data
		
	e_data = json_object.data
	
	if e_data.has("best_score"):
		best_score = e_data["best_score"]
	if e_data.has("coins"):
		coins = e_data["coins"]
	if e_data.has("skin2bought"):
		skin2bought = e_data["skin2bought"]
	if e_data.has("tutorial_finished"):
		tutorial_finished = e_data["tutorial_finished"]
		
	return e_data

func save_json_file():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + json_path)
		return
		
	e_data["best_score"] = best_score
	e_data["coins"] = coins
	e_data["skin2bought"] = skin2bought
	e_data["tutorial_finished"] = tutorial_finished
	var json_string = JSON.stringify(e_data)
	file.store_string(json_string)
	file.close()
