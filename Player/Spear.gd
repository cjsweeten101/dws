extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var deployed = false
var current_speed = Vector2()
var UP = Vector2(0,-1)
var gravity = Vector2(0,40)
var air_friction = .3
var launch_speed = 1000
var frozen = false
var retract = false

func _ready():
	# Initialization here
	pass

func _process(delta):
	if deployed and !frozen:
		update_angle()
		gravity()
		current_speed = move_and_slide(current_speed, UP)
	elif frozen:
		current_speed = Vector2(0,0)
		if retract:
			queue_free()
	
	current_speed = move_and_slide(current_speed, UP)

func deploy(angle):
	deployed = true
	var angle_vect = Vector2(0,-1).rotated(angle*PI/180)
	current_speed = angle_vect*launch_speed

func gravity():
	current_speed += gravity

func retract():
	retract = true

func update_angle():
	if !current_speed.y == 0:
		rotation = current_speed.angle() + PI/2
	

func _on_HitBox_area_entered(area):
	print(area)


func _on_HitBox_body_entered(body):
	if !body.is_in_group("player"):
		freeze()

func freeze():
	frozen = true