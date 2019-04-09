extends KinematicBody2D

var grappled = false
var current_speed = Vector2(0,0 )

func grapple_hit():
	$AnimationPlayer.play("shake_anim")
	grappled = true
	current_speed = Vector2(0,0)

func explode():
	$CollisionShape2D.disabled = true
	$AnimationPlayer.play("explosion_anim")

func _on_HurtBox_body_entered(body):
	if body.is_in_group("player"):
		if !grappled and !self.is_in_group("soft"):
			body.remove_health(1)