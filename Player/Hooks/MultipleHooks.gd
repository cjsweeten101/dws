extends Node2D

var hook_name = "MultipleHooks"
var ammo = 4
var max_ammo = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if $BasicWeapon1.is_grappled():
		$BasicWeapon1.rotation_degrees = 0
	else:
		$BasicWeapon1.rotation_degrees = -5
	if $BasicWeapon2.is_grappled():
		$BasicWeapon2.rotation_degrees = 0
	else:
		$BasicWeapon2.rotation_degrees = 5
	

func set_x_speed(speed):
	$BasicWeapon1.set_x_speed(speed)
	$BasicWeapon2.set_x_speed(speed)
	
func fire():
	if ammo > 0 and grapples_cooldown():
		$BasicWeapon1.rotation_degrees = 0
		$BasicWeapon2.rotation_degrees = 0
		$BasicWeapon1.fire()
		$BasicWeapon2.fire()
		ammo -= 1

func is_grappled():
	if $BasicWeapon1.is_grappled() or $BasicWeapon2.is_grappled():
		return true
	else:
		return false

func get_ammo():
	return ammo

func refill_ammo():
	ammo = max_ammo
	$BasicWeapon1.refill_ammo()
	$BasicWeapon2.refill_ammo()

func release():
	$BasicWeapon1.release()
	$BasicWeapon2.release()

func get_elasticity():
	return $BasicWeapon1.get_elasticity()

func get_reel_speed():
	if $BasicWeapon1.is_grappled() and $BasicWeapon2.is_grappled():
		return ($BasicWeapon1.get_reel_speed() + $BasicWeapon2.get_reel_speed())/2
	elif $BasicWeapon1.is_grappled():
		return $BasicWeapon1.get_reel_speed()
	elif $BasicWeapon2.is_grappled():
		return $BasicWeapon2.get_reel_speed()
	else:
		return 0

func get_grapple_boost():
	return $BasicWeapon1.get_grapple_boost()

func grapples_cooldown():
	if $BasicWeapon1.grapple_cooled_down and $BasicWeapon2.grapple_cooled_down:
		return true
	else:
		return false
	