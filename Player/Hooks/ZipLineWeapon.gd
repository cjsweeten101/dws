extends Node2D

var hook_name = "zipline"
var grapple_points = []
onready var rays = [$GrappleCast, $GrappleCast/EdgeRay1, $GrappleCast/EdgeRay2]
var grappled = false
var reel_in_speed = 1250
var max_speed = 700
var just_released = false
var grapple_point
var grapple_cooled_down = true
var reel_first_pass = true
var grapple_length = 0
var elasticity = .10
var grapple_boost = Vector2(2.0,1.5)
var x_speed
export var max_ammo = 3
var ammo = max_ammo

func set_x_speed(speed):
	x_speed = speed
func _physics_process(delta):
	set_aim_rotation()
	if grappled:
		$GrappleCast/AimingSprite.visible = false
		$GrappleCast/ArrowSprite.global_position = grapple_points[0]
		_check_for_break()

func set_aim_rotation():
	if grappled:
		just_released = true
		$GrappleCast.rotation_degrees = (grapple_point - global_position).angle()*180/PI - 90
	else:
		if just_released:
				$GrappleCast.rotation_degrees = 180 + x_speed/max_speed*(45)
				just_released = false
		else:
			$GrappleCast.rotation_degrees = lerp($GrappleCast.rotation_degrees, 180 + x_speed/max_speed*(45), 0.2)

func fire():
	if !grappled and grapple_cooled_down and ammo > 0:
		ammo -= 1
		if _rays_colliding():
			grappled = true
			grapple_point = _get_ray_collision_point()
			grapple_points = [grapple_point]
			grapple_cooled_down = false
		else:
			grappled = false
			grapple_cooled_down = false
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
	$GrappleCast/AimingSprite.visible = true
	grapple_cooled_down = false
	grappled = false
	grapple_points = []
	grapple_point = null
	reel_first_pass = true
	$GrappleCast/ArrowSprite.position = Vector2(0.095701,36.381802)
	if $GrappleCoolDown.is_stopped():
			$GrappleCoolDown.start()
	update()

func is_grappled():
	return grappled

func get_reel_speed():
	grapple_point = grapple_points[grapple_points.size()-1]
	var grapple_vector = (grapple_point - global_position)
	if grapple_vector.length() > grapple_length+5 and !reel_first_pass:
		release()
		return Vector2(0,0)
	if reel_first_pass:
		reel_first_pass = false

	grapple_length = grapple_vector.length()
	_draw_grapple_hook(grapple_points[0] - global_position)
	return grapple_vector.normalized()*reel_in_speed

func get_elasticity():
	return elasticity

func get_grapple_boost():
	return grapple_boost

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
	$MissDisplay.stop()
	$GrappleCast/ArrowSprite.position = Vector2(0.095701, 36.381802)
	grapple_points = []
	update()
	if $GrappleCoolDown.is_stopped():
		$GrappleCoolDown.start()


func _on_GrappleCoolDown_timeout():
	grapple_cooled_down = true
	$GrappleCoolDown.stop()

func get_ammo():
	return ammo

func refill_ammo():
	ammo = max_ammo