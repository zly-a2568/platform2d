extends Node2D

var finger_idx:int=-1
var origin_pos:Vector2=Vector2(0.0,0.0)
var fg_offset:Vector2=Vector2(0.0,0.0)

func _ready() -> void:
	origin_pos=position

func _input(event: InputEvent) -> void:
	var evt=event as InputEventScreenTouch
	if evt:
		if evt.pressed and finger_idx==-1:
			if evt.position.x<=get_viewport_rect().size.x/2:
				finger_idx=evt.index
				fg_offset=evt.position-position
		else:
			if finger_idx==evt.index:
				finger_idx=-1
				position=origin_pos
				Input.action_release("ui_left")
				Input.action_release("ui_right")
			
	var evt1=event as InputEventScreenDrag
	if evt1:
		if not evt1.index==finger_idx:
			return
		var pos=evt1.position-fg_offset
		var movement:Vector2=(pos-origin_pos).limit_length(15.0)
		position=origin_pos+movement
		
		movement=movement.normalized()
		if movement.x>0:
			Input.action_release("ui_left")
			Input.action_press("ui_right",abs(movement.x))
		if movement.x<0:
			Input.action_release("ui_right")
			Input.action_press("ui_left",abs(movement.x))
