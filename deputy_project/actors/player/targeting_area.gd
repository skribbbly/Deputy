extends Area3D


var TargetIndicator := preload("res://game_elements/target_indicator.tscn")
var target_indi
var target



func _process(delta: float) -> void:
	if target_indi:
		target_indi.global_position = target.global_position


func _on_area_entered(area: Area3D) -> void:
	target_indi = TargetIndicator.instantiate()
	get_parent().get_parent().get_parent().get_parent().add_child(target_indi)
	target = area
	


func _on_area_exited(area: Area3D) -> void:
	target = null
	target_indi.queue_free()
	target_indi = null
