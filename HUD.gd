extends CanvasLayer
signal start_game
signal instruction
signal back
var move=0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(delta):
	if move>=0:
		if $Node2D.position.y<408:
			$Node2D.position.y=$Node2D.position.y+3
		else:
			move+=1
			$TextureRect2.show()
			$Node2D2.show()
			$TextureRect12.hide()
			$TextureRect11.show()
			$TextureRect6.hide()
			if move%80==0:
				$Node2D2.hide()
				$TextureRect2.hide()
				$TextureRect12.show()
				$TextureRect11.hide()
				$TextureRect6.show()
				$Node2D.position.y=290	
				
			elif move%30==0:
				$Node2D2.position.y=480
				$Node2D2.position.y=$Node2D2.position.y+5
			elif move%15==0:
				$Node2D2.position.y=480
				$Node2D2.position.y=$Node2D2.position.y-5
	

		
	
func show_message(text):
	$MessageLabel.text=text
	$MessageLabel.show()
	$MessageTimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func show_end_score():
	$EndGameLabel.show()
	$ScoreLabel.hide()
func update_endScore(current,highscore):
	$EndGameLabel.text=str("Last Score: ", current,"\n","Best Score: ",highscore)
func update_highscore(highscore):
	$HighScoreLabel.text=str("High Score: ", highscore)
func update_score(score):
    $ScoreLabel.text = str(score)

func show_game_over(wordNumber):   
	if  wordNumber>=268:
		show_message("WINRAR")
	else:
		show_message("  Game Over")

	$LevelLabel.hide()
	$LevelTimer.stop()
	$ColorRect.show()
	$FlashTimer.start()
	yield($MessageTimer, "timeout")
	#$MessageLabel.text = "  Play Again?"
	#$MessageLabel.show()
	$EndGameLabel.show()
	$ScoreLabel.hide()
	$MessageLabel.text=""
	yield(get_tree().create_timer(1), 'timeout')
	$ScoreLabel.hide()
	$EndGameLabel.show()
	$StartButton.show()
	$InstructionButton.show()

func show_level(level):
	$LevelLabel.text="Level" +str(level)
	$LevelLabel.show()
	$LevelTimer.start()
func _on_StartButton_pressed():
	$StartButton.hide()
	$EndGameLabel.hide()
	$HighScoreLabel.hide()
	$ScoreLabel.show()
	$InstructionButton.hide()
	#show_level(1)
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
	$TextureRect5.show()
	$TextureRect6.show()
	$TextureRect7.show()
	$TextureRect8.show()
	$TextureRect9.show()
	$TextureRect10.show()
	$Node2D.show()
	move=0
	emit_signal("instruction")
	pass # Replace with function body.

func _on_BackButton_pressed():
	$BackButton.hide()
	$StartButton.show()
	$MessageLabel.show()
	$InstructionButton.show()
	$InstructionLabel.hide()
	$Node2D2.hide()
	$Node2D.hide()
	$TextureRect2.hide()
	$TextureRect12.hide()
	$TextureRect11.hide()
	$TextureRect6.hide()
	$TextureButton.hide()
	$TextureRect5.hide()
	$TextureRect6.hide()
	$TextureRect7.hide()
	$TextureRect8.hide()
	$TextureRect9.hide()
	$TextureRect10.hide()
	$Node2D.hide()
	
	move=-1
	emit_signal("back")
	pass # Replace with function body.


func _on_FlashTimer_timeout():
	$ColorRect.hide()


func _on_TextureButton_pressed():
	if $Node2D.position.y>408:
		$StartButton.hide()
		$EndGameLabel.hide()
		$HighScoreLabel.hide()
		$ScoreLabel.show()
		$InstructionButton.hide()
		$Node2D2.hide()
		$Node2D.hide()
		$TextureRect2.hide()
		$TextureRect12.hide()
		$TextureRect11.hide()
		$TextureRect6.hide()
		$TextureButton.hide()
		$TextureRect5.hide()
		$TextureRect6.hide()
		$TextureRect7.hide()
		$TextureRect8.hide()
		$TextureRect9.hide()
		$TextureRect10.hide()
		
		move=-1
		#show_level(1)
		emit_signal("start_game")
		print("Fuck")
	pass # Replace with function body.

