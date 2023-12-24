extends Node

# Variables
var address: String = "127.0.0.1"
var port: int = 8910
var server: ENetMultiplayerPeer 
var playerData: Dictionary = {"name": "Unknown", "index": 0}
var mainScene:String = "res://Scenes/UI/network_ui.tscn"
var NextScene: String = "res://Scenes/Levels/level_1.tscn"
var connected: bool = false

# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild

# Node Function
func _process(_delta):
	if connected == true:
		if multiplayer.multiplayer_peer == null:
			GameManager.players.clear()
			GameManager.playersLoaded = 0
			connected = false

# Multiplayer Functions

# Excuted on all devices Exept current
func playerConnected(id) -> void:
	print("Player " + str(id) + " Connected")
	GameManager.playersLoaded += 1
	checkName()
	register_player.rpc_id(id, playerData)	
	player_connected.emit(id, playerData)

func playerDisconnected(id) -> void:
	# Remove the player data if disconnected
	GameManager.players.erase(id)
	GameManager.playersLoaded -= 1
	print("Player " + str(id) + " Disconnected")
	player_disconnected.emit(id)	

# Excuted Only On the Clients
func serverConnected() -> void:
	GameManager.playersLoaded += 1
	print("Server Connected!")
	checkName()
	# add player data to players array
	GameManager.players[multiplayer.get_unique_id()] = playerData
	connected = true

func serverDisconnected() -> void:
	print("Server Disconnected!")
	multiplayer.multiplayer_peer = null
	GameManager.players.clear()
	GameManager.playersLoaded = 0
	server_disconnected.emit()
	returnToMain()

func connectionFailed() -> void:
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null



# Create Server
func createServer() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
		
	var err = server.create_server(port, MAX_CONNECTIONS)


	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		return false
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()
	
	GameManager.playersLoaded += 1
	
	GameManager.players[1] = playerData
	
	
	# Broadcast room Data 
	#setUpBroadCast(playerData["name"])
	
	return true

# Create Client
func createClient() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkName()
	
	# Start Listening
	#runListener()
	#await  get_tree().create_timer(2).timeout
	
	#if address not in Global.avilableRooms:
		#print(Global.avilableRooms)
		#print("This IP Not Exist")
		#disconnectFromTheServer()
		#return false
		#
	# Create the client
	
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server
	
	return true

# RPC Functions
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	GameManager.players[newPlayerId] = newPlayerData
	
@rpc("any_peer", "call_local")
func nextScene():
	# Change Scene to Gane Scene
	TransitionLayer.visible = true
	await TransitionLayer.animate()
	
	get_tree().change_scene_to_file(NextScene)
	
	TransitionLayer.visible = true
	await TransitionLayer.animate_reverse()
	
@rpc("any_peer", "call_local")
func removePlayer(id: int):
	get_node(str(id)).queue_free()
	
# My Custem Functions
func checkName() -> void:
	playerData["name"] = "Unknown" if playerData["name"].strip_edges() == "" else playerData["name"]

func checkAddress() -> void:
	# To check if it is null
	address = "127.0.0.1" if address.strip_edges() == "" else address

func printPlayersData() -> void:
	print("\nThere Is [" + str(GameManager.playersLoaded) + "] Players\n")
	
	for player in GameManager.players.keys():
		print(GameManager.players[player])
		
	print("\n")

func multiplayerFunc() -> void:
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(serverConnected)
	multiplayer.server_disconnected.connect(serverDisconnected)
	multiplayer.connection_failed.connect(connectionFailed)

func disconnectFromTheServer() -> void:
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func returnToMain():
	get_tree().change_scene_to_file(mainScene)
