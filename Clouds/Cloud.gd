extends Sprite2D

var size: String
var time: float = 10

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(-200, position.y), time)
	tween.tween_callback(self.queue_free)
