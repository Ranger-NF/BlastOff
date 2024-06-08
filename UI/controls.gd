extends Control

enum {
    LEFT,
    RIGHT
}

func _ready() -> void:
    GameManager.game_over.connect(func (): get_parent().remove_child(self))

func switch_pressed_button(current_button: int) -> void:
    match current_button:
        LEFT:
            GameManager.is_left_button_pressed = true
            GameManager.is_right_button_pressed = false
        RIGHT:
            GameManager.is_right_button_pressed = true
            GameManager.is_left_button_pressed = false

func _input(event: InputEvent) -> void:
    var horizontal_screen_size = get_viewport_rect().size.x
    if (event is InputEventScreenTouch and event.is_pressed()) or (event is InputEventScreenDrag):

        if event.position.x > (horizontal_screen_size / 2):
            switch_pressed_button(RIGHT)
        else:
            switch_pressed_button(LEFT)
    elif event is InputEventScreenTouch and event.is_released():
        if event.position.x > (horizontal_screen_size / 2):
            GameManager.is_right_button_pressed = false
        else:
            GameManager.is_left_button_pressed = false
