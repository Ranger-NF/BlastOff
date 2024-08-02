## This file manages every configurable part of the obstacle

extends Node

enum {
    BIRD,
    SATELLITE,
    STAR,
    SHIELD,
    BOOST
}

@onready var SPAWNABLE_SCENES: Dictionary = {
    BIRD: preload("res://Enemies/Birds/Bird.tscn"),
    SATELLITE: preload("res://Enemies/Satellite/satellite.tscn"),
    STAR: preload("res://Collectables/Star/star.tscn"),
    SHIELD: preload("res://Collectables/Shield/shield.tscn"),
    BOOST: preload("res://Collectables/Boost/boost.tscn")
}

var active_spawns: Dictionary = {
    BIRD: [],
    SATELLITE: [],
    STAR: [],
    SHIELD: [],
    BOOST: []
}

var difficulty_level_values = {
    GameManager.DIFFICULTY_LEVELS.EASY: {
        BIRD: {
            "flock_probability" = 0.2,
            "horizontal_speed" = {
                "min": 6,
                "max": 8,
            },
            "flock_size" = {
                "min": 2,
                "max": 4,
            },
            "spawning_interval" = {
                "min": 0.5,
                "max": 2.5,
            },
        },
        SATELLITE: {
            "spawning_propabilty" = 0.2,
            "spawning_interval" = {
                "min": 3,
                "max": 7,
            },
        },
        STAR: {
            "spawning_interval" = {
                "min": 2,
                "max": 5,
            },
        }
    },
    GameManager.DIFFICULTY_LEVELS.NORMAL: {
        BIRD: {
            "flock_probability" = 0.6,
            "horizontal_speed" = {
                "min": 7,
                "max": 9,
            },
            "flock_size" = {
                "min": 4,
                "max": 7,
            },
            "spawning_interval" = {
                "min": 0.35,
                "max": 2,
            },
        },
        SATELLITE: {
            "spawning_propabilty" = 0.6,
            "spawning_interval" = {
                "min": 1,
                "max": 4,
            },
        },
        STAR: {
            "spawning_interval" = {
                "min": 1,
                "max": 4,
            },
        }
    },
    GameManager.DIFFICULTY_LEVELS.HARD: {
        BIRD: {
            "flock_probability" = 0.9,
            "horizontal_speed" = {
                "min": 3,
                "max": 10,
            },
            "flock_size" = {
                "min": 6,
                "max": 10,
            },
            "spawning_interval" = {
                "min": 0.2,
                "max": 1.5,
            },
        },
        SATELLITE: {
            "spawning_propabilty" = 1,
            "spawning_interval" = {
                "min": 0,
                "max": 3
            },
        },
        STAR: {
            "spawning_interval" = {
                "min": 0.5,
                "max": 2.5,
            },
        },
    },
}

# Related to spawning
var current_bird_flock_probability: float
var current_satellite_spawning_propability: float

var current_bird_spawning_interval: Vector2
var current_satellite_spawning_interval: Vector2
var current_star_spawning_interval: Vector2

# Related to grouping
var current_bird_flock_size: Vector2i = Vector2i(6, 8)

# Related to horizontal movment
var bird_horizontal_speed: Vector2 = Vector2(3, 6) # Represents minimum and maxmum speed

func _ready() -> void:
    GameManager.level_up.connect(_on_level_up)

    GameManager.difficulty_level_changed.connect(_reload_difficulty_data)

    _reload_difficulty_data()

func _reload_difficulty_data(difficulty_level: int = GameManager.current_difficulty_level):
    var current_difficulty_data: Dictionary = difficulty_level_values.get(difficulty_level)

    var bird_data: Dictionary = current_difficulty_data.get(BIRD)

    current_bird_flock_probability = bird_data.flock_probability
    current_bird_flock_size = Vector2i(bird_data.get("flock_size").min, bird_data.get("flock_size").max)
    bird_horizontal_speed = Vector2(bird_data.get("horizontal_speed").min, bird_data.get("horizontal_speed").max)
    current_bird_spawning_interval = Vector2(bird_data.get("spawning_interval").min, bird_data.get("spawning_interval").max)

    var satellite_data: Dictionary = current_difficulty_data.get(SATELLITE)

    current_satellite_spawning_propability = satellite_data.get("spawning_propabilty")
    current_star_spawning_interval = Vector2(satellite_data.get("spawning_interval").min, satellite_data.get("spawning_interval").max)

    var star_data: Dictionary = current_difficulty_data.get(STAR)

    current_star_spawning_interval = Vector2(star_data.get("spawning_interval").min, star_data.get("spawning_interval").max)


func _on_level_up() -> void:
    return
    #current_bird_flock_probability += 0.05
    #current_satellite_spawning_propability += 0.05

func get_free_obstacle(obstacle_type: int) -> Node2D:
    var instantiable_res: PackedScene = SPAWNABLE_SCENES.get(obstacle_type)

    if not instantiable_res:
        push_error("No such obstacle type")
        return null
    else:
        var new_obstacle: Node2D = instantiable_res.instantiate()
        (active_spawns.get(obstacle_type) as Array).append(new_obstacle)
        return new_obstacle

func make_obstacle_free(obstacle_node: Node2D, obstacle_type: int) -> void:
    (active_spawns.get(obstacle_type) as Array).erase(obstacle_node)
    obstacle_node.queue_free()
