class_name StatsComponent
extends Node

# Create the health variable and connect a setter
@export var health: int = 1:
	set(value):
		health = value
		
		# Signal out that the health has changed
		health_changed.emit()
		
		#Signal out when health is at 0
		if health == 0: no_health.emit()
		
signal health_changed()
signal no_health()
