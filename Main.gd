extends Node

export (PackedScene) var PlayerTexts
export (PackedScene) var LetterButtons
var screenSize
var score
var dropPositions=[]
var buttonArray=[]
var letters=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y"]

var words=[]
var wordQueue=[]
var buttonLayoutArrayofArray=[]
var correctLetterArrayofArray=[]
var correctPositionArrayofArray=[]
var currentBodies=[]
var matchedBodies=[]
var holdingdoubles=[]
var currentWord=[]
var gameStart=false




func _ready():
	randomize()
	setupPositioning()
	values_to_labels(["P","U","S","S","A","W"])
	set_process_input(true)

func _process(delta):
	if Input.is_action_just_pressed("a"):
		buttonArray[buttonArray.size()-1].pressing()
		
	if Input.is_action_just_pressed("s"):
		buttonArray[buttonArray.size()-2].pressing()
		
	if Input.is_action_just_pressed("d"):
		buttonArray[buttonArray.size()-3].pressing()
		
	if Input.is_action_just_pressed("f"):
		buttonArray[buttonArray.size()-4].pressing()
		
	if Input.is_action_just_pressed("g"):
		buttonArray[buttonArray.size()-5].pressing()
		
	if Input.is_action_just_pressed("h"):
		buttonArray[buttonArray.size()-6].pressing()
		

func setupPositioning():
	var screenSize=get_viewport().size.x
	var detectorextent=$Detector.get_node("CollisionShape2D").shape.extents
	var detectorglobalPos=$Detector.get_node("CollisionShape2D").shape.extents
	var possiblePositions= (detectorextent.x*2-20)/(PlayerTexts.instance().get_node("CollisionShape2D").shape.extents.x*2)
	var detectorLeftCorner=detectorglobalPos.x-detectorextent.x
	var possibleWidths=(detectorextent.x*2-20)/floor(possiblePositions)
	var possibleWidthsButton=screenSize/(floor(possiblePositions)+1)
	#var averagespacething=(possibleWidths+possibleWidthsButton)/2
	for i in range(floor(possiblePositions),0,-1):
		dropPositions.append(detectorLeftCorner+10+possibleWidths*(i-1))
		create_button((i-.5)*possibleWidthsButton,575,possibleWidths,100)
func create_button(positionx,positiony,sizex,sizey):
	var button=LetterButtons.instance()
	add_child(button)
	button.rect_position.x=positionx
	button.rect_position.y=positiony
	button.rect_size.x=sizex
	button.rect_size.y=sizey
	button.get_node("Label").rect_position=Vector2(0-sizex/7,0-sizey/2.5)
	button.get_node("Label").get("custom_fonts/font").set_size((sizex+sizey)/2)
	#print("but",button.get_node("Label").get("custom_fonts/font").size)
	buttonArray.append(button)
	button.connect("buttonPressed",self,"on_Button_Pressed")
	
	
	 
func new_game():
	resetVariables()
#$Detector.start($StartPosition.position)
	$HUD.show_message("Get Ready")
	$StartTimer.start()
	$HUD.update_score(score)
func spawn(position,letter,score):
	$TextPath/TextSpawnLocation.set_offset(position)
	#$TextPath/TextSpawnLocation.set_offset(dropPositions[0])
	var text=PlayerTexts.instance()
	add_child(text)
	text.get_node("Label").text=letter
	text.position = $TextPath/TextSpawnLocation.position
	var speeds=[Vector2(0, 350),Vector2(0,100),Vector2(0,385),Vector2(0,450)]
	text.linear_velocity = speeds[1]
	currentBodies.append(text)
	$HUD.connect("start_game", text, "_on_start_game")

