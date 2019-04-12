extends "res://AbstractEnemy.gd"

var UP = Vector2(0,-1)
var player_detected = false

func _ready():
	pass

func _physics_process(delta):
	if player_detected:
		move()

#So if player enters his agro area, dive towards him.  (Sliding on walls or bouncing? Maybe even falling))
func move():
	current_speed += Vector2(0,0)
	current_speed = move_and_slide(current_speed, UP)

func _on_AgroBox_body_entered(body):
	if body.is_in_group("player"):
		player_detected = true


func _on_AgroBox_body_exited(body):
	if body.is_in_group("player"):
		player_detected = false
