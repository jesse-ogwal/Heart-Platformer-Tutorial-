class_name HurtBoxComponent
extends Area2D

# Grabs the stats so we can alter the health
@export var stats_component: StatsComponent

# Grab a hurtbox so we know when we have taken a hit
@export var hurtbox_component: HurtBoxComponent

func _ready():
	# Connect the hurt signal on the hurbox component to an anonymous funciton
	# that removes health equal to the damage from the hitbox
