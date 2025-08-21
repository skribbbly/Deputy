extends CharacterBody3D


@onready var speed : float = run 
@export var run := 5.1

@onready var accel : float = ground_accel
@export var ground_accel := 10.1

@onready var drag : float = friction
@export var friction := 10.1


var dir : Vector3
var mo_vec : Vector3
var grav : Vector3


@onready var mesh := $base_character
@onready var anim := $AnimationTree
@onready var climbray: RayCast3D = $base_character/ClimbRay
@onready var col: CollisionShape3D = $CollisionShape3D



func _process(delta: float) -> void:
	mesh.global_position = global_position
	if dir != Vector3.ZERO:
			mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-dir.x, -dir.z), 10 * delta)
	
	if Input.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("FPS: ", Engine.get_frames_per_second())

func _physics_process(delta: float) -> void:
	var h_rot = global_transform.basis.get_euler().y
	var input_vec := Vector2.ZERO
	input_vec.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	input_vec.y = Input.get_action_strength("s") - Input.get_action_strength("w")
	dir = Vector3(input_vec.x,0, input_vec.y).rotated(Vector3.UP, h_rot).normalized()
	
	if input_vec != Vector2.ZERO:
		mo_vec = mo_vec.move_toward(dir * speed, accel * delta)
	else:
		mo_vec = mo_vec.move_toward(Vector3.ZERO, accel * delta)
	
	
	if !is_on_floor():
		grav.y -= 9.8 * delta
		anim.set("parameters/AirSwamp/transition_request", "Air")
		col.shape.height = 1.1
		if climbray.is_colliding():
			if Input.is_action_just_pressed("space"):
				global_position = climbray.get_collision_point()
		
	else:
		grav.y = 0
		anim.set("parameters/AirSwamp/transition_request", "Ground")
		col.shape.height = 1.6
		if Input.is_action_just_pressed("space"):
			if climbray.is_colliding():
				global_position = climbray.get_collision_point()
			else:
				grav.y += 4
	
	anim.set("parameters/RunBlend/blend_amount", clamp(mo_vec.length() / speed, 0.0, 1.0))
	
	velocity = mo_vec + grav
	
	move_and_slide()
