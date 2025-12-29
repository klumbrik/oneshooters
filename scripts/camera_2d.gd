extends Camera2D
#I'll make precise position relative to main if I find out how to do it.
#change to your code. refine

@export var wiggle_enabled: bool
@export var wiggle_intensity := 15.0
@export var wiggle_speed := 5.0

var base_position := Vector2.ZERO
var wiggle_time := 0.0

@export var zoom_normal := Vector2(1, 1)
@export var zoom_in := Vector2(1.1, 1.1)
@export var zoom_speed := 5.0
@export var y_offset_on_zoom := 60.0
@export var offset_lerp_speed := 5.0
func _ready():
	pass
	#base_position = position

func _process(delta):
	# WIGGLE
	if wiggle_enabled:
		wiggle_time += delta
		var x = sin(wiggle_time * wiggle_speed) * wiggle_intensity
		var y = sin(wiggle_time * wiggle_speed * 0.7) * wiggle_intensity * 0.6
		position = position.lerp(base_position + Vector2(x, y), 0.05)
		
		# ZOOM
		var target_zoom: Vector2
		if G.moving:
			target_zoom = zoom_in
		else:
			target_zoom = zoom_normal

		zoom = zoom.lerp(target_zoom, zoom_speed * delta)
		
		var target_offset: Vector2
		if G.moving:
			target_offset = Vector2(0,y_offset_on_zoom)
		else:
			target_offset = Vector2.ZERO

		offset = offset.lerp(target_offset, offset_lerp_speed * delta)
	else:
		pass
		#position = position.lerp(base_position, 0.1)


		
