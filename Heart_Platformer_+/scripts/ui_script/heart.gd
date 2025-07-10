extends Area2D

@onready var sfx_pickup_heart = $sfx_pickupHeart

func _on_body_entered(_body):
	
	#Play the sound when the heart is collected
	sfx_pickup_heart.play()
	
	#Makes it appear that the heart dissapears as soon as collected
	hide()
	
	#wait until sound has finished playing before removing heart
	await sfx_pickup_heart.finished
	
	queue_free() 
	
	# 
	var hearts = get_tree().get_nodes_in_group("Hearts")
	if hearts.size() == 1:
		Events.level_completed.emit()
		#print("Level Completed")
	
	
