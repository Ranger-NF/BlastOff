extends Control

signal play_button_pressed
signal settings_button_pressed
signal quit_button_pressed
signal change_skin_button_pressed
signal statistics_button_pressed

@onready var title_texture: TextureRect = $MarginContainer/VBoxContainer/VBoxContainer/Title
@onready var color_overlay_node: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RocketSkin/Color
@onready var texture_overlay_node: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RocketSkin/Texture

func _ready() -> void:

    self.play_button_pressed.connect(_on_play_button_pressed)
    self.statistics_button_pressed.connect(_on_statistics_button_pressed)
    self.settings_button_pressed.connect(_on_settings_button_pressed)
    self.quit_button_pressed.connect(_on_quit_button_pressed)
    self.change_skin_button_pressed.connect(_on_change_skin_button_pressed)

    self.child_entered_tree.connect(_update_current_skin)
    _pulsate()

    _update_current_skin()

func _update_current_skin(_node: Node = null) -> void:
    GameManager.game_screen_size = get_viewport_rect().size

    color_overlay_node.texture = SkinManager.current_skin_textures.color
    texture_overlay_node.texture = SkinManager.current_skin_textures.texture

func _on_play_button_pressed() -> void:
    UiManager.emit_signal("triggered_gamearea_setup")

func _on_statistics_button_pressed() -> void:
    UiManager.emit_signal("opened_statistics")

func _on_quit_button_pressed() -> void:
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

func _on_settings_button_pressed() -> void:
    UiManager.emit_signal("opened_settings")

func _pulsate() -> void:
    var PULSATE_PERIOD: float = 0.5
    var initial_title_y = title_texture.position.y
    while 1 > 0:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(title_texture, "position", Vector2(title_texture.position.x, initial_title_y + 3), PULSATE_PERIOD).set_trans(Tween.TRANS_CUBIC).set_delay(PULSATE_PERIOD * 0.74)
        tween.tween_property(title_texture, "position", Vector2(title_texture.position.x, initial_title_y), PULSATE_PERIOD).set_trans(Tween.TRANS_CUBIC).set_delay(PULSATE_PERIOD * 0.74 + PULSATE_PERIOD)
        await tween.finished

func _on_change_skin_button_pressed() -> void:
    UiManager.emit_signal("opened_skin_selector")
