extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,25)
var acceleration = 200
var max_speed = 700
var ground_friction = .3
var current_speed = Vector2(0,0)
var grappled = false
var direction = 1

func _physics_process(delta):
	move()
	set_direction()

func move():
	if Input.is_action_pressed("right"):
		current_speed.x = min(current_speed.x + acceleration, max_speed)
		direction = 1
	elif Input.is_action_pressed("left"):
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
		direction = -1
	
	if Input.is_action_pressed("action"):
		#If grapple collides with _anything_ grapple that shit
		if $GrappleCast.is_colliding():
			grappled = true

	
	if is_on_floor():
		current_speed.x = lerp(current_speed.x, 0, ground_friction)
	else:
		current_speed += gravity
	
	current_speed = move_and_slide(current_speed, UP)

func set_direction():
	if direction == 1:
		$GrappleCast.rotation_degrees = 210
	if direction == -1:
		$GrappleCast.rotation_degrees = 150