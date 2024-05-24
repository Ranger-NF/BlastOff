extends Control

const status_messages = {
    "game_over": "Game Over",
}

@onready var score_label = $CanvasLayer/HBoxContainer/VBoxContainer2/Score
@onready var game_status = $CanvasLayer/GameStatus

func _physics_process(_delta: float) -> void:
    score_label.text = "{score}".format({"score": StatManager.score_gained})

func _show_game_status(current_status: String) -> void:
    pass

