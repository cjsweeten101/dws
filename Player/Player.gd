extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,25)
var acceleration = 200
var max_speed = 700
var ground_friction = .3
var current_speed = Vector2(0,0)

func _physics_process(delta):
	move()

func move():

	if Input.is_action_pressed("right"):
		current_speed.x = min(current_speed.x + acceleration, max_speed)
	elif Input.is_action_pressed("left"):
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
	
	if is_on_floor():
		current_speed.x = lerp(current_speed.x, 0, ground_friction)
	else:
		current_speed += gravity
	
	current_speed = move_and_slide(current_speed, UP)