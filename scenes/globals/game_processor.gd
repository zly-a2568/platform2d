extends Node
@onready var color_rect = $ColorRect


var GAME_VERSION="1.0.3.3"


const CONFIG_PATH="user://config.ini"
const DATA_PATH = "user://scenedata.tres"
const KEYMAP_PATH = "user://keymap.tres"
signal fix_camera

var tween_started:bool=false
var message_started:bool=false
var message_list:Array[String]=[]

var scene_data:Dictionary={}
var player_status:Dictionary={
	"health":20,
	"energy":100.0
}

var current_scene:String=""

const SceneFile:Dictionary={
	"grass":"res://scenes/grass.tscn",
	"purple":"res://scenes/purple.tscn",
	"skyland":"res://scenes/skyland.tscn",
	"iron":"res://scenes/iron.tscn",
	"gold":"res://scenes/gold.tscn",
	"cooper":"res://scenes/cooper.tscn",
	"snow":"res://scenes/snow.tscn"
}

signal camera_shock(amount:float)

@onready var tip: Label = $Tip

func _init() -> void:
	
	if OS.get_name()=="Android" or OS.get_name()=="Windows" and not Engine.is_editor_hint():
		if FileAccess.file_exists("user://update.pck"):
			print(ProjectSettings.load_resource_pack("user://update.pck"))
			GAME_VERSION=(load("res://version_info.res") as VersionInfo).version
			print(GAME_VERSION)

func _ready():
	if OS.get_name()=="Android":
		OS.request_permissions()
	load_data()
	color_rect.hide()
	load_config()
	#get_window().min_size=Vector2i(1024,648)
	
func get_game_version()->String:
	return GAME_VERSION

func change_scene(path:String):
	if tween_started or message_started:
		return
	tween_started=true
	message_list.clear()
	set_process(false)
	var tree=get_tree()
	tree.paused=true
	color_rect.show()
	var tween=create_tween()
	tween.tween_property(color_rect,"color:a",1,0.5)
	await  tween.finished
	tree.change_scene_to_file(path)
	await tree.tree_changed
	tree.paused=false
	tween=create_tween()
	tween.tween_property(color_rect,"color:a",0,0.5)
	await tween.finished
	tween_started=false
	color_rect.hide()

func save_config():
	var file=ConfigFile.new()
	file.load(CONFIG_PATH)
	file.set_value("Audio","master",SoundManager.get_volume(SoundManager.Bus.MASTER))
	file.set_value("Audio","sfx",SoundManager.get_volume(SoundManager.Bus.SFX))
	file.save(CONFIG_PATH)
	
func load_config():
	var file=ConfigFile.new()
	file.load(CONFIG_PATH)
	SoundManager.set_volume(SoundManager.Bus.MASTER,file.get_value("Audio","master",0.5))
	SoundManager.set_volume(SoundManager.Bus.SFX,file.get_value("Audio","sfx",1.0))

func is_first_run()->bool:
	var config=ConfigFile.new()
	config.load(CONFIG_PATH)
	return config.get_value("Run","is_first_run",true)

func shake_camera(amount:float):
	camera_shock.emit(amount)




func stop_game():
	var node=get_tree().current_scene
	if node:
		stop(node)

func resume_game():
	
	var node=get_tree().current_scene
	if node:
		resume(node)

func load_keymap():
	var key_map=KeyMapData.new() if not FileAccess.file_exists(KEYMAP_PATH) else ResourceLoader.load(KEYMAP_PATH) as KeyMapData
	for action in key_map.keymap.keys():
		var input_event:=InputEventKey.new()
		input_event.keycode=key_map.keymap[action]
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action,input_event)

func _process(delta):
	if not message_list.is_empty():
		if message_started:
			return
		message_started=true
		var str=message_list[0]
		tip.modulate.a=1.0
		tip.text=str
		tip.visible_characters=0
		var tween=create_tween()
		tween.tween_property(tip,"visible_characters",str.length(),0.2)
		await get_tree().create_timer(1.0).timeout
		tween=create_tween()
		tween.tween_property(tip,"modulate",Color(1.0,1.0,1.0,0.0),0.2)
		await tween.finished
		message_list.pop_at(0)
		message_started=false


func resume(node:Node):
	var pausepanel:=node as PausePanel
	if not pausepanel:
		node.process_mode=Node.PROCESS_MODE_INHERIT
	else:
		return
	for child in node.get_children():
		resume(child)

func stop(node:Node):
	var pausepanel:=node as PausePanel
	if not pausepanel:
		node.process_mode=Node.PROCESS_MODE_DISABLED
	else:
		return
	for child in node.get_children():
		stop(child)

