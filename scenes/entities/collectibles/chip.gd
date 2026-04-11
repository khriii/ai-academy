class_name Chip
extends Collectible

@export var animation_player: AnimationPlayer

func _ready() -> void:
	if animation_player:
		animation_player.play("floating")

func collect():
	CollectiblesManager.collect(id)
	queue_free()