func on_Button_Pressed(text):
	if gameStart:
		#print(text, "button")
		var overlappingBodies=$Detector.get_full_OverlappingBodies()
		#print($Detector.get_overlapping_bodies())
		if overlappingBodies!=null:
			#print(overlappingBodies,"overlap")
			var overlappingBodiesTextValues=bodyArrayToTexts(overlappingBodies)
			var currentlyMatchedBodies=bodyArrayToTexts(matchedBodies)
			var currentlyUncheckedBodies=getNonIntersectors(overlappingBodies,matchedBodies)
			#print(currentlyMatchedBodies,"unamhs")
			var currentlyUncheckedTexts=bodyArrayToTexts(currentlyUncheckedBodies)
			#print(currentlyUncheckedTexts,"curtexts")
			#print(holdingdoubles[0])
			#print(overlappingBodiesTextValues,"yowtf")
			if selectedLetterInDetector(overlappingBodiesTextValues,text):
				#print(currentlyUncheckedTexts,"unchecked")
				for i in currentlyUncheckedBodies:
					if i.get_node("Label").text==text:
						i.linear_velocity=Vector2(0,0)
						i.position=Vector2(i.position.x,$Detector.position.y)
						matchedBodies.append(i)
						#print(holdingdoubles[0],"first")
						#print(matchedBodies)
						holdingdoubles[0].remove(holdingdoubles[0].find(i.get_node("Label").text))
						#print(holdingdoubles[0],"holding in ")
						if holdingdoubles[0].size()==0:
							#print("Hairo")
							holdingdoubles.remove(0)
							buttonLayoutArrayofArray[0].remove(0)
							if buttonLayoutArrayofArray[0].size()==0:
								buttonLayoutArrayofArray.remove(0)
							values_to_labels(buttonLayoutArrayofArray[0][0])
						add_one_to_score()
						break
						
				if matchedBodies.size()==currentWord[0].length():
					$Gong.play()
					#print(overlappingBodies.size())
					for i in range(overlappingBodies.size()):
						remove_child(overlappingBodies[0])
					matchedBodies.clear()
					currentWord.remove(0)
			else:
				game_over()
		else:
			game_over()

	
func _on_StartTimer_timeout():
	gameStart=true
	wordManager()
	$TextTimer.start()
	#values_to_labels(tempButtonArray.back(),buttonArray)
	#tempButtonArray.pop_back()
func stringtoArray(word):
	var array1= []
	for c in word:
    	array1.append(c)
	return array1
func createPositionArray(percentageArray,word):
	var returnedButtonArrays=[]
	var returnedButtonLetterArrays2=[]
	var returnedButtonTemplateArray3=[]
	var wordPositions=[]
	for i in range(word.length()):
		wordPositions.append(i)
	while wordPositions.size()!=0:
		var getPositionCounts=randi()%100
		var currentNumber
		for i in range(percentageArray.size()):
			if getPositionCounts<percentageArray[i]:
				currentNumber=i+1
				break				
		var totalelementsList=createSingleLayout(min(currentNumber,wordPositions.size()),word,wordPositions)
		var elementList=totalelementsList[0]
		var elementWordList=totalelementsList[1]
		var elementButtonTemplateList=totalelementsList[2]
		returnedButtonLetterArrays2.append(elementWordList)
		returnedButtonArrays.append(elementList)
		for i in totalelementsList[2]:
			returnedButtonTemplateArray3.append(i)
		for i in elementList:
			wordPositions.remove(wordPositions.find(i))
	return [returnedButtonArrays,returnedButtonLetterArrays2,returnedButtonTemplateArray3]



func wordManager():
	var positionArray=[]
	var letterArray=[]
	var buttonTemplateArray=[]
	if wordQueue.size()<2:
		print(words,"words")
		var selectedWords=wordSelectQueue(2-wordQueue.size(),words)
		for i in selectedWords:
			wordQueue.push_back(i)
			#buttonPotentialArrayofArray.append()
			#correctButtonArrayofArray=.append()
			words.remove(words.find(i))
			var totalArray=createPositionArray(createPercentageArray(score),i)
			#print(totalArray)
			correctPositionArrayofArray.push_back(totalArray[0])
			correctLetterArrayofArray.push_back(totalArray[1])
			buttonLayoutArrayofArray.push_back(totalArray[2])
		#print("NEXT")
		#print(wordQueue,"wordQueu")
		#print(correctPositionArrayofArray,"correctPosition")
		#print(correctLetterArrayofArray,"correctLetter")
		#print(buttonLayoutArrayofArray,"buttonLayout")
	values_to_labels(buttonLayoutArrayofArray[0][0])
	for i in range(correctPositionArrayofArray[0][0].size()):
		spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score)
	holdingdoubles.append(correctLetterArrayofArray[0][0])
	#print(holdingdoubles,"holll")
	correctPositionArrayofArray[0].remove(0)
	correctLetterArrayofArray[0].remove(0)
	if buttonLayoutArrayofArray[0].size()==0:
		buttonLayoutArrayofArray.remove(0)
	if correctPositionArrayofArray[0].size()==0:
		correctPositionArrayofArray.remove(0)
	if correctLetterArrayofArray[0].size()==0:
		correctLetterArrayofArray.remove(0)
	print(wordQueue,"first")
	currentWord.append(wordQueue[0])
	wordQueue.remove(0)
	print(wordQueue,"second")
	#print(wordQueue,"wordQueu")
	#print(correctPositionArrayofArray,"correctPosition")
	#print(correctLetterArrayofArray,"correctLetter")
	#print(buttonLayoutArrayofArray,"buttonLayout")
		

			
			
			
