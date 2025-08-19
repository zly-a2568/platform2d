extends Control
var pad_scale:=0.5


func open_panel():
	for child:TouchScreenButton in $JoyPad/Control4.get_children():
		child.pressed.connect(func():
			child.modulate.a=0.5
			)
		child.released.connect(func():
			child.modulate.a=1
			)
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)
	pad_scale=config.get_value("Settings","pad_scale",0.5)
	
	
	$VBoxContainer/HBoxContainer/HSlider.value=pad_scale
	for child:Control in $JoyPad.get_children():
		child.scale=Vector2(1.0,1.0)*2*pad_scale
	show()



func _on_save_pressed() -> void:
	var config:=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)
	config.set_value("Settings","pad_scale",pad_scale)
	config.save(GameProcesser.CONFIG_PATH)
	

func _on_h_slider_value_changed(value: float) -> void:
	pad_scale=value
	for child:Control in $JoyPad.get_children():
		child.scale=Vector2(1.0,1.0)*2*value

func _on_exit_pressed() -> void:
	hide()
