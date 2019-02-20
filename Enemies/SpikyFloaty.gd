extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var max_speed = 200
var current_speed = Vector2(0,0)
var target = Vector2()
var last_direction = Vector2(0,0)
var acceleration = 10
var dir
var grappled = false
var proximity_point
onready var rays = [$RayCast2D, $RayCast2D/RayCast2D7, $RayCast2D/RayCast2D6, $RayCast2D/RayCast2D6, $RayCast2D/RayCast2D5, $RayCast2D/RayCast2D5, $RayCast2D/RayCast2D4, $RayCast2D/RayCast2D4, $RayCast2D/RayCast2D3, $RayCast2D/RayCast2D2, $RayCast2D/RayCast2D]
var proximity_move = false

#Need this boy to roam around randomly.
#Basic Implemantion with a timer?
#Every time the timer goes off choose a new direction
#And randomly pick a new time
#Some pauses in there also?
#New direction could be restricted to a range based on last direction
#So it doesn't appear so random.
#also dont want him roaming too near to the ground or of screen. or on platforms
#So maybe he has an area that detects platforms?  Doesn't pick values near them
#acceleration/friction would be nice also
func _ready():
	randomize()

func _physics_process(delta):
	if !grappled:
		move(delta)

func move(delta):
	if $PauseTimer.is_stopped():
		if $MoveTimer.is_stopped():
			dir = new_dir()
			if $MoveTimer.is_stopped():
				$MoveTimer.start()
		else:
			var max_x = dir.x*max_speed
			var max_y = dir.y*max_speed
			current_speed.x = min(current_speed.x + acceleration, max_x)
			current_speed.y = max(current_speed.y + acceleration, max_y)
			current_speed = dir*max_speed
	else:
		current_speed.x = lerp(current_speed.x, 0, .1)
		current_speed.y = lerp(current_speed.y, 0, .1)

	proximity_check()
	move_and_slide(current_speed)

func proximity_check():
	if !proximity_move:
		for ray in rays:
			if ray.is_colliding():
				if ray.get_collider().is_in_group("tiles"):
					proximity_point = ray.get_collision_point()
					var opposite_direction = -(proximity_point - global_position).normalized()
					dir.x = rand_range(opposite_direction.x - .75, opposite_direction.x + .75)
					dir.y = rand_range(opposite_direction.y - .75, opposite_direction.y + .75)
					dir = dir.normalized()
					proximity_move = true
					return

func new_dir():
	var rand_dir = Vector2()
	if last_direction == Vector2(0,0):
		rand_dir.x = rand_range(-1,1)
		rand_dir.y = rand_range(-1,1)
	else:
		#TODO weight with current direction
		var normalized_speed = current_speed.normalized()
		rand_dir.x = rand_range(-1,1)
		rand_dir.y = rand_range(-1,1)

	last_direction = rand_dir
	return rand_dir
	
func _on_MoveTimer_timeout():
	$MoveTimer.stop()
	$MoveTimer.wait_time = rand_range(.5,1.5)
	if $PauseTimer.is_stopped():
		$PauseTimer.start()


func _on_PauseTimer_timeout():
	proximity_move = false
	$PauseTimer.stop()
	$PauseTimer.wait_time = rand_range(.5,1)


#Idea, pause when grappled.  Then shake a bit (anim), then explode (anim)
func grapple_hit():
	$AnimationPlayer.play("shake_anim")
	grappled = true
	current_speed = Vector2(0,0)

func explode():
	$AnimationPlayer.play("explosion_anim")

func _on_HurtBox_body_entered(body):
	if body.is_in_group("player"):
		body.remove_health(1)
