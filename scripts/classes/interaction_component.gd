class_name InteractionComponent
extends Area2D

@export var interaction_area: CollisionShape2D
var collectibles: Array[Item]
var current_npc: Npc = null

var filename = get_script().get_path()

func _ready() -> void:
	Global.check_nodes(filename, {
		"interaction_area": interaction_area,
	})

	body_entered.connect(onBodyJoin)
	body_exited.connect(onLeave)
	area_entered.connect(onAreaJoin)

func onBodyJoin(body: Node2D) -> void:
	print("Entrato in contatto con: ", body.name)
	
	if body is Chip:
		body.collect()
		
	elif body is Npc and body.is_interactable:
		current_npc = body

func onAreaJoin(area: Area2D) -> void:
	var parent = area.get_parent()
	
	print("Entrato in contatto con l'area: ", parent.name)
	
	if parent is Chip:
		parent.collect()

func onLeave(body: Node2D) -> void:
	if body == current_npc:
		current_npc = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_npc and not Global.is_dialogue_active:
		EventBus.npc_interacted.emit(current_npc.id)
		get_viewport().set_input_as_handled()
