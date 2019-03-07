extends Area2D

# class member variables go here, for example:
# var a = 2
var path = "res://Player/Hooks/SpikyBallWeapon.tscn"

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_weapon_path():
	return path