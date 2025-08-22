@tool
extends Puzzle
class_name Fan
@export var target_point:Vector2
var interface:EditorSelection
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	$RayCast2D.target_position=target_point
	if $RayCast2D.is_colliding():
		var player = get_tree().get_first_node_in_group("player") as Player
		player.velocity.y=move_toward(player.velocity.y,-500.0,4500*delta)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		interface= EditorInterface.get_selection()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_CTRL) and (self in interface.get_selected_nodes()):
			target_point=get_local_mouse_position()
