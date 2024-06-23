extends Control

var star_textures = [
    preload("res://Background/bg_star.svg"),
    preload("res://Background/bg_star_white.svg")
]

@onready var day_sky: TextureRect = $DaySky
@onready var night_sky: TextureRect = $NightSky

@onready var mother_star_node: TextureRect = $MotherStar
@onready var star_ray: Line2D = $Line2D

const DAY_PROPABILITY: float = 1 # CHANGE!!!

const MIN_CLUSTERS: int = 3
const MAX_CLUSTERS: int = 4

const MOTHER_STAR_SPAWN_MARGIN: float = 200 ## defines How far from the screen edge should be the boundary
const MIN_CLUSTER_LENGTH: float = 100
const MAX_CLUSTER_LENGTH: float = 100

const CHILD_STAR_SPACING: float = 20
const CHILD_STAR_MAX_DEVIATION: float = 500


var is_day_time: bool = true

var is_in_initial_setup: bool = true

func _ready() -> void:
    GameManager.time_phase_changed.connect(_on_time_phase_change)
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    _select_day_or_night()

func _select_day_or_night() -> void:
    var rand_num: float = randf()

    if rand_num > DAY_PROPABILITY:
        is_day_time = true
        GameManager.emit_signal("time_phase_changed", GameManager.TIME_PHASES.DAY)
    else:
        is_day_time = false
        GameManager.emit_signal("time_phase_changed", GameManager.TIME_PHASES.NIGHT)

func _on_time_phase_change(time_phase: int):
    if time_phase == GameManager.TIME_PHASES.DAY:
        day_sky.show()
        night_sky.hide()
    elif time_phase == GameManager.TIME_PHASES.NIGHT:
        night_sky.show()
        day_sky.hide()

        if is_in_initial_setup:
            await GameManager.screen_size_updated
            _spawn_stars()

func _on_screen_size_updated(screen_size: Vector2):
    if is_in_initial_setup:
        is_in_initial_setup = false

        $LightEmitter.position.x = screen_size.x * 0.8
        $LightEmitter.position.y = randf_range(0, screen_size.y * 0.3)

func _spawn_stars() -> void:
    var num_of_clusters = randi_range(MIN_CLUSTERS , MAX_CLUSTERS)
    var current_cluster_count: float = 0

    while current_cluster_count < num_of_clusters:
        _setup_clusters()
        current_cluster_count += 1

func _setup_clusters() -> void:
    star_ray.clear_points()

    var new_mother_star: TextureRect = mother_star_node.duplicate()
    self.add_child(new_mother_star)
    new_mother_star.visible = true

    var mother_star_location: Vector2 = Vector2(randf_range(MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.x - MOTHER_STAR_SPAWN_MARGIN) , randf_range(MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.y - MOTHER_STAR_SPAWN_MARGIN))
    new_mother_star.position = mother_star_location

    star_ray.position = mother_star_location
    star_ray.add_point(mother_star_location)

    var is_ray_in_optimal_spot: bool = false

    var current_cluster_length = randf_range(MIN_CLUSTER_LENGTH, MAX_CLUSTER_LENGTH)
    var cluster_rotation: float ## In radians

    while not is_ray_in_optimal_spot: # For checking
        print(star_ray.get_point_count())
        if star_ray.get_point_count() > 2:
            push_error("Unexpected no. of points")
        elif star_ray.get_point_count() == 2:
            star_ray.remove_point(star_ray.get_point_count() - 1)

        star_ray.add_point( Vector2(star_ray.position.x + ([1, -1].pick_random() * current_cluster_length), star_ray.position.y))
        cluster_rotation = deg_to_rad(randi_range(0, 360))

        star_ray.rotate(cluster_rotation)

        var pos_of_cluster_half: Vector2 = star_ray.get_point_position(1) / 2

        if _check_if_inside_range(pos_of_cluster_half.x, 0, GameManager.game_screen_size.x) or _check_if_inside_range(pos_of_cluster_half.y, 0, GameManager.game_screen_size.y):
            is_ray_in_optimal_spot = true
        else:
            is_ray_in_optimal_spot = false

    _spawn_cluster_members(new_mother_star, cluster_rotation, current_cluster_length)

func  _check_if_inside_range(value_to_check:float, range_start: float, range_end: float) -> bool:
    if value_to_check > range_start or value_to_check < range_end:
        return true
    else:
        return false

func _spawn_cluster_members(mother_star: Node, cluster_rotation, cluster_length: float = MIN_CLUSTER_LENGTH) -> void:
    var num_of_child_stars: int = roundi(cluster_length / CHILD_STAR_SPACING)
    var child_stars: Array[TextureRect] = []

    var current_spacing: float = 0

    while child_stars.size() < num_of_child_stars:
        var new_child_star: TextureRect = TextureRect.new()
        new_child_star.texture = star_textures.pick_random()

        current_spacing += CHILD_STAR_SPACING

        new_child_star.position = Vector2(current_spacing, randf_range(0, CHILD_STAR_MAX_DEVIATION))
        var rand_scale_value = randf_range(0.2, 0.5)
        new_child_star.scale = Vector2(rand_scale_value, rand_scale_value)

        child_stars.append(new_child_star)

    for star in child_stars:
        mother_star.add_child(star)

    mother_star.rotation = cluster_rotation
