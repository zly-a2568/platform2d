extends World


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player.status.health=0
	pass # Replace with function body.
