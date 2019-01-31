extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,40)
var acceleration = 150
var max_speed = 700
var current_speed = Vector2()
var ground_friction = .3
var direction

func ready():
	current_speed = move_and_slide(gravity, UP)

func _physics_process(delta):
	move()

func move():
	var friction = false
	current_speed += gravity
	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed("right"):
		current_speed.x = min(current_speed.x + acceleration, max_speed)
		direction = 1
	elif Input.is_action_pressed("left"):
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
		direction = -1
	else:
		friction = true
	
	if friction == true:
		current_speed.x = lerp(current_speed.x, 0, ground_friction)