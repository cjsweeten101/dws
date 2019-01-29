extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,40)
var acceleration = 150
var max_speed = 700
var ground_friction = .3
var air_friction = .3
var grapple_friction = .3
var current_speed = Vector2(0,0)
var grappled = false
var direction = 1
var grapple_point = Vector2()
var grapple_cooled_down = true
var grapple_angle
var elasticity = .10
var grapple_boost = 1.2

func ready():
	current_speed = move_and_slide(gravity, UP)

func _physics_process(delta):
	move()
	set_grapple_direction()
	if grappled:
		reel_in()
		check_for_break()

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
	
	if Input.is_action_just_pressed("action") and !grappled and grapple_cooled_down:
		#If grapple collides with _anything_ grapple that shit
		if $GrappleCast.is_colliding():
			set_grappled(true)
	elif Input.is_action_just_released("action"):
		set_grappled(false)
	
	if friction == true:
		if grappled:
			current_speed.x = lerp(current_speed.x, 0, grapple_friction)
		elif is_on_floor():
			current_speed.x = lerp(current_speed.x, 0, ground_friction)
		else:
			current_speed.x = lerp(current_speed.x, 0, air_friction)

func set_grapple_direction():
	if grappled:
		$GrappleCast.rotation_degrees = (grapple_point - global_position).normalized().angle()*180/PI - 90
	else:
		$GrappleCast.rotation_degrees = 180 + current_speed.x/max_speed*(35)

func reel_in():
	var grapple_vector = (grapple_point - global_position)
	current_speed += grapple_vector.normalized()*75
	draw_grapple_hook(grapple_vector)

func draw_grapple_hook(vect):
	var size = vect.length()
	var direction = vect.normalized()
	$GrappleSprite.rotation_degrees = direction.angle() * 180/PI - 90
	$GrappleSprite.scale.y = size/($GrappleSprite.texture.get_height())
	$GrappleCast/ArrowSprite.global_position = grapple_point

func check_for_break():
	if $GrappleCast.is_colliding():
		if $GrappleCast.get_collision_point().round() != grapple_point.round():
			set_grappled(false)

func set_grappled(booly):
	if booly == true:
		current_speed.y *= elasticity
		grapple_point = $GrappleCast.get_collision_point()
		grappled = true
		$GrappleSprite.visible = true
	elif booly == false:
		$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
		current_speed *= grapple_boost
		grappled = false
		$GrappleSprite.visible = false
		grapple_cooled_down = false
		if $GrappleCoolDown.is_stopped():
			$GrappleCoolDown.start()

func _on_GrappleCoolDown_timeout():
	grapple_cooled_down = true
