extends "res://Collectables/collectable.gd"

func _on_collection() -> void:
    SkinManager.emit_signal("powerup_activated", collectable_type)
