extends Control

const SETTING_FILE="user://config.ini"
var is_guichu:bool=false
var introduced:bool=false
var knob_sensitivity:float=1.0
var settings=ConfigFile.new()
var update_downloading:bool=false
var update_source:String
var ver:String

func _ready() -> void:
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)

func load_settings():
	settings.load(SETTING_FILE)
	introduced=settings.get_value("Run","is_first_run",false)
	update_source=settings.get_value("Settings","update_source","gitee")
	ProjectSettings.set_setting("application/config/version",settings.get_value("Run","version","1.0.1"))
	knob_sensitivity=settings.get_value("Settings","knob_sensitivity",1.0)
	is_guichu=settings.get_value("Settings","is_guichu",false)
	$VBoxContainer/ScrollContainer/GridContainer/HSlider2.value=knob_sensitivity
	$VBoxContainer/ScrollContainer/GridContainer/CheckButton.button_pressed=is_guichu
func apply_settings():
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





func _on_exit_pressed() -> void:
	hide()
	(self.get_parent().get_node("Panel/Panel/Settings") as Button).grab_focus()


func _on_check_button_pressed() -> void:
	SoundManager.play_sfx("Press")
	is_guichu=$VBoxContainer/ScrollContainer/GridContainer/CheckButton.button_pressed
	apply_settings()


func _on_button_pressed() -> void:
	#get_parent().get_node("JoyPadEditable").open_panel()
	#return
	if OS.get_name()=="Android":
		get_parent().get_node("JoyPadEditable").open_panel()
	else:
		get_parent().get_node("KeyBoardSettings").open_panel()


func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_check_update_pressed() -> void:
	if OS.get_name()!="Android" and OS.get_name()!="Windows":
		OS.alert("暂时仅对Windows和Android开放")
		return
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.disabled=true
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.text="检查中"
	$VBoxContainer/Exit.disabled=true
	var update_url:String
	if update_source=="github":
		update_url="https://github.com/zly-a1/platform/releases/download/latest/version-note.txt"
	else:
		update_url="https://gitee.com/zly-k/platformer2d/releases/download/latest/version-note.txt"
	var error = $VersionCheck.request(update_url)
	print(error)
		
	pass # Replace with function body.


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result!=HTTPRequest.RESULT_SUCCESS:
		print("网络请求错误：",result)
		fail_update()
		return
	var remote_version=body.get_string_from_utf8().substr(1)
	ver=remote_version
	var current_version=ProjectSettings.get_setting("application/config/version") as String
	var cur_ver_array=current_version.split(".")
	var rem_ver_array=remote_version.split(".")
	if OS.get_name()!="Android":
		for a in range(3):
			if int(rem_ver_array[a])>int(cur_ver_array[a]):
				print("update avivable")
				if OS.get_name()!="Android":
					$ExecutableDownload.download_file=OS.get_executable_path().get_base_dir()+"/platform2d.pck"
					var update_url:String
					if update_source=="github":
						update_url="https://github.com/zly-a1/platform/releases/download/latest/platform2d.pck"
					else:
						update_url="https://gitee.com/zly-k/platformer2d/releases/download/latest/platform2d.pck"
					$ExecutableDownload.request(update_url)
					
					update_downloading=true
					return
				else:
					var download_dir:=OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/platform"
					if not DirAccess.dir_exists_absolute(download_dir):
						if DirAccess.make_dir_recursive_absolute(download_dir)!=OK:
							fail_update()
							return
					var download_package=download_dir+"platform2d.apk"
					$ExecutableDownload.download_file=download_package
					var update_url:String
					if update_source=="github":
						update_url="https://github.com/zly-a1/platform/releases/download/latest/platform2d.apk"
					else:
						update_url="https://gitee.com/zly-k/platformer2d/releases/download/latest/platform2d.apk"
					$ExecutableDownload.request(update_url)
					update_downloading=true
					return
	OS.alert("已是最新版本","提示")
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.disabled=false
	$VBoxContainer/Exit.disabled=false
	pass
	
func _process(delta: float) -> void:
	if update_downloading:
		$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.text=str($ExecutableDownload.get_downloaded_bytes()/1000/1000)+"MB"

func _on_executable_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.text="检查"
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.disabled=false
	$VBoxContainer/Exit.disabled=false
	update_downloading=false
	if result==HTTPRequest.RESULT_SUCCESS:
		ProjectSettings.set_setting("application/config/version",ver)
		settings.set_value("Run","version",ProjectSettings.get_setting("application/config/version") as String)
		settings.save(GameProcesser.CONFIG_PATH)
		if OS.get_name()=="Android":
			var downloaded_file:=OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/platform/platform2d.apk"
			OS.shell_open(downloaded_file)
			OS.alert("更新完成，请重启","提示")
			get_tree().quit()
	else:
		fail_update()
		return
	
	pass # Replace with function body.

func fail_update():
	OS.alert("更新失败","警告")
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.text="检查"
	$VBoxContainer/ScrollContainer/GridContainer/CheckUpdate.disabled=false
	$VBoxContainer/Exit.disabled=false

func _on_option_button_item_selected(index: int) -> void:
	if index==0:
		update_source="github"
	elif index==1:
		update_source="gitee"
	pass # Replace with function body.
