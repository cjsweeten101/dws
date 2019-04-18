extends "res://AbstractEnemy.gd"

var UP = Vector2(0,-1)
var player_detected = false
var accel = Vector2(0,100)
var max_speed = Vector2()
var player_pos = Vector2()
var moving = false
var diving_direction = 0
var dive_speed = Vector2(300,400)
var moving_up = false

func _ready():
	pass

func _physics_process(delta):
	if player_detected or moving:
		move()

#So if player enters his agro area, dive towards him.  (Sliding on walls or bouncing? Maybe even falling))
#And Keep moving, until movement is done (even if player leaves area)
func move():
	moving = true
	if diving_direction == 0:
		diving_direction = sign((player_pos.x - global_position.x))
		current_speed = dive_speed
		if diving_direction == -1:
			current_speed.x *= -1
	if player_pos.y - global_position.y < 10 or moving_up:
		moving_up = true 
		move_and_slide(current_speed*Vector2(1,-1))
	else:
		move_and_slide(current_speed)

func _on_AgroBox_body_entered(body):
	if body.is_in_group("player"):
		player_detected = true
		player_pos = body.global_position

func _on_AgroBox_body_exited(body):
	if body.is_in_group("player"):
		player_detected = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("tiles") and moving_up:
		moving = false
		diving_direction = 0
