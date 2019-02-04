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
var grapple_boost = Vector2(1.3,1.5)
var initial_grapple
var just_released = true

func ready():
	current_speed = move_and_slide(gravity, UP)

func _physics_process(delta):
	move()
	if $MissDisplay.is_stopped():
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
		else:
			draw_miss()
	elif Input.is_action_just_released("action"):
		set_grappled(false)
	
	if friction == true:
		if grappled:
			current_speed.x = lerp(current_speed.x, 0, grapple_friction)
		elif is_on_floor():
			current_speed.x = lerp(current_speed.x, 0, ground_friction)
		else:
			current_speed.x = lerp(current_speed.x, 0, air_friction)

func draw_miss():
	var angle = $GrappleCast.rotation
	$GrappleSprite.visible = true
	draw_grapple_hook(Vector2(0,1).rotated(angle)*300)
	if $MissDisplay.is_stopped():
		$MissDisplay.start()

func set_grapple_direction():
	
	if grappled:
		just_released = true
		$GrappleCast.rotation_degrees = (grapple_point - global_position).normalized().angle()*180/PI - 90
	else:
		if just_released:
				$GrappleCast.rotation_degrees = 180 + current_speed.x/max_speed*(45)
				just_released = false
		else:
			$GrappleCast.rotation_degrees = lerp($GrappleCast.rotation_degrees, 180 + current_speed.x/max_speed*(45), 0.25)

func reel_in():
	var grapple_vector = (grapple_point - global_position)
	var reel_in_speed = 75
	current_speed += grapple_vector.normalized()*reel_in_speed
	if grapple_vector.length() > initial_grapple.length():
		#Do something here lol
		pass
	draw_grapple_hook(grapple_vector)

func draw_grapple_hook(vect):
	var size = vect.length()
	var direction = vect.normalized()
	$GrappleSprite.rotation_degrees = direction.angle() * 180/PI - 90
	$GrappleSprite.scale.y = size/($GrappleSprite.texture.get_height())
	$GrappleCast/ArrowSprite.global_position = global_position + vect

func check_for_break():
	if $GrappleCast.is_colliding():
		if $GrappleCast.get_collision_point().round() != grapple_point.round():
			set_grappled(false)

func set_grappled(booly):
	if booly == true:
		$GrappleCast/AimingSprite.visible = false
		current_speed.y *= elasticity
		grapple_point = $GrappleCast.get_collision_point()
		grappled = true
		$GrappleSprite.visible = true
		initial_grapple = global_position - grapple_point
	elif booly == false:
		$GrappleCast/AimingSprite.visible = true
		$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
		current_speed *= grapple_boost
		grappled = false
		$GrappleSprite.visible = false
		grapple_cooled_down = false
		if $GrappleCoolDown.is_stopped():
			$GrappleCoolDown.start()

func _on_GrappleCoolDown_timeout():
	grapple_cooled_down = true


func _on_MissDisplay_timeout():
	$GrappleSprite.visible = false
	$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
	if $GrappleCoolDown.is_stopped():
		$GrappleCoolDown.start()
