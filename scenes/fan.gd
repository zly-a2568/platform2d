extends Puzzle
class_name Fan
@export var target_point:Vector2

func _ready() -> void:
	$RayCast2D.target_position=target_point
	$RayCast2D2.target_position=target_point
	$RayCast2D3.target_position=target_point
	$wind.scale.y=int(target_point.y/28.0)
	var mat:=$wind.material as ShaderMaterial
	mat.set_shader_parameter("vertical_tiles",int(-target_point.y/5.0))
	$wind.position.y=target_point.y/2
	$wind.show()

func _physics_process(delta: float) -> void:
	if $RayCast2D.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D3.is_colliding():
		var player = get_tree().get_first_node_in_group("player") as Player
		player.velocity.y=move_toward(player.velocity.y,-500.0,4500*delta)
