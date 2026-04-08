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

	# 1. CAMBIATO QUI: Usiamo i segnali per i Body!
	body_entered.connect(onJoin)
	body_exited.connect(onLeave)

# 2. Il parametro in ingresso ora è Node2D (il tipo base dei body)
func onJoin(body: Node2D) -> void:
	print("Entrato in contatto con: ", body.name)
	
	if body is Collectible:
		pass
		
	# 3. Ora 'body' è direttamente il tuo Npc (CharacterBody2D)!
	elif body is Npc and body.is_interactable:
		current_npc = body

func onLeave(body: Node2D) -> void:
	if body == current_npc:
		current_npc = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_npc:
		current_npc.interact()
		get_viewport().set_input_as_handled()
