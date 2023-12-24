extends Node3D

@export var playerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("player_disconnected", playerDisconnected)
	
	# Create Players 
	for player in GameManager.players.keys():
		var curretntPlayer = playerScene.instantiate() as CharacterBody3D
		curretntPlayer.name = str(player)
		add_child(curretntPlayer)	
		
		for spawn in get_tree().get_nodes_in_group("pos"):
			if spawn.name == str(GameManager.players[player]["index"]):
				curretntPlayer.global_position = spawn.global_position	

func playerDisconnected(id):
	get_node(str(id)).queue_free()
