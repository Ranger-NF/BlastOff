extends Control

const status_messages = {
    "game_over": "Game Over",
}

@onready var whole_ui = $CanvasLayer/WholeScreen

@onready var score_label = $CanvasLayer/WholeScreen/WholeCenter/ScoreBox/Score
@onready var game_status_label = $CanvasLayer/WholeScreen/WholeCenter/NavBox/GameStatus
@onready var warning_sign = $CanvasLayer/Warning
@onready var warning_anim = $CanvasLayer/WarningAnimation

@onready var navigation_box = $CanvasLayer/WholeScreen/WholeCenter/NavBox

var is_warning_on: bool = false

func _ready() -> void:
    whole_ui.hide()
    GameManager.game_over.connect(_show_game_status.bind("game_over"))
    GameManager.game_started.connect(_on_game_start)

    UiManager.warning_announced.connect(_flash_warning)
    UiManager.warning_withdrawn.connect(_stop_warning)

func _physics_process(_delta: float) -> void:
    score_label.text = "{score}".format({"score": StatManager.score_gained})

func _show_game_status(current_status: String) -> void:
    game_status_label.text = status_messages.get(current_status)
    navigation_box.show()

func _flash_warning(x_position: float):
    var vertical_screen_size: float = get_viewport_rect().size.y
    warning_sign.position = Vector2(x_position, (0.1 * vertical_screen_size))
    warning_sign.show()
    warning_anim.play("warning_sign")

func _stop_warning():
    warning_anim.stop()
    warning_sign.hide()

func _on_game_start() -> void:
    whole_ui.show()
    navigation_box.hide()

func _on_restart_button_pressed() -> void:
    GameManager.emit_signal("game_started")

func _on_back_button_pressed() -> void:
    whole_ui.hide()
    UiManager.emit_signal("skipped_to_main_menu")
