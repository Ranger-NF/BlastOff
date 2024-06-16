extends RichTextLabel

@onready var star_image: Texture = preload("res://Collectables/star.svg")

func _ready() -> void:
    self.child_entered_tree.connect(_update_star_count)
    StatManager.star_count_changed.connect(_update_star_count)
    _update_star_count()

func _update_star_count(_change_in_stars = 0):
    self.clear()

    self.append_text("[center]")
    self.add_image(star_image, 40, 40)
    self.append_text(str(DataManager.gameplay.total_stars))
