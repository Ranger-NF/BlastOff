extends "res://Collectables/collectable.gd"

func _on_collection() -> void:
    StatManager.emit_signal("star_count_changed", 1)
