extends Node

export (PackedScene) var PlayerTexts
export (PackedScene) var LetterButtons
var screenSize
var score
var gamecount=0
var dropPositions=[]
var buttonArray=[]
var levelMarkings=[20,22]
var letters=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
var words=[]
var admob=null
var speeds=[Vector2(0,120),Vector2(0, 155),Vector2(0,170),Vector2(0,190),Vector2(0,150),Vector2(0,135),Vector2(0,169)]
var hardspeeds=[Vector2(0,220),Vector2(0, 250),Vector2(0,280),Vector2(0,295),Vector2(0,200),Vector2(0,300),Vector2(0,320),Vector2(0,310),Vector2(0,275)]
var currentSpeed=speeds[0]
var wordQueue=[]
var buttonLayoutArrayofArray=[]
var correctLetterArrayofArray=[]
var correctPositionArrayofArray=[]
var currentBodies=[]
var matchedBodies=[]
var holdingdoubles=[]
var currentWord=[]
var gameStart=false
var level=1
var wordNumber=0

var score_file = "user://highscore.save"
var highscore

func load_score():
    var f = File.new()
    if f.file_exists(score_file):
        f.open(score_file, File.READ)
        highscore = f.get_var()
        f.close()
    else:
        highscore = 0

func save_score():
	var f = File.new()
	f.open(score_file, File.WRITE)
	if score>highscore:
    	f.store_var(score)
	else:
		f.store_var(highscore)
	f.close()



func _ready():
	randomize()
	setupPositioning()
	values_to_labels(["p","u","z","z","a","w"])
	set_process_input(true)
	load_score()
	$HUD.update_highscore(highscore)
	print(highscore,"rar")
	if Engine.has_singleton("AdMob"):
		admob = Engine.get_singleton("AdMob")
		admob.init(true, get_instance_id())
		admob.loadBanner("ca-app-pub-8163785840954716/1983507262",true)
		admob.loadInterstitial("ca-app-pub-8163785840954716/5016662425")
		print("fuck")
	if admob:
		admob.showBanner()
		



	
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
	print($Detector.position.y-1*detectorextent.y)
	var possiblePositions= (detectorextent.x*2-20)/(PlayerTexts.instance().get_node("CollisionShape2D").shape.extents.x*2)
	var detectorLeftCorner=detectorglobalPos.x-detectorextent.x
	var possibleWidths=(detectorextent.x*2-20)/floor(possiblePositions)
	var buttonSpacing=(detectorextent.x*2-20)/floor(possiblePositions)
	var buttonWidths=(screenSize-5)/(floor(possiblePositions))

	#var averagespacething=(possibleWidths+possibleWidthsButton)/2
	for i in range(floor(possiblePositions),0,-1):
		dropPositions.append(detectorLeftCorner+10+possibleWidths*(i-1))
		create_button(2.5+(i-1)*buttonWidths,510,buttonWidths,100)
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
	$HUD.show_message("   Get Ready")
	$StartTimer.start()
	$HUD.update_score(score)
