extends CenterContainer

var last_count = 0
var current_count
var digit_count
var has_reset = false

var starting_scale
var starting_offset
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#G.score = 9999 #for tests
	starting_offset = pivot_offset
	starting_scale = scale
	print(starting_offset, starting_scale)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_reset()
	
	digit_count = str(G.score).length()
	if digit_count >= 4:
		current_count = digit_count
		if current_count - last_count == 1: #if the difference is 1
			var percent = scale * 0.12
			pivot_offset = size * 0.5
			scale -= percent
			print("new scale: " + str(scale))
		last_count = digit_count


func check_reset():
	if G.score == 0 and !has_reset: #reset
		scale = starting_scale
		pivot_offset = starting_offset
		print("reset")
		has_reset = true
	if G.score != 0 and has_reset:
		has_reset = false
		
		
