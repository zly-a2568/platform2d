extends HSlider

@export var bus:StringName="Master"

@onready var bus_idx:int=AudioServer.get_bus_index(bus)

# Called when the node enters the scene tree for the first time.
func _ready():
	value=SoundManager.get_volume(bus_idx)
	
	value_changed.connect(func(v:float):
		SoundManager.set_volume(bus_idx,v)
		GameProcesser.save_config()
		)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
