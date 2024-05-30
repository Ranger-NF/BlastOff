extends Control

func _ready() -> void:
    self.hide()
    UiManager.opened_settings.connect()

func _on_settings_opened() -> void:
    self.show()
