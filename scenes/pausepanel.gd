class_name PausePanel
extends Control
@onready var quit = $V/Actions/H/Quit
@onready var resume = $V/Actions/H/Resume

var can_show:bool=true

	
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	visibility_changed.connect(func():
		get_tree().paused=visible
		resume.grab_focus()
	)
	for child in get_children():
		child = child as Button
		if child:
			child.mouse_entered.connect(func():
				child.grab_focus()
			)
	


func show_panel():
	if GameProcesser.tween_started:
		return
	GameProcesser.stop_game()
	show()
func close_panel():
	GameProcesser.resume_game()
	hide()
	get_window().set_input_as_handled()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close_panel()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	





func _on_resume_pressed():
	close_panel()
	pass # Replace with function body.


func _on_quit_pressed():
	close_panel()
	GameProcesser.back_to_title()
	pass # Replace with function body.


func _on_player_died():
	can_show=false
	pass # Replace with function body.
