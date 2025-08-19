class_name Hitter
extends Area2D

signal hit(hurter:Hurter)

func _init():
	area_entered.connect(on_area_entered)

func on_area_entered(hurter:Hurter)->void:
	print("Hit:%s->%s"%[owner.name,hurter.owner.name])
	hit.emit(hurter)
	hurter.hurt.emit(self)
	
