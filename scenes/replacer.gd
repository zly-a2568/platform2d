extends Area2D
@export var to:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_body_entered(body: Node2D) -> void:
	body.global_position=to
	pass # Replace with function body.
