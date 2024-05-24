extends Node

var time_spent: float

# Variables for score calculation
var score_gained: float
var current_level: int = 1

func _calculate_score() -> void:
    score_gained = roundi(current_level * time_spent)

    if !(roundi(score_gained) % roundi(pow(10, current_level))) and score_gained != 0:
        current_level += 1
        GameManager.emit_signal("rocket_speed_changed")

func _physics_process(_delta: float) -> void:
    _calculate_score()
