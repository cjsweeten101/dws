extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var weapon_path = ""

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_weapon_path():
	return weapon_path