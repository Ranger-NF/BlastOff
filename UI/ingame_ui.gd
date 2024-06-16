extends Control

const status_messages = {
    "game_over": "Game Over",
}

var active_warnings: Dictionary = {}

const STAR_VISIBLE_TIME: float = 5

@onready var score_label = $WholeScreen/ScoreBox/Panel/VBoxContainer/Score
@onready var warning_sign: AnimatedSprite2D = $WarningSign

var is_warning_on: bool = false

func _ready() -> void:
    UiManager.warning_announced.connect(_flash_warning)
    UiManager.warning_withdrawn.connect(_stop_warning)

func _physics_process(_delta: float) -> void:
    score_label.text = "{score}".format({"score": StatManager.score_gained})

func _flash_warning(x_position: float, warning_id: int):
    var vertical_screen_size: float = get_viewport_rect().size.y

    var new_warning_sign: AnimatedSprite2D = warning_sign.duplicate()

    active_warnings[str(warning_id)] = new_warning_sign
    add_child(new_warning_sign)
    new_warning_sign.position = Vector2(x_position, (0.1 * vertical_screen_size))
    new_warning_sign.show()

func _stop_warning(warning_id: int):
    if not active_warnings.has(str(warning_id)):
        return

    var active_warning_sign: Node = active_warnings.get(str(warning_id))

    if not active_warning_sign: # Prevent it from trying to deleteit twice
        return

    active_warning_sign.hide()
    active_warning_sign.queue_free()
    active_warnings.erase(str(warning_id))



