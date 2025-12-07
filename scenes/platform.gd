extends CharacterBody2D
class_name Platform
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

const SPEED=100.0
@export var v:Vector2
@export var limit:Rect2
@export var type:Type=Type.COLLISION
@export var can_fade:bool=false
@export var fading:bool=false
enum Type{
	COLLISION,
	BOUND
}

func set_stats(velocity:Vector2,pos:Vector2):
	global_position=pos
	v=velocity
	

func _physics_process(delta: float) -> void:
	if not fading:
		animation_player.play("idle")
	global_position+=v*delta
	if type==Type.BOUND:
		if not limit.has_point(position):
			v*=-1

func _process(delta: float) -> void:
	pass
func _on_ground_entered(body: Node2D) -> void:
	if body is Platform:
		return
	if type==Type.COLLISION and body is TileMap:
		v*=-1
	elif body is Player:
		if can_fade:
			await get_tree().create_timer(0.5).timeout
			fading=true
			animation_player.play("fade")
			
