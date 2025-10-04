class_name Switch
extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var entering:bool=false
@export var toogled:bool=false
signal enter()
signal exit()

func toogle():
	animation_player.play("toogle")
	SoundManager.play_sfx("Focus")
func untoogle():
	animation_player.play("untoogle")
	SoundManager.play_sfx("Focus")

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter") and entering:
		if not toogled:
			toogle()
			toogled=true
		else:
			untoogle()
			toogled=false


func _on_player_entered(body: Node2D) -> void:
	if body is Player:
		entering=true
		enter.emit()
	pass # Replace with function body.


func _on_player_exited(body: Node2D) -> void:
	if body is Player:
		entering=false
		exit.emit()
	pass # Replace with function body.
