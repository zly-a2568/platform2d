extends Label

var num:int=0
var velocity:Vector2=Vector2(0,0)
var origin_pos:Vector2


func _ready() -> void:
	velocity=Vector2(randi_range(-1,1)*randf_range(0,30),randf_range(-150,-300))
	text=str(num)
	origin_pos=position
	var tween=create_tween()
	tween.tween_property(self,"modulate:a",0.0,1.0)

func _physics_process(delta: float) -> void:
	position+=velocity*delta
	velocity+=Vector2(0.0,9.8)
	if (origin_pos-position).length()>=100:
		queue_free()
