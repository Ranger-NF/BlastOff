extends Node

var main_menu_vol: float = -9
var game_vol: float  = 0

var music_vol_tween: Tween

func _ready() -> void:
    GameManager.game_started.connect(_on_game_started)
    GameManager.game_over.connect(_on_game_over)

func _change_music_bus_vol(vol: float):
    var music_audio_bus_id: int = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(music_audio_bus_id, vol)

func _on_game_started() -> void:
    var music_audio_bus_id: int = AudioServer.get_bus_index("Music")
    if music_vol_tween:
        music_vol_tween.stop()
        music_vol_tween.kill()
    music_vol_tween = create_tween()
    music_vol_tween.tween_method(_change_music_bus_vol, AudioServer.get_bus_volume_db(music_audio_bus_id), game_vol, 2)

func _on_game_over() -> void:
    var music_audio_bus_id: int = AudioServer.get_bus_index("Music")
    if music_vol_tween:
        music_vol_tween.stop()
        music_vol_tween.kill()
    music_vol_tween = create_tween()
    music_vol_tween.tween_method(_change_music_bus_vol, AudioServer.get_bus_volume_db(music_audio_bus_id), main_menu_vol, 2)
