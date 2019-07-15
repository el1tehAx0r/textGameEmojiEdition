extends TextureButton
signal buttonPressed


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var assignedLetter
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	

func pressing():
	emit_signal("buttonPressed",get_node("Label").text)
	
func _on_LetterButtons_pressed():
	emit_signal("buttonPressed",get_node("Label").text)
