extends Node

const port = 4444
var network = WebSocketServer.new()
onready var root_node = get_tree().get_root()

func _ready():
	start_server()
	
func _process(_delta):
	if network.is_listening():
		network.poll()

func start_server():
	network.listen(port, PoolStringArray(), true);
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(player_id):
	print("connect")

func _peer_disconnected(player_id):
	print("disconnect")

remote func CloseConnection():
	var player_id = get_tree().get_rpc_sender_id()
	network.disconnect_peer(player_id)
