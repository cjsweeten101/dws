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
var just_released = true
var grapple_length = 0
var reel_in_speed = 75
var reel_first_pass = true
var grapple_off = false
var health = 3
var new_grapple_point
var grapple_points = []
onready var rays = [$GrappleCast, $GrappleCast/EdgeRay1, $GrappleCast/EdgeRay2]
var i_frames_active = false
var touch_right = false
var touch_left = false
var action_pressed = false

var touch_action = false
var touch_release = false


func ready():
	current_speed = move_and_slide(gravity, UP)

func _draw():
	if grapple_points != null:
		for i in range (0, grapple_points.size()):
			if i == grapple_points.size() - 1:
				draw_line(grapple_points[i] - global_position, Vector2(0,0), Color(255,255,255), 2)
			else:
				draw_line(grapple_points[i+1]- global_position, grapple_points[i] - global_position, Color(255,255,255), 2)

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

	if Input.is_action_pressed("right") or touch_right:
		current_speed.x = min(current_speed.x + acceleration, max_speed)
		direction = 1
	elif Input.is_action_pressed("left") or touch_left:
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
		direction = -1
	else:
		friction = true
	
	if (Input.is_action_just_pressed("action") or touch_action) and !grappled and grapple_cooled_down:
		touch_action = false
		if rays_colliding():
		#if $GrappleCast.is_colliding():
		#	if $GrappleCast.get_collider().is_in_group("enemies"):
		#		$GrappleCast.get_collider().grapple_hit()
			set_grappled(true, get_ray_collision_point())
		else:
			draw_miss()
	elif (Input.is_action_just_released("action") or touch_release) or grapple_off:
		touch_release = false
		set_grappled(false, 0)
		grapple_off = false
		
	if friction == true:
		if grappled:
			current_speed.x = lerp(current_speed.x, 0, grapple_friction)
		elif is_on_floor():
			current_speed.x = lerp(current_speed.x, 0, ground_friction)
		else:
			current_speed.x = lerp(current_speed.x, 0, air_friction)

func rays_colliding():
	for ray in rays:
		if ray.is_colliding():
			if ray.get_collider().is_in_group("enemies"):
				ray.get_collider().grapple_hit()
			return true
	return false

func get_ray_collision_point():
	var points = []
	for ray in rays:
		if ray.is_colliding():
			points.append(ray.get_collision_point())
	return points[0]

func draw_miss():
	var angle = $GrappleCast.rotation
	grapple_points.append($GrappleCast/ArrowSprite.global_position + (Vector2(0,1).rotated(angle)*275))
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
			$GrappleCast.rotation_degrees = lerp($GrappleCast.rotation_degrees, 180 + current_speed.x/max_speed*(45), 0.2)
	
func reel_in():
	grapple_point = grapple_points[grapple_points.size()-1]
	var grapple_vector = (grapple_point - global_position)
	if grapple_vector.length() > grapple_length+5 and !reel_first_pass:
		grapple_off = true
	if reel_first_pass:
		reel_first_pass = false

	grapple_length = grapple_vector.length()
	current_speed += grapple_vector.normalized()*reel_in_speed
	draw_grapple_hook(grapple_points[0] - global_position)

func draw_grapple_hook(vect):
	var size = vect.length()
	var direction = vect.normalized()
	$GrappleCast/ArrowSprite.global_position = global_position + vect
	update()
	
func check_for_break():
	if $GrappleCast.is_colliding():
		if $GrappleCast.get_collision_point().round() != grapple_point.round():
			if grapple_points.size() > 2:
				set_grappled(false, 0)
			else:
				if round($GrappleCast.get_collision_point().y) != round(grapple_points[grapple_points.size() - 1].y):
					grapple_points.append($GrappleCast.get_collision_point())

func set_grappled(booly, point):
	if booly == true:
		$GrappleCast/AimingSprite.visible = false
		current_speed.y *= elasticity
		grapple_point = point
		grapple_points = [grapple_point]
		grappled = true
	elif booly == false:
		reel_first_pass = true
		$GrappleCast/AimingSprite.visible = true
		$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
		current_speed *= grapple_boost
		grappled = false
		grapple_cooled_down = false
		if $GrappleCoolDown.is_stopped():
			$GrappleCoolDown.start()
		grapple_points = []
		update()

func _on_GrappleCoolDown_timeout():
	grapple_cooled_down = true
	touch_action = false


func _on_MissDisplay_timeout():
	$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
	grapple_points = []
	update()
	if $GrappleCoolDown.is_stopped():
		$GrappleCoolDown.start()

func add_health(amt):
	health += amt

func remove_health(amt):
	if !i_frames_active:
		$AnimationPlayer.play("hurt_anim")
		health -= amt

func _on_HurtBox_body_entered(body):
	if body.is_in_group("soft"):
		attack(body)

func attack(body):
	body.hit()
	if current_speed.y > 0:
		current_speed.y = 0
	current_speed.y -= 700
	current_speed.x *= 3.5

func is_grappled():
	return grappled

func get_health():
	return health

func i_frames(status):
	i_frames_active = status

func move_right():
	touch_right = true

func move_left():
	touch_left = true

func reset_move():
	touch_left = false
	touch_right = false

func action():
	touch_action = true

func release_action():
	touch_release = true