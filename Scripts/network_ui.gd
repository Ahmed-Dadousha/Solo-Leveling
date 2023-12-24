extends Control

func _ready():
	GameManager.connect("count_changed", changeCount)
	NetworkManager.connect("server_disconnected", serverDisconnected)

func serverDisconnected():

	# Hide Main menu
	$MainControlsContainer.visible = true
	# Show Lobby Menu
	$LobbyControlsContainer.visible = false

func _on_host_pressed():
	# Set Data
	NetworkManager.playerData["name"] = $MainControlsContainer/Name.text
	
	if NetworkManager.createServer():
		$MainControlsContainer.visible = false
		$LobbyControlsContainer.visible = true
		
		NetworkManager.playerData["index"] = GameManager.playersLoaded 		
		
		$LobbyControlsContainer/HBoxContainer/Start.visible = true
	else:
		NetworkManager.disconnectFromTheServer()

func _on_join_pressed():
	# Set Data
	NetworkManager.playerData["name"] = $MainControlsContainer/Name.text
	NetworkManager.address = $MainControlsContainer/IP.text

	if NetworkManager.createClient():
		$MainControlsContainer.visible = false
		$LobbyControlsContainer.visible = true
		NetworkManager.playerData["index"] = GameManager.playersLoaded 
	else:
		NetworkManager.disconnectFromTheServer()

func _on_start_pressed():
	NetworkManager.nextScene.rpc()

func _on_exit_pressed():
	NetworkManager.disconnectFromTheServer()
	
	$MainControlsContainer.visible = true
	$LobbyControlsContainer/HBoxContainer/Start.visible = false
	$LobbyControlsContainer.visible = false
	#$LanServerVrowser.visible = true
	#NetworkManger.cleanUp()
	GameManager.playersLoaded = 0
	GameManager.players.clear()

# My Custem Functions
func changeCount():
	$LobbyControlsContainer/playersCount.text = str(GameManager.playersLoaded)

