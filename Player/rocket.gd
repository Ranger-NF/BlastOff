extends Area2D

const MAX_SPEED: float = 100
const ACCELERATION: float = 70
const FRICTION = 90
const ROTATION_PER_FRAME = 50 # in degrees

@onready var flame_particle_node: CPUParticles2D = $CPUParticles2D
@onready var rocket_collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_overlay_node: Sprite2D = $Sprite/Color
@onready var texture_overlay_node: Sprite2D = $Sprite/Texture

signal player_hurt

var is_game_running: bool = false
var is_free_falling: bool = false

var move_vec: Vector2
var last_sway_direction: int = UiManager.DIRECTIONS.RESET

var rotation_reset_tween: Tween
var faceplant_tween: Tween
var time_idle: float = 0

var initial_flame_speed: float
var half_of_rocket_width: float

# Variable to control rocket using FOLLOW control
var has_target_pos: bool
var target_x_pos: float
var targetted_side: int


func _reset_properties() -> void:
    _update_current_skin()
    self.show()
    $CollisionShape2D.disabled = false

    half_of_rocket_width = rocket_collision_shape.shape.radius + 5

    if faceplant_tween:
        faceplant_tween.stop()
        faceplant_tween.kill()

    move_vec = Vector2.ZERO
    is_free_falling = false
    self.rotation = 0
    var screen_size = get_viewport_rect().size

    self.position.x = screen_size.x / 2
    self.position.y = 0.8 * screen_size.y

func _ready() -> void:
    self.hide()
    GameManager.game_started.connect(_on_game_start)
    GameManager.game_over.connect(_on_game_over)

    GameManager.rocket_speed_changed.connect(_on_rocket_speed_changed)
    GameManager.ordered_rocket_to_target.connect(_set_target_pos)
    GameManager.rocket_has_reached_target.connect(_on_target_reached)

    self.connect("player_hurt", _on_hurt)

    initial_flame_speed = GameManager.rocket_speed

func apply_friction(velocity: float, delta: float) -> float:
    var magniitude_of_vec = abs(velocity)
    var direction_of_vec = (velocity / magniitude_of_vec) # Gives either 1 or -1 (left or right)
    magniitude_of_vec -= FRICTION * delta # Reduces the velocity

    if direction_of_vec == UiManager.DIRECTIONS.LEFT:
        sway(UiManager.DIRECTIONS.RIGHT, delta)
    else:
        sway(UiManager.DIRECTIONS.LEFT, delta)
    return (direction_of_vec * magniitude_of_vec)

func sway(sway_direction: int, delta: float) -> void:
    if not sway_direction in [-1, 0, 1]:
        push_error("Inputted a value other than -1 or 1")
        return
    if sway_direction != UiManager.DIRECTIONS.RESET:

        # if last rotation was opposite to current, set to zero then, sway to current side
        if last_sway_direction != sway_direction and self.rotation != 0:
            if not rotation_reset_tween or not rotation_reset_tween.is_running() :
                rotation_reset_tween = create_tween()
                rotation_reset_tween.tween_property(self, "rotation", 0, 0.1)
        else:
            if rotation_reset_tween:
                rotation_reset_tween.stop()
                rotation_reset_tween.kill()

            last_sway_direction = sway_direction
            self.rotate(sway_direction * deg_to_rad(ROTATION_PER_FRAME * delta))
    else:
        if not rotation_reset_tween or not rotation_reset_tween.is_running() :
            rotation_reset_tween = create_tween()
            rotation_reset_tween.tween_property(self, "rotation", 0, 0.1)

func _free_fall(delta) -> void:
    self.position.y += (GameManager.rocket_speed * delta)

func _set_target_pos(new_target_x_pos: float, taget_side: int):
    has_target_pos = true
    target_x_pos = new_target_x_pos
    targetted_side = taget_side

func move(delta: float):
    if is_free_falling:
        return
    # Increment velocity with ACCELERATION if given the input
    if GameManager.is_left_button_pressed or GameManager.is_right_button_pressed: # Checking whether either button is pressed
        if (GameManager.is_left_button_pressed and GameManager.is_right_button_pressed): # If both buttons are pressed, cancel it
            move_vec.x = apply_friction(move_vec.x, delta)
            time_idle += delta
        else:
            time_idle = 0

            if GameManager.is_left_button_pressed: # If asked to move left, accelerate to max speed
                move_vec.x += -1 * (ACCELERATION * delta) # Accelerate to -ve x
                sway(UiManager.DIRECTIONS.LEFT, delta)

            elif GameManager.is_right_button_pressed:
                move_vec.x += (ACCELERATION * delta)
                sway(UiManager.DIRECTIONS.RIGHT, delta)

    # Slowing down (gradually)
    elif move_vec.length() > (FRICTION * delta):
        time_idle += delta
        move_vec.x = apply_friction(move_vec.x, delta)
    else:
        time_idle += delta
        move_vec = Vector2.ZERO # Stop the character

    if time_idle > 0.2:
        sway(UiManager.DIRECTIONS.RESET, delta)

    move_vec = move_vec.limit_length(MAX_SPEED)
    self.position += move_vec

    # Preventing player from moving outside the screen
    var horizontal_screen_size = get_viewport_rect().size.x

    if (self.position.x >= horizontal_screen_size - half_of_rocket_width) or (self.position.x <= half_of_rocket_width):
        sway(UiManager.DIRECTIONS.RESET, delta)
        self.position.x = clamp(self.position.x , half_of_rocket_width, horizontal_screen_size - half_of_rocket_width) # Prevents the rocket from going off the screen
        move_vec = Vector2.ZERO # Resets the velocity to sudden stop

    GameManager.current_rocket_x_pos = self.position.x

    if has_target_pos:
        _check_if_passed_point(self.position.x, target_x_pos, targetted_side)

func _physics_process(delta: float) -> void:
    if is_game_running and not is_free_falling:
        move(delta)
    elif is_free_falling:
        _free_fall(delta) # When the rocket hits something

func _on_hurt():
    if is_free_falling:
        return

    UiManager.emit_signal("triggered_menu_ui_setup")
    flame_particle_node.emitting = false
    is_free_falling = true

    if faceplant_tween:
        faceplant_tween.stop()
        faceplant_tween.kill()

    faceplant_tween = create_tween()
    faceplant_tween.tween_property(self, "rotation", deg_to_rad(180), 0.5)
    $CollisionShape2D.set_deferred("disabled", true)

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
    if area.has_method("_on_hit"):
        area.call("_on_hit")

    if area.is_in_group("obstacles"):
        emit_signal("player_hurt")


func _on_game_start() -> void:
    _reset_properties()
    flame_particle_node.emitting = true
    is_game_running = true

func _on_game_over() -> void:
    flame_particle_node.emitting = false
    self.hide()

func _update_current_skin() -> void:
    color_overlay_node.texture = SkinManager.current_skin_textures.color
    texture_overlay_node.texture = SkinManager.current_skin_textures.texture

func _on_rocket_speed_changed(new_rocket_speed: float):
    flame_particle_node.speed_scale = new_rocket_speed / initial_flame_speed

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    self.hide()
    is_game_running = false

func _check_if_passed_point(current_x_pos: float, target_pos: float, target_side: int):
    match target_side:
        UiManager.DIRECTIONS.LEFT:
            if current_x_pos <= target_pos:
                GameManager.emit_signal("rocket_has_reached_target")

        UiManager.DIRECTIONS.RIGHT:
            if current_x_pos >= target_pos:
                GameManager.emit_signal("rocket_has_reached_target")

func _on_target_reached():
    has_target_pos = false
