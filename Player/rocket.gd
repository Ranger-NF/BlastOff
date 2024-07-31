extends Area2D

signal rocket_shield_toggled(is_active: bool)

const MAX_SPEED: float = 100
const ACCELERATION: float = 70
const FRICTION = 90
const ROTATION_PER_FRAME = 50 # in degrees

const SHIELD_TEXTURE: Texture2D = preload("res://Player/Powerups/rocket_shield.svg")

@onready var flame_particle_node: CPUParticles2D = $CPUParticles2D
@onready var rocket_collision_shape: CollisionShape2D = $CollisionShape2D

@onready var color_overlay_node: Sprite2D = $Sprite/Color
@onready var texture_overlay_node: Sprite2D = $Sprite/Texture
@onready var powerup_overlay_node: Sprite2D = $Sprite/Powerup

signal player_hurt

var recently_collided_obstacles: Array[Node2D] = []

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

# Variables related to powerups
var is_shield_active: bool:
    set(value):
        self.emit_signal("rocket_shield_toggled", value)
        is_shield_active = value

var shield_lifetime: float = 15
var original_shield_scale: float = 0.3

var shield_scale_tween: Tween

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

    is_shield_active = true

func _ready() -> void:
    self.hide()
    GameManager.game_started.connect(_on_game_start)
    GameManager.game_over.connect(_on_game_over)

    GameManager.rocket_speed_changed.connect(_on_rocket_speed_changed)
    GameManager.ordered_rocket_to_target.connect(_set_target_pos)
    GameManager.rocket_has_reached_target.connect(_on_target_reached)

    self.connect("player_hurt", _on_hurt)
    self.rocket_shield_toggled.connect(_on_shield_toggled)

    $ShieldTimer.timeout.connect(func (): is_shield_active = false)
    $ShieldEndingTimer.timeout.connect(_blink_shield)

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
    if is_free_falling: # The rocket has already has got the signal that its hurt
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

    if not recently_collided_obstacles.has(area):
        recently_collided_obstacles.append(area)

        var removal_timer = get_tree().create_timer(0.5)
        removal_timer.timeout.connect(func (): recently_collided_obstacles.erase(area))

        if area.has_method("_on_hit"): # Calls the function present on the obstacle / collectable
            area.call("_on_hit")

        if area.is_in_group("obstacles"):
            if not is_shield_active:
                emit_signal("player_hurt")
            else:
                _expand_shield() # Make the shield shine


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

func _on_shield_toggled(is_activated: bool = false) -> void:
    if is_activated:

        powerup_overlay_node.texture = SHIELD_TEXTURE

        powerup_overlay_node.show()
        $ShieldTimer.start(shield_lifetime)
        $ShieldEndingTimer.start(shield_lifetime * .6)
    else:
        powerup_overlay_node.hide()

func _expand_shield() -> void:
    powerup_overlay_node.scale = Vector2(original_shield_scale, original_shield_scale)
    const SCALE_TIME_PERIOD: float = .2

    var single_scale_lifetime: float = SCALE_TIME_PERIOD / 2
    var shrinking_scale = Vector2(original_shield_scale * 0.7, original_shield_scale * 0.7)

    if shield_scale_tween and shield_scale_tween.is_running():
        shield_scale_tween.stop()
        shield_scale_tween.kill()

    shield_scale_tween = create_tween().set_parallel(true)
    shield_scale_tween.tween_property(powerup_overlay_node, "scale", shrinking_scale, single_scale_lifetime)
    shield_scale_tween.tween_property(powerup_overlay_node, "scale", Vector2(original_shield_scale, original_shield_scale), single_scale_lifetime).set_delay(single_scale_lifetime)

func _blink_shield() -> void:
    const TIMES_TO_BLINK: float = 3

    var fade_lifetime: float = (0.4 * shield_lifetime) / (TIMES_TO_BLINK / 2)
    var tween = create_tween().set_parallel(true)

    var times_blinked: int = 0
    var tween_turn_num: int = 0 # To calculate delay

    while times_blinked < TIMES_TO_BLINK:
        tween.tween_property(powerup_overlay_node, "modulate:a", 0,fade_lifetime).set_delay(tween_turn_num * fade_lifetime)
        tween_turn_num += 1
        tween.tween_property(powerup_overlay_node, "modulate:a", 1, fade_lifetime).set_delay(tween_turn_num * fade_lifetime)
        tween_turn_num += 1

        times_blinked += 1