func spawn(position,letter,score,velocity):
	$TextPath/TextSpawnLocation.set_offset(position)
	#$TextPath/TextSpawnLocation.set_offset(dropPositions[0])
	var text=PlayerTexts.instance()
	add_child(text)
	if letter==letter.to_upper():
		text.get_node("AnimatedSprite2").set_animation(letter)
		text.get_node("AnimatedSprite2").set_visible(true)
		text.get_node("Label").set_visible(false)
	else:
		text.get_node("AnimatedSprite2").set_visible(false)
		text.get_node("Label").set_visible(true)
	text.get_node("Label").text=letter
	text.position = $TextPath/TextSpawnLocation.position
	
	text.linear_velocity = velocity
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
		print(totalelementsList)
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
	if wordQueue.size()<2:
		#print(words,"words")
		var selectedWords=wordSelectQueue(2-wordQueue.size(),words)
		for i in selectedWords:
			wordQueue.push_back(i)
			#buttonPotentialArrayofArray.append()
			#correctButtonArrayofArray=.append()
			words.remove(words.find(i))
			var totalArray=createPositionArray(createPercentageArray(wordNumber),i)
			#print(totalArray)
			correctPositionArrayofArray.push_back(totalArray[0])
			correctLetterArrayofArray.push_back(totalArray[1])
			buttonLayoutArrayofArray.push_back(totalArray[2])
	values_to_labels(buttonLayoutArrayofArray[0][0])
	var dropSize=0
	print(wordNumber)
	$TextTimer.stop()
	"""if wordNumber==0:
		$TextTimer.wait_time=1.3
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeds[0])
		currentSpeed=speeds[2]
	elif wordNumber==1:
		var speeding=speeds[randi()%speeds.size()]
		while (1.5+395/speeding.y<440/currentSpeed.y):
			speeding=speeds[randi()%speeds.size()]
		print(speeding.y,"speed")
		$TextTimer.wait_time=1.2
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeds[1])
	elif wordNumber==2:
		print("fuck")
		$TextTimer.wait_time=1
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeds[2])"""
	if wordNumber<9:
		if wordNumber+correctPositionArrayofArray[0][0].size()>8:
			$TextTimer.wait_time=2.5
		else:
			$TextTimer.wait_time=2.25
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,rand_range(90,100)))
	elif wordNumber<18:
		if wordNumber+correctPositionArrayofArray[0][0].size()>17:
			$TextTimer.wait_time=2.6
		else:
			$TextTimer.wait_time=1.9
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,rand_range(90,100)))
	elif wordNumber<31:
		if wordNumber+correctPositionArrayofArray[0][0].size()>27:
			$TextTimer.wait_time=2.6
		else:
			$TextTimer.wait_time==1.8
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,rand_range(100,110)))
	elif wordNumber<43:
		if wordNumber+correctPositionArrayofArray[0][0].size()>43:
			$TextTimer.wait_time=3.5
		else:
			$TextTimer.wait_time==1.6
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,rand_range(100,115)))
	elif wordNumber<71:
		$TextTimer.wait_time=rand_range(.65,1.25)
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,rand_range(100,115)))
		currentSpeed=speeds[3]
	elif wordNumber<100:
		var speeding=speeds[randi()%speeds.size()]
		while (1.2+375/speeding.y<440/currentSpeed.y):
			speeding=speeds[randi()%speeds.size()]
		print(speeding.y,"speed")
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeding)
		if wordNumber+correctPositionArrayofArray[0][0].size()>65:
			$TextTimer.wait_time=3.5
		else:
			$TextTimer.wait_time=1.3
		currentSpeed=speeding
	elif wordNumber<145:
		$TextTimer.wait_time=0.7
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,300))
		if wordNumber+correctPositionArrayofArray[0][0].size()>107:
			$TextTimer.wait_time=3
		else:
			$TextTimer.wait_time=1
		currentSpeed=Vector2(0,300)
	elif wordNumber<350:
		$TextTimer.wait_time=0.7
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,Vector2(0,300))
		if wordNumber+correctPositionArrayofArray[0][0].size()>107:
			$TextTimer.wait_time=3
		else:
			$TextTimer.wait_time=1
		currentSpeed=Vector2(0,300)
	elif wordNumber<387:
		var speeding=speeds[randi()%speeds.size()]
		while (1+370/speeding.y<440/currentSpeed.y):
			speeding=speeds[randi()%speeds.size()]
		print(speeding.y,"speed")
		for i in range(correctPositionArrayofArray[0][0].size()):
			spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeding)
		if wordNumber+correctPositionArrayofArray[0][0].size()>386:
			$TextTimer.wait_time=4
		else:
			$TextTimer.wait_time=1
		currentSpeed=speeding
	elif wordNumber<400:
		if $TextTimer.wait_time==4:
			currentSpeed=hardspeeds[1]
			for i in range(correctPositionArrayofArray[0][0].size()):
				spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,currentSpeed)
			$TextTimer.wait_time=rand_range(.5,1.2)
		else:
			var speeding=hardspeeds[randi()%speeds.size()]
			while ($TextTimer.wait_time+365/speeding.y<440/currentSpeed.y):
				speeding=hardspeeds[randi()%speeds.size()]
			for i in range(correctPositionArrayofArray[0][0].size()):
				spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeding)
			currentSpeed=speeding
		$TextTimer.wait_time=rand_range(.5,1.2)
		if wordNumber+correctPositionArrayofArray[0][0].size()>387:
			$EndTimer.start()
	else:
		$TextTimer.wait_time=1.5
		for i in range(correctPositionArrayofArray[0][0].size()):
				spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeds[0])
		
	$TextTimer.start()
	wordNumber+=correctPositionArrayofArray[0][0].size()
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
	#print(wordQueue,"first")
	currentWord.append(wordQueue[0])
	wordQueue.remove(0)
	#print(wordNumber,"second")



	
		
		#print("NEXT")
		#print(wordQueue,"wordQueu")
		#print(correctPositionArrayofArray,"correctPosition")
		#print(correctLetterArrayofArray,"correctLetter")
		#print(buttonLayoutArrayofArray,"buttonLayout")

	#print(wordQueue,"wordQueu")
	#print(correctPositionArrayofArray,"correctPosition")
	#print(correctLetterArrayofArray,"correctLetter")
	#print(buttonLayoutArrayofArray,"buttonLayout")

func _on_SpawnTimer_timeout():
	values_to_labels(buttonLayoutArrayofArray[0][0])
	for i in range(correctPositionArrayofArray[0][0].size()):
		spawn(dropPositions[correctPositionArrayofArray[0][0][i]],correctLetterArrayofArray[0][0][i],score,speeds[0])
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

func values_to_labels(var letters):
	for i in range(letters.size()):
		buttonArray[i].get_node("Label").text=letters[i]
		if letters[i]==letters[i].to_upper():
			buttonArray[i].get_node("AnimatedSprite2").set_animation(letters[i])
			buttonArray[i].get_node("AnimatedSprite2").set_visible(true)
			buttonArray[i].get_node("Label").set_visible(false)
		else:
			buttonArray[i].get_node("AnimatedSprite2").set_visible(false)
			buttonArray[i].get_node("Label").set_visible(true)
			
