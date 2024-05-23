extends CanvasLayer

enum {
    LEFT,
    RIGHT
}

func switch_pressed_button(current_button: int) -> void:
    match current_button:
        LEFT:
            GameManager.is_left_button_pressed = true
            GameManager.is_right_button_pressed = false
        RIGHT:
            GameManager.is_right_button_pressed = true
            GameManager.is_left_button_pressed = false

func _input(event: InputEvent) -> void:
    var screen_size = get_viewport().size
    if (event is InputEventScreenTouch and event.is_pressed()) or (event is InputEventScreenDrag):

        if event.position.x > (screen_size / 2):
            switch_pressed_button(RIGHT)
        else:
            switch_pressed_button(LEFT)
    elif event is InputEventScreenTouch and event.is_released():
        pass


#
#func _on_left_button_down() -> void:
    #GameManager.is_left_button_pressed = true
#
#func _on_left_button_up() -> void:
    #GameManager.is_left_button_pressed = false
#
#func _on_right_button_down() -> void:
    #GameManager.is_right_button_pressed = true
#
#func _on_right_button_up() -> void:
    #GameManager.is_right_button_pressed = false
