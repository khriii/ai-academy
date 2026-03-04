class_name InteractionComponent
extends Area2D

@export var interaction_area: CollisionShape2D
var collectibles: Array[Item]

func _ready() -> void:
	self.area_entered.connect(onJoin)
	
func onJoin(area: Area2D):
	var parent = area.get_parent()
	if parent is Collectible:
		parent.collect()
