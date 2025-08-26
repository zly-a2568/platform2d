extends Control

const SETTING_FILE="user://config.ini"
var is_guichu:bool=false
var introduced:bool=false
var knob_sensitivity:float=1.0
var settings=ConfigFile.new()
var update_downloading:bool=false
var ver:String

func _ready() -> void:
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)

func load_settings():
	settings.load(SETTING_FILE)
	introduced=settings.get_value("Run","introduced",false)
	knob_sensitivity=settings.get_value("Settings","knob_sensitivity",1.0)
	is_guichu=settings.get_value("Settings","is_guichu",false)
	$VBoxContainer/GridContainer/HSlider2.value=knob_sensitivity
	$VBoxContainer/GridContainer/CheckButton.button_pressed=is_guichu
func apply_settings():
	var settings=ConfigFile.new()
	settings.load(SETTING_FILE)
	settings.set_value("Settings","is_guichu",is_guichu)
	settings.save(SETTING_FILE)
	(SoundManager.get_node("BGM/GameOver") as AudioStreamPlayer).stream=preload("res://assets/bgm/Turn All The Lights On.mp3") if is_guichu else preload("res://assets/bgm/game_over.mp3")
	(SoundManager.get_node("SFX/Hurt") as AudioStreamPlayer).stream=preload("res://assets/sfx/niganma.mp3") if is_guichu else preload("res://assets/sfx/hurt.mp3")
	(SoundManager.get_node("SFX/Slash") as AudioStreamPlayer).stream=preload("res://assets/sfx/zhiyin.ogg") if is_guichu else preload("res://assets/sfx/07_human_atk_sword_1.ogg")
	(SoundManager.get_node("SFX/Attack") as AudioStreamPlayer).stream=preload("res://assets/sfx/ahha.ogg") if is_guichu else preload("res://assets/sfx/attack1.mp3")
	(SoundManager.get_node("SFX/Flash") as AudioStreamPlayer).stream=preload("res://assets/sfx/zhiyin.ogg") if is_guichu else preload("res://assets/sfx/flash.mp3")
	
func open_panel():
	show()
	$VBoxContainer/Exit.grab_focus()
	load_settings()
	

	
	



func _on_h_slider_2_value_changed(value: float) -> void:
	knob_sensitivity=value
	settings.set_value("Settings","knob_sensitivity",knob_sensitivity)
	settings.save(SETTING_FILE)



func _on_h_slider_2_drag_ended(value_changed: bool) -> void:
	if not introduced:
		GameProcesser.message_send("此设置在教程关卡不起效")

func _on_exit_pressed() -> void:
	hide()
	(self.get_parent().get_node("Panel/Panel/Settings") as Button).grab_focus()


func _on_check_button_pressed() -> void:
	SoundManager.play_sfx("Press")
	is_guichu=$VBoxContainer/GridContainer/CheckButton.button_pressed
	apply_settings()


func _on_button_pressed() -> void:
	if OS.get_name()=="Android":
		get_parent().get_node("JoyPadEditable").open_panel()
	else:
		get_parent().get_node("KeyBoardSettings").open_panel()


func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_check_update_pressed() -> void:
	if OS.get_name()!="Windows":
		OS.alert("此功能目前仅对Windows开放")
		return
	OS.alert("需要加速器")
	$VBoxContainer/HBoxContainer/CheckUpdate.disabled=true
	var error = $VersionCheck.request("https://gh-proxy.net/https://github.com/zly-a1/platform/releases/latest/download/version-note.txt")
	print(error)
		
	pass # Replace with function body.


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	var remote_version=body.get_string_from_utf8().substr(1)
	ver=remote_version
	var current_version=ProjectSettings.get_setting("application/config/version") as String
	var cur_ver_array=current_version.split(".")
	var rem_ver_array=remote_version.split(".")
	for a in range(3):
		if int(rem_ver_array[a])>int(cur_ver_array[a]):
			print("update avivable")
			$ExecutableDownload.download_file="user://win.zip"
			if OS.get_name()=="Windows":
				$ExecutableDownload.request("https://gh-proxy.net/https://github.com/zly-a1/platform/releases/latest/download/windows-x64.zip")
				update_downloading=true
				var downloaded:=Label.new()
				downloaded.name="downloaded"
				$VBoxContainer/HBoxContainer.add_child(downloaded)
			return
	pass
	
func _process(delta: float) -> void:
	if update_downloading:
		$VBoxContainer/HBoxContainer.get_node("downloaded").text=str($ExecutableDownload.get_downloaded_bytes()/1000/1000)+"MB"

func _on_executable_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	ProjectSettings.set_setting("application/config/version",ver)
	$VBoxContainer/HBoxContainer/CheckUpdate.disabled=false
	$VBoxContainer/HBoxContainer.get_node("downloaded").queue_free()
	update_downloading=false
	OS.alert("请到数据文件夹查看安装包")
	pass # Replace with function body.
