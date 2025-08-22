extends Node2D
# Called when the node enters the scene tree for the first time.
var last_target_enemy = null #tracking last enemy for animation control
var manual_target = false
func _ready() -> void:
	G.enemy_tap.connect(self._on_enemy_tap)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	#test
	#print("Current target = " + str(G.current_target_enemy))
	#print(manual_target)
	#if G.enemiesonscreen.size() > 0:
		#print("Target at 0 = " + str(G.enemiesonscreen[0]))
		#setting the first target
	#test
	
	
	if G.enemiesonscreen.size() > 0:
		visible = true
		
		
		
		
		auto_select_target()
		
		if G.current_target_enemy != last_target_enemy: #play anim once if the target enemy has changed
			$target_anim/AnimationPlayer.play("added")
			last_target_enemy = G.current_target_enemy
			
		move_target_to(G.current_target_enemy)
	else:
		visible = false
		last_target_enemy = null


func _on_enemy_tap(enemy):
	if enemy in G.enemiesonscreen:
		G.current_target_enemy = enemy
		manual_target = true
		#connect signal to detect tree exit
		if not enemy.is_connected("tree_exited", Callable(self, "_on_target_removed")):
			enemy.connect("tree_exited", Callable(self, "_on_target_removed"))

func move_target_to(target_enemy):
	if is_instance_valid(target_enemy):
		global_position.x = target_enemy.global_position.x
	
	
	#reparenting to the target enemy
	#get_parent().remove_child(self)
	#target_enemy.add_child(self)
	
func auto_select_target():
	G.enemiesonscreen = G.enemiesonscreen.filter(is_instance_valid) #for safe purposes need to delete all freed objects
	
	
	G.enemiesonscreen.sort_custom(_sort_by_x)
	
	if manual_target:
		return	
	else:
		if G.current_target_enemy == null: 
			if G.enemiesonscreen.size() > 0:
				G.current_target_enemy = G.enemiesonscreen[0]
			else:
				visible = false
			#target.get_parent().remove_child(target)
				
		else: #if there is a target enemy
			for enemy in G.enemiesonscreen:
				if enemy.global_position.x < G.current_target_enemy.global_position.x:
					G.current_target_enemy = enemy
	

func _sort_by_x(a, b):
	return a.global_position.x < b.global_position.x

func _on_target_removed():
		manual_target = false
		G.current_target_enemy = null
		auto_select_target()	
		print("WORKED")
