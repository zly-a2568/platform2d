extends Control

var toturial_list:Array[String]=[
	"按下键盘左右箭头键移动",
	"单次按下键盘空格键跳跃",
	"两次按下键盘空格可以二段跳",
	"按下键盘J键攻击",
	"按下键盘K键闪现",
	"按下键盘M键发射子弹",
	"遇到存档点可以按下键盘Enter键存档",
	"遇到传送门可以按下键盘Enter键传送至下一关",
	"按下键盘Esc键可以暂停游戏，
	还有，注意能量条的能量消耗
	"
]
const toturial_list_android:Array[String]=[
	"拖动摇杆移动",
	"单次按下绿色按键跳跃",
	"两次按下绿色按键可以二段跳",
	"按下红色按键攻击",
	"按下灰色按键闪现",
	"按下橙色按键发射子弹",
	"遇到存档点可以按下蓝色按键存档",
	"遇到传送门可以按下蓝色按键传送至下一关",
	"按下右上角齿轮按键可以暂停游戏，
	还有，注意能量条的能量消耗
	"
]
const video_list:Array=[
	preload("res://assets/show/run.ogv"),
	preload("res://assets/show/jump.ogv"),
	preload("res://assets/show/doublejump.ogv"),
	preload("res://assets/show/attack.ogv"),
	preload("res://assets/show/flash.ogv"),
	preload("res://assets/show/shoot.ogv"),
	preload("res://assets/show/save.ogv"),
	preload("res://assets/show/transport.ogv")
]

var index:int=0


func show_panel()->void:
	show()
	if OS.get_name()=="Android":
		toturial_list=toturial_list_android
	$VBoxContainer/Label.text=toturial_list[index]
	$VBoxContainer/PanelContainer/VideoStreamPlayer.play()
	


func _on_next_pressed() -> void:
	if index>=8:
		return
	$VBoxContainer/PanelContainer/VideoStreamPlayer.stop()
	index+=1
	$VBoxContainer/Label.text=toturial_list[index]
	if index<8:
		$VBoxContainer/PanelContainer/VideoStreamPlayer.stream=video_list[index]
		$VBoxContainer/PanelContainer/VideoStreamPlayer.play()
	else:
		$VBoxContainer/PanelContainer.queue_free()
	if index==8:
		$VBoxContainer/HBoxContainer/Skip.text="完成"
		$VBoxContainer/HBoxContainer/Next.queue_free()
	pass # Replace with function body.

func finish_introduce():
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)
	config.set_value("Run","is_first_run",true)
	config.save(GameProcesser.CONFIG_PATH)

func _on_skip_pressed() -> void:
	if index<8:
		if OS.get_name()!="Android":
			$ConfirmationDialog.show()
		else:
			finish_introduce()
			get_tree().current_scene.process_mode=Node.PROCESS_MODE_PAUSABLE
			get_parent().queue_free()
	else:
		finish_introduce()
		get_tree().current_scene.process_mode=Node.PROCESS_MODE_PAUSABLE
		get_parent().queue_free()
	pass # Replace with function body.


func _on_confirmation_dialog_confirmed() -> void:
	finish_introduce()
	get_tree().current_scene.process_mode=Node.PROCESS_MODE_PAUSABLE
	get_parent().queue_free()
	pass # Replace with function body.
