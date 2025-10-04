# line_segment.gd
@tool # 添加 @tool 使得该资源在编辑器中也能实时看到效果
class_name LineSegment extends Resource

@export var start: Vector2 = Vector2(0, 0)
@export var end: Vector2 = Vector2(100, 100)
@export var color: Color = Color.WHITE
@export var width: float = 1.0

# 可以添加一些便捷的方法
func length() -> float:
	return start.distance_to(end)

# 可选：如果你想在编辑器中也能直观地看到这个线段，可以绘制它
func _draw(canvas: CanvasItem) -> void:
	if Engine.is_editor_hint():
		canvas.draw_line(start, end, color, width)
