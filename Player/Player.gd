extends KinematicBody2D

export var speed = 800
export var friction = 0.2
export var acceleration = 0.4

var input = Vector2.ZERO
var dir_x = 0
var dir_y = 0

var sucked_object : RigidBody2D = null
var objects_in_vision = []

export var shoot_power = 500
export var suck_power = 200
export var shoot_power_rate = 100

var screensize
var controller = false


func _ready():
	screensize = get_viewport_rect().size
	$Hand.connect("tip_touched", self, "tip_touched")


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
	
	if controller == true:
		var dirinput = Vector2(Input.get_axis("player_look_left", "player_look_right"), Input.get_axis("player_look_up", "player_look_down"))
		
		if dirinput.angle() != 0 && (abs(Input.get_axis("player_look_left", "player_look_right")) > 0.7 || abs(Input.get_axis("player_look_up", "player_look_down")) > 0.7):
			rotation = dirinput.angle()
	
	elif controller == false:
		look_at(get_global_mouse_position())
	
	if sucked_object != null:
		sucked_object.global_position = sucked_object.global_position.linear_interpolate($Hand/Position2D.global_position, delta * 15)


func _input(event):
	if event is InputEventMouseMotion:
		controller = false
	if event is InputEventJoypadMotion:
		controller = true


func _process(delta):
	screensize = get_viewport_rect().size
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
	
	if Input.is_action_pressed("player_suck"):
		suck_object(delta)
	
	if Input.is_action_pressed("player_shoot"):
		start_charge(delta)
	
	if Input.is_action_just_released("player_shoot"):
		shoot_object()


func suck_object(delta):
	if sucked_object == null:
		for body in objects_in_vision:
			var direction = ($Hand.global_position - body.global_position).normalized()
			body.apply_central_impulse(direction * suck_power)


func tip_touched(body):
	if sucked_object == null && Input.is_action_pressed("player_suck"):
		print("tip touched")
		sucked_object = body
		# sucked_object.mode = RigidBody2D.MODE_STATIC
		# $Hand/Position2D.add_child(body)
		$Vision.monitoring = false


func start_charge(delta):
	if sucked_object != null:
		$ChargeBar.value += delta * shoot_power_rate


func shoot_object():
	if sucked_object != null:
		var direction = (get_global_mouse_position() - sucked_object.global_position).normalized()
		sucked_object.apply_central_impulse(direction * $ChargeBar.value * shoot_power)
		print("shoot!")
		sucked_object = null
		$ChargeBar.value = 0
		$Vision.monitoring = true


func _on_Range_body_entered(body):
	pass


func _on_Range_body_exited(body):
	pass


func _on_Vision_body_entered(body):
	if body.is_in_group("components"):
		objects_in_vision.append(body)
	print(objects_in_vision)


func _on_Vision_body_exited(body):
	if body.is_in_group("components"):
		objects_in_vision.erase(body)
	print(objects_in_vision)
