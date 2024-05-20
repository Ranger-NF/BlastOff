extends Node2D

@export var asteroid_node: PackedScene

func spawn_asteroids():
    var screen_size = get_viewport_rect().size.x
    var spawn_location = Vector2(randf_range(0, screen_size), 0)

    var new_asteroid = asteroid_node.instantiate()
    new_asteroid.position = spawn_location
    add_child(new_asteroid)

func _ready() -> void:
    spawn_asteroids()




func _on_asteroid_timer_timeout() -> void:
    pass # Replace with function body.
