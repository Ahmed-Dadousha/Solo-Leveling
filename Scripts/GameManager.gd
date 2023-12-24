extends Node

# Signals
signal stats_changed
signal count_changed
# Variables
var ammo: int = 30:
	set(value):
		if value >= 0:
			ammo = value
		stats_changed.emit()
		
var health: int = 200:
	set(value):
		if value >= 0:
			health = value
		stats_changed.emit()

var players: Dictionary = {}

var playersLoaded: int = 0:
	set(value):
		playersLoaded = value
		count_changed.emit()

# Functions
func addIP(_value):
	pass

func removeIP(_value):
	pass
