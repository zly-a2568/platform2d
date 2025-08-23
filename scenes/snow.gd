extends World

func _ready() -> void:
	super()
	var player:=get_tree().get_first_node_in_group("player") as Player
	player.GROUND_ACCELERATION=700
	player.AIR_ACCELERATION=2500
	player.JUMP_VELOCITY=-350
func _exit_tree() -> void:
	player.GROUND_ACCELERATION=1500
	player.AIR_ACCELERATION=3000
	player.JUMP_VELOCITY=-380

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player.status.health=0
	pass # Replace with function body.
