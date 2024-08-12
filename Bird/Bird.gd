extends AnimatedSprite2D
@onready var Audio = get_node("/root/Game/Audio")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().gameState == get_parent().gameStates.Play:
		position.y = get_global_mouse_position().y

func onAreaEntered(area):
	if area.is_in_group("Clouds"):
		Audio.stream = preload("res://Audio/Explosion.sfxr")
		Audio.play()
		if get_parent().shieldDuration > 0: get_parent().shieldDuration = 0
		else: get_parent().restartGame()
	if area.is_in_group("Powerups"):
		Audio.stream = preload("res://Audio/Powerup.sfxr")
		Audio.play()
		if area.get_parent().type == "Powerup50": get_parent().addedScores.append(50)
		if area.get_parent().type == "Powerup100": get_parent().addedScores.append(100)
		if area.get_parent().type == "Powerup200": get_parent().addedScores.append(200)
		if area.get_parent().type == "Powerup2X": get_parent().multiplierCounter.append([2, 15])
		if area.get_parent().type == "Powerup3X": get_parent().multiplierCounter.append([3, 15])
		if area.get_parent().type == "Shield": get_parent().shieldDuration = 15
		area.get_parent().queue_free()
