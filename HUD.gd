extends CanvasLayer
signal start_game
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func show_message(text):
	$MessageLabel.text=text
	$MessageLabel.show()
	$MessageTimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_score(score):
    $ScoreLabel.text = str(score)

func show_game_over(wordNumber):   
	if  wordNumber>=268:
		show_message("WINRAR")
	else:
		show_message("Game Over")
	$LevelLabel.hide()
	$LevelTimer.stop()
	yield($MessageTimer, "timeout")
	$MessageLabel.text = "Play Again"
	$MessageLabel.show()
	yield(get_tree().create_timer(1), 'timeout')
	$StartButton.show()

func show_level(level):
	$LevelLabel.text="Level" +str(level)
	$LevelLabel.show()
	$LevelTimer.start()
func _on_StartButton_pressed():
	$StartButton.hide()
	$InstructionButton.hide()
	show_level(1)
	emit_signal("start_game")

func _on_MessageTimer_timeout():
	$MessageLabel.hide()

func _on_LevelTimer_timeout():
	$LevelLabel.hide()

func _on_InstructionButton_pressed():
	$BackButton.show()
	$ScoreLabel.hide()
	$StartButton.hide()
	$MessageLabel.hide()
	$InstructionButton.hide()
	$InstructionLabel.show()
	pass # Replace with function body.

func _on_BackButton_pressed():
	$BackButton.hide()
	$ScoreLabel.show()
	$StartButton.show()
	$MessageLabel.show()
	$InstructionButton.show()
	$InstructionLabel.hide()
	pass # Replace with function body.
