extends CanvasLayer
@onready var panel: Control = $Panel
@onready var start: Button = $Panel/Panel/Start
@onready var new: Button = $Panel/Panel/New
@onready var setting_panel: Control = $SettingPanel

func _ready() -> void:
	get_window().set_input_as_handled()
	if not FileAccess.file_exists(GameProcesser.DATA_PATH):
		start.disabled=true
	for child in get_children():
		child=child as Button
		if child:
			child.mouse_entered.connect(func():
				child.grab_focus()
			)
	SoundManager.setup_ui_sounds(self)
	setting_panel.load_settings()
	setting_panel.apply_settings()
	new.grab_focus()
	
func hide_title():
	hide()

func show_title():
	show()

func _on_start_pressed() -> void:
	GameProcesser.load_data()
	var scene_file:String=GameProcesser.SceneFile[GameProcesser.current_scene]
	GameProcesser.load_game(scene_file)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_new_pressed() -> void:
	var file=ConfigFile.new()
	file.load(GameProcesser.CONFIG_PATH)
	var introduced=file.get_value("Run","introduced",false)
	if introduced:
		GameProcesser.new_game()
	else:
		GameProcesser.change_scene("res://scenes/tutorial.tscn")




func _process(delta: float) -> void:
	pass

func _on_settings_pressed() -> void:
	$SettingPanel.open_panel()
