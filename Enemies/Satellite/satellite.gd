extends "res://Enemies/Obstacle.gd"

func _ready() -> void:
    can_move = false
    UiManager.emit_signal("warning_announced")


func _on_warn_timer_timeout() -> void:
    can_move = true