func values_to_labels(var letters):
	for i in range(letters.size()):
		buttonArray[i].get_node("Label").text=letters[i]
func wordSelectQueue(howMany,wordList):
	var selectedWords=[]
	for i in range(howMany):
		if words.size()>i:
			selectedWords.append(words[i])
	return selectedWords
	
func createPercentageArray(whatIsScore):
	if whatIsScore<5:
		return [90,100]
	elif whatIsScore<10:
		return[50,100]
	else:
		return [70,100]
func slowFreezeLetters(curren):
	for i in curren:
		if is_instance_valid(i):
			if i.get_class()=="RigidBody2D":
				i.linear_velocity=Vector2(0,0)
		else:
			curren.remove(curren.find(i))

func createSingleLayout(maxPositions,word, wordPositions):
	var selectedPositions=[]
	var selectedLetters=[]
	var buttonChoices=[]
	var combine=[]
	for i in range(maxPositions):
		var randNum=randi()%wordPositions.size()
		while selectedPositions.find(wordPositions[randNum])!=-1:
			randNum=randi()%wordPositions.size()
		selectedPositions.append(wordPositions[randNum])
		selectedLetters.append(word.substr(wordPositions[randNum],1))
	buttonChoices.append(buttonChoiceCreator(selectedLetters))

	return [selectedPositions,selectedLetters,buttonChoices]

		
func buttonChoiceCreator(selectedLetters):
	var letterChoices=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
	var buttonTemplateArray=[]
	for i in selectedLetters:
		buttonTemplateArray.append(i)
		letterChoices.remove(letterChoices.find(i))
	for i in range(buttonArray.size()-selectedLetters.size()):
		var randNum=randi()%letterChoices.size()
		buttonTemplateArray.append(letterChoices[randNum])
		letterChoices.remove(randNum)
	buttonTemplateArray.shuffle()
	return buttonTemplateArray

func chooseWordOnStart():
	wordQueue.append(wordSelectQueue(2,words))
func chooseWord():
	wordQueue.append



func _on_Back_entered():
	game_over()

		

	
func _on_TextTimer_timeout():
	wordManager()
	
func game_over():
	gameStart=false
	slowFreezeLetters(currentBodies)
	$Bloop.play()
	
	$TextTimer.stop()
	$HUD.show_game_over()

	

	



	
func resetVariables():
	randomize()
	matchedBodies.clear()
	wordQueue.clear()
	buttonLayoutArrayofArray.clear()
	correctLetterArrayofArray.clear()
	correctPositionArrayofArray.clear()
	currentBodies.clear()
	currentBodies.clear()
	matchedBodies.clear()
	holdingdoubles.clear()
	currentWord.clear()
	score=0
	words=[1,"hello","dan","y","b","a","u","o","e","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
	


			
func selectedLetterInDetector(var comparingArray, var selectedButtonTexts):
	if comparingArray.has(selectedButtonTexts):
		return true
	else: 
		return false
		
func bodyArrayToTexts(var array):
	var array1=[]
	for i in array:
		array1.append(i.get_node("Label").text)
	return array1
func getNonIntersectors(var getNonIntersectorsFrom,var comparingTo):
	var comparingToCopy=comparingTo.duplicate()
	var getNonIntersectorsFromCopy=getNonIntersectorsFrom.duplicate()
	for i in comparingToCopy:
		if getNonIntersectorsFromCopy.find(i)!=-1:
			getNonIntersectorsFromCopy.remove(getNonIntersectorsFromCopy.find(i))
	return getNonIntersectorsFromCopy
			
	
	
func add_one_to_score():
	score+=1
	$HUD.update_score(score)




	


	

