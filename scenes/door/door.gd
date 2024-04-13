extends Area3D

@export var scene_path : String
@export var teleport_position : Vector3
@export var teleport_rotation : Vector3
@export var character : CharacterBody3D
@onready var scene_to_go = load(scene_path)
signal entered(teleport_position, teleport_rotation, scene_to_go)

func _on_interactable_interacted(interactor):
	emit_signal("entered", teleport_position, teleport_rotation, scene_to_go)
