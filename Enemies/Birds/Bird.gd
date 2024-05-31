extends "res://Enemies/Obstacle.gd"

@export var max_flock_size: int = 4

@onready var clipping_area: CollisionShape2D = $DetectionArea/CollisionShape2D

enum {
    BACK,
    TOP,
    BOTTOM,
}

var spawnable_locations: Array[int] = [TOP, BACK, BOTTOM]

# Flock code
func _further_setup() -> void: ## Extension of _ready() to implement extra logic per class of obstacle
    var rand_num = randf()

    if rand_num < GameManager.flock_probability and is_flock_leader:
        initial_leader_pos = self.position

        var flock_size = randi_range(2, max_flock_size)
        _spawn_flock(flock_size)


func _spawn_flock(flock_size: int):
    var current_flock_size: int = 1

    while current_flock_size < flock_size:
        var new_individual: Area2D = self.duplicate()
        var new_spawn_location: int = spawnable_locations.pick_random()

        new_individual.position.x = self.position.x + (-1 * clipping_area.shape.radius )

        if new_spawn_location == BACK:
            new_individual.position.x += (-1 * clipping_area.shape.radius )
        else:
            match new_spawn_location:
                TOP:
                    new_individual.position.y += -1 * clipping_area.shape.radius
                BOTTOM:
                    new_individual.position.y += clipping_area.shape.radius

        new_individual = _transfer_flock_properties(new_individual)

        get_parent().add_child(new_individual)
        spawnable_locations.erase(new_spawn_location)
        current_flock_size += 1

func _transfer_flock_properties(new_member: Node) -> Node:
    new_member.is_flock_leader = false
    new_member.flock_speed = flock_speed
    new_member.initial_leader_pos = initial_leader_pos

    return new_member

func _after_hit():
    self.horizontal_speed = 0
    animated_sprite.flip_v = true
    animated_sprite.stop()
