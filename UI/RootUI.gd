extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func ui_health(val):
	$TopBar.set_health(val)

func right_pressed():
	return $TouchButtonUI.right_pressed()

func left_pressed():
	return $TouchButtonUI.left_pressed()

func action_pressed():
	return $TouchButtonUI.action_pressed()