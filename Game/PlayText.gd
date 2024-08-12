extends Sprite2D

var animation_direction: String = "UP"
var upper_bound: float = 40.0
var lower_bound: float = 36.0
var speed: float = 80.0

func _process(delta):
	var factor: float

	if animation_direction == "UP":
		factor = ease_in_out((upper_bound - position.y) / (upper_bound - lower_bound))
		position.y += factor * speed * delta
		if position.y >= upper_bound - 0.1: animation_direction = "DOWN"
	elif animation_direction == "DOWN":
		factor = ease_in_out((position.y - lower_bound) / (upper_bound - lower_bound))
		position.y -= factor * speed * delta
		if position.y <= lower_bound + 0.1: animation_direction = "UP"

func ease_in_out(t: float) -> float:
	# Ease in and out function
	return t * t * (3.0 - 2.0 * t)
