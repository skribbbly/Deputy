extends CharacterBody3D


var TargetIndicator := preload("res://game_elements/target_indicator.tscn")

enum {
	FREE,
	TARGET,
}

var state : = FREE

@onready var mesh := $base_character
@onready var anim := $AnimationTree
@onready var climbray: RayCast3D = $base_character/ClimbRay
@onready var ground_cast: RayCast3D = $GroundCast

@onready var col: CollisionShape3D = $CollisionShape3D

@onready var cam_root: Node3D = $head
@onready var spring_arm: SpringArm3D = $head/SpringArm3D
@onready var cam: Camera3D = $head/SpringArm3D/Camera3D
@onready var cam_pos: Marker3D = $CamPos




@onready var speed : float = run 
@export var run := 5.1

@onready var accel : float = ground_accel
@export var ground_accel := 10.1

@onready var drag : float = friction
@export var friction := 10.1



var dir : Vector3
var mo_vec : Vector3
var grav : Vector3


var target_list : Dictionary = {}
var target_indi
var target


var can_cut := true
@onready var mouse_free := false


var health :int = 20


func _process(delta: float) -> void:
	mesh.global_position = global_position
	
	match state:
		FREE:
			if dir != Vector3.ZERO:
				mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-dir.x, -dir.z), 10 * delta)
				
			if !target_list.is_empty():
				target = find_target()
			else:
				if target_indi != null:
					target_indi.queue_free()
					target_indi = null
					target = null
			
			if Input.is_action_just_pressed("mc") and target:
				state = TARGET
		TARGET:
			mesh.look_at(Vector3(target.global_position.x,global_position.y,target.global_position.z))
			cam_root.global_position = (Vector3(global_position.x,global_position.y + 1.1,global_position.z) + target.global_position) / 2
			spring_arm.spring_length = global_position.distance_to(cam_root.global_position) * 1.7
			
			anim.set("parameters/TargBlend/blend_amount", 1)
			
			var mesh_dir = dir.rotated(Vector3.UP, -mesh.global_transform.basis.get_euler().y).normalized()
			
			if Input.is_action_just_pressed("mc"):
				cam_root.global_position = cam_pos.global_position
				spring_arm.spring_length = 2.3
				state = FREE
	
	
	if target_indi and target:
		target_indi.global_position = target.global_position
	
	if Input.is_action_pressed("esc"):
		mouse_free = !mouse_free
		set_mouse()
	
	
	
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
		if col.shape.height == 1.1:
			global_position.y = ground_cast.get_collision_point().y
		col.shape.height = 1.6
		if Input.is_action_just_pressed("space"):
			if climbray.is_colliding():
				global_position = climbray.get_collision_point()
			else:
				grav.y += 4
		
		if can_cut:
			if Input.is_action_just_pressed("lc"):
				attack()
	
	anim.set("parameters/RunBlend/blend_amount", clamp(mo_vec.length() / speed, 0.0, 1.0))
	
	velocity = mo_vec + grav
	
	move_and_slide()



func attack():
	anim.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	can_cut = false



func find_target() -> Area3D:
	if !target_indi:
		target_indi = TargetIndicator.instantiate()
		get_parent().add_child(target_indi)
	
	
	var nearest = null
	var closest_distance = INF
	
	for area in target_list.values():
		var distance = global_position.distance_to(area.global_position)
		
		if distance < closest_distance:
			closest_distance = distance
			nearest = area
		
	
	target_indi.global_position = nearest.global_position
	
	return nearest
	


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Targetable"):
		target_list[area.get_instance_id()] = area
		
		print("Target Entered: ", area.get_instance_id())
		

func _on_area_3d_area_exited(area: Area3D) -> void:
	var id = area.get_instance_id()
	if id in target_list:
		target_list.erase(id)
		
		print("Erased from Target List: ", area.get_instance_id())



func set_mouse():
	if mouse_free:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Cut":
		can_cut = true
