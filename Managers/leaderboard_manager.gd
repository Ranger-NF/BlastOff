extends Node

signal triggered_leaderboard_reload
signal display_name_changed(new_name: String)

@onready var player_id: String = OS.get_unique_id()
var is_leaderboard_allowed: bool = false

var current_display_name: String = OS.get_unique_id()

func _ready() -> void:
    _setup_displayname()

    StatManager.new_high_score_gained.connect(_add_player_high_score)
    self.display_name_changed.connect(_process_new_display_name)

    var sw_api_key = _get_api_key()

    if sw_api_key:
        is_leaderboard_allowed = true

        SilentWolf.configure({
            "api_key": sw_api_key,
            "game_id": "BlastOff",
            "log_level": 0
        })

        _process_high_score()
    else:
        is_leaderboard_allowed = false

func _setup_displayname() -> void:
    if not DataManager.is_initialisation_complete:
        await DataManager.data_reloaded

    var saved_display_name: String = DataManager.settings.display_name

    if saved_display_name.is_empty(): # Sets player id as display name
        DataManager.settings.display_name = current_display_name
        DataManager.emit_signal("save_triggered")
    else:
        current_display_name = saved_display_name

func _process_high_score() -> void:
    # Get scores of all player
    var player_score_data: Dictionary = await SilentWolf.Scores.get_scores_by_player(player_id).sw_get_player_scores_complete
    var player_top_score: Dictionary = await SilentWolf.Scores.get_top_score_by_player(player_id).sw_top_player_score_complete

    var player_scores: Array = player_score_data.scores
# If more than 1 score, keep only the highest
    if player_scores.size() > 1:
        for each_score_data in player_scores:
            if each_score_data.score_id != player_top_score.top_score.score_id:
                await SilentWolf.Scores.delete_score(each_score_data.score_id).sw_delete_score_complete

    # Checking it with local saved score, and keeping the highest one
    if not DataManager.is_initialisation_complete:
        await  DataManager.data_reloaded

    if player_top_score.score.empty() or DataManager.gameplay.high_score > player_top_score.score:
        _replace_high_score(DataManager.gameplay.high_score)
    elif DataManager.gameplay.high_score == player_top_score.score: ## Happens when trying to update display name
        if not player_top_score.has("metadata") or player_top_score.metadata.has("display_name") or player_top_score.metadata.display_name != current_display_name:
            print("  !!! here  ")
            _replace_high_score(DataManager.gameplay.high_score)
    else:
        DataManager.gameplay.high_score = player_top_score.top_score.score
        DataManager.emit_signal("save_triggered")

    emit_signal("triggered_leaderboard_reload")


func _replace_high_score(new_high_score: int) -> void:
    await SilentWolf.Scores.save_score(player_id, new_high_score, "main", {"display_name": current_display_name}).sw_save_score_complete
    _process_high_score()

func _get_api_key() -> String:
    var f = FileAccess.open('res://secrets.env', FileAccess.READ)
    var api_key:String =f.get_line()
    f.close()

    return api_key

func _add_player_high_score(new_high_score: int) -> void:
    if is_leaderboard_allowed:
        _replace_high_score(new_high_score)

func _process_new_display_name(new_name: String):
    # TODO: Add bad word filter

    DataManager.settings.display_name = new_name
    current_display_name = new_name

    DataManager.emit_signal("save_triggered")
    _add_player_high_score(DataManager.gameplay.high_score) # To trigger save, with new metadata
