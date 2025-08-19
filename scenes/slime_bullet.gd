class_name  Slime_Bullet
extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction:=1
var fading:bool=false

const SPEED = 200.0

func _ready() -> void:
	animation_player.play("flying")

func _physics_process(delta):
	sprite_2d.scale.x=direction *0.5
	if is_on_wall() or is_on_ceiling() or is_on_floor():
		Fade()
	move_and_slide()



func Fade():
	if fading:
		return
	fading=true
	velocity.x=0
	velocity.y=0
	animation_player.play("hit")



func _on_hitter_hit(hurter: Hurter) -> void:
	Fade()
