extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	G.enemy_tap.connect(self._on_enemy_tap)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
		#setting the first target
	if G.enemiesonscreen.size() > 0:
		visible = true
		if G.current_target_enemy == null: 
			G.current_target_enemy = G.enemiesonscreen[0]
			#target.get_parent().remove_child(target)
		move_target_to(G.current_target_enemy)
	else:
		visible = false
func _on_enemy_tap(enemy):
	if enemy in G.enemiesonscreen:
		G.current_target_enemy = enemy
		

func move_target_to(target_enemy):
	global_position.x = target_enemy.global_position.x
	
	#reparenting to the target enemy
	#get_parent().remove_child(self)
	#target_enemy.add_child(self)
