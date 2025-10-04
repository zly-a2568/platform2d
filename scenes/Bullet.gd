class_name Bullet
extends CharacterBody2D
@onready var sprite_2d = $Sprite2D


const SPEED = 400.0

func _physics_process(delta):
	
	sprite_2d.rotate(10)
	if is_on_wall():
		Fade()
	move_and_slide()



func Fade():
	var tween=create_tween()
	tween.tween_property(self,"modulate:a",0.0,0.2)
	tween=create_tween()
	tween.tween_property(self,"scale",Vector2(2.0,2.0),0.2)
	await tween.finished	
	queue_free()


	
