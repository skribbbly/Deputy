extends Node


enum {
	FREE,
	TARGET,
}


var state : = FREE

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("mc"):
		pass
