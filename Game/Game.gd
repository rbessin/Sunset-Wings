extends Node2D

enum gameStates {Start, Play, Restart}
var gameState: gameStates

enum cloudSizes {Small, Medium, Large}
var cloudTimes: Dictionary = {"Small": 5, "Medium": 10, "Large": 20}
enum powerupTypes {Powerup50, Powerup100, Powerup200, Powerup2X, Powerup3X, Shield}

var score: int
var addedScores: Array = []
var multiplier: int = 1
var multiplierCounter: Array = []
var shieldDuration: int = 0

var sunTween: Tween = null
var backgroundTween: Tween = null

func _ready():
	startGame()

func _process(delta):
	switchGameState()

func spawnCloud():
	var cloudInstance
	var size = cloudSizes.keys()[randi_range(0, cloudSizes.size() - 1)]
	if size == "Small":
		cloudInstance = load("res://Clouds/" + str(size) + "Cloud" + str(randi_range(1, 5)) + ".tscn").instantiate()
	else:
		cloudInstance = load("res://Clouds/" + str(size) + "Cloud" + str(randi_range(1, 3)) + ".tscn").instantiate()
	cloudInstance.global_position = Vector2(140, randi_range(-67, 67))
	cloudInstance.size = size
	cloudInstance.time = cloudTimes[size]
	$Clouds.add_child(cloudInstance)
	await get_tree().create_timer(1).timeout
	if gameState == gameStates.Play:
		spawnCloud()

func spawnPowerup():
	var type = powerupTypes.keys()[randi_range(0, powerupTypes.size() - 1)]
	var powerupInstance = load("res://Powerups/" + str(type) + ".tscn").instantiate()
	powerupInstance.global_position = Vector2(140, randi_range(-67, 67))
	powerupInstance.type = type
	powerupInstance.time = 10
	$Powerups.add_child(powerupInstance)
	await get_tree().create_timer(3).timeout
	if gameState == gameStates.Play:
		spawnPowerup()

func switchGameState():
	if Input.is_key_pressed(KEY_SPACE) and gameState != gameStates.Play:
		gameState = gameStates.Play
		playGame()
	elif gameState == gameStates.Restart:
		if sunTween != null and sunTween.is_valid():
			sunTween.stop()
			backgroundTween.stop()
			$Sun.visible = false

func playGame():
	for child in $Background.get_children():
		child.visible = false
	score = 0
	multiplier = 1
	multiplierCounter.clear()
	$Bird.visible = true
	$Bird.global_position = Vector2(-100, -1)
	$Background.texture = preload("res://Backgrounds/BackgroundLong.png")
	$Background.position = Vector2(0, -67)
	$Play.visible = false
	$Header.visible = true
	$Music.play()
	spawnCloud()
	spawnPowerup()
	updateMultiplierCounter()
	updateScore()
	updateShield()
	playSun()

func startGame():
	gameState = gameStates.Start
	$Background.texture = preload("res://Backgrounds/StartBackground.png")
	$Play.visible = true
	$Header.visible = false
	$Play.texture = preload("res://Play/Start.png")

func restartGame():
	gameState = gameStates.Restart
	for child in $Clouds.get_children():
		child.queue_free()
	for child in $Powerups.get_children():
		child.queue_free()
	updateRestartScore()
	$Bird.visible = false
	$Background.texture = preload("res://Backgrounds/EndBackground.png")
	$Background.global_position = Vector2(0, 1)
	for child in $Background.get_children():
		child.visible = true
	$Play.visible = true
	$Header.visible = false
	$Play.texture = preload("res://Play/Restart.png")
	$Music.stop()

func updateScore():
	if addedScores.size() > 0:  # Add additional scores
		for addedScore in addedScores:
			score += (addedScore * multiplier)
		addedScores.clear()
	score += (10 * multiplier)
	var score_str = str(score).pad_zeros(5)
	for i in range(5):
		var digit = score_str[i]
		var sprite = get_node("Header/Num" + str(i + 1)) as Sprite2D
		sprite.texture = load("res://Score/" + digit + ".png")
	await get_tree().create_timer(1).timeout
	if gameState == gameStates.Play:
		updateScore()

func updateMultiplierCounter():
	multiplier = 1
	if multiplierCounter.size() > 0:
		for i in range(multiplierCounter.size() - 1, -1, -1):
			if multiplierCounter[i][1] <= 0:
				multiplierCounter.remove_at(i)
			else:
				multiplierCounter[i][1] -= 1
				multiplier += multiplierCounter[i][0]
	var multiplier_str = str(multiplier).pad_zeros(2)
	for i in range(2):
		var digit = multiplier_str[i]
		var sprite = get_node("Header/Mul" + str(i + 1)) as Sprite2D
		sprite.texture = load("res://Score/" + digit + ".png")
	await get_tree().create_timer(1).timeout
	if gameState == gameStates.Play:
		updateMultiplierCounter()

func updateShield():
	if shieldDuration > 0:
		shieldDuration -= 1
		get_node("Header/Shield").visible = true
	else:
		get_node("Header/Shield").visible = false
	await get_tree().create_timer(1).timeout
	if gameState == gameStates.Play:
		updateShield()

func playSun():
	$Sun.visible = true
	$Sun.global_position.y = -104
	var time = 100
	backgroundTween = create_tween()
	sunTween = create_tween()
	sunTween.tween_property($Sun, "position", Vector2(0, 106), time)
	backgroundTween.tween_property($Background, "position", Vector2(0, 68), time)
	backgroundTween.connect("finished", onBackgroundTweenFinished)
	sunTween.connect("finished", onSunTweenFinished)

func onSunTweenFinished():
	$Sun.visible = false
	if gameState != gameStates.Restart: restartGame()

func onBackgroundTweenFinished():
	$Background.global_position = Vector2(0, 1)

func updateRestartScore():
	var score_str = str(score).pad_zeros(5)
	for i in range(5):
		var digit = score_str[i]
		var sprite = get_node("Background/Num" + str(i + 1)) as Sprite2D
		sprite.texture = load("res://Score/" + digit + ".png")
