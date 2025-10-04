extends Area2D
class_name Portal
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal enter()
signal exit()

var entering:bool=false
@export var target_world:String

func _process(delta: float) -> void:
	animation_player.play("shine")
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter") and entering:
		GameProcesser.load_game(target_world)



func _on_player_entered(body: Node2D) -> void:
	if body is Player:
		entering=true
		enter.emit()


func _on_player_exited(body: Node2D) -> void:
	if body is Player:
		entering=false
		exit.emit()
	pass # Replace with function body.
