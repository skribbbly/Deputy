extends Node3D

@export_category("Camera Control")
@export_group("Mouse")
@export var mouse_sensitivity := 0.1

@export var min_arm_length := .7    # closest‑in distance
@export var max_arm_length := 2.5    # farthest‑out distance
@export var max_tilt_for_zoom := 60  # degrees of pitch that maps to max length


@onready var player := get_parent()
@onready var cam := $SpringArm3D/Camera3D
@onready var spring_arm := $SpringArm3D

var pos_dif : Vector3


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if !player.state == player.TARGET:
		_update_arm_length()

func _process(delta: float) -> void:
	player.rotation.y = get_parent().rotation.y

func _update_arm_length() -> void:
	# |rotation.x| goes 0 → max_tilt_for_zoom  (in radians)  
	var tilt = abs(rotation.x)
	var t := inverse_lerp(deg_to_rad(89), 0.0, rotation.x)

	spring_arm.spring_length = lerp(min_arm_length, max_arm_length, t)
