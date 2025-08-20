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
	if sound:
		G.sound_on = true
	else:
		G.sound_on = false
		
	if G.sound_on:
		$Synthoneshootersdemo4.bus = "Music"
		$Synthoneshootersdemo4.play()
		

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
	#safely delete last instance of game window (child) if exists
	if $SubViewportContainer/SubViewport.get_child_count() > 0:
		var old_child = $SubViewportContainer/SubViewport.get_child(0)
		old_child.queue_free() #close game scene
		
		await old_child.tree_exited                                      #good base for window system!
		var scene = main.instantiate() #instantiate scene
		$SubViewportContainer/SubViewport.add_child(scene) #add/open it again
