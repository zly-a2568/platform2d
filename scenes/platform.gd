extends CharacterBody2D
class_name Platform
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

const SPEED=100.0
@export var v:Vector2
@export var limit:Rect2
@export var type:Type=Type.COLLISION
enum Type{
	COLLISION,
	BOUND
}

func set_stats(velocity:Vector2,pos:Vector2):
	global_position=pos
	v=velocity
	

func _physics_process(delta: float) -> void:
	animation_player.play("idle")
	global_position+=v*delta
	if type==Type.BOUND:
		if not limit.has_point(position):
			v*=-1

func _process(delta: float) -> void:
	pass
func _on_ground_entered(body: Node2D) -> void:
	if type==Type.COLLISION and not body is Player and not body is Enemy:
		v*=-1
