extends Node2D

@onready var background = $Background
@onready var map = $map
@onready var camera_2d = $player/PlayerCamera
@onready var player: CharacterBody2D = $player

var portal_entering:bool=false




# Called when the node enters the scene tree for the first time.
func _ready():
	SoundManager.setup_ui_sounds(self)
	var rect =background.get_rect()
	camera_2d.limit_left=rect.position.x
	camera_2d.limit_right=rect.end.x
	camera_2d.limit_top=rect.position.y
	camera_2d.limit_bottom=rect.end.y
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()
	for child in player.key_map as Dictionary:
		player.key_map[child]=true

func _on_player_entered(body: Node2D) -> void:
	if body.get_path()==player.get_path():
		portal_entering=true
	pass


func _on_player_exited(body: Node2D) -> void:
	if body.get_path()==player.get_path():
		portal_entering=false
	pass # Replace with function body.

func _process(delta: float) -> void:
	if portal_entering and Input.is_action_just_pressed("enter"):
		var file = ConfigFile.new()
		file.load(GameProcesser.CONFIG_PATH)
		file.set_value("Run", "introduced", true)
		file.save(GameProcesser.CONFIG_PATH)

		GameProcesser.new_game()