func wordSelectQueue(howMany,wordList):
	var selectedWords=[]
	for i in range(howMany):
		if words.size()>i:
			selectedWords.append(words[i])
	return selectedWords
	
func createPercentageArray(wordNumber):
	if wordNumber<53:
		return [100,100]
	elif wordNumber<20:
		return [70,100]
	elif wordNumber<37:
		return [39,100]
	elif wordNumber<66:
		return [30,100]
	elif wordNumber<108:
		return[99,100]
	elif wordNumber<165:
		return[50,100]
	else:
		return[30,100]

	
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
	print(selectedLetters)
	buttonChoices.append(buttonChoiceCreator(selectedLetters))

	return [selectedPositions,selectedLetters,buttonChoices]

		
func buttonChoiceCreator(selectedLetters):
	var letterChoices=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
	var buttonTemplateArray=[]
	var upper=false
	var lower=false
	for i in selectedLetters:
		if i==i.to_upper():
			upper=true
		if i==i.to_lower():
			lower=true
		#print(i,"itoll")
		buttonTemplateArray.append(i)
		letterChoices.remove(letterChoices.find(i))
	if upper and lower:
		for i in range(buttonArray.size()-selectedLetters.size()):
			var randNum=randi()%letterChoices.size()
			buttonTemplateArray.append(letterChoices[randNum])
			letterChoices.remove(randNum)
	if upper and !lower:
		for i in range(buttonArray.size()-selectedLetters.size()):
			var randNum=randi()%letterChoices.size()
			while letterChoices[randNum]!=letterChoices[randNum].to_upper():
				randNum=randi()%letterChoices.size()
			buttonTemplateArray.append(letterChoices[randNum])
			letterChoices.remove(randNum)
	if lower and !upper:
		for i in range(buttonArray.size()-selectedLetters.size()):
			var randNum=randi()%letterChoices.size()
			while letterChoices[randNum]!=letterChoices[randNum].to_lower():
				randNum=randi()%letterChoices.size()
			buttonTemplateArray.append(letterChoices[randNum])
			letterChoices.remove(randNum)
	buttonTemplateArray.shuffle()
	for i in selectedLetters:
		for j in selectedLetters:
			while buttonTemplateArray.find(i)==buttonTemplateArray.find_last(j)+1 or buttonTemplateArray.find(i)==buttonTemplateArray.find_last(j)-1:
				buttonTemplateArray.shuffle()
				print(buttonTemplateArray.find(i))
				print(buttonTemplateArray.find_last(j))
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
	gamecount+=1
	save_score()
	load_score()
	$HUD.update_highscore(highscore)
	$HUD.update_endScore(score,highscore)
	slowFreezeLetters(currentBodies)
	gameStart=false
	$Bloop.play()
	$SpawnTimer.stop()
	$TextTimer.stop()
	$HUD.show_game_over(wordNumber)
	if admob:
		admob.showInterstitial()
	

	

	



	
func resetVariables():
	randomize()
	wordNumber=0
	$TextTimer.wait_time=0
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
	level=1
	currentSpeed=speeds[0]
	words=["B","wovel","eno","C","a","b","c","d","e","A","B","C","wovel","owtR","ecinG","Eboj","f","F","g","GX","h","H","wovel","sert","I","prus","esir","V","moteg","P","Z","Y","Y","vowel","ruof","YK","KM","TJ","FO","SK","MG","RV","VR","R","R","V","V","vowel","evif","adR","gnah","fo","Pti","g","h","E","F","G","ih","oy","pu","oy","on","no","bro","pls","lol","yay","wow","AB","time","DAX","is","F","up","mi","nekorb","Xpleh",'Yslp','h','e','l','p','fY','fX','fT','fG','fL','F','F','F','ABCDEF','GHIJKL','MNOPQR','STUVWXY',"dneirf","DA",'sknaht','rof','nipleh','tAC',"B","god","C","woc","D","d","e","AKX","g","DEF","i","evol","u","bb","oy","siht","si","eht","linaf","level","evah","nuf","dna","sknaht","rof","niyalp","eraA","Buoy","Lydear","A","GKXl","ZYtm","ZMyxle","LTkol","V","C","J","KMIPR","emag","Wdne","Qevah","Odug","Byad","A","A","A","A","A","A","A","A","A","A","A","A","A","A"]
	var whereat=0
	var wutiswordnumba=[]
	for i in words:
		wutiswordnumba.append(whereat)
		wutiswordnumba.append(i)
		whereat+=len(i)
	print(wutiswordnumba)
	

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




	


	


func _on_EndTimer_timeout():
	game_over()
	

	


func _on_HUD_instruction():
	values_to_labels(["p","u","z","z","a","w"])
	pass # Replace with function body.


func _on_HUD_back():
	pass # Replace with function body.
