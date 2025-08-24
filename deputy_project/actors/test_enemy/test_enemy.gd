extends CharacterBody3D

@export var health :int = 20

@onready var speed : float = run 
@export var run := 5.1

@onready var accel : float = ground_accel
@export var ground_accel := 10.1

@onready var drag : float = friction
@export var friction := 10.1

var dir : Vector3
var mov_vec : Vector3
var grav : Vector3

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var look_cast: RayCast3D = $LookCast
@onready var mantle_cast: RayCast3D = $MantleCast


var target

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
	
	if nav_agent.target_position:
		look_at(Vector3(nav_agent.get_next_path_position().x, global_position.y, nav_agent.get_next_path_position().z))


func _physics_process(delta: float) -> void:
	var h_rot = global_transform.basis.get_euler().y
	
	if look_cast.is_colliding() && look_cast.get_collider() is CharacterBody3D:
		target = look_cast.get_collider()
	
	if mantle_cast.is_colliding():
		global_position = mantle_cast.get_collision_point()
	
	if target:
		nav_agent.target_position = target.global_position
	
	
	if nav_agent.target_position:
		dir = Vector3(nav_agent.get_next_path_position() - global_position).normalized()
		mov_vec = mov_vec.move_toward(dir * speed, accel * delta)
	else:
		mov_vec = mov_vec.move_toward(Vector3.ZERO, drag * delta)
	
	if !is_on_floor():
		grav.y -= 9.8 * delta
	else:
		grav.y = 0
	velocity = mov_vec + grav
	
	
	move_and_slide()
	
	print(velocity)
