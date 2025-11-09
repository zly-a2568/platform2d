extends Enemy

signal found()

enum State{
	IDLE,
	WALK,
	RUN,
	HURT,
	DYING
}
@onready var calmdown_timer = $CalmdownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var player_checker = $Graphics/PlayerChecker
@onready var floorchker = $Graphics/Floor
@onready var wall = $Graphics/Wall
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


var is_hurt:bool=false
var can_hurt:bool=true
var back_direction:int=0


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
	if $Graphics/Wall.is_colliding() or not $Graphics/Floor.is_colliding():
		if is_on_floor():
			direction*=-1 
			if $StateChart/Root/Living/Walk.active:
				state_chart.send_event("idle")
	if status.health<=0:
		state_chart.send_event("dying")
	if player_checker.is_colliding() and not$StateChart/Root/Living/Hurt.active:
		state_chart.send_event("run")
	if is_on_floor():
		velocity.y=0
	else:
		velocity.y+=default_gravity*delta
	move_and_slide()
	floorchker.force_raycast_update()
	player_checker.force_raycast_update()
	wall.force_raycast_update()
	pass # Replace with function body.


func _on_on_run_taken() -> void:
	$Graphics/Hurter/CollisionShape2D.set_deferred("disabled",false)
	$Graphics/Hurter/CollisionShape2D2.set_deferred("disabled",false)
	can_hurt=true
	animation_state.travel("run")
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
	$Graphics/Hurter/CollisionShape2D2.set_deferred("disabled",true)
	can_hurt=false
	pass # Replace with function body.


func _on_walk_state_physics_processing(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * direction, acceleration * delta)
	pass # Replace with function body.


func _on_run_state_physics_processing(delta: float) -> void:
	floorchker.force_raycast_update()
	wall.force_raycast_update()
	player_checker.force_raycast_update()
	velocity.x = move_toward(velocity.x, MAX_SPEED * direction, acceleration * delta)
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	floorchker.force_raycast_update()
	wall.force_raycast_update()
	player_checker.force_raycast_update()
	velocity.x=0
	animation_state.travel("idle")
		
	pass # Replace with function body.


func _on_on_idle_taken() -> void:
	animation_state.travel("idle")
	pass # Replace with function body.


func _on_dying_state_physics_processing(delta: float) -> void:
	if $StateChart/Root/Dying/DyingTimer.is_stopped():
		queue_free()
	pass # Replace with function body.
