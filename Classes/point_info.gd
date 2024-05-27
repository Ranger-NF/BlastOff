class_name point_info

var normal       : Vector2
var velocity     : Vector2
var width        : float
var width_noise  : float
var offset_noise : float
var color        : Color

func reset():
    normal       = Vector2.RIGHT
    velocity     = Vector2.ZERO
    width        = 0.0
    width_noise  = 0.0
    offset_noise = 0.0
    color        = Color.BLACK
