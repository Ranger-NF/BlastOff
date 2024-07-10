extends Node

signal star_count_changed(change_in_stars: int)
signal stars_depleted
signal new_high_score_gained

const SCORE_MULTIPLIER: Dictionary = {
    GameManager.DIFFICULTY_LEVELS.EASY: 1,
    GameManager.DIFFICULTY_LEVELS.NORMAL: 1.5,
    GameManager.DIFFICULTY_LEVELS.HARD: 2,
}

const SCORING_INTERVAL: float = 0.5

var time_since_last_scoring: float

var time_spent: float

# Variables for score calculation
var score_gained: float
var current_level: int = 1

# Variable for obstacles
var satellite_number: int = 0 # Resets to zero whenver game restarts [Incremented in satellite scene]

func _ready() -> void:
    GameManager.game_over.connect(_check_high_score)
    GameManager.game_started.connect(_init_score)
    self.star_count_changed.connect(_on_star_count_changed)

func _on_star_count_changed(change_in_stars: int) -> void:
    DataManager.gameplay.total_stars += change_in_stars

    if DataManager.gameplay.total_stars < 0:
        DataManager.gameplay.total_stars = 0
        emit_signal("stars_depleted")

func _calculate_score() -> void:
    # Changed scoring system so as to avoid massive jumps
    score_gained += roundi(current_level  * SCORE_MULTIPLIER.get(GameManager.current_difficulty_level))

    if !(roundi(score_gained) % roundi(pow(10, current_level))) and score_gained != 0:
        current_level += 1
        GameManager.emit_signal("level_up")

func _physics_process(delta: float) -> void:
    time_since_last_scoring += delta

    if time_since_last_scoring > SCORING_INTERVAL:
        _calculate_score()
        time_since_last_scoring = 0

func _check_high_score() -> void:
    if score_gained > DataManager.gameplay.high_score:
        DataManager.gameplay.high_score = score_gained
        self.emit_signal("new_high_score_gained", score_gained)
        DataManager.emit_signal("save_triggered")

func _init_score() -> void:
    score_gained = 0
