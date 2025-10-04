extends Enemy

enum State{
	IDLE,
	WALK,
	HURT,
	DYING,
	ATTACK
}
@onready var wall: RayCast2D = $Graphics/Wall
@onready var floorchker: RayCast2D = $Graphics/Floor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback =animation_tree.get("parameters/playback")

var is_hurt:bool=false
var can_hurt:bool=true
var back_direction:int=0
var bullet=preload("res://scenes/slime_bullet.tscn")
var lock_turn:bool=false
var lock2_turn:bool=false


func _ready() -> void:
	add_to_group("enemies")
	
func _process(delta: float) -> void:
	super(delta)

func _on_hurter_hurt(hitter):
	super(hitter)
	if can_hurt:
		GameProcesser.shake_camera(5.0)
		hurt_back(hitter.owner)
		state_chart.send_event("hurt")
	


func _on_on_walk_taken() -> void:
	animation_state.travel("walk")
	pass # Replace with function body.


func _on_living_state_physics_processing(delta: float) -> void:
	if status.health<=0:
		state_chart.send_event("dying")
	if player_checker.is_colliding() and not$StateChart/Root/Living/Hurt.active and not $StateChart/Root/Living/Shoot.active:
		state_chart.send_event("shoot")
	if is_on_floor():
		velocity.y=0
	else:
		velocity.y+=default_gravity*delta
	move_and_slide()
	floorchker.force_raycast_update()
	player_checker.force_raycast_update()
	wall.force_raycast_update()
	pass # Replace with function body.


func _on_on_shoot_taken() -> void:
	if lock2_turn:
		$Graphics/Hurter/CollisionShape2D.set_deferred("disabled",false)
		can_hurt=true
		lock2_turn=false
	animation_state.travel("walk")
	var playerposX:=(get_tree().get_first_node_in_group("player") as Player).global_position.x
	direction=-1 if playerposX<global_position.x else 1
	pass # Replace with function body.


func _on_on_dying_taken() -> void:
	animation_state.travel("dying")
	$StateChart/Root/Dying/DyingTimer.start()
	pass # Replace with function body.


func _on_on_hurt_taken() -> void:
	SoundManager.play_sfx("Hurt")
	animation_state.travel("hurt")
	status.health-=1
	$Graphics/Hurter/CollisionShape2D.set_deferred("disabled",true)
	
	lock2_turn=true
	can_hurt=false
	pass # Replace with function body.


func _on_walk_state_physics_processing(delta: float) -> void:
	if wall.is_colliding() or not floorchker.is_colliding():
		velocity.x=0
		lock_turn=true
		state_chart.send_event("idle")
	velocity.x = move_toward(velocity.x, SPEED * direction, acceleration * delta)
	pass # Replace with function body.


func _on_shoot_state_entered() -> void:
	shoot()
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	velocity.x=0
	animation_state.travel("idle")
	if lock_turn and is_on_floor():
		direction*=-1
		lock_turn=false
		
	pass # Replace with function body.


func _on_on_idle_taken() -> void:
	animation_state.travel("idle")
	pass # Replace with function body.


func _on_dying_state_physics_processing(delta: float) -> void:
	if $StateChart/Root/Dying/DyingTimer.is_stopped():
		queue_free()
	pass # Replace with function body.

func shoot():
	var bullet_inst:=bullet.instantiate() as Slime_Bullet
	bullet_inst.velocity.x=direction*bullet_inst.SPEED
	bullet_inst.global_position=global_position
	get_tree().current_scene.add_child(bullet_inst)
	


func _on_end_shoot_taken() -> void:
	pass # Replace with function body.
