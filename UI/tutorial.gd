extends Control

@onready var left_tutorial: VBoxContainer = $VBoxContainer/HBoxContainer/MarginContainer/LeftTutorial
@onready var right_tutorial: VBoxContainer =$VBoxContainer/HBoxContainer/MarginContainer2/RightTutorial

@onready var objective_label: Label = $VBoxContainer/Objective

var initial_rocket_speed: float # For accessing after tutorial is done

var is_tutorial_finished: bool = true
var next_needed_input: int # Either left or right
var current_stage: int
var previous_stage: int = -1

enum {
    RIGHT,
    LEFT,
    END,
}

func _ready() -> void:
    UiManager.show_tutorial.connect(show_tutorial)
    self.hide()
    left_tutorial.hide()
    right_tutorial.hide()
    objective_label.hide()

func show_tutorial() -> void:

    self.show()
    initial_rocket_speed = GameManager.rocket_speed
    GameManager.emit_signal("rocket_speed_changed", 100)
    current_stage = RIGHT # Initializing
    is_tutorial_finished = false
    _check_tutorial_status()

func _check_tutorial_status() -> void:
        if previous_stage == current_stage:
            return

        match current_stage:
            RIGHT: # Shows right side instructions and wait for input
                right_tutorial.show()
                left_tutorial.hide()
                objective_label.hide()
            LEFT:
                left_tutorial.show()
                right_tutorial.hide()
                objective_label.hide()
            END: # Shows objective label and in the nxt step, make it fade
                objective_label.show()
                right_tutorial.hide()
                left_tutorial.hide()

                is_tutorial_finished = true
                await get_tree().create_timer(3).timeout

                _on_tutorial_finished()

            _:
                previous_stage = current_stage

func _physics_process(_delta: float) -> void:
    if not is_tutorial_finished:
        if GameManager.is_right_button_pressed and current_stage == RIGHT:
            current_stage = LEFT
            _check_tutorial_status()
        elif GameManager.is_left_button_pressed and current_stage == LEFT:
            current_stage = END
            _check_tutorial_status()

func _on_tutorial_finished() -> void:
    GameManager.emit_signal("rocket_speed_changed", initial_rocket_speed)
    objective_label.hide()

