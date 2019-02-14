extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var max_speed = 300
var current_speed = Vector2(0,0)
var target = Vector2()
var last_direction = Vector2(0,0)
var acceleration = 75
var proximity_tile_pos
var dir
var grappled = false

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
			if dir.x > 0:
				current_speed.x = min(current_speed.x + acceleration, max_speed)
			elif dir.x < 0:
				current_speed.x = max(current_speed.x - acceleration, -max_speed)
			if dir.y > 0:
				current_speed.y = min(current_speed.y + acceleration, max_speed)
			elif dir.y < 0:
				current_speed.y = max(current_speed.y - acceleration, -max_speed)
			if $MoveTimer.is_stopped():
				$MoveTimer.start()
	else:
		current_speed.x = lerp(current_speed.x, 0, .1)
		current_speed.y = lerp(current_speed.y, 0, .1)

	proximity_check(delta)
	move_and_slide(current_speed)

func proximity_check(delta):
	#TODO Fix this shit obvi
	if proximity_tile_pos != null:
		var tile_direction = (proximity_tile_pos - global_position).normalized()
		dir.x = rand_range(-tile_direction.x, -tile_direction.x + 1)
		dir.y = rand_range(-tile_direction.x, -tile_direction.x + 1)
	
	if (global_position.y + current_speed.y*delta) < 0:
		pass

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
	$PauseTimer.stop()
	$PauseTimer.wait_time = rand_range(.5,1)


func _on_Area2D_body_entered(body):
	if body.is_in_group("tiles"):
		proximity_tile_pos = body.global_position


func _on_Area2D_body_exited(body):
	if body.is_in_group("tiles"):
		proximity_tile_pos = null

#Idea, pause when grappled.  Then shake a bit (anim), then explode (anim)
func grapple_hit():
	$AnimationPlayer.play("shake_anim")
	grappled = true
	current_speed = Vector2(0,0)

func explode():
	$AnimationPlayer.play("explosion_anim")