func back_to_title():
	change_scene("res://scenes/title_screen.tscn")

func save_game():
	var player:=get_tree().get_first_node_in_group("player") as Player
	var sav_scene:String=get_tree().current_scene.scene_file_path.get_basename().get_file()
	var data:=SceneData.new()
	data.current_scene=sav_scene
	data.player_status={
		"health":player.status.health,
		"energy":player.status.energy
	}
	scene_data[sav_scene]=get_tree().current_scene.packdata()
	data.scenes=scene_data
	ResourceSaver.save(data,DATA_PATH)

func load_game(path:String):
	if not current_scene:
		return
	if tween_started or message_started:
		return
	tween_started=true
	message_list.clear()
	var tree=get_tree()
	tree.paused=true
	color_rect.show()
	var tween=create_tween()
	tween.tween_property(color_rect,"color:a",1,0.5)
	await  tween.finished
	if tree.current_scene is World:
		var player:=tree.get_first_node_in_group("player") as Player
		var old_scene:String=tree.current_scene.scene_file_path.get_basename().get_file()
		scene_data[old_scene]=tree.current_scene.packdata()
		player_status["health"] = player.status.health
		player_status["energy"] = player.status.energy
	
	tree.change_scene_to_file(path)
	await tree.tree_changed
	await tree.current_scene!=null
	
	
	if tree.current_scene is World:
		var new_scene:String=tree.current_scene.scene_file_path.get_basename().get_file()
		current_scene=new_scene
		if new_scene in scene_data.keys():
			tree.current_scene.setup_scene(scene_data[new_scene])
			var player:=tree.get_first_node_in_group("player") as Player
			player.status.health=player_status["health"]
			player.status.energy=player_status["energy"]
	
	camera_fix()
	tree.paused=false
	tween=create_tween()
	tween.tween_property(color_rect,"color:a",0,0.5)
	await tween.finished
	tween_started=false
	color_rect.hide()

func reload_game():
	if tween_started:
		return
	tween_started=true
	var tree=get_tree()
	tree.paused=true
	color_rect.show()
	var tween=create_tween()
	tween.tween_property(color_rect,"color:a",1,0.5)
	await  tween.finished
	load_data()
	var old_scene:String=SceneFile[current_scene]
	
	tree.change_scene_to_file(old_scene)
	await tree.tree_changed
	await tree.current_scene!=null
	
	
	
	if tree.current_scene is World:
		var new_scene:String=tree.current_scene.scene_file_path.get_basename().get_file()
		current_scene=new_scene
		if new_scene in scene_data.keys():
			tree.current_scene.setup_scene(scene_data[new_scene])
			var player:=tree.get_first_node_in_group("player") as Player
			player.status.health=player_status["health"]
			player.status.energy=player_status["energy"]
	
	camera_fix()
	tree.paused=false
	tween=create_tween()
	tween.tween_property(color_rect,"color:a",0,0.5)
	await tween.finished
	tween_started=false
	color_rect.hide()

func new_game():
	if tween_started:
		return
	tween_started=true
	if FileAccess.file_exists(DATA_PATH):
		DirAccess.open(DATA_PATH.get_base_dir()).remove(DATA_PATH.get_file())
	
	var tree=get_tree()
	tree.paused=true
	color_rect.show()
	var tween=create_tween()
	tween.tween_property(color_rect,"color:a",1,0.5)
	await  tween.finished
	tree.change_scene_to_file("res://scenes/grass.tscn")
	await tree.tree_changed
	await tree.current_scene!=null
	scene_data={}
	player_status={
		"health":20,
		"energy":100.0
	}
	current_scene=tree.current_scene.scene_file_path.get_basename().get_file()
	var player:=tree.get_first_node_in_group("player") as Player
	player.status.health=player_status["health"]
	player.status.energy=player_status["energy"]
	camera_fix()
	tree.paused=false
	tween=create_tween()
	tween.tween_property(color_rect,"color:a",0,0.5)
	await tween.finished
	tween_started=false
	color_rect.hide()

func change_world():
	pass

func camera_fix():
	fix_camera.emit()

func load_data():
	if FileAccess.file_exists(DATA_PATH):
		var data:=ResourceLoader.load(DATA_PATH) as SceneData
		scene_data=data.scenes
		player_status=data.player_status
		current_scene=data.current_scene
	else:
		scene_data={}
		player_status={
			"health":20,
			"energy":100.0
		}
		current_scene="grass"

func message_send(str: String):
	message_list.append(str)
	
