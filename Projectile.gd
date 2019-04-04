extends Node2D


var current_speed = Vector2()
var speed = 45
var angle
var stuck

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if !stuck:
		move()
		

func set_direction(val):
	angle = val
	rotation = val+PI

func set_position(pos):
	position = pos

func move():
	position += Vector2(0,1).rotated(angle)*speed

func _on_Area2D_body_entered(body):
	if !body.is_in_group("player"):
		stuck = true
		if body.is_in_group("enemies"):
			body.grapple_hit()
