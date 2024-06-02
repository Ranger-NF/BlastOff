extends Node

signal save_triggered # Triggered from settings and when game is over (Here)
signal reload_triggered

signal data_reloaded
# All items here are synced across sessions

const SAVE_FILE_NAME: String = "user://blastoff_data.cfg"

## Gameplay
var gameplay: Dictionary = {
    high_score = 0,
}

## settings
var settings: Dictionary = {
    bus_volumes = {}, # Bus volume mapped to their id value is decibels
}

func _ready() -> void:
    load_from_files()
    self.save_triggered.connect(save_to_files)
    self.reload_triggered.connect(load_from_files)

    GameManager.game_over.connect(func (): self.emit_signal("save_triggered"))

func save_to_files() -> void:
    SoundManager._report_bus_volumes()
    var new_file = ConfigFile.new()

    for each_key in gameplay:
        new_file.set_value("gameplay", each_key, gameplay[each_key])

    for each_key in settings:
        new_file.set_value("settings", each_key, settings[each_key])

    new_file.save(SAVE_FILE_NAME)

func load_from_files() -> void:
    var saved_file: ConfigFile = ConfigFile.new()

    var load_status = saved_file.load(SAVE_FILE_NAME)

    if load_status != OK: # No save file, treating as if the game is started for the first time
        UiManager.emit_signal("first_startup")
        return

    for each_section in saved_file.get_sections():
        match each_section:
            "gameplay":
                gameplay = _load_data_to_dictionary(saved_file, each_section) # Overwrites all the data in dictionary
            "settings":
                settings = _load_data_to_dictionary(saved_file, each_section)
    emit_signal("data_reloaded")


func _load_data_to_dictionary(save_file: ConfigFile, section_name: String) -> Dictionary:
    var target_dict: Dictionary = {}
    for each_key in save_file.get_section_keys(section_name):
        target_dict[each_key] = save_file.get_value(section_name, each_key)

    return target_dict
