@tool
extends RayCast2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		target_position=owner.target_point
		var selection=EditorInterface.get_selection()
		if Input.is_key_pressed(KEY_SHIFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and ($".." in selection.get_selected_nodes()):
			$"..".target_point=$"..".get_local_mouse_position()
