extends Control
var sprite_angle = 0.0
var body_in_area
var current_bullet
var scene_switching := false



var ui_shown = false
@onready var current_screen = "menu"

@export var sound: bool

var bullet_ui = preload("res://scenes/jebulletui.tscn")

var game_scene = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !G.tutorial_finished:
		$TutorialSkipButton.visible = true
	
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


func _input(event: InputEvent) -> void: #space key start and restart
	if event.is_action_pressed("space"):
		var game_over: GameOverLayer = find_child("GameOver", true, false)
		var main: MainScreen = find_child("main", true, false)
		if main != null:
			if game_over == null:
				if !G.game_started and G.character_ref != null:
					if G.character_ref.character_state_machine.get_active_state().name == "shooting":
						#await get_tree().create_timer(0.1).timeout
						if main.start_game_button.visible:
							main.start_game()
			else:
				game_over.animate_reload_button()  
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(G.rooms)
	#print(current_bullet)
	#print(mouse_on_screen)
	
	#print(current_screen)
	
	
	if current_screen == "menu":
		$TutorialStartButton.hide()
		$LobbySoundButton.hide()
		$ExitToMenuButton.hide()
	
	if G.game_started and !ui_shown:
		show_ui()
		ui_shown = true
		crossfade_buses("LobbyMusic", "Music", 1)
		
		$ExitToMenuButton.hide()
	
	#show lobby buttons - refactor in future
	if current_screen == "wardrobe" and !G.game_started:
		$TutorialSkipButton.hide()
		$TutorialSkipButton.disabled = true
		
		$TutorialStartButton.hide()
		$TutorialStartButton.disabled = true
		
		$LobbySoundButton.show()
		$LobbySoundButton.disabled = false
		
		$ExitToMenuButton.hide()
		$ExitToMenuButton.disabled = true
	
	elif current_screen == "menu":
		$TutorialStartButton.hide()
		$TutorialStartButton.disabled = true
		
		$LobbySoundButton.hide()
		$LobbySoundButton.disabled = true

		$TutorialSkipButton.hide()
		$TutorialSkipButton.disabled = true
		
	elif current_screen == "tutorial":
		$TutorialSkipButton.show()
		$TutorialSkipButton.disabled = false
		
		$ExitToMenuButton.hide()
		$ExitToMenuButton.disabled = true
		
	elif G.game_started:
		$TutorialSkipButton.hide()
		$TutorialSkipButton.disabled = true
		
		$TutorialStartButton.hide()
		$TutorialStartButton.disabled = true
		
		$LobbySoundButton.hide()
		$LobbySoundButton.disabled = true
		
		$ExitToMenuButton.hide()
		$ExitToMenuButton.disabled = true
	elif G.game_over:
		$TutorialSkipButton.hide()
		$TutorialSkipButton.disabled = true
		
		$TutorialStartButton.hide()
		$TutorialStartButton.disabled = true
		
		$LobbySoundButton.hide()
		$LobbySoundButton.disabled = true
		
		$ExitToMenuButton.hide()
		$ExitToMenuButton.disabled = true
	else:
		var game_over = find_child("GameOver", true, false)
		if game_over != null:
			var anim: AnimationPlayer = game_over.animation_player
			await anim.animation_finished
			#print("AWAITING")
		#else:
			#print("GAME OVER NOT FOUND")
		
		$TutorialSkipButton.hide()
		$TutorialSkipButton.disabled = true
		
		$TutorialStartButton.show()
		$TutorialStartButton.disabled = false
		
		$LobbySoundButton.show()
		$LobbySoundButton.disabled = false
		
		$ExitToMenuButton.show()
		$ExitToMenuButton.disabled = false
	
		

	#if !G.tutorial_finished:
	#	$TutorialSkipButton.show()
	#	$TutorialSkipButton.disabled = false
	#else:
	#	$TutorialSkipButton.hide()
	#	$TutorialSkipButton.disabled = true
		
	
	
	#print(current_screen)	
		
	#if current_screen == "menu":
		#$CenterContainer2.visible = false
		#$CenterContainer3.visible = false
	#else:
		#$CenterContainer2.visible = true
		#$CenterContainer3.visible = true
		
	
func _on_game_reload():
	var main = preload("res://scenes/main.tscn")
	var tutorial = preload("res://scenes/tutorial.tscn")
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
	var menu = preload("res://scenes/mainmenu.tscn")
	change_scene_to(menu)
	crossfade_buses("Music", "LobbyMusic", 1)
	hide_ui()
	current_screen = "menu"
	G.reset()
	
	
	
func hide_ui():
	#$SubViewportContainer/CanvasLayer.visible = false
	$ScoreLayer.visible = false
	$PauseButton.visible = false
	
	$TutorialSkipButton.hide()
	$TutorialSkipButton.disabled = true
		
	$TutorialStartButton.hide()
	$TutorialStartButton.disabled = true
		
	$LobbySoundButton.hide()
	$LobbySoundButton.disabled = true
		
	$ExitToMenuButton.hide()
	$ExitToMenuButton.disabled = true
	
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
	pause()


func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	
	
	var main_menu_or_null = get_node_or_null("SubViewportContainer/SubViewport/MainMenu")
	var wardrobe_or_null = get_node_or_null("SubViewportContainer/SubViewport/Wardrobe")
	
	
	var main = preload("res://scenes/main.tscn")
	var wardrobe = preload("res://scenes/wardrobe.tscn")
	var tutorial = preload("res://scenes/tutorial.tscn")
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
	var game_over_ui = preload("res://scenes/game_over.tscn").instantiate()
	add_child(game_over_ui)
	
	#reset
	G.reset()
	G.game_over = true
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


func pause(): 
	if not G.pause_added:
		get_tree().paused = true
		var pause = preload("res://scenes/pause.tscn").instantiate()
		$PauseLayer.add_child(pause)
		G.pause_added = true


#auto pause
func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			auto_pause_if_needed()


func auto_pause_if_needed():
	if G.game_started and not G.pause_added and not G.game_over:
		pause()

#tutorial skip
func _on_tutorial_skip_button_button_down() -> void:
	var main = preload("res://scenes/main.tscn")
	G.tutorial_finished = true
	change_scene_to(main)
	current_screen = "main"
	$TutorialSkipButton.visible = false
	$TutorialSkipButton.disabled = true
	G.reset()
	$fade.play()
	print("bim-bom")

#tutorial start from lobby
func _on_tutorial_start_button_button_down() -> void:
	if $Transition_player.is_playing():
		return
	var tutorial = preload("res://scenes/tutorial.tscn")
	G.tutorial_finished = false
	G.reset()
	process_mode = Node.PROCESS_MODE_ALWAYS #Careful with this line
	change_scene_to(tutorial)
	current_screen = "tutorial"
	$TutorialStartButton.visible = false
	$TutorialStartButton.disabled = true
	$fade.play()




func _on_lobby_sound_button_toggled(toggled_on: bool) -> void:
	$impact.play()
	if toggled_on:
		G.sound_on = false
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)
		
	else:
		G.sound_on = true
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -8.8)


func _on_exit_to_menu_button_button_down() -> void:
	if $Transition_player.is_playing():
		return
	var menu = preload("res://scenes/mainmenu.tscn")
	change_scene_to(menu)
	crossfade_buses("Music", "LobbyMusic", 1)
	hide_ui()
	current_screen = "menu"
	G.tutorial_finished = true
	G.reset()
	#G.tutorial_finished если надо
