class_name InteractionComponent
extends Area2D

@export var interaction_area: CollisionShape2D
var collectibles: Array[Item]

var filename = get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"interaction_area": interaction_area,
	})

	self.area_entered.connect(onJoin)


func onJoin(area: Area2D):
	var parent = area.get_parent()
	if parent is Collectible:
		pass
		#parent.collect()
