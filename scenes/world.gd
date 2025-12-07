extends Node2D
class_name World
@onready var background = $Background
@onready var map = $map
@onready var camera_2d:Camera2D = $player/PlayerCamera
@onready var player: Player = $player






# Called when the node enters the scene tree for the first time.
func _ready():
	tree_exiting.connect(func():
		for child:AudioStreamPlayer in SoundManager.get_node("SFX").get_children():
			child.stop()
		for child:AudioStreamPlayer in SoundManager.get_node("BGM").get_children():
			child.stop()
		)
	GameProcesser.fix_camera.connect(func():
		camera_2d.reset_smoothing()
		camera_2d.force_update_scroll()
		)
	var tilesize=map.tile_set.tile_size.x
	var mappos=map.get_used_rect().position*tilesize
	var mapsize=map.get_used_rect().size*tilesize
	background.size=mapsize+Vector2i(800,800)
	background.position=mappos-Vector2i(400,400)
	camera_2d.limit_left=mappos.x
	camera_2d.limit_top=mappos.y-400
	camera_2d.limit_right=mappos.x+mapsize.x
	camera_2d.limit_bottom=mappos.y+mapsize.y
	SoundManager.setup_ui_sounds(self)
	player.status.health=GameProcesser.player_status.health
	player.status.energy=GameProcesser.player_status.energy

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index==MOUSE_BUTTON_WHEEL_UP:
				camera_2d.zoom*=1.1 if camera_2d.zoom.x<=1.5 else 1.0
			if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
				camera_2d.zoom*=0.7 if camera_2d.zoom.x>=0.6 else 1.0
			

func packdata() -> Dictionary:
	var enemies_data:={}
	for enemy:Enemy in get_tree().get_nodes_in_group("enemies"):
		enemies_data[enemy.get_path()]={
			"health":enemy.status.health,
			"position":enemy.global_position,
			"direction":enemy.direction
		}
	var platform_data:={}
	for platform:Platform in get_tree().get_nodes_in_group("platforms"):
		platform_data[platform.get_path()]={
			"position":platform.global_position,
			"velocity":platform.v
		}
	var fruit_data:={}
	for fruit:Fruit in get_tree().get_nodes_in_group("fruits"):
		fruit_data[fruit.get_path()]={
			"type":fruit.type
		}
	var switch_data:={}
	for switch:Switch in get_tree().get_nodes_in_group("switches"):
		switch_data[switch.get_path()]={
			"toogled":switch.toogled
		}
		
	return {
		"player_position":player.global_position,
		"player_direction":player.direction,
		"enemies":enemies_data,
		"platforms":platform_data,
		"fruits":fruit_data,
		"switches":switch_data
	}

func setup_scene(data:Dictionary):
	for enemy:Enemy in get_tree().get_nodes_in_group("enemies"):
		
		if enemy.get_path() not in data["enemies"]:
			enemy.queue_free()
			continue
		enemy.status.health=data["enemies"][enemy.get_path()]["health"]
		enemy.global_position=data["enemies"][enemy.get_path()]["position"]
		enemy.direction=data["enemies"][enemy.get_path()]["direction"]
	for platform:NodePath in data["platforms"]:
		var plat:=get_node(platform) as Platform
		plat.set_stats(data["platforms"][platform]["velocity"],data["platforms"][platform]["position"])
	for fruit:Fruit in get_tree().get_nodes_in_group("fruits"):
		if fruit.get_path() not in data["fruits"]:
			fruit.queue_free()
			continue
		fruit.type=data["fruits"][fruit.get_path()]["type"]
	for switch:Switch in get_tree().get_nodes_in_group("switches"):
		if switch.get_path() not in data["switches"]:
			switch.queue_free()
			continue
		switch.toogled=data["switches"][switch.get_path()]["toogled"]
		switch.toogle() if switch.toogled else switch.untoogle()
	player.global_position=data["player_position"]
	player.direction=data["player_direction"]


	
