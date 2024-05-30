class_name Obstacle
extends Area2D

@export var free_fall_multiplier: float = 1 # Ideally more than 1, for faster obstacle
@export var can_be_grouped: bool = false
@export var can_move_horizontally: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_move: bool = false
var move_vec: Vector2 = Vector2.ZERO

enum {
    LEFT,
    RIGHT
}

# For objects that move across the screen
var horizontal_min_speed: float = 3
var horizontal_max_speed: float = 10
var horizontal_speed: float = 0 # Should be constant speed

var direction_to_move: int # Left or Right

func _ready() -> void:
    can_move = true
    if can_move_horizontally:
        horizontal_speed = randf_range(3, 10 ) # Randomize

    var horizontal_screen_size = get_viewport_rect().size.x
    if horizontal_speed != 0 and self.position.x > (horizontal_screen_size / 2): # If on the right side move to left
        direction_to_move = LEFT
    else:
        direction_to_move = RIGHT

func _change_anim_speed():
    var new_speed_scale =  horizontal_speed / ((horizontal_min_speed + horizontal_max_speed)/2)
    animated_sprite.speed_scale = new_speed_scale

func free_fall(delta) -> void:
    move_vec.y = (GameManager.rocket_speed * free_fall_multiplier * delta)

    self.position.y += move_vec.y

func _physics_process(delta: float) -> void:
    if not can_move:
        return

    free_fall(delta)
    if not horizontal_speed == 0:

        match direction_to_move:
            RIGHT:
                move_vec.x += (horizontal_speed * delta)
                $AnimatedSprite2D.flip_h = false
            LEFT:
                move_vec.x += -1 * (horizontal_speed * delta) # Make it move to left side (-ve x)
                $AnimatedSprite2D.flip_h = true

        move_vec.x = limit_speed(move_vec.x, horizontal_speed)
        self.position.x += move_vec.x

func limit_speed(current_speed: float, max_speed: float) -> float:
    if current_speed > max_speed:
        return max_speed
    else:
        return current_speed

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()
