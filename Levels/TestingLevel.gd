extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var game_over = false
onready var player_health = $Player.get_health()
var shake_amount = 13

func _ready():
	pass
	
func _process(delta):
	if !game_over:
		$UI/RootUI.ui_health($Player.get_health())
	else:
		if Input.is_action_pressed("action"):
			get_tree().reload_current_scene()
	#Refactor big boi
	if !game_over and $ShakeTimer.is_stopped():
			$Camera.position.x = $Player.position.x
	elif !$ShakeTimer.is_stopped():
		$Camera.set_offset(Vector2( \
        	rand_range(-1.0, 1.0) * shake_amount, \
        	rand_range(-1.0, 1.0) * shake_amount \
   		))

	shake_cam()
	check_for_game_over()

func shake_cam():
	if !game_over and player_health != $Player.get_health():
		player_health = $Player.get_health()
		if $ShakeTimer.is_stopped():
			$ShakeTimer.start()

func check_for_game_over():
	if !game_over and $Player.get_health() == 0:
		$Player.queue_free()
		game_over = true


func _on_ShakeTimer_timeout():
	$Camera.offset = Vector2(0,0)
	$ShakeTimer.stop()
