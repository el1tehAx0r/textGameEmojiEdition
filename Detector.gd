extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screen_size  # Size of the game window.
signal hit
signal exit
var bodyLetterType=null
var bodyInsideKeyType="none"
var body=null
var fullOverlappingBodies=[]



# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
	
func get_full_OverlappingBodies():
	fullOverlappingBodies.clear()
	var overlappingBodies= get_overlapping_bodies()
	#print(overlappingBodies,"HEYYYYYYYYYY")
	for body in overlappingBodies:
		#print("alksjdklfjsklBODD",body)
		var body_extents = body.get_node('CollisionShape2D').shape.extents
		var body_global_pos=body.get_node('CollisionShape2D').global_position
		var body_rect = Rect2(body_global_pos-body_extents,body_extents*2)
		var detector_extents=$CollisionShape2D.shape.extents
		var detector_global_pos=$CollisionShape2D.global_position
		var detector_rect = Rect2(detector_global_pos-detector_extents,detector_extents*2)
		var clipped_rect=detector_rect.clip(body_rect)
		#print(clipped_rect.get_area(),"CLIPED AREA")
		#print(body_rect.get_area(),"BODY RECT AREA")
		#print(clipped_rect.get_area()/body_rect.get_area())
		#print(body)
		if clipped_rect.get_area()/body_rect.get_area()>.95:
			fullOverlappingBodies.append(body)
	return fullOverlappingBodies
		
			
		
	
func _on_Detector_body_entered(body):
	#hide()  # Player disappears after being hit.
	
	emit_signal("hit",body)
	"""print(body.get_name())
	print(detector_global_pos)
	print(body_global_pos)"""
	self.bodyInsideKeyType=body.get_node('CollisionShape2D').get_owner().letterType
	#print(bodyInsideKeyType)
	self.body=body
	
	#$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false

func _on_Keyboard_lowerq():
	if(self.bodyInsideKeyType=="q"):
		print("hot")
		body.set_deferred("disabled",true)
		self.bodyInsideKeyType="none"
	else:
		print("shidding")


func _on_Detector_body_exited(body):
	if fullOverlappingBodies.has(body):
		fullOverlappingBodies.remove(fullOverlappingBodies.find(body))
	emit_signal("exit",body)
	
