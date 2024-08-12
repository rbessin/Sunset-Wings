extends Sprite2D

var type: String
var time: float

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(-200, position.y), time)
	tween.tween_callback(self.queue_free)
