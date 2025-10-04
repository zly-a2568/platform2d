extends Puzzle
class_name Fan
@export var target_point:Vector2

func _ready() -> void:
	$RayCast2D.target_position=target_point

func _physics_process(delta: float) -> void:
	if $RayCast2D.is_colliding():
		var player = get_tree().get_first_node_in_group("player") as Player
		player.velocity.y=move_toward(player.velocity.y,-500.0,4500*delta)
