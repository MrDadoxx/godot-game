extends Node3D

@onready var player = get_parent().get_parent().get_parent().get_node("Entities/Player")

func _process(delta):
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
