extends MarginContainer

func right_pressed():
	return $HBoxContainer/Arrows/Right.pressed

func left_pressed():
	return $HBoxContainer/Arrows/Left.pressed

func action_pressed():
	return $HBoxContainer/MarginContainer/Action.pressed