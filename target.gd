extends Node2D
# Called when the node enters the scene tree for the first time.
var last_target_enemy = null #tracking last enemy for animation control
func _ready() -> void:
	G.enemy_tap.connect(self._on_enemy_tap)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	#test
	#print("Current target = " + str(G.current_target_enemy))
	#if G.enemiesonscreen.size() > 0:
		#print("Target at 0 = " + str(G.enemiesonscreen[0]))
		#setting the first target
	#test
	
	
	if G.enemiesonscreen.size() > 0:
		visible = true
		if G.current_target_enemy == null: 
			G.current_target_enemy = G.enemiesonscreen[0]
			#target.get_parent().remove_child(target)
		
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

func move_target_to(target_enemy):
	global_position.x = target_enemy.global_position.x
	
	
	#reparenting to the target enemy
	#get_parent().remove_child(self)
	#target_enemy.add_child(self)
