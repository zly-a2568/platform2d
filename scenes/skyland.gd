extends World

func _on_player_entered_boundary(body: Node2D) -> void:
	if body is Player:
		var pl:Player=body as Player
		pl.status.health=0
	if body is Enemy:
		var en:Enemy=body as Enemy
		en.status.health=0
