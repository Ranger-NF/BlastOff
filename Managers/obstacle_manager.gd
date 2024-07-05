## This file manages every configurable part of the obstacle

extends Node

enum {
    BIRD,
    SATELLITE
}

@onready var OBSTACLE_SCENES: Dictionary = {
    BIRD: preload("res://Enemies/Birds/Bird.tscn").instantiate(),
    SATELLITE: preload("res://Enemies/Satellite/satellite.tscn").instantiate(),
}

# Related to spawning
var flock_probability: float = 0.2
var satellite_falling_propability: float = 0.1

# Related to grouping
var min_bird_flock_size: int = 2
var max_bird_flock_size: int = 4



func _ready() -> void:
    GameManager.level_up.connect(_on_level_up)

func _on_level_up() -> void:
    flock_probability += 0.05
    satellite_falling_propability += 0.05
