extends Control
var sprite_angle = 0.0
var body_in_area
var current_bullet
@export var sound: bool

var bullet_ui = preload("res://jebulletui.tscn")

var game_scene = preload("res://main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	G.reload_game.connect(self._on_game_reload)
	G.menu_play.connect(self._on_play_pressed)
	G.pause_menu.connect(self._on_pause_to_menu_pressed)
	
	if sound:
		G.sound_on = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	else:
		G.sound_on = false 
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		

	$Synthoneshootersdemo4.bus = "Music"
	$Synthoneshootersdemo4.play()
		
	hide_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_bullet)
	#print(mouse_on_screen)
	
	pass


func _on_game_reload():
	var main = preload("res://main.tscn")
	change_scene_to(main)
	#reset happens in button script

func _on_play_pressed():
	$Transition_player/ColorRect.visible = true
	var main = preload("res://main.tscn")
	#$Transition_player.play("basic_fade")
	#await $Transition_player.animation_finished
	change_scene_to(main)
	#$Transition_player.play_backwards("basic_fade")
	$Transition_player/ColorRect.visible = false
	show_ui()

func _on_pause_to_menu_pressed():
	var menu = preload("res://mainmenu.tscn")
	change_scene_to(menu)
	hide_ui()
	G.reset()
	
	
func hide_ui():
	#$SubViewportContainer/CanvasLayer.visible = false
	$ScoreLayer.visible = false
	$PauseButton.visible = false
	
func show_ui():
	#$SubViewportContainer/CanvasLayer.visible = true
	$ScoreLayer.visible = true
	$PauseButton.visible = true

func change_scene_to(scene: PackedScene):
	if $SubViewportContainer/SubViewport.get_child_count() > 0:
		var old_child = $SubViewportContainer/SubViewport.get_child(0)
		old_child.queue_free() #close game scene
		#safely delete last instance of game window (child) if exists
		await old_child.tree_exited                                      #good base for window system!
		var new_scene = scene.instantiate() #instantiate scene
		$SubViewportContainer/SubViewport.add_child(new_scene) #add/open it again
			
