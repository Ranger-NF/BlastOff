extends Area2D

@export var inital_speed = 30
@export var acceleration = 5
@export var max_speed = 60

var can_move: bool = false
var move_vec: Vector2 = Vector2.ZERO

func _ready() -> void:
    can_move = true
    move_vec.y = inital_speed

func _physics_process(delta: float) -> void:
    if can_move:
        move_vec.y += (acceleration * delta)
        move_vec.limit_length(max_speed)
