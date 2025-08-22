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
	else:
		G.sound_on = false
		
	if G.sound_on:
		$Synthoneshootersdemo4.bus = "Music"
		$Synthoneshootersdemo4.play()
		
	hide_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_bullet)
	#print(mouse_on_screen)
	pass
	
	
func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event is InputEventMouseButton and event.pressed:
		##print(event, event.global_position)
		#var new_event = event.duplicate() #creating a copy of event for safety
		#$SubViewportContainer/SubViewport.push_input(new_event)




func _on_game_reload():
	var main = preload("res://main.tscn")
	change_scene_to(main)
	#reset happens in button script

func _on_play_pressed():
	var main = preload("res://main.tscn")
	change_scene_to(main)
	show_ui()

func _on_pause_to_menu_pressed():
	var menu = preload("res://mainmenu.tscn")
	change_scene_to(menu)
	hide_ui()
	G.reset()
	
	
func hide_ui():
	#$SubViewportContainer/CanvasLayer.visible = false
	$score.visible = false
	$PauseButton.visible = false
	
func show_ui():
	#$SubViewportContainer/CanvasLayer.visible = true
	$score.visible = true
	$PauseButton.visible = true

func change_scene_to(scene: PackedScene):
	if $SubViewportContainer/SubViewport.get_child_count() > 0:
		var old_child = $SubViewportContainer/SubViewport.get_child(0)
		old_child.queue_free() #close game scene
		#safely delete last instance of game window (child) if exists
		await old_child.tree_exited                                      #good base for window system!
		var new_scene = scene.instantiate() #instantiate scene
		$SubViewportContainer/SubViewport.add_child(new_scene) #add/open it again
			
