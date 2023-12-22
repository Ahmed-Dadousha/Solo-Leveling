extends Node

signal stats_changed

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
