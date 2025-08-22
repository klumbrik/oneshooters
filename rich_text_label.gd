extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "bullets: " + str(G.ammo) + "\n" + "score: " + str(G.score) + "\n" + "ammo stash: " + str(G.stash) + "\n" + "stash pcs: " + str(G.stash_pieces)
