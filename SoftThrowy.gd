extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var direction = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

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