extends Control

@onready var master_slider: HSlider = $UiBackground/MarginContainer/WholeScreen/HBoxContainer/Sliders/MasterSlide
@onready var music_slider: HSlider = $UiBackground/MarginContainer/WholeScreen/HBoxContainer/Sliders/MusicSlider
@onready var sfx_slider: HSlider = $UiBackground/MarginContainer/WholeScreen/HBoxContainer/Sliders/SfxSlider
@onready var ui_slider: HSlider = $UiBackground/MarginContainer/WholeScreen/HBoxContainer/Sliders/UiSlider

@onready var button_pressed_sound = $ButtonSound

var volume_offset:float = 0

func _ready() -> void:
    master_slider.value = db_to_linear(SoundManager.get_bus_volume(SoundManager.MASTER)) + volume_offset
    music_slider.value = db_to_linear(SoundManager.get_bus_volume(SoundManager.MUSIC)) + volume_offset
    sfx_slider.value = db_to_linear(SoundManager.get_bus_volume(SoundManager.SFX)) + volume_offset
    ui_slider.value = db_to_linear(SoundManager.get_bus_volume(SoundManager.UI)) + volume_offset

func _on_back_button_pressed() -> void:
    _on_button_pressed()
    DataManager.emit_signal("save_triggered")
    UiManager.emit_signal("skipped_to_main_menu")

func _on_master_slide_drag_ended(_value_changed: bool) -> void:
    _on_button_pressed()
    SoundManager.set_bus_volume(SoundManager.MASTER, linear_to_db(master_slider.value - volume_offset))

func _on_music_slider_drag_ended(_value_changed: bool) -> void:
    _on_button_pressed()
    SoundManager.set_bus_volume(SoundManager.MUSIC, linear_to_db(music_slider.value - volume_offset))

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
    _on_button_pressed()
    SoundManager.set_bus_volume(SoundManager.SFX, linear_to_db(sfx_slider.value - volume_offset))

func _on_ui_slider_drag_ended(_value_changed: bool) -> void:
    _on_button_pressed()
    SoundManager.set_bus_volume(SoundManager.UI, linear_to_db(ui_slider.value - volume_offset))

func _on_credits_button_pressed() -> void:
    _on_button_pressed()
    DataManager.emit_signal("save_triggered")
    UiManager.emit_signal("opened_credits")

func _on_button_pressed() -> void:
    button_pressed_sound.play()

