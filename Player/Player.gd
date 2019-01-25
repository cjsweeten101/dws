extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,25)
var acceleration = 200
var max_speed = 700
var ground_friction = .3
var current_speed = Vector2(0,0)
var grappled = false
var direction = 1
var grapple_point = Vector2()

func _physics_process(delta):
	move()
	set_direction()
	if grappled:
		reel_in()

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
			grapple_point = $GrappleCast.get_collision_point()
			grappled = true
	elif Input.is_action_just_released("action"):
		grappled = false
	
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

func reel_in():
	var grapple_direction = (grapple_point - global_position).normalized()
	current_speed += grapple_direction*50