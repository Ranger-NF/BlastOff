extends "res://Collectables/collectable.gd"

func _on_collection() -> void:
    const TWEEN_TIME: float = 0.5
    var collection_move_tween: Tween = create_tween().set_parallel(true)

    collection_move_tween.tween_property(self, "global_position", UiManager.star_count_global_pos, TWEEN_TIME).set_ease(Tween.EASE_IN)
    collection_move_tween.tween_property(self, "scale", Vector2(0, 0), TWEEN_TIME).set_ease(Tween.EASE_IN)

    await collection_move_tween.finished

    StatManager.emit_signal("star_count_changed", 1)
    self.free_obstacle()
