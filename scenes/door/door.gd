extends Area3D

@export var scene_to_go : PackedScene

func _on_interactable_interacted(interactor):
	get_tree().change_scene_to_packed(scene_to_go)
