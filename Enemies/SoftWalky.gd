extends KinematicBody2D

var gravity = Vector2(0,40)
var UP = Vector2(0,-1)
var max_speed = 200
var ground_friction = .3
var acceleration = 50
var current_speed = Vector2()
var direction = -1

func _ready():
	pass

func _physics_process(delta):
	move()
	check_for_turnaround()
	
func move():
	current_speed = move_and_slide(current_speed, UP)
	if direction == 1:
		current_speed.x = min(current_speed.x + acceleration, max_speed)
	elif direction == -1:
		current_speed.x = max(current_speed.x - acceleration, -max_speed)

func check_for_turnaround():
	if !$TurnAroundRay.is_colliding():
		turn_around()
	
func turn_around():
	self.scale.x *= -1
	direction *= -1

func _on_HurtBox_body_entered(body):
	if body.is_in_group("player"):
		body.remove_health(1)
