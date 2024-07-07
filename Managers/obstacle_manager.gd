## This file manages every configurable part of the obstacle

extends Node

enum {
    BIRD,
    SATELLITE,
    STAR,
}

@onready var OBSTACLE_SCENES: Dictionary = {
    BIRD: preload("res://Enemies/Birds/Bird.tscn"),
    SATELLITE: preload("res://Enemies/Satellite/satellite.tscn"),
    STAR: preload("res://Collectables/star.tscn")
}

var active_obstacles: Dictionary = {
    BIRD: [],
    SATELLITE: [],
    STAR: [],
}

# Related to spawning
var flock_probability: float = 0.2
var satellite_falling_propability: float = 0.1

# Related to grouping
var min_bird_flock_size: int = 6
var max_bird_flock_size: int = 8

func _ready() -> void:
    GameManager.level_up.connect(_on_level_up)

func _on_level_up() -> void:
    flock_probability += 0.05
    satellite_falling_propability += 0.05

func get_free_obstacle(obstacle_type: int) -> Node2D:
    var instantiable_res: PackedScene = OBSTACLE_SCENES.get(obstacle_type)

    if not instantiable_res:
        push_error("No such obstacle type")
        return null
    else:
        var new_obstacle: Node2D = instantiable_res.instantiate()
        (active_obstacles.get(obstacle_type) as Array).append(new_obstacle)
        return new_obstacle

func make_obstacle_free(obstacle_node: Node2D, obstacle_type: int) -> void:
    (active_obstacles.get(obstacle_type) as Array).erase(obstacle_node)
    obstacle_node.queue_free()
