extends CharacterBody2D
class_name Fruit

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum FruitType{
	HEALTH,
	ENERGY
}
@export var type:FruitType=FruitType.HEALTH

var tween_started:bool=false

func _ready() -> void:
	match type:
		FruitType.HEALTH:
			animated_sprite_2d.animation="apple"
		FruitType.ENERGY:
			animated_sprite_2d.animation="banana"

func _process(delta: float) -> void:
	var player:=get_tree().get_first_node_in_group("player") as Player
	if player and (global_position-player.global_position).length()<=20:
		if tween_started:
			return
		tween_started=true
		SoundManager.play_sfx("GetFruit")
		match type:
			FruitType.HEALTH:
				player.status.health+=1
			FruitType.ENERGY:
				player.status.energy+=20
		animated_sprite_2d.animation="collected"
		await animated_sprite_2d.animation_finished
		queue_free()
