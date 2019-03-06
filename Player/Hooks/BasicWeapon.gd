extends Node2D

var grapple_points = []
onready var rays = [$GrappleCast, $GrappleCast/EdgeRay1, $GrappleCast/EdgeRay2]
var grappled = false
var reel_in_speed = 75
var max_speed = 700
var just_released
var grapple_point
var grapple_cooled_down = true
var reel_first_pass = true
var grapple_length = 0




func _physics_process(delta):
	if grappled:
		_check_for_break()

func set_rotation(x_speed):
	if grappled:
		just_released = true
		$GrappleCast.rotation = (grapple_point - global_position).normalized().angle()
	else:
		if just_released:
				$GrappleCast.rotation_degrees = 180 + x_speed/max_speed*(45)
				just_released = false
		else:
			$GrappleCast.rotation_degrees = lerp($GrappleCast.rotation_degrees, 180 + x_speed/max_speed*(45), 0.2)

func fire():
	if _rays_colliding():
		grappled = true
		grapple_point = _get_ray_collision_point()
		grapple_points = [grapple_point]
		grapple_cooled_down = false
	else:
		grappled = false
		_draw_miss()

func _get_ray_collision_point():
	var points = []
	for ray in rays:
		if ray.is_colliding():
			points.append(ray.get_collision_point())
	return points[0]

func _rays_colliding():
	for ray in rays:
		if ray.is_colliding():
			if ray.get_collider().is_in_group("enemies"):
				ray.get_collider().grapple_hit()
			return true
	return false

func release():
	grappled = false
	grapple_points = null
	grapple_point = null
	reel_first_pass = true
	if $GrappleCoolDown.is_stopped():
			$GrappleCoolDown.start()
	update()

func is_grappled():
	pass

func get_reel_speed():
	grapple_point = grapple_points[grapple_points.size()-1]
	var grapple_vector = (grapple_point - global_position)
	if grapple_vector.length() > grapple_length+5 and !reel_first_pass:
		release()
	if reel_first_pass:
		reel_first_pass = false

	grapple_length = grapple_vector.length()
	_draw_grapple_hook(grapple_points[0] - global_position)
	return grapple_vector.normalized()*reel_in_speed

func _check_for_break():
	if $GrappleCast.is_colliding():
		if $GrappleCast.get_collision_point().round() != grapple_point.round():
			if grapple_points.size() > 2:
				release()
			else:
				if round($GrappleCast.get_collision_point().y) != round(grapple_points[grapple_points.size() - 1].y):
					grapple_points.append($GrappleCast.get_collision_point())

func _draw_miss():
	var angle = $GrappleCast.rotation
	grapple_points.append($GrappleCast/ArrowSprite.global_position + (Vector2(0,1).rotated(angle)*275))
	_draw_grapple_hook(Vector2(0,1).rotated(angle)*300)
	if $MissDisplay.is_stopped():
		$MissDisplay.start()

func _draw_grapple_hook(vect):
	var size = vect.length()
	var direction = vect.normalized()
	$GrappleCast/ArrowSprite.global_position = global_position + vect
	update()

func _draw():
	if grapple_points != null:
		for i in range (0, grapple_points.size()):
			if i == grapple_points.size() - 1:
				draw_line(grapple_points[i] - global_position, Vector2(0,0), Color(255,255,255), 2)
			else:
				draw_line(grapple_points[i+1]- global_position, grapple_points[i] - global_position, Color(255,255,255), 2)

func _on_MissDisplay_timeout():
	$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
	grapple_points = []
	update()
	if $GrappleCoolDown.is_stopped():
		$GrappleCoolDown.start()


func _on_GrappleCoolDown_timeout():
	grapple_cooled_down = true
