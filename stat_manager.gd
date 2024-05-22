extends Node

var time_spent: float

# Variables for score calculation
var score_gained: float

var rocket_speed: float = 1

func _calculate_score() -> void:
    score_gained = roundi(rocket_speed * time_spent)

func _physics_process(_delta: float) -> void:
    _calculate_score()
