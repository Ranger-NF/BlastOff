class_name Obstacle
extends Area2D

@export var free_fall_multiplier: float = 1 # Ideally more than 1, for faster obstacle
@export var can_be_grouped: bool = false
@export var can_move_horizontally: bool = true

## Variables to configure groups
var is_flock_leader: bool = true
var flock_speed: float = 10
var initial_leader_pos: Vector2 = Vector2.ZERO

@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var can_move: bool = false
var move_vec: Vector2 = Vector2.ZERO

# For objects that move across the screen
var horizontal_min_speed: float = 3
var horizontal_max_speed: float = 6
var horizontal_speed: float = 0 # Should be constant speed

func _ready() -> void:
    can_move = true
    GameManager.game_over.connect(_on_game_over)
    if can_move_horizontally:
        _determine_horizontal_movement()

    if self.has_method("_further_setup"):
        self.call("_further_setup")

func _determine_horizontal_movement() -> void:
    if is_flock_leader:
        horizontal_speed = randf_range(horizontal_min_speed, horizontal_max_speed) # Randomize
        flock_speed = horizontal_speed
    else:
        horizontal_speed = flock_speed

    var horizontal_screen_size = get_viewport_rect().size.x

    var initial_pos = self.position

    if not is_flock_leader: # To prevent members of flock from flying to opposite side
        initial_pos = initial_leader_pos

    if initial_pos.x > (horizontal_screen_size / 2): # If on the right side move to left
        horizontal_speed *= -1 # Make it move to left side (-ve x)
        $AnimatedSprite2D.flip_h = true


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

    if can_move_horizontally:
        move_vec.x += (horizontal_speed * delta)

        move_vec.x = limit_speed(move_vec.x, horizontal_speed)
        self.position.x += move_vec.x

func limit_speed(current_speed: float, max_speed: float) -> float:
    if current_speed > max_speed:
        return max_speed
    else:
        return current_speed

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()

func _on_hit() -> void:
    collision_shape.set_deferred("disabled", true)
    hit_sound.play()
    if self.has_method("_after_hit"): self.call("_after_hit")

func _on_game_over() -> void:
    collision_shape.set_deferred("disabled", true)
    if horizontal_speed != 0:

        if horizontal_speed < 0: # Preventing from changing directions
            horizontal_speed = -1 * horizontal_max_speed * 1.5
        else:
            horizontal_speed = horizontal_max_speed * 1.5

        free_fall_multiplier = 0
        _change_anim_speed()
    else:
        free_fall_multiplier += 1

