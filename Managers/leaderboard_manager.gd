extends Node

@onready var player_name: String = OS.get_unique_id()

func _ready() -> void:
    StatManager.new_high_score_gained.connect(_add_player_high_score)
    var sw_api_key = _get_api_key()
    SilentWolf.configure({
        "api_key": sw_api_key,
        "game_id": "BlastOff",
        "log_level": 2
    })

    #_retrieve_player_scores()

func _get_api_key() -> String:
    var f = FileAccess.open('res://secrets.env', FileAccess.READ)
    var api_key:String =f.get_line()
    f.close()

    return api_key

func _retrieve_player_scores() -> Array:
    var sw_score: Dictionary = await SilentWolf.Scores.get_scores_by_player(player_name).sw_get_player_scores_complete
    return sw_score.scores

func _add_player_high_score(new_high_score: int) -> void:
    SilentWolf.Scores.save_score(player_name, new_high_score)
