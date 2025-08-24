extends CharacterBody3D

@export var health :int = 20

func _process(delta: float) -> void:
	#print(health)
	if health <= 0:
		queue_free()
