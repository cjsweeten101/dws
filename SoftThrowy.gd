extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var direction = 1
var ball = preload("res://Enemies/SoftThrowy/ThrowableBall.tscn")
var throw = true

func _physics_process(delta):
	if throw:
		throw()

func throw():
	var new_ball = ball.instance()
	add_child(new_ball)
	new_ball.set_launch_speed(Vector2(-500,-1100))
	throw = false
	if $ThrowTimer.is_stopped():
		$ThrowTimer.start()
	
func turn_around():
	self.scale.x *= -1
	direction *= -1

func _on_HurtBox_body_entered(body):
	if body.is_in_group("player"):
		if body.is_grappled():
			body.remove_health(1)

func hit():
	print('trying to hit')
	$AnimationPlayer.play("explosion_anim")

func _on_ThrowTimer_timeout():
	$ThrowTimer.stop()
	throw = true
