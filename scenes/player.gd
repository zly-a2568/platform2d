extends  CharacterBody2D
class_name Player

const SPEED = 200
const JUMP_VELOCITY = -400
const GROUND_ACCELERATION = 1500
const AIR_ACCELERATION =3000
const GRAVITY = 900
const FLASH_SPEED =800
const HURT_BACK_AMOUNT=700
const WALL_JUMP_AMOUNT_X =800

var knob_sensitivity:float
var acceleration:float
var on_floor:bool=false
var still:bool=true
var controlled:bool=true
var bar_length=4.7

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var status: Status = $Status
@onready var state_chart: StateChart = $StateChart
@export var bullet_prefab:PackedScene
@export var smoke_prefab:PackedScene

enum Direction{
	LEFT=-1,
	RIGHT=1
}

@export var direction:Direction=Direction.RIGHT:
	set(v):
		$Graphics.scale.x=v
		direction=v

func _ready() -> void:
	
	var config=ConfigFile.new()
	config.load(GameProcesser.CONFIG_PATH)
	knob_sensitivity=config.get_value("Settings","knob_sensitivity",1.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$foreUI/pausepanel.show_panel()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if status.energy>10:
			shoot_bullet()
			status.energy-=10
		if status.energy<0:
			status.energy=0

func _physics_process(delta: float) -> void:
	if $StateChart/Root/Dying.active:
		return
	#Controlling of Movement
	var dire =Input.get_axis("ui_left","ui_right") 
	
	acceleration=GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	if controlled:
		if not is_zero_approx(dire):
			if not $StateChart/Root/Living/Intract/Hurting/Hurt.active:
				velocity.x=move_toward(velocity.x,direction*SPEED*knob_sensitivity,acceleration*delta*knob_sensitivity)
			else:
				velocity.x=move_toward(velocity.x,0,acceleration*delta)
			direction=sign(dire)
			if still:
				still=false
		else:
			velocity.x=move_toward(velocity.x,0,acceleration*delta)
			if not still:
				still=true
	else:
		pass
	
	
	#Natural Movement
	move_and_slide()
	
	#State Start
	if controlled:
		if is_on_floor():
			velocity.y=0
			if not on_floor:
				on_floor=true
				state_chart.send_event("grounded")
		else:
			if not $StateChart/Root/Living/Movement/Flashing.active:
				velocity.y+=GRAVITY*delta 
			else:
				velocity.y=0
			if on_floor:
				on_floor=false
				state_chart.send_event("airborne")
		
	
	if not still and not $StateChart/Root/Living/Intract/Attacking/Attack.active and not $StateChart/Root/Living/Intract/Hurting/Hurt.active:
		animation_state.travel("move")
	if still:
		animation_state.travel("idle")
		
	
	animation_tree["parameters/move/blend_position"]=signf(velocity.y)
	animation_tree["parameters/idle/blend_position"]=signf(velocity.y)
			

func hurt_back(hitter:Node2D):
	var back_direction=(global_position-hitter.global_position).normalized()
	var back_vector=back_direction*HURT_BACK_AMOUNT
	velocity=back_vector
	
func shoot_bullet():
	var bullet:=bullet_prefab.instantiate() as Bullet
	bullet.global_position=global_position
	bullet.velocity.x=direction*400
	get_tree().current_scene.add_child(bullet)
	SoundManager.play_sfx("Slash")
	pass

func _on_grounded_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y=JUMP_VELOCITY
		SoundManager.play_sfx("Jump")
		state_chart.send_event("jump")
	pass # Replace with function body.





func _on_prepare_to_flash_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("grounded")
	if Input.is_action_just_pressed("flash"):
		if status.energy>=20:
			state_chart.send_event("flash")
			status.energy-=30
		if status.energy<0:
			status.energy=0
	if $Graphics/WallChecker.is_colliding() and sign(Input.get_axis("ui_left","ui_right"))==direction and velocity.y>0:
		state_chart.send_event("sliding")
	pass # Replace with function body.


func _on_on_flash_taken() -> void:
	if not $StateChart/Root/Living/Intract/Attacking/Attack.active:
		animation_state.travel("flash")
	velocity.x=direction*FLASH_SPEED
	SoundManager.play_sfx("Flash")
	$Graphics/Hurter/CollisionShape2D.disabled=true
	pass # Replace with function body.


func _on_on_grounded_taken() -> void:
	print("on ground")
	pass # Replace with function body.


func _on_cannot_jump_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("grounded")
	pass # Replace with function body.


func _on_free_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		state_chart.send_event("attack")
	pass # Replace with function body.


func _on_on_attack_taken() -> void:
	$Graphics/Hitter/CollisionShape2D.disabled=false
	animation_state.travel("attack")
	SoundManager.play_sfx("Attack")
	pass # Replace with function body.


func _on_on_free_taken() -> void:
	$Graphics/Hitter/CollisionShape2D.disabled=true
	pass # Replace with function body.


func _on_end_flash_taken() -> void:
	$Graphics/Hurter/CollisionShape2D.disabled=false
	modulate.a=1.0
	#for supertime->free
	$Hurttip.hide()
	pass # Replace with function body.


func _on_hurter_hurt(hitter: Variant) -> void:
	if not $StateChart/Root/Living/Intract/Hurting/Hurt.active and not $StateChart/Root/Living/Intract/Hurting/SuperTime.active:
		hurt_back(hitter.owner as Node2D)
		state_chart.send_event("hurt")
	pass # Replace with function body.


func _on_hurter_body_entered(body: Node2D) -> void:
	if not $StateChart/Root/Living/Intract/Hurting/Hurt.active and not $StateChart/Root/Living/Intract/Hurting/SuperTime.active:
		hurt_back(body)
		state_chart.send_event("hurt")
	pass # Replace with function body.


func _on_on_hurt_taken() -> void:
	$Graphics/Hurter/CollisionShape2D.set_deferred("disabled",true)
	SoundManager.play_sfx("Hurt")
	GameProcesser.shake_camera(5.0)
	status.health-=1
	animation_state.travel("hurt")
	#for hurttip bar
	bar_length=4.7
	pass # Replace with function body.


func _on_super_time_state_physics_processing(delta: float) -> void:
	modulate.a=sin(Time.get_ticks_msec()/40)+0.5
	$Hurttip.show()
	$Hurttip.scale.x=bar_length/4.7
	bar_length-=delta
	pass # Replace with function body.


func _on_sliding_state_physics_processing(delta: float) -> void:
	animation_state.travel("walljump")
	velocity.y=move_toward(velocity.y,GRAVITY/18,3000*delta)
	if Input.is_action_just_pressed("jump"):
		velocity.x=get_wall_normal().x*WALL_JUMP_AMOUNT_X
		velocity.y=JUMP_VELOCITY
		state_chart.send_event("jump")
	if not $Graphics/WallChecker.is_colliding():
		state_chart.send_event("airborne")
	pass # Replace with function body.


func _on_on_jump_taken() -> void:
	if status.energy>=10:
		SoundManager.play_sfx("Jump")
		var smoke=smoke_prefab.instantiate() as AnimatedSprite2D
		smoke.global_position=global_position
		smoke.animation_finished.connect(func():
			smoke.queue_free()
			)
		get_tree().current_scene.add_child(smoke)
		status.energy-=10
	pass # Replace with function body.


func _on_living_state_physics_processing(delta: float) -> void:
	if status.health<=0:
		state_chart.send_event("dying")
	pass # Replace with function body.


func _on_on_dying_taken() -> void:
	$foreUI/GameOverPanel.show_panel()
	velocity=Vector2(0,0)
	pass # Replace with function body.



func _on_dying_state_physics_processing(delta: float) -> void:
	animation_state.travel("dying")
	pass # Replace with function body.
