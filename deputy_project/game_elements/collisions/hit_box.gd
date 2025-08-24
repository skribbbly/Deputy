extends Area3D

@export var damage := 5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	print(body, body.health)
	body.health -= damage


func _on_area_entered(area: Area3D) -> void:
	print("ZOMBIE")
	#print(area, area.get_parent().health)
	#area.get_parent().health -= damage
