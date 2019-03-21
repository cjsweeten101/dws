extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point_a
var point_b
var initial_position
var boost = 700

func set_polyline(point_1, point_2, rot):
	position = point_2 + Vector2(0,30)
	var stretch = (point_1 - (point_2 + Vector2(0,30))).length()/$Sprite.texture.get_width()
	$Sprite.scale.y = stretch
	$Sprite.rotation = rot
	initial_position = global_position
	point_a = point_1
	point_b = point_2

func get_boost_vector():
	return Vector2(0,1).rotated($Sprite.rotation).normalized()*boost