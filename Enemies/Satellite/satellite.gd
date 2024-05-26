extends "res://Enemies/Obstacle.gd"

func _ready() -> void:
    GameManager.game_over.connect(_on_game_over)

    can_move = false
    UiManager.emit_signal("warning_announced", self.position.x)
    $WarnTimer.start(2)

func _on_warn_timer_timeout() -> void:
    can_move = true
    UiManager.emit_signal("warning_withdrawn")

func _on_game_over() -> void:
    UiManager.emit_signal("warning_withdrawn")
    queue_free()
