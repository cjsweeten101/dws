extends Node2D

export var margin = 25
export var button_spacing = 100

func _ready():
	place_buttons()

func place_buttons():
	$Left.position.x = margin
	$Right.position.x = $Left.position.x + button_spacing
	$Action.position.x = get_viewport().size.x - margin - $Action.normal.get_width()
	
	var screen_height = get_viewport().size.y
	$Left.position.y = screen_height - $Left.normal.get_height() - margin
	$Right.position.y = screen_height - $Right.normal.get_height() - margin
	$Action.position.y = screen_height - $Action.normal.get_height() - margin

func right_pressed():
	return $Right.is_pressed()

func left_pressed():
	return $Left.is_pressed()

func action_pressed():
	return $Action.is_pressed()