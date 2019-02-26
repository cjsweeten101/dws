extends Node2D


var game_over = false
onready var player_health = $Player.get_health()
var shake_amount = 13
var action_pressed = false
var action_released = false

func _ready():
	pass
	
func _process(delta):

	if !game_over:
		touch_move()
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
	if check_for_win():
		if !game_over:
			$Player.queue_free()
		game_over = true

func touch_move():
	if $UI/RootUI.right_pressed():
		$Player.move_right()
	elif $UI/RootUI.left_pressed():
		$Player.move_left()
	else:
		$Player.reset_move()
	
	if $UI/RootUI.action_pressed() and !action_pressed:
		$Player.action()
		action_pressed = true
		action_released = false
	
	elif !$UI/RootUI.action_pressed() and !action_released:
		$Player.release_action()
		action_pressed = false
		action_released = true

func shake_cam():
	if !game_over and player_health != $Player.get_health():
		player_health = $Player.get_health()
		if $ShakeTimer.is_stopped():
			$ShakeTimer.start()

func check_for_game_over():
	if !game_over and $Player.get_health() == 0:
		$Label.rect_position = $Camera.global_position
		$Label.text = "You Loose! Press enter to play again!"
		$Player.queue_free()
		game_over = true


func _on_ShakeTimer_timeout():
	$Camera.offset = Vector2(0,0)
	$ShakeTimer.stop()

func check_for_win():
	if !game_over:
		if $WinZone.get_win_state() == true:
			$Label.rect_position = $Camera.global_position - Vector2(300,0)
			$Label.text = "You win! Press enter to play again!"
			return true
