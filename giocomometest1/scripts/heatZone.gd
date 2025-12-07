class_name HeatZone
extends Area2D

func _init() -> void:
	collision_layer = 3
	collision_mask = 1
	
func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	self.connect("area_exited", _on_area_exited)
	
func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox == null:
		return
	# Notifica il player che è entrato nella zona calda
	if hitbox.owner.has_method("enter_heat_zone"):
		hitbox.owner.enter_heat_zone()

func _on_area_exited(hitbox: Area2D) -> void:
	if hitbox == null:
		return
	# Notifica il player che è uscito dalla zona calda
	if hitbox.owner.has_method("exit_heat_zone"):
		hitbox.owner.exit_heat_zone()
