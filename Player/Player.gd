extends KinematicBody2D

var UP = Vector2(0,-1)
var gravity = Vector2(0,40)
var acceleration = 150
#if you change this make sure you change it in the hooks as well, yes I know I'm dumb
var max_speed = 700
var ground_friction = .3
var air_friction = .3
var grapple_friction = .1
var current_speed = Vector2(0,0)
var direction = 1
var health = 3
var i_frames_active = false
var touch_right = false
var touch_left = false
var action_pressed = false

var touch_action = false
var touch_release = false
onready var default_weapon = preload("res://Player/Hooks/BasicWeapon.tscn")
var current_weapon

var just_grappled = true
var just_rel = false

func _ready():
	current_weapon = default_weapon.instance()
	add_child(current_weapon)
	current_speed = move_and_slide(gravity, UP)


#Note touch screen control may be buggy after this refactor
func _physics_process(delta):
	current_weapon.set_x_speed(current_speed.x)
	if current_weapon.is_grappled():
		if just_grappled:
			current_speed.y *= current_weapon.get_elasticity()
			just_grappled = false
			just_rel = true
		if current_weapon.hook_name == "zipline":
			current_speed = current_weapon.get_reel_speed()
		else:
			current_speed += current_weapon.get_reel_speed()
	else:
		if just_rel:
			touch_action = false
			just_grappled = true
			just_rel = false
			current_speed *= current_weapon.get_grapple_boost()
	
	move()

	if is_on_floor():
		current_weapon.refill_ammo()

func move():

	var friction = false
	current_speed += gravity
	current_speed = move_and_slide(current_speed, UP)

	if Input.is_action_pressed("right") or touch_right:
		current_speed.x = min(current_speed.x + acceleration, max_speed)
		direction = 1
	elif Input.is_action_pressed("left") or touch_left:
		current_speed.x = max(current_speed.x - acceleration, -max_speed)
		direction = -1
	else:
		friction = true
	
	if (Input.is_action_just_pressed("action") or touch_action):
		touch_action = false
		current_weapon.fire()
	elif (Input.is_action_just_released("action") or touch_release):
		touch_release = false
		current_weapon.release()
		
	if friction == true:
		if current_weapon.is_grappled():
			current_speed.x = lerp(current_speed.x, 0, grapple_friction)
		elif is_on_floor():
			current_speed.x = lerp(current_speed.x, 0, ground_friction)
		else:
			current_speed.x = lerp(current_speed.x, 0, air_friction)
	
#So this was in grapple cool down time out for some reason
#touch_action = false

func add_health(amt):
	health += amt

func remove_health(amt):
	if !i_frames_active:
		$AnimationPlayer.play("hurt_anim")
		health -= amt

func _on_HurtBox_body_entered(body):
	if body.is_in_group("soft"):
		attack(body)

func attack(body):
	current_weapon.refill_ammo()
	body.hit()
	if current_speed.y > 0:
		current_speed.y = 0
	current_speed.y -= 700
	current_speed.x *= 3.5

func is_grappled():
	return current_weapon.is_grappled()

func get_health():
	return health

func i_frames(status):
	i_frames_active = status

func move_right():
	touch_right = true

func move_left():
	touch_left = true

func reset_move():
	touch_left = false
	touch_right = false

func action():
	touch_action = true

func release_action():
	touch_release = true

func _on_HurtBox_area_entered(area):
	if area.is_in_group("WeaponPickups"):
		switch_weapon(area.get_weapon_path())
		area.queue_free()

func switch_weapon(path):
	current_weapon.queue_free()
	current_weapon = load(path).instance()
	add_child(current_weapon)

func get_ammo():
	return current_weapon.get_ammo()