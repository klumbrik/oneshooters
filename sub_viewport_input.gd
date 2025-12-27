extends Control
var sprite_angle = 0.0
var body_in_area
var current_bullet
var scene_switching := false

var ui_shown = false
@onready var current_screen = "menu"

@export var sound: bool

var bullet_ui = preload("res://jebulletui.tscn")

var game_scene = preload("res://main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$LobbyMusic.play()
	$Synthoneshootersdemo4.play()
	AudioServer.set_bus_volume_db(1, -80)
	AudioServer.set_bus_volume_db(2, 0)
	
	G.player_died.connect(self._on_player_died)
	G.to_wardrobe.connect(self._go_to_wardrobe)
	G.reload_game.connect(self._on_game_reload)
	if not G.menu_play.is_connected(self._on_play_pressed):
		G.menu_play.connect(self._on_play_pressed)
	G.pause_menu.connect(self._on_pause_to_menu_pressed)
	
	$CenterContainer2.visible = false
	$CenterContainer3.visible = false
	
	
	
	if sound:
		G.sound_on = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	else:
		G.sound_on = false 
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		

	$Synthoneshootersdemo4.bus = "Music"
	$LobbyMusic.play()
		
	hide_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_bullet)
	#print(mouse_on_screen)
	
	if G.game_started and !ui_shown:
		show_ui()
		ui_shown = true
		crossfade_buses("LobbyMusic", "Music", 1)
	
	#print(current_screen)	
		
	#if current_screen == "menu":
		#$CenterContainer2.visible = false
		#$CenterContainer3.visible = false
	#else:
		#$CenterContainer2.visible = true
		#$CenterContainer3.visible = true
		
	
func _on_game_reload():
	var main = preload("res://main.tscn")
	var tutorial = preload("res://tutorial.tscn")
	if G.tutorial_finished:
		change_scene_to(main)
	else:
		change_scene_to(tutorial)
	#reset happens in on player died

func _on_play_pressed(): #scene changes when transition is finished (see signal "anim finished") #rename signa to start_transition
	$Transition_player/ColorRect.visible = true
	
	$fade.play()
	
	$Transition_player.play("basic_fade")
	#await $Transition_player.animation_finished
	
	#$Transition_player.play_backwards("basic_fade")
	$Transition_player/ColorRect.visible = false
	ui_shown = false
	
func _on_pause_to_menu_pressed():
	var menu = preload("res://mainmenu.tscn")
	change_scene_to(menu)
	crossfade_buses("Music", "LobbyMusic", 1)
	hide_ui()
	current_screen = "menu"
	G.reset()
	
	
	
func hide_ui():
	#$SubViewportContainer/CanvasLayer.visible = false
	$ScoreLayer.visible = false
	$PauseButton.visible = false
	
func show_ui():
	#$SubViewportContainer/CanvasLayer.visible = true
	$ScoreLayer.visible = true
	$PauseButton.visible = true
	$CenterContainer2.visible = true
	$CenterContainer3.visible = true





func change_scene_to(scene: PackedScene):
	if scene_switching:
		return
	scene_switching = true
	
	if $SubViewportContainer/SubViewport.get_child_count() > 0:
		var old_child = $SubViewportContainer/SubViewport.get_child(0)
		old_child.queue_free() #close game scene
		#safely delete last instance of game window (child) if exists
		await old_child.tree_exited                                      #good base for window system!
	var new_scene = scene.instantiate() #instantiate scene
	$SubViewportContainer/SubViewport.add_child(new_scene) #add/open it again
	
	
	$Transition_player.play_backwards("basic_fade")

	if current_screen == "menu":
	
		crossfade_buses("Music", "LobbyMusic", 1)
		$CenterContainer2.visible = false
		$CenterContainer3.visible = false
		
	if current_screen == "main":
		$CenterContainer2.visible = true
		$CenterContainer3.visible = true
		
	scene_switching = false




func _on_pause_button_button_down() -> void:
	if not G.pause_added:
		get_tree().paused = true
		var pause = preload("res://pause.tscn").instantiate()
		$PauseLayer.add_child(pause)
		G.pause_added = true


	


	


func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	
	
	var main_menu_or_null = get_node_or_null("SubViewportContainer/SubViewport/MainMenu")
	var wardrobe_or_null = get_node_or_null("SubViewportContainer/SubViewport/Wardrobe")
	
	
	var main = preload("res://main.tscn")
	var wardrobe = preload("res://wardrobe.tscn")
	var tutorial = preload("res://tutorial.tscn")
	var direct_order = $Transition_player.current_animation_position == $Transition_player.current_animation_length
	
	if anim_name == "basic_fade" and current_screen == "menu" and direct_order:
		if G.tutorial_finished == false:
			process_mode = Node.PROCESS_MODE_ALWAYS #Careful with this line
			change_scene_to(tutorial)
			current_screen = "tutorial"
		else:	
			change_scene_to(main)
			current_screen = "main"
		
	elif anim_name == "basic_fade" and current_screen == "main" and direct_order:
		change_scene_to(wardrobe)
		current_screen = "wardrobe"
		
	elif anim_name == "basic_fade" and current_screen == "wardrobe" and direct_order:
		change_scene_to(main)
		current_screen = "main"
		G.connect("to_wardrobe", self._go_to_wardrobe) #connecting the wardeobe button again
		
	elif anim_name == "basic_fade" and current_screen == "tutorial" and direct_order:
		change_scene_to(main)
		current_screen = "main"
		
		
	if main_menu_or_null:
		main_menu_or_null.animation_playing = false
		
	if wardrobe_or_null:
		wardrobe_or_null.animation_playing = false
		
	
func _on_transition_player_animation_started(anim_name: StringName) -> void:
	#crash protection
	
	var main_menu_or_null = get_node_or_null("SubViewportContainer/SubViewport/MainMenu")
	var wardrobe_or_null = get_node_or_null("SubViewportContainer/SubViewport/Wardrobe")
	
	if main_menu_or_null:
		main_menu_or_null.animation_playing = true
		
	if wardrobe_or_null:
		wardrobe_or_null.animation_playing = true


func _go_to_wardrobe():
	
	print("going to wardrobe")
	$fade.play()
	$Transition_player.play("basic_fade")
	G.disconnect("to_wardrobe", self._go_to_wardrobe)
	

func _on_player_died():
	$ScoreLayer.hide()
	var game_over_ui = preload("res://game_over.tscn").instantiate()
	add_child(game_over_ui)
	
	
	
	#reset
	G.reset()
	
	crossfade_buses("Music", "LobbyMusic", 1)
	hide_ui()
	ui_shown = false


func _on_lobby_music_finished() -> void:
	$LobbyMusic.play()


func _on_synthoneshootersdemo_4_finished() -> void:
	$Synthoneshootersdemo4.play()

func crossfade_buses(from_bus: String, to_bus: String, duration: float = 2.0):
	var tween = create_tween()
	var from_index = AudioServer.get_bus_index(from_bus)
	var to_index = AudioServer.get_bus_index(to_bus)

	# Начнем с текущих значений
	var from_volume = AudioServer.get_bus_volume_db(from_index)
	var to_volume = AudioServer.get_bus_volume_db(to_index)
	
	tween.set_parallel()
	# Crossfade: от текущего до целевого
	tween.parallel().tween_method(
		func(db): AudioServer.set_bus_volume_db(from_index, db),
		from_volume, -80, duration
	)
	tween.parallel().tween_method(
		func(db): AudioServer.set_bus_volume_db(to_index, db),
		to_volume, 0, duration
	)
