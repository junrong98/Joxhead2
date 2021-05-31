extends Node

const IP_ADDRESS = "joxhead.herokuapp.com"
const PORT = 443
var server_url = 'wss://%s:%d/ws/' % [IP_ADDRESS, PORT]
var network = WebSocketClient.new()

func _ready():
	pass

func _process(_delta):
	if network.get_connection_status() in [NetworkedMultiplayerPeer.CONNECTION_CONNECTED, NetworkedMultiplayerPeer.CONNECTION_CONNECTING]:
		network.poll()

func connect_to_server():
	network.connect_to_url(server_url, PoolStringArray(), true);
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
func _on_connection_failed():
	print("Unsuccessfully connected to server")

func _on_connection_succeeded():
	print("Successfully connected to server")
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func logout():
	Firebase.Auth.logout()
	rpc_id(1, "CloseConnection")
	get_tree().change_scene("res://Scenes/MainScenes/Login.tscn")
