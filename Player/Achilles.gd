extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,40)
var acceleration = 150
var max_speed = 700
var current_speed = Vector2()
var ground_friction = .3
var direction
var strange_aim_scaling_value = 89
var can_grapple = true
var spear

func ready():
	current_speed = move_and_slide(gravity, UP)

func _physics_process(delta):
	move()
	update_aim()
	grapple()

func move():
	var friction = false
	current_speed += gravity
	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed("right"):
		current_speed.x = min(current_speed.x + acceleration, max_speed)
		direction = 1
	elif Input.is_action_pressed("left"):
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
		direction = -1
	else:
		friction = true
	
	if friction == true:
		current_speed.x = lerp(current_speed.x, 0, ground_friction)

func update_aim():
	if current_speed.x > 0:
		$AimSprite.rotation_degrees = current_speed.x/max_speed*strange_aim_scaling_value
	else:
		$AimSprite.rotation_degrees = 0

func grapple():
	if Input.is_action_just_pressed("action") and can_grapple:
		deploy_spear()
	elif Input.is_action_just_released("action"):
		spear.retract()

func deploy_spear():
	spear = load("res://Player/Spear.tscn")
	spear = spear.instance()
	get_parent().add_child(spear)
	spear.global_position = global_position
	spear.deploy($AimSprite.rotation_degrees)