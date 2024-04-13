extends Interactor

@export var player : CharacterBody3D
@onready var mouse_texture_1 = load("res://assets/textures/cursor1.png")
@onready var mouse_texture_2 = load("res://assets/textures/cursor2.png")
var mouse_rect = MousePointer.get_node("MouseRect")
var look_threshold : float = 0.5 
var cached_closest : Interactable = null

func get_closest_interactable() -> Interactable:
	var interactables = get_overlapping_areas().filter(func(area): return area is Interactable)
	var closest : Interactable = null
	var closest_distance : float = INF
	var player_direction = player.head.global_transform.basis.z.normalized()

	for interactable in interactables:
		if is_facing(interactable, player_direction):
			var distance = global_position.distance_to(interactable.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest = interactable

	return closest

func is_facing(target: Interactable, direction: Vector3) -> bool:
	var to_target = (target.global_position - player.global_position).normalized()
	var local_to_target = player.to_local(to_target)
	return direction.dot(local_to_target) > look_threshold


func focus(target: Interactable) -> void:
	mouse_rect.texture = mouse_texture_2

func unfocus(target: Interactable) -> void:
	mouse_rect.texture = mouse_texture_1

func _physics_process(delta):
	var new_closest : Interactable = get_closest_interactable()
	if new_closest != cached_closest:
		if is_instance_valid(cached_closest):
			unfocus(cached_closest)
		if new_closest:
			focus(new_closest)
		cached_closest = new_closest

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if cached_closest:
			interact(cached_closest)

func _on_area_exited(area : Interactable) -> void:
	if cached_closest == area:
		unfocus(area)
