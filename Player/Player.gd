extends KinematicBody2D

export var speed = 800
export var friction = 0.2
export var acceleration = 0.4

var input = Vector2.ZERO
var dir_x = 0
var dir_y = 0


func get_input():
	dir_x = 0
	dir_y = 0
	
	if Input.is_action_pressed("player_right"):
		dir_x += 1
	if Input.is_action_pressed("player_left"):
		dir_x -= 1
	
	if dir_x != 0:
		input.x = lerp(input.x, dir_x * speed, acceleration)
	else:
		input.x = lerp(input.x, 0, friction)
	
	if Input.is_action_pressed("player_up"):
		dir_y -= 1
	if Input.is_action_pressed("player_down"):
		dir_y += 1
		
	if dir_y != 0:
		input.y = lerp(input.y, dir_y * speed, acceleration)
	else:
		input.y = lerp(input.y, 0, friction)


func _physics_process(delta):
	get_input()
	input = move_and_slide(input)
