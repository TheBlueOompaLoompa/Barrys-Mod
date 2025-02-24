extends Node

signal Closed

var file_dialog: FileDialog

func toggle_mod_menu():
    $ModMenu.visible = not $ModMenu.visible
    if not $ModMenu.visible:
        emit_signal("Closed")
    return $ModMenu.visible

var props = {}

func load_mods():
    if not ResourceLoader.exists("user://mods"):
        DirAccess.make_dir_absolute("user://mods")
    
    var user_mod_folders = ResourceLoader.list_directory("user://mods")
    var builtin_mod_folders = ResourceLoader.list_directory("res://builtin_mods")
    
    var mod_folders = []
    for folder in user_mod_folders:
        mod_folders.append("user://mods/"+folder+'/')
    for folder in builtin_mod_folders:
        mod_folders.append("res://builtin_mods/"+folder+'/')
    
    for folder in mod_folders:
        var mod_config = ConfigFile.new()
        if mod_config.load(folder + "config.ini") == 0:
            load_mod(folder, mod_config)

func load_mod(path: String, config: ConfigFile):
    var name = config.get_value("info", "name")
    var t_props = config.get_value("parts", "props")
    if t_props != null:
        props[name] = []
        
        for prop in t_props:
            props[name].push_back(prop[0])
            if len(prop) > 1:
                $ModMenu.add_prop(prop[1], path + prop[0])
            else:
                $ModMenu.add_prop(prop[0], path + prop[0])
                
            %PropSpawner.add_spawnable_scene(path + prop[0])
    

#func open_mod(path):
#	var result : Node = null
#	if ResourceLoader.exists(path):
#		result = ResourceLoader.load(path).instantiate()
#		if result:
#			var mod_file = FileAccess.open(path, FileAccess.READ)
#			var file_length = mod_file.get_length()
#			var mod_bytes = mod_file.get_buffer(file_length)
#			mod_file.close()
#			local_mods.push_front(mod_bytes)
#
#			var file = FileAccess.open("user://" + result.name + ".bmod", FileAccess.WRITE)
#			file.store_buffer(mod_bytes)
#			file.close()
#
#			names.push_front(result.name)
#			add_child(result)
#	emit_signal("Closed")
#
#func spawn_mods(player_id: int):
#	rpc_id(player_id, "rpc_sync_mods", local_mods, names)
#
#@rpc("any_peer", "call_remote", "reliable")
#func rpc_sync_mods(mods, names):
#	for mod_id in len(mods):
#		var file = FileAccess.open("user://" + names[mod_id] + ".bmod", FileAccess.WRITE_READ)
#		print(file.file_exists("user://" + names[mod_id] + ".bmod"))
#
#		file.store_buffer(PackedByteArray(mods[mod_id]))
#		print(file.get_buffer(file.get_length()))
#		file.close()
#
#		var mod = ResourceLoader.load("user://" + names[mod_id] + ".bmod")
#		print(mod)

func _ready():
    load_mods()
