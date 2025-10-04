extends Control


func _ready() -> void:
	$Control4/TouchScreenButton7.hide()
	var prompt:=get_tree().get_first_node_in_group("player").get_node("Prompt") as Sprite2D
	for portal:Portal in get_tree().get_nodes_in_group("portals"):
		portal.enter.connect(func():
			$Control4/TouchScreenButton7.show()
			prompt.show()
			
			)
		portal.exit.connect(func():
			$Control4/TouchScreenButton7.hide()
			prompt.hide()
			)
	for save_point:SavePoint in get_tree().get_nodes_in_group("save_points"):
		save_point.enter.connect(func():
			$Control4/TouchScreenButton7.show()
			prompt.show()
			)
		save_point.exit.connect(func():
			$Control4/TouchScreenButton7.hide()
			prompt.hide()
			)
	for switch:Switch in get_tree().get_nodes_in_group("switches"):
		switch.enter.connect(func():
			$Control4/TouchScreenButton7.show()
			prompt.show()
			)
		switch.exit.connect(func():
			$Control4/TouchScreenButton7.hide()
			prompt.hide()
			)
	for child:TouchScreenButton in $Control4.get_children():
		child.pressed.connect(func():
			child.modulate.a=0.5
			)
		child.released.connect(func():
			child.modulate.a=1
			)
