extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var game_over = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if !game_over:
		$UI/RootUI.ui_health($Player.get_health())
		$Camera.position.x = $Player.position.x
	else:
		if Input.is_action_pressed("action"):
			get_tree().reload_current_scene()
	check_for_game_over()

func check_for_game_over():
	if !game_over and $Player.get_health() == 0:
		$Player.queue_free()
		game_over = true