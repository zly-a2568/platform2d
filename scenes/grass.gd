extends World

var introduced:bool=false

func _ready() -> void:
	super()
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)
	introduced=config.get_value("Run","is_first_run",false)
	if not introduced:
		goto_toturial()	
	else:
		$ToturialLayer/TutorialPanel.queue_free()

func goto_toturial():
	await get_tree().create_timer(1.0).timeout
	get_tree().current_scene.process_mode=Node.PROCESS_MODE_DISABLED
	$ToturialLayer/TutorialPanel.show_panel()
