extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var current_speed = Vector2(0,0)
var gravity = Vector2(0,35)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	current_speed += gravity
	move_and_slide(current_speed)

func set_launch_speed(speed):
	current_speed = speed



func _on_HurtBox_body_entered(body):
		if body.is_in_group("tiles"):
			queue_free()
		elif body.is_in_group("player"):
			body.remove_health(1)
