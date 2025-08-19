extends World


func _on_dead_line_body_entered(body: Node2D) -> void:
	if body is Player:
		body.status.health=0
	pass # Replace with function body.


func _on_not_allow_flash_body_entered(body: Node2D) -> void:
	if body is Player:
		body.disable_flash()
		GameProcesser.message_send("此区域禁止闪现")
	pass # Replace with function body.

func _on_not_allow_flash_body_exited(body: Node2D) -> void:
	if body is Player:
		body.enable_flash()
		GameProcesser.message_send("闪现恢复")
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.controlled=false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body.controlled=true
