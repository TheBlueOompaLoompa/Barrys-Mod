extends Node

const Player = preload("res://player/Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
    if Input.is_action_just_pressed("quit"):
        get_tree().quit()

func _on_host_button_pressed():
    %MainMenu.hide()
    
    enet_peer.create_server(PORT)
    multiplayer.multiplayer_peer = enet_peer
    multiplayer.peer_connected.connect(add_player)
    multiplayer.peer_disconnected.connect(remove_player)
    
    add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
    %MainMenu.hide()
    
    if %MainMenu/Net/Options/Remote.text == "":
        %MainMenu/Net/Options/Remote.text = "127.0.0.1"
    enet_peer.create_client(%MainMenu/Net/Options/Remote.text, PORT)
    multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
    var player = Player.instantiate()
    player.name = str(peer_id)
    player.position = Vector3(0, 1, 0)
    %Mods.send_mod_list(peer_id)
    %Players.add_child(player)
    
func remove_player(peer_id):
    var player = get_node_or_null(str(peer_id))
    if player:
        player.queue_free()
