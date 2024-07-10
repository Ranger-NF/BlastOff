extends Control

var star_textures = [
    preload("res://Background/bg_star.svg"),
    preload("res://Background/bg_star_white.svg")
]

@onready var day_sky: TextureRect = $DaySky
@onready var night_sky: TextureRect = $NightSky

@onready var mother_star_node: TextureRect = $MotherStar
@onready var star_ray: Line2D = $Line2D

@onready var light_emitter_node: TextureRect = $LightEmitter
@onready var star_clusters_group: Node2D = $StarClusters

const DAY_PROPABILITY: float = 0.5

const CHUNK_WIDTH: float = 350 # For determining no. of clusters

const MOTHER_STAR_SPAWN_MARGIN: float = 150 ## defines How far from the screen edge should be the boundary
const MIN_CLUSTER_LENGTH: float = 100
const MAX_CLUSTER_LENGTH: float = 130

const MIN_CLUSTER_GAP: float = 100

const CHILD_STAR_SPACING: float = 35
const CHILD_STAR_MIN_DEVIATION: float = 250
const CHILD_STAR_MAX_DEVIATION: float = 350

var current_mother_stars: Array[TextureRect] = []

var is_in_initial_setup: bool = true
var has_star_generated: bool = false

func _ready() -> void:
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    UiManager.time_phase_changed.connect(_on_time_phase_change)
    UiManager.background_reload_requested.connect(_update_background)

    _update_background()

func _update_background() -> void:
    var current_background_type: int = DataManager.settings.background_selection

    match current_background_type:
        UiManager.BACKGROUND_TYPES.RANDOM:

            var rand_num: float = randf()

            if rand_num > DAY_PROPABILITY:

                UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.DAY)
            else:
                UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.NIGHT)

        UiManager.BACKGROUND_TYPES.DAY:

            UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.DAY)

        UiManager.BACKGROUND_TYPES.NIGHT:
            UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.NIGHT)

        UiManager.BACKGROUND_TYPES.TIME_BASED:
            # Get time from os
            var current_system_time: Dictionary = Time.get_time_dict_from_system()

            # If 6AM - 6PM then, consider it as a day
            if current_system_time.hour > 6 and current_system_time.hour < 18:

                UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.DAY)
            else:
                UiManager.emit_signal("time_phase_changed", UiManager.TIME_PHASES.NIGHT)



func _on_time_phase_change(time_phase: int):
    if time_phase == UiManager.TIME_PHASES.DAY:
        day_sky.show()
        night_sky.hide()
        light_emitter_node.self_modulate.b = 0.6

        star_clusters_group.hide()

    elif time_phase == UiManager.TIME_PHASES.NIGHT:
        night_sky.show()
        day_sky.hide()
        light_emitter_node.self_modulate.b = 1

        star_clusters_group.show()

        if not has_star_generated:
            if is_in_initial_setup:
                await GameManager.screen_size_updated
            _spawn_stars()
            has_star_generated = true

func _on_screen_size_updated(screen_size: Vector2):
    if is_in_initial_setup:
        is_in_initial_setup = false

        light_emitter_node.position.x = screen_size.x * [0.8, 0.1].pick_random()
        light_emitter_node.position.y = randf_range(0, screen_size.y * 0.2)

func _spawn_stars() -> void:
    star_ray.show()
    current_mother_stars.clear()

    var num_of_clusters = _determine_cluster_count()

    while current_mother_stars.size() < num_of_clusters:
        current_mother_stars.append(_setup_clusters(current_mother_stars.size()))

    for each_mother in current_mother_stars:
        each_mother.reparent(star_clusters_group)

    star_ray.hide()
    light_emitter_node.move_to_front()


func _setup_clusters(current_cluster_num: int) -> TextureRect: # Returns mothers star location (i.e cluster origin)
    star_ray.clear_points()

    var new_mother_star: TextureRect = mother_star_node.duplicate()
    self.add_child(new_mother_star)
    new_mother_star.visible = true

    var mother_star_location: Vector2 = Vector2(randf_range((current_cluster_num * CHUNK_WIDTH) - CHUNK_WIDTH, current_cluster_num * CHUNK_WIDTH) , randf_range(MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.y - MOTHER_STAR_SPAWN_MARGIN))
    mother_star_location.clamp(Vector2(MOTHER_STAR_SPAWN_MARGIN, MOTHER_STAR_SPAWN_MARGIN), Vector2(GameManager.game_screen_size.x - MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.y - MOTHER_STAR_SPAWN_MARGIN))

    new_mother_star.position = mother_star_location
    mother_star_node.texture = star_textures.pick_random()

    star_ray.position = mother_star_location
    star_ray.add_point(mother_star_location)


    var current_cluster_length = randf_range(MIN_CLUSTER_LENGTH, MAX_CLUSTER_LENGTH)
    var cluster_rotation: float ## In radians

    star_ray.rotation = 0

    if star_ray.get_point_count() > 2:
        push_error("Unexpected no. of points")
    elif star_ray.get_point_count() == 2:
        star_ray.remove_point(star_ray.get_point_count() - 1)

    star_ray.add_point( Vector2(star_ray.position.x + ([1, -1].pick_random() * current_cluster_length), star_ray.position.y))

    if new_mother_star.position.x < (GameManager.game_screen_size.x / 2): # Cluster on the left side of screen
        cluster_rotation = deg_to_rad(randi_range(-60, 60))
    else:
        cluster_rotation = deg_to_rad(randi_range(130, 240))

    star_ray.rotate(cluster_rotation)
    star_ray.rotation = 0
    _spawn_cluster_members(new_mother_star, cluster_rotation, current_cluster_length)
    return new_mother_star

func _spawn_cluster_members(mother_star: Node, cluster_rotation, cluster_length: float = MIN_CLUSTER_LENGTH) -> void:
    var num_of_child_stars: int = roundi(cluster_length / CHILD_STAR_SPACING) * 2
    var child_stars: Array[TextureRect] = []

    var current_spacing: float = 0

    while child_stars.size() < num_of_child_stars:
        var new_child_star: TextureRect = TextureRect.new()
        new_child_star.texture = star_textures.pick_random()
        new_child_star.self_modulate.g = randf_range(0.6, 1)

        new_child_star.position = Vector2(current_spacing, randf_range(CHILD_STAR_MIN_DEVIATION, CHILD_STAR_MAX_DEVIATION))
        current_spacing += CHILD_STAR_SPACING
        var rand_scale_value = randf_range(0.2, 0.7)
        new_child_star.scale = Vector2(rand_scale_value, rand_scale_value)

        child_stars.append(new_child_star)

    for star in child_stars:
        mother_star.add_child(star)

    mother_star.rotation = cluster_rotation

func _determine_cluster_count() -> int:
    return roundi(GameManager.game_screen_size.x / CHUNK_WIDTH) + 1
