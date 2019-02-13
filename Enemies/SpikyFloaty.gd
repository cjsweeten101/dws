extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var max_speed = 250
var current_speed = Vector2(0,0)
var target = Vector2()
var last_direction = Vector2(0,0)

#Need this boy to roam around randomly.
#Basic Implemantion with a timer?
#Every time the timer goes off choose a new direction
#And randomly pick a new time
#Some pauses in there also?
#New direction could be restricted to a range based on last direction
#So it doesn't appear so random.
#also dont want him roaming too near to the ground or of screen. or on platforms

func _ready():
	randomize()

func _physics_process(delta):
	move()

func move():
	if $PauseTimer.is_stopped():
		if $MoveTimer.is_stopped():
			print("startin move")
			current_speed = start_move()
	move_and_slide(current_speed)

func start_move():
	var rand_dir = Vector2()
	if last_direction == Vector2(0,0):
		rand_dir.x = rand_range(-1,1)
		rand_dir.y = rand_range(-1,1)
	else:
		#Weight with current direction
		rand_dir.x = rand_range(-1,1)
		rand_dir.y = rand_range(-1,1)

	if $MoveTimer.is_stopped():
		$MoveTimer.start()

	last_direction = rand_dir
	return max_speed*rand_dir
	
func _on_MoveTimer_timeout():
	$MoveTimer.stop()
	$MoveTimer.wait_time = rand_range(.2,1)
	current_speed = Vector2(0,0)
	if $PauseTimer.is_stopped():
		$PauseTimer.start()


func _on_PauseTimer_timeout():
	$PauseTimer.stop()
	$PauseTimer.wait_time = rand_range(.5,1)
