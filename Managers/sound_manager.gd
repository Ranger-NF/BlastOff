extends Node

var main_menu_vol: float = -9
var game_vol: float  = 0

var music_vol_tween: Tween

enum {
    MASTER,
    MUSIC,
    SFX,
    UI,
}

const bus_names = {
    MASTER: "Master",
    MUSIC: "Music",
    SFX: "Sfx",
    UI: "UI",
}


func _ready() -> void:
    DataManager.data_reloaded.connect(_reload_bus_volumes)

func _change_music_bus_vol(vol: float):
    var music_audio_bus_id: int = AudioServer.get_bus_index(bus_names.get(MUSIC))
    AudioServer.set_bus_volume_db(music_audio_bus_id, vol)

func set_bus_volume(bus_name_enum: int, vol: float) -> void:
    var audio_bus_id = AudioServer.get_bus_index(bus_names.get(bus_name_enum))
    AudioServer.set_bus_volume_db(audio_bus_id, vol)

func get_bus_volume(bus_name_enum: int) -> float:
    var audio_bus_id = AudioServer.get_bus_index(bus_names.get(bus_name_enum))
    return AudioServer.get_bus_volume_db(audio_bus_id)

func _reload_bus_volumes() -> void:
    var saved_data = DataManager.settings.bus_volumes
    for each_bus_name in saved_data:
        var bus_id: int = AudioServer.get_bus_index(each_bus_name)
        AudioServer.set_bus_volume_db(bus_id, saved_data.get(each_bus_name))

func _report_bus_volumes() -> void:
    for each_name in bus_names:
        var each_bus_name: String = bus_names.get(each_name)
        var bus_id: int = AudioServer.get_bus_index(each_bus_name)
        var bus_vol: float = AudioServer.get_bus_volume_db(bus_id)

        DataManager.settings.bus_volumes[each_bus_name] = bus_vol
