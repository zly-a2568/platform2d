extends Puzzle

@export var amount:float=650

var direction:Vector2=Vector2(0.0,1.0)

var jumping:bool=false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
	direction=Vector2(cos(rotation-PI/2),sin(rotation-PI/2))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player.play("jump")
		SoundManager.play_sfx("Focus")
		(body as Player).velocity=direction*amount


func test(body: Node2D) -> void:
	if body is Player:
		#get_tree().paused=true
		pass
