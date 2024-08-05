extends "res://Enemies/Obstacle.gd"

@onready var clipping_area: CollisionShape2D = $DetectionArea/CollisionShape2D

enum {
    BACK,
    TOP,
    BOTTOM,
}

var spawnable_locations: Array[int] = [TOP, BACK, BOTTOM]

# Variables to control spawning members
var total_flock_size: int = 1
var members_remaining_to_spawn: int = 0

# Flock code
func _further_setup() -> void: ## Extension of _ready() to implement extra logic per class of obstacle
    var rand_num = randf()

    if current_role == ROLES.LEADER and rand_num < SpawnManager.current_bird_flock_probability:
        initial_leader_pos = self.position

        total_flock_size = randi_range(SpawnManager.current_bird_flock_size.x, SpawnManager.current_bird_flock_size.y)

        members_remaining_to_spawn = total_flock_size
        _spawn_flock(members_remaining_to_spawn)
    if current_role == ROLES.COLEADER and members_remaining_to_spawn > 0:
        _spawn_flock(members_remaining_to_spawn)

func _spawn_flock(members_to_spawn: int):
    var members_spawned: int

    if current_role == ROLES.COLEADER:
        members_spawned = 0

        if members_to_spawn > 3: # Limiting number of members under a single leader/co-leader
            members_to_spawn = 3

    elif current_role == ROLES.LEADER:
        members_spawned = 1

        if members_to_spawn > 4: # Limiting number of members under a single leader/co-leader
            members_to_spawn = 4


    members_remaining_to_spawn -= members_to_spawn

    while members_spawned < members_to_spawn:
        var new_individual: Area2D = self.duplicate()
        var new_spawn_location: int = spawnable_locations.pick_random()

        spawnable_locations.erase(new_spawn_location)
        new_individual.position.x = self.position.x + (-1 * clipping_area.shape.radius )

        if new_spawn_location == BACK:
            new_individual.position.x += (-1 * clipping_area.shape.radius)

            if members_remaining_to_spawn > 0:
                new_individual = _transfer_flock_properties(new_individual, ROLES.COLEADER)
            else:
                new_individual = _transfer_flock_properties(new_individual, ROLES.MEMBER)

        else:
            match new_spawn_location:
                TOP:
                    new_individual.position.y += -1 * clipping_area.shape.radius
                BOTTOM:
                    new_individual.position.y += clipping_area.shape.radius

            new_individual = _transfer_flock_properties(new_individual, ROLES.MEMBER)

        get_parent().add_child(new_individual)
        members_spawned += 1

func _transfer_flock_properties(new_member: Node, role_of_individual: int = ROLES.MEMBER) -> Node:
    new_member.current_role = role_of_individual
    new_member.flock_speed = flock_speed
    new_member.initial_leader_pos = initial_leader_pos

    if role_of_individual == ROLES.COLEADER:
        new_member.members_remaining_to_spawn = members_remaining_to_spawn

    return new_member

func _after_hit():
    UiManager.emit_signal("triggered_screen_shake", UiManager.STRENGTH_TYPES.LOW)
    self.horizontal_speed = 0
    animated_sprite.flip_v = true
    animated_sprite.stop()
