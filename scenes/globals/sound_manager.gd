extends Node
@onready var sfx = $SFX
@onready var bgm: Node = $BGM

enum Bus{
	MASTER,
	SFX,
	BGM
}

func _process(delta: float) -> void:
	pass

func play_sfx(name:String)->void:
	var player:=sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()

func play_bgm(name:String)->void:
	var player:=bgm.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()
	
func setup_ui_sounds(node:Node)->void:
	var button:=node as Button
	if button:
		button.pressed.connect(play_sfx.bind("Press"))
		button.focus_entered.connect(play_sfx.bind("Focus"))
		button.mouse_entered.connect(button.grab_focus)
		
	var slider:=node as HSlider
	if slider:
		slider.value_changed.connect(play_sfx.bind("Press").unbind(1))
		slider.focus_entered.connect(play_sfx.bind("Focus"))
		slider.mouse_entered.connect(slider.grab_focus)
		
	for child in node.get_children():
		setup_ui_sounds(child)

func get_volume(idx:int)->float:
	var db:=AudioServer.get_bus_volume_db(idx)
	return db_to_linear(db)
	
func set_volume(idx:int,volume:float)->void:
	var db:=linear_to_db(volume)
	AudioServer.set_bus_volume_db(idx,db)
