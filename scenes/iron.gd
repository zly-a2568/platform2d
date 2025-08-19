extends World

var portal_lock:bool=true
var toogle_times:Array=[]

func _process(delta: float) -> void:
	if player.position.y>=361.0:
		player.status.health=0
	for enemy:Enemy in $Enemies.get_children():
		if enemy.position.y>=361.0:
			enemy.status.health=0
	if portal_lock:
		$Portals/Portal2.set_process_input(false)
		$Portals/Portal2.modulate.a=0.5
		for child:Switch in $Switches.get_children():
			toogle_times.append(child.toogled)
		if not false in toogle_times:
			$Portals/Portal2.modulate.a=1.0
			$Portals/Portal2.set_process_input(true)
			portal_lock=false
		toogle_times=[]
	else:
		for child:Switch in $Switches.get_children():
			toogle_times.append(child.toogled)
		if false in toogle_times:
			portal_lock=true
		toogle_times=[]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameProcesser.message_send("无敌时间将缩短！")
		player.super_time.wait_time=2.0
	pass # Replace with function body.


func _on_area_body_exited(body: Node2D) -> void:
	if body is Player:
		GameProcesser.message_send("无敌时间已恢复！")
		player.super_time.wait_time=4.0
	pass # Replace with function body.



func _on_portal_2_body_entered(body: Node2D) -> void:
	if body is Player and portal_lock:
		GameProcesser.message_send("打开所有开关，传送门才会出现！")
