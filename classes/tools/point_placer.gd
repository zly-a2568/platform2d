@tool
extends Node

@export var target_point:Vector2
var parent_path:NodePath
@export var propertry_name:StringName:
	set(v):
		propertry_name=v
		if not get_parent():
			return
		if get_parent().get(v) is Vector2:
			target_point=get_parent().get(v)
@export var listening_node:Node
var interface:EditorSelection


func _get_configuration_warnings():
	if not get_parent() is Node2D:
		return ["需要把此节点放于Node2D下使用"]

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if get_parent().get_path()!=parent_path:
			parent_path=get_parent().get_path()
			update_configuration_warnings()
		
		interface= EditorInterface.get_selection()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_SHIFT) and (listening_node in interface.get_selected_nodes()):
			var parent = get_parent() as Node2D
			if parent:
				target_point=parent.get_local_mouse_position()
				if parent.get(propertry_name) is Vector2:
					parent.set(propertry_name,target_point)
