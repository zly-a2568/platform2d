extends Camera2D

var shockstrength:float=0
var recovery_speed:float=32
# Called when the node enters the scene tree for the first time.
func _ready():
	GameProcesser.camera_shock.connect(func(v:float):
		shockstrength=v
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset.x=randf_range(-shockstrength,shockstrength)
	offset.y=randf_range(-shockstrength,shockstrength)
	shockstrength = move_toward(shockstrength, 0, recovery_speed * delta)
