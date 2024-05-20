extends Area2D

var max_speed: int = 60
var move_vec: float

var target_pos: Vector2 # Can have 2 values: left (-1, 0) or right (1,0)

func _physics_process(delta: float) -> void:
    if not move_vec == 0.0:
        self.position += move_vec


func _input(event: InputEvent) -> void:
    if (event is InputEventScreenTouch):
        print(event.position)